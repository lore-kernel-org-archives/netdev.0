From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: Fix the b0rked ingress VLAN_FLAG_REORDER_HDR
 check.
Date: Tue, 24 May 2011 00:54:14 -0400 (EDT)
Message-ID: <20110524.005414.2103486595611055177.davem@davemloft.net>
References: <20110523140048.777fb378@nehalam>
	<20110523.172047.1438754754048434316.davem@davemloft.net>
	<m1oc2tyn20.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, jpirko@redhat.com, xiaosuo@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761Ab1EXE4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 00:56:04 -0400
In-Reply-To: <m1oc2tyn20.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 23 May 2011 17:11:51 -0700

> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index 41495dc..c08dae7 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -23,6 +23,11 @@ bool vlan_do_receive(struct sk_buff **skbp)
>  		return false;
>  
>  	skb->dev = vlan_dev;
> +	if (unlikely(!(vlan_dev_info(vlan_dev)->flags & VLAN_FLAG_REORDER_HDR))) {
> +		skb = *skbp = vlan_insert_tag(skb, skb->vlan_tci);
> +		if (!skb)
> +			return false;
> +	}
>  	skb->priority = vlan_get_ingress_priority(vlan_dev, skb->vlan_tci);
>  	skb->vlan_tci = 0;
>  

Below we do a eth_hdr(skb) based check on the ethernet address in the
PACKET_OTHERHOST case.

Won't this VLAN tag insertion change skb->mac_header and thus screw up
that test?

Touching this code requires surgical precision and long audits, because
there are so many subtble dependencies all over the place like this.
