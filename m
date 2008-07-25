From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] dccp: Fix incorrect length check for ICMPv4 packets
Date: Fri, 25 Jul 2008 02:51:45 -0700 (PDT)
Message-ID: <20080725.025145.51942248.davem@davemloft.net>
References: <1216976578-17767-4-git-send-email-gerrit@erg.abdn.ac.uk>
	<1216976578-17767-5-git-send-email-gerrit@erg.abdn.ac.uk>
	<1216976578-17767-6-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org, yjwei@cn.fujitsu.com
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53892
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753002AbYGYJvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 05:51:45 -0400
In-Reply-To: <1216976578-17767-6-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 25 Jul 2008 10:02:57 +0100

> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -207,7 +207,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
>  	int err;
>  	struct net *net = dev_net(skb->dev);
>  
> -	if (skb->len < (iph->ihl << 2) + 8) {
> +	if (skb->len < (iph->ihl << 2) + __dccp_basic_hdr_len(dh)) {
>  		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
>  		return;
>  	}

You can't dereference "dh" before you know there is even
space past offset "iph->ihl << 2".  Yet that is what doing
an unconditional __dccp_basic_hdr_len() call here is going
to do.

The ipv6 patch has the same bug.

The test probably needs to be something like:

	if (skb->len < (iph->ihl << 2) + sizeof(*dh) ||
	    skb->len < (iph->ihl << 2) + __dccp_basic_hdr_len(dh))

in order to make the tests safely.
