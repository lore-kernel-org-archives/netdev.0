From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Fri, 01 Jun 2007 16:54:56 +0200
Message-ID: <46603340.2050309@trash.net>
References: <20070530131123.10843.0@janus.isnogud.escape.de> <20070530131204.10843.5@janus.isnogud.escape.de> <465DB0B6.109@trash.net> <465F2F20.6090700@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33736 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760252AbXFAO43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 10:56:29 -0400
In-Reply-To: <465F2F20.6090700@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp wrote:
> Patrick McHardy wrote:
> 
>>Urs Thuermann wrote:
>>  
>>
>>>+	/* tx socket reference pointer: Loopback required if not NULL */
>>>+	loop = *(struct sock **)skb->cb != NULL;
>>>    
>>
>>
>>Qdiscs might change skb->cb. Maybe use skb->sk?
>>
>>  
> 
> due to current projects Urs and me had only a short time today to
> discuss the use of other skbuff-elements to implement the needed
> loopback functionality. Urs remembered that the value of skb->sk was not
> 'stable' in the whole loopback and therefore the use of skb->cb was a
> reasonable approach - and it was indeed working. Btw. triggered by your
> remark, we're looking for alternatives.


Yes, its working, but only in certain combinations and you're breaking
the rules for skb->cb, making it impossible for other layers to use.
skb->sk is "stable" at the output path, the regular loopback device
orphans the skb in hard_start_xmit. So you can at least use it there.

> Another thing is, that i would like to know, if Qdiscs would ever touch
> skb's containing CAN-frames?!?
> The MTU is 16 bytes (sizeof(struct can_frame)) and each skb contains
> exact one CAN-frame.
> What would a packet scheduler do with these skb's? IMO there is nothing
> that could be optimized and linked together like in IPv4 / IPv6 data.


Qdiscs don't care about the content. If a user attaches one to your
device, it will get used.

> Would therefore skb->cb left unchanged in my skb's? Or is there any flag
> that can be set in the skb to keep the packet scheduler's hands off?


No, and I don't think we want a flag to signal that something is
violating the rules for skb->cb, there are other users of this
besides qdiscs.
