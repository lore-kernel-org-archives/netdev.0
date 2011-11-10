From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [REPOST patch net-next V6] net: introduce ethernet teaming device
Date: Thu, 10 Nov 2011 07:51:12 +0100
Message-ID: <20111110065111.GC2058@minipsycho>
References: <1320876793-1158-1-git-send-email-jpirko@redhat.com>
 <1320880355.5825.1.camel@edumazet-laptop>
 <1320882789.5825.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com, ivecera@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32648 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753888Ab1KJGvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Nov 2011 01:51:23 -0500
Content-Disposition: inline
In-Reply-To: <1320882789.5825.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 10, 2011 at 12:53:09AM CET, eric.dumazet@gmail.com wrote:
>Le jeudi 10 novembre 2011 =E0 00:12 +0100, Eric Dumazet a =E9crit :
>> Le mercredi 09 novembre 2011 =E0 23:13 +0100, Jiri Pirko a =E9crit :
>> > This patch introduces new network device called team. It supposes =
to be
>> > very fast, simple, userspace-driven alternative to existing bondin=
g
>> > driver.
>>=20
>> ...
>>=20
>> > +/*
>> > + * note: already called with rcu_read_lock
>> > + */
>> > +static netdev_tx_t team_xmit(struct sk_buff *skb, struct net_devi=
ce *dev)
>> > +{
>> > +	struct team *team =3D netdev_priv(dev);
>> > +	bool tx_success =3D false;
>> > +	unsigned int len =3D skb->len;
>> > +
>> > +	/*
>> > +	 * Ensure transmit function is called only in case there is at l=
east
>> > +	 * one port present.
>> > +	 */
>> > +	if (likely(!list_empty(&team->port_list) && team->mode_ops.trans=
mit))
>> > +		tx_success =3D team->mode_ops.transmit(team, skb);
>
>Not clear why its so complex here.
>
>When you manipulate team->port_list and make it empty, why dont you se=
t
>team->mode_ops.transmit to a helper function, freeing the skb and
>returning false.
>
>Also, instead of setting .transmit to NULL, you also could set it to
>same helper function.
>
>This way you could just do in fast path :
>
>	tx_succcess =3D team->mode_ops.transmit(team, skb);
>
>Avoiding two tests

This approach I was thinking of as well. I was not sure that it would b=
e
so nice to change this function from port_add/port_del but I'm going to
look at this.

>
>> > +	if (tx_success) {
>> > +		struct team_pcpu_stats *pcpu_stats;
>> > +
>> > +		pcpu_stats =3D this_cpu_ptr(team->pcpu_stats);
>> > +		u64_stats_update_begin(&pcpu_stats->syncp);
>> > +		pcpu_stats->tx_packets++;
>> > +		pcpu_stats->tx_bytes +=3D len;
>> > +		u64_stats_update_end(&pcpu_stats->syncp);
>> > +	} else {
>> > +		this_cpu_inc(team->pcpu_stats->tx_dropped);
>> > +	}
>> > +
>> > +	return NETDEV_TX_OK;
>> > +}
>> > +
>>=20
>
>
>
