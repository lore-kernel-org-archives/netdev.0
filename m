From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next V2] net: introduce ethernet teaming device
Date: Sat, 22 Oct 2011 17:13:48 +0200
Message-ID: <20111022151346.GA2028@minipsycho.orion>
References: <1319200747-2508-1-git-send-email-jpirko@redhat.com>
 <1319208237.32161.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4812 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751336Ab1JVPOH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Oct 2011 11:14:07 -0400
Content-Disposition: inline
In-Reply-To: <1319208237.32161.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +
>> +/************************
>> + * Rx path frame handler
>> + ************************/
>> +
>> +/* note: already called with rcu_read_lock */
>> +static rx_handler_result_t team_handle_frame(struct sk_buff **pskb)
>> +{
>> +	struct sk_buff *skb = *pskb;
>> +	struct team_port *port;
>> +	struct team *team;
>> +	rx_handler_result_t res = RX_HANDLER_ANOTHER;
>> +
>> +	skb = skb_share_check(skb, GFP_ATOMIC);
>> +	if (!skb)
>> +		return RX_HANDLER_CONSUMED;
>> +
>> +	*pskb = skb;
>> +
>> +	port = team_port_get_rcu(skb->dev);
>> +	team = port->team;
>> +
>> +	if (team->mode_ops.receive)
>
>Hmm, you need ACCESS_ONCE() here or rcu_dereference()
>
>See commit 4d97480b1806e883eb (bonding: use local function pointer of
>bond->recv_probe in bond_handle_frame) for reference

I do not think so. Because mode_ops.receive changes only from
__team_change_mode() and this can be called only in case no ports are in
team. And team_port_del() calls synchronize_rcu().

Jirka

>
>> +		res = team->mode_ops.receive(team, port, skb);
>> +
>> +	if (res == RX_HANDLER_ANOTHER) {
>> +		struct team_pcpu_stats *pcpu_stats;
>> +
>> +		pcpu_stats = this_cpu_ptr(team->pcpu_stats);
>> +		u64_stats_update_begin(&pcpu_stats->syncp);
>> +		pcpu_stats->rx_packets++;
>> +		pcpu_stats->rx_bytes += skb->len;
>> +		if (skb->pkt_type == PACKET_MULTICAST)
>> +			pcpu_stats->rx_multicast++;
>> +		u64_stats_update_end(&pcpu_stats->syncp);
>> +
>> +		skb->dev = team->dev;
>> +	} else {
>> +		this_cpu_inc(team->pcpu_stats->rx_dropped);
>> +	}
>> +
>> +	return res;
>> +}
>> +
