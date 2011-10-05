From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: introduce ethernet teaming device
Date: Wed, 5 Oct 2011 10:22:50 +0200
Message-ID: <20111005082249.GA2089@minipsycho>
References: <1317737703-19457-1-git-send-email-jpirko@redhat.com>
 <20111004115344.0aca0fa1@asterix.rh>
 <20111004161241.GB2011@minipsycho>
 <20111004142713.7d8aa201@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com, jesse@nicira.com
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752658Ab1JEIXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 04:23:32 -0400
Content-Disposition: inline
In-Reply-To: <20111004142713.7d8aa201@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 04, 2011 at 07:27:13PM CEST, fbl@redhat.com wrote:
>On Tue, 4 Oct 2011 18:12:41 +0200
>Jiri Pirko <jpirko@redhat.com> wrote:
>
>> Tue, Oct 04, 2011 at 04:53:44PM CEST, fbl@redhat.com wrote:
>> 
>> <snip>
>> 
>> >> +
>> >> +struct team_mode_ops {
>> >> +	int (*init)(struct team *team);
>> >> +	void (*exit)(struct team *team);
>> >> +	rx_handler_result_t (*receive)(struct team *team,
>> >> +				       struct team_port *port,
>> >> +				       struct sk_buff *skb);
>> >
>> >nitpick:
>> >As it doesn't have any other type of results, I would suggest
>> >to rename rx_handler_result_t be to shorter, i.e. rx_result_t.
>> 
>> Well that type is defined already in include/linux/netdevice.h
>> I like the original name better because it has "handler" word in it
>> (which imo reduces possible confusion)
>
>Alright, I missed that somehow. Sorry.
>
>> >
>> >> +	bool (*transmit)(struct team *team, struct sk_buff *skb);
>> >> +	int (*port_enter)(struct team *team, struct team_port
>> >> *port);
>> >
>> >Perhaps instead of 'port_enter', use 'port_join'.
>> 
>> Might be more appropriate, not sure (my eng skills recognize these two
>> as very similar in this case)
>
>Yeah, I am just trying to find the term that is most used for this. We
>used attach/detach terms in bonding driver and they seem appropriated
>to me.

Well it's more about "entering" and "leaving" team mode.

>
>
>> >> +	int (*getter)(struct team *team, void *arg);
>> >> +	int (*setter)(struct team *team, void *arg);
>> >
>> >What means getter and setter?
>> 
>> Option getter and setter. Function used to set and get the option.
>
>sorry, I meant the last part of it - "ter". 
>getoption and setoption would make more sense to me.

I think current naming is appropriate. Similar to obj languages
terminology.

>
>
><snipped>
>> >> +	union {
>> >> +		char priv_first_byte;
>> >> +		struct ab_priv ab_priv;
>> >> +		struct rr_priv rr_priv;
>> >> +	};
>> >
>> >I think the union should be a pointer or work in the same
>> >way as netdev_priv() does.
>> 
>> The reason I did this this way is saving one pointer dereference in
>> hot paths. In netdev priv the memory for priv data is allcated along
>> with netdev struct. In this case this is not possible because mode
>> can be changed during team device lifetime (and team priv is netdev
>> priv).
>>
>
>but then any external/new team mode will require patching the
>team driver. 

Yes.

>
>> <snip>
>> 
>> >> +
>> >> +static bool rr_transmit(struct team *team, struct sk_buff *skb)
>> >> +{
>> >> +	struct team_port *port;
>> >> +	int port_index;
>> >> +
>> >> +	port_index = team->rr_priv.sent_packets++ %
>> >> team->port_count;
>> >> +	port = team_get_port_by_index_rcu(team, port_index);
>> >> +	port = __get_first_port_up(team, port);
>> >
>> >Well, __get_first_port_up() will frequently just do:
>> >
>> >	if (port->linkup)
>> >		return port;
>> >
>> >so, as it is in the hot TX path, can this be modified to be something
>> >like below to avoid one function call?
>> >
>> >        port = team_get_port_by_index_rcu(team, port_index);
>> >        if (unlikely(port->linkup))
>> >            port = __get_first_port_up(team, port);
>> 
>> Hmm, I don't think this is correct place to use "likely". Imagine you
>> have 2 ports and one of them is down all the team lifetime. You would
>> be hitting wrong branch always which will cause performance penalty.
>
>Right, my point was to avoid the extra function call.
>I agree with you that using "likely" there might not be a good idea.
>
>
>> >> +
>> >> +static const struct team_mode ab_mode = {
>> >> +	.kind		= "activebackup",
>> >> +	.ops		= &ab_mode_ops,
>> >> +};
>> >> +
>> >
>> >I would suggest to move each of the ab and rr specifics
>> >to their own module.  The idea is to have the team module
>> >as a generic module as possible and every mode on its module.
>> >Not sure what your plans are for this.
>> 
>> Well I was thinking about this for sure. One reason to have this in
>> one place is the mode_priv union you were referring to.
>> Other reason is that mode parts should be very easy and short. Also
>> their number should be limited (~4).
>> 
>
>Are you sure? :)

Well I'm not. I must admit I did have module loading implemented already
in similar way it's done in md raid code. But on second though, I
realized I do not want team to be second bonding with bazillion ugly
modes as atb and such. Therefore I decided to make that in more "static"
way to make mode code as much slim as it can be. The goal is to provide
adventerous people tools to do their ugly tricks in userspace :)

>
>
>> <snip>
>> >> +
>> >> +static struct rtnl_link_stats64 *team_get_stats(struct net_device
>> >> *dev,
>> >> +						struct
>> >> rtnl_link_stats64 *stats) +{
>> >> +	struct team *team = netdev_priv(dev);
>> >> +	struct rtnl_link_stats64 temp;
>> >> +	struct team_port *port;
>> >> +
>> >> +	memset(stats, 0, sizeof(*stats));
>> >> +
>> >> +	rcu_read_lock();
>> >> +	list_for_each_entry_rcu(port, &team->port_list, list) {
>> >> +		const struct rtnl_link_stats64 *pstats;
>> >> +
>> >> +		pstats = dev_get_stats(port->dev, &temp);
>> >> +
>> >> +		stats->rx_packets += pstats->rx_packets;
>> >> +		stats->rx_bytes += pstats->rx_bytes;
>> >> +		stats->rx_errors += pstats->rx_errors;
>> >> +		stats->rx_dropped += pstats->rx_dropped;
>> >> +
>> >> +		stats->tx_packets += pstats->tx_packets;
>> >> +		stats->tx_bytes += pstats->tx_bytes;
>> >> +		stats->tx_errors += pstats->tx_errors;
>> >> +		stats->tx_dropped += pstats->tx_dropped;
>> >> +
>> >> +		stats->multicast += pstats->multicast;
>> >> +		stats->collisions += pstats->collisions;
>> >> +
>> >> +		stats->rx_length_errors +=
>> >> pstats->rx_length_errors;
>> >> +		stats->rx_over_errors += pstats->rx_over_errors;
>> >> +		stats->rx_crc_errors += pstats->rx_crc_errors;
>> >> +		stats->rx_frame_errors += pstats->rx_frame_errors;
>> >> +		stats->rx_fifo_errors += pstats->rx_fifo_errors;
>> >> +		stats->rx_missed_errors +=
>> >> pstats->rx_missed_errors; +
>> >> +		stats->tx_aborted_errors +=
>> >> pstats->tx_aborted_errors;
>> >> +		stats->tx_carrier_errors +=
>> >> pstats->tx_carrier_errors;
>> >> +		stats->tx_fifo_errors += pstats->tx_fifo_errors;
>> >> +		stats->tx_heartbeat_errors +=
>> >> pstats->tx_heartbeat_errors;
>> >> +		stats->tx_window_errors +=
>> >> pstats->tx_window_errors;
>> >> +	}
>> >> +	rcu_read_unlock();
>> >> +
>> >> +	return stats;
>> >> +}
>> >
>> >I don't think computing stats like that is useful.  We can do
>> >that in userlevel with ethtool -S on each slave and sum all them.
>> >I think it would be better to have the errors computed based on
>> >events that happens inside of Team driver, so we can really see if
>> >something is happening inside of the Team driver or on its slaves.
>> 
>> I was thinking about this as well. I did this in same ways it's done
>> in bonding driver. One of reasons were that I can't count dropped
>> packets in team_handle_frame because I do not call netif_rx there and
>> only return RX_HANDLER_ANOTHER to "reinject" (saving one function
>> call).
>>
>
>My concern is that while debugging some issue, I cannot tell if Team
>driver dropped packets or not. Actually, there are some places in the
>patch dropping skbs without any sort of notification.  So, I suggested
>to compute the stats leaving the slave stats out of it but now I have
>realized that the admin and monitoring tools will expect to find the
>interface stats to be a sum of all its slaves.
>
>I think the solution would be having a master stats set apart to keep
>track of internal driver work and then sum the slaves stats like the
>patch does right now.  By doing so, I can grab ethtool -S of all slaves,
>sum them, and check if Team dropped or not.

I see your point. I will try to implement this (I have an idea how to maybe
resolve RX_HANDLER_ANOTHER missed result problem)

>
>
>
>> 
>> <snip>
>> 
>> >> +
>> >> +static int team_add_slave(struct net_device *dev, struct
>> >> net_device *port_dev) +{
>> >> +	struct team *team = netdev_priv(dev);
>> >> +	int err;
>> >> +
>> >> +	spin_lock(&team->lock);
>> >> +	err = team_port_add(team, port_dev);
>> >> +	spin_unlock(&team->lock);
>> >> +	return err;
>> >> +}
>> >
>> >I am not seeing any difference between slave and port, so why not
>> >stick with just one?
>> 
>> I like "port" better. It's more accurate. 
>
>Definitely.
>
>> team_add/del_slave has its
>> name only because ndo is named the same.
>
>Hm, makes sense then.
>
>Although I am still digesting the patch, nice work Jiri!
>thanks,
>fbl
>
>
>
