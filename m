From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] ipv4: Change rt->rt_iif encoding.
Date: Tue, 24 Jul 2012 03:24:38 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207240226340.2633@ja.ssi.bg>
References: <20120723.152220.822947775372843073.davem@davemloft.net> <alpine.LFD.2.00.1207240157120.2404@ja.ssi.bg> <20120723.160541.184307938805782289.davem@davemloft.net> <20120723.161446.36265037346365173.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44017 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754843Ab2GXAYn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2012 20:24:43 -0400
In-Reply-To: <20120723.161446.36265037346365173.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 23 Jul 2012, David Miller wrote:

> Hmmm, the problem is that when we decapsulate VLAN devices, we're left
> with the parent device's index in skb->skb_iif.

	Not sure if it is a problem with VLANs, can be also
with some virtual devices but may be they use dev_forward_skb()
where skb_iif is zeroed.

> That's what all of that "orig_dev" logic in __netif_receive_skb() is
> all about.  The skb->dev is rewritten by vlan_do_receive() for that
> case.

	This is the part that I didn't know for skb_iif. I was
also worrying about ip_mc_output looping packets with skb_iif
because skb_clone copies the field but may be such loops
happen only for locally originated traffic where skb_iif starts
with 0.

	Still, the comment in ipmr_queue_xmit() and the
IPSKB_FORWARDED bit puzzles me:

         * RFC1584 teaches, that DVMRP/PIM router must deliver packets locally
         * not only before forwarding, but after forwarding on all output
         * interfaces. It is clear, if mrouter runs a multicasting

	ip_mr_forward preserves one copy to local app,
calls ipmr_queue_xmit() where packet can be looped?

	ip_mr_input():

        /* Packet is looped back after forward, it should not be
         * forwarded second time, but still can be delivered locally.
         */

	I really hope the case is for locally originated
multicast, not for packets received from network.

> I wonder if we should just get rid of all of that orig_dev logic and
> simply update skb->skb_iif every time we hit the code starting at
> label "another_round"

	I don't have opinion about this problem. I see your
new change for __netif_receive_skb, the skb_iif places are
something that I have to check for me...

Regards

--
Julian Anastasov <ja@ssi.bg>
