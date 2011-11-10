From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [REPOST patch net-next V6] net: introduce ethernet teaming device
Date: Thu, 10 Nov 2011 07:48:08 +0100
Message-ID: <20111110064807.GB2058@minipsycho>
References: <1320876793-1158-1-git-send-email-jpirko@redhat.com>
 <1320880355.5825.1.camel@edumazet-laptop>
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
Received: from mx1.redhat.com ([209.132.183.28]:50364 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752883Ab1KJGsU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Nov 2011 01:48:20 -0500
Content-Disposition: inline
In-Reply-To: <1320880355.5825.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 10, 2011 at 12:12:35AM CET, eric.dumazet@gmail.com wrote:
>Le mercredi 09 novembre 2011 =E0 23:13 +0100, Jiri Pirko a =E9crit :
>> This patch introduces new network device called team. It supposes to=
 be
>> very fast, simple, userspace-driven alternative to existing bonding
>> driver.
>
>...
>
>> +/*
>> + * note: already called with rcu_read_lock
>> + */
>> +static netdev_tx_t team_xmit(struct sk_buff *skb, struct net_device=
 *dev)
>> +{
>> +	struct team *team =3D netdev_priv(dev);
>> +	bool tx_success =3D false;
>> +	unsigned int len =3D skb->len;
>> +
>> +	/*
>> +	 * Ensure transmit function is called only in case there is at lea=
st
>> +	 * one port present.
>> +	 */
>> +	if (likely(!list_empty(&team->port_list) && team->mode_ops.transmi=
t))
>> +		tx_success =3D team->mode_ops.transmit(team, skb);
>> +	if (tx_success) {
>> +		struct team_pcpu_stats *pcpu_stats;
>> +
>> +		pcpu_stats =3D this_cpu_ptr(team->pcpu_stats);
>> +		u64_stats_update_begin(&pcpu_stats->syncp);
>> +		pcpu_stats->tx_packets++;
>> +		pcpu_stats->tx_bytes +=3D len;
>> +		u64_stats_update_end(&pcpu_stats->syncp);
>> +	} else {
>> +		this_cpu_inc(team->pcpu_stats->tx_dropped);
>> +	}
>> +
>> +	return NETDEV_TX_OK;
>> +}
>> +
>
>If skb is not transmitted, its leaked.

dev_kfree_skb is called from module transmit functions to handle free o=
f
skb when needed. But I see now that in case when
(likely(!list_empty(&team->port_list) && team->mode_ops.transmit)) =3D=3D=
 false
this would leak. I'm going to rewrite this bit somehow.
>
>
>
