From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Sat, 02 Jun 2007 11:51:58 +0200
Message-ID: <46613DBE.3010602@hartkopp.net>
References: <20070530131123.10843.0@janus.isnogud.escape.de> <20070530131204.10843.5@janus.isnogud.escape.de> <465DB0B6.109@trash.net> <465F2F20.6090700@hartkopp.net> <46603340.2050309@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:42099 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752016AbXFBJwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2007 05:52:07 -0400
In-Reply-To: <46603340.2050309@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Oliver Hartkopp wrote:
>   
>> Patrick McHardy wrote:
>>     
>
> Yes, its working, but only in certain combinations and you're breaking
> the rules for skb->cb, making it impossible for other layers to use.
> skb->sk is "stable" at the output path, the regular loopback device
> orphans the skb in hard_start_xmit. So you can at least use it there.
>
>   
>> Would therefore skb->cb left unchanged in my skb's? Or is there any flag
>> that can be set in the skb to keep the packet scheduler's hands off?
>>     
>
>
> No, and I don't think we want a flag to signal that something is
> violating the rules for skb->cb, there are other users of this
> besides qdiscs.
>   

Hm - regarding Patricks and Urs' last mails i just had the idea to put
the sk-reference that's needed for this special
CAN-only-loopback-functionality into the data section of the skb, e.g.
by introducing a new struct can_skb_data:

struct can_skb_data {
    struct can_frame cf;
    sock *txsk;
};

So instead of allocating the space of struct can_frame the alloc_skb()
would allocate the size of struct can_skb_data.
The needed txsk would be stable in any case and could be used like the
currently missused skb->cb. This would also lead to a type proof(!)
implementation.

In raw_rcv() in raw.c there could be a check for the size of struct
can_skb_data first before checking the txsk - this would also guarantee
the backward compatibility for current CAN drivers that allocate only
the size of struct can_frame. For me this looks like a safe and
compatible (Kernel & CAN) solution.

Any objections/comments for this approach?

Best regards,
Oliver


