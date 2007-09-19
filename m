From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Wed, 19 Sep 2007 10:41:05 +0200
Message-ID: <46F0E0A1.6000108@trash.net>
References: <20070917100321.18347.0@janus.isnogud.escape.de>	<20070917100440.18347.5@janus.isnogud.escape.de>	<46EFE89D.7050006@trash.net> <ygf7imnzk60.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58007 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753842AbXISIsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 04:48:01 -0400
In-Reply-To: <ygf7imnzk60.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
> 
>>>+static int loopback; /* loopback testing. Default: 0 (Off) */
>>>+module_param(loopback, int, S_IRUGO);
>>>+MODULE_PARM_DESC(loopback, "Loop back frames (for testing). Default: 0 (Off)");
>>
>>
>>I would still prefer to have this on a per-device level configured
>>through netlink, but since we currently don't support specifying
>>flags for new devices anyways, I won't argue about it anymore
>>(OTOH, if you'd agree I could send a patch to add this feature
>>to the rtnl_link API).
> 
> 
> Hm, somehow this topic comes up again and again.  I think there is
> some misunderstanding about loopback in general and vcan, but I must
> admit that our documentation until recently didn't describe this good
> enough.  In fact, I think we also got better understanding from this
> discussion and trying to explain this.
> 
> vcan is *not* a special loopback device like lo and it is not needed
> to use PF_CAN.  Every CAN device driver should preferably loop back
> frames sent by dev->hard_start_xmit() to netif_rx().  Since this is
> unusual for netdevice drivers, the CAN core can do this itself as a
> fallback for drivers that don't loopback.


I understood that from Oliver's explanations.

> For vcan it makes no difference whether loopback is done in the vcan
> driver or in the CAN core.  No user will ever have to use this module
> parameter.  Having a driver which can show both driver behaviors is
> however useful for debugging our own code, to check whether the CAN
> core does the right thing in both cases.
> 
> vcan is not a loopback device but a null device which simply discards
> all sent frames since there is no hardware to send the frame to.  Like
> other CAN drivers it can loop back the frame to the CAN core, but this
> is not different from other CAN drivers.
> 
> It can be useful to have several vcan null devices so that different
> apps can talk to each other through different interfaces.


My opinion is simply that stuff like that shouldn't be configured
through module parameters, but as I said, I don't want to get into
this discussion again, its not a big deal if you insist on keeping
it.

> Now I think we should consider removing the loopback code from
> can_send() and demand from each CAN driver that it *has to* implement
> this itself.


Really? I don't know about any other drivers, but it seems to make
sense to me to handle this in the core instead of reimplementing
it in every driver.

> 
> 
>>>+
>>>+struct vcan_priv {
>>>+	struct net_device *dev;
>>>+	struct list_head list;
>>>+};
>>
>>
>>This is not needed anymore. The rtnl_link_unregister function calls
>>the ->dellink function for each device of this type. Check out the
>>current dummy.c driver.
> 
> 
> OK.
> 
> 
>>>+		if (atomic_read(&skb->users) != 1) {
>>>+			struct sk_buff *old_skb = skb;
>>>+
>>>+			skb = skb_clone(old_skb, GFP_ATOMIC);
>>>+			DBG(KERN_INFO "%s: %s: freeing old skbuff %p, "
>>>+			    "using new skbuff %p\n",
>>>+			    dev->name, __FUNCTION__, old_skb, skb);
>>>+			kfree_skb(old_skb);
>>
>>skb_share_check()?
> 
> 
> New to me.  I read that skb_share_check() decrements the refcount so I
> am not sure it is we want.  Will take a look tomorrow.


It kfree_skb's the old skb, just as you do above.

> 
> 
>>>+		/* receive with packet counting */
>>>+		skb->sk = srcsk;
>>
>>
>>Where is the socket used and what makes sure it still exists?
> 
> 
> This socket pointer is used when the loopback frame is processed in
> raw_rcv, only to compare it to the receiving socket to determine if
> this frame was sent by the receiving socket itself.  The srcsk is only
> compared, not dereferenced.


Thanks for the explanation, that should be fine.
