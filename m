From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: introduce ethernet teaming device
Date: Tue, 4 Oct 2011 18:40:47 +0200
Message-ID: <20111004164046.GC2011@minipsycho>
References: <1317737703-19457-1-git-send-email-jpirko@redhat.com>
 <1317741242.24651.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46586 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932522Ab1JDQlE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Oct 2011 12:41:04 -0400
Content-Disposition: inline
In-Reply-To: <1317741242.24651.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 04, 2011 at 05:14:02PM CEST, eric.dumazet@gmail.com wrote:

<snip>

>> +
>> +static bool rr_transmit(struct team *team, struct sk_buff *skb)
>> +{
>> +	struct team_port *port;
>> +	int port_index;
>> +
>> +	port_index = team->rr_priv.sent_packets++ % team->port_count;
>
>This is a bit expensive (change of sent_packets (cache line ping pong)
>and a modulo operation.
>
>Thanks to LLTX, we run here lockless.
>
>You could use a percpu pseudo random generator and a reciprocal divide.
>
>static u32 random_N(unsigned int N)
>{
>	return reciprocal_divide(random32(), N);
>}
>...
>	port_index = random_N(team->port_count);

Interesting, I will look at this more closely.

>> +
>> +static int team_port_list_init(struct team *team)
>> +{
>> +	int i;
>> +	struct hlist_head *hash;
>> +
>> +	hash = kmalloc(sizeof(*hash) * TEAM_PORT_HASHENTRIES, GFP_KERNEL);
>> +	if (hash != NULL) {
>> +		for (i = 0; i < TEAM_PORT_HASHENTRIES; i++)
>> +			INIT_HLIST_HEAD(&hash[i]);
>> +	} else {
>> +		return -ENOMEM;
>> +	}
>
>	if (!hash)
>		return -ENOMEM;
>
>	for (i = 0; i < TEAM_PORT_HASHENTRIES; i++)
>		INIT_HLIST_HEAD(&hash[i]);
>

Yeah, nicer :) I stole the code without much thinking.

<snip>

>> +
>> +static void team_change_rx_flags(struct net_device *dev, int change)
>> +{
>> +	struct team *team = netdev_priv(dev);
>> +	struct team_port *port;
>> +	int inc;
>> +
>> +	rcu_read_lock();
>
>It seems there is a bit of confusion.
>
>Dont we hold rtnl at this point ? (no rcu is needed)
>

I'm glad you spotted this :) I was not absolutelly sure how to do this.
I'm aware rtnl is held. Anyway I try to not to depend on it in team
code. I use team->lock spinlock for writers and in this case the code
is reader -> rcu_read gets locked.
I think this approach is clean and makes sense don't it?

<snip>

>> +static struct rtnl_link_stats64 *team_get_stats(struct net_device *dev,
>> +						struct rtnl_link_stats64 *stats)
>> +{
>> +	struct team *team = netdev_priv(dev);
>> +	struct rtnl_link_stats64 temp;
>> +	struct team_port *port;
>> +
>> +	memset(stats, 0, sizeof(*stats));
>> +
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(port, &team->port_list, list) {
>> +		const struct rtnl_link_stats64 *pstats;
>> +
>> +		pstats = dev_get_stats(port->dev, &temp);
>> +
>> +		stats->rx_packets += pstats->rx_packets;
>> +		stats->rx_bytes += pstats->rx_bytes;
>> +		stats->rx_errors += pstats->rx_errors;
>> +		stats->rx_dropped += pstats->rx_dropped;
>> +
>> +		stats->tx_packets += pstats->tx_packets;
>> +		stats->tx_bytes += pstats->tx_bytes;
>> +		stats->tx_errors += pstats->tx_errors;
>> +		stats->tx_dropped += pstats->tx_dropped;
>> +
>> +		stats->multicast += pstats->multicast;
>> +		stats->collisions += pstats->collisions;
>> +
>> +		stats->rx_length_errors += pstats->rx_length_errors;
>> +		stats->rx_over_errors += pstats->rx_over_errors;
>> +		stats->rx_crc_errors += pstats->rx_crc_errors;
>> +		stats->rx_frame_errors += pstats->rx_frame_errors;
>> +		stats->rx_fifo_errors += pstats->rx_fifo_errors;
>> +		stats->rx_missed_errors += pstats->rx_missed_errors;
>> +
>> +		stats->tx_aborted_errors += pstats->tx_aborted_errors;
>> +		stats->tx_carrier_errors += pstats->tx_carrier_errors;
>> +		stats->tx_fifo_errors += pstats->tx_fifo_errors;
>> +		stats->tx_heartbeat_errors += pstats->tx_heartbeat_errors;
>> +		stats->tx_window_errors += pstats->tx_window_errors;
>> +	}
>> +	rcu_read_unlock();
>> +
>
>One thing that bothers me is stats are wrong when we add or remove a
>slave.
>
>We really should have a per master structure to take into account
>offsets when we add/remove a slave, to keep monotonic master stats.

Please see my answer in previous reply to Flavio.

<snip>

Eric, thanks for review.

Jirka
