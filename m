From: Arvid Brodin <arvid.brodin@enea.com>
Subject: Re: bridge: HSR support - possible recursive locking?
Date: Thu, 12 Jan 2012 19:02:23 +0100
Message-ID: <4F0F202F.8060901@enea.com>
References: <4E948A04.8060400@enea.com> <20111011112821.28cd3e51@nehalam.linuxnetplumber.net> <4E94D67A.9060207@enea.com> <4EA5738B.8080008@enea.com> <4F073954.7040001@enea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: arbr <Arvid.Brodin@enea.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sestofw01.enea.se ([192.36.1.252]:25692 "HELO mx-3.enea.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751142Ab2ALSCk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jan 2012 13:02:40 -0500
In-Reply-To: <4F073954.7040001@enea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arvid Brodin wrote:
> Arvid Brodin wrote:
>>> On Tue, 11 Oct 2011 20:25:08 +0200
>>> Arvid Brodin <arvid.brodin@enea.com> wrote:
>>>
>>>> Hi,
>>>>
>>>> I want to add support for HSR ("High-availability Seamless Redundancy",
>>>> IEC-62439-3) to the bridge code. With HSR, all connected units have two network
>>>> ports and are connected in a ring. All new Ethernet packets are sent on both
>>>> ports (or passed through if the current unit is not the originating unit). The
>>>> same packet is never passed twice. Non-HSR units are not allowed in the ring.
>>>>
>>>> This gives instant, reconfiguration-free failover.
>>>>
> *snip*
>> I need to do two things:
>>
>> 1) Bind two network interfaces into one (say, eth0 & eth1 => hsr0). Frames sent on
>>    hsr0 should get an HSR tag (including the correct EtherType) and go out on both
>>    eth0 and eth1.
>>
>> 2) Ingress frames on eth0 & eth1, with EtherType 0x88fb, should be captured and 
>>    handled specially (either received on hsr0 or forwarded to the other bound 
>>    physical interface).
>>
> 
> I'm slowly getting there! :)
> 
> But what is net_device->header_ops->rebuild supposed to do?
> 

I have a "possible recursive locking" when I send cloned packets, and I can't figure out
why. Here's the stack dump and some debug printouts:


hsr_dev_xmit:286: sent on first slave

=============================================
[ INFO: possible recursive locking detected ]
2.6.37 #43
---------------------------------------------
swapper/0 is trying to acquire lock:
 (_xmit_ETHER#2){+.-...}, at: [<901b9aae>] sch_direct_xmit+0x24/0x152

but task is already holding lock:
 (_xmit_ETHER#2){+.-...}, at: [<901afc4a>] dev_queue_xmit+0x2ce/0x37c

other info that might help us debug this:
4 locks held by swapper/0:
 #0:  (&n->timer){+.-...}, at: [<9002b2b4>] run_timer_softirq+0x98/0x184
 #1:  (rcu_read_lock_bh){.+....}, at: [<901af97c>] dev_queue_xmit+0x0/0x37c
 #2:  (_xmit_ETHER#2){+.-...}, at: [<901afc4a>] dev_queue_xmit+0x2ce/0x37c
 #3:  (rcu_read_lock_bh){.+....}, at: [<901af97c>] dev_queue_xmit+0x0/0x37c

stack backtrace:
Call trace:
 [<9001c264>] dump_stack+0x18/0x20
 [<9003fdbc>] validate_chain+0x40c/0x9ac
 [<90040968>] __lock_acquire+0x60c/0x670
 [<90041cda>] lock_acquire+0x3a/0x48
 [<90216c5c>] _raw_spin_lock+0x20/0x44
 [<901b9aae>] sch_direct_xmit+0x24/0x152
 [<901afb44>] dev_queue_xmit+0x1c8/0x37c
 [<90213090>] nf_hook_xmit+0x8/0xc
 [<902130a2>] slave_xmit+0xe/0x10
 [<902131d6>] hsr_dev_xmit+0xa6/0xcc
 [<901af8c2>] dev_hard_start_xmit+0x382/0x43c
 [<901afc64>] dev_queue_xmit+0x2e8/0x37c
 [<901dc8a0>] arp_xmit+0x8/0xc
 [<901dcf86>] arp_send+0x2a/0x2c
 [<901dd978>] arp_solicit+0x110/0x130
 [<901b54a4>] neigh_timer_handler+0x1c2/0x206
 [<9002b31e>] run_timer_softirq+0x102/0x184
 [<90027eb8>] __do_softirq+0x64/0xe0
 [<9002804a>] do_softirq+0x26/0x48
 [<90028146>] irq_exit+0x2e/0x64
 [<90019bae>] do_IRQ+0x46/0x5c
 [<90018424>] irq_level0+0x18/0x60
 [<902136ae>] rest_init+0x72/0x90
 [<9000063c>] start_kernel+0x21c/0x258
 [<00000000>] 0x0

hsr_dev_xmit:289: sent on second slave

The code looks like this (from my hsr_dev_xmit() function):

	...
	skb2 = skb_clone(skb, GFP_ATOMIC);
	slave_xmit(skb, hsr_priv->slave_data[0].dev);
	printk(KERN_INFO "%s:%d: sent on first slave\n", __func__, __LINE__);
	if (skb2)
		slave_xmit(skb2, hsr_priv->slave_data[1].dev);
	printk(KERN_INFO "%s:%d: sent on second slave\n", __func__, __LINE__);
	...

and slave_xmit looks like this:

int nf_hook_xmit(struct sk_buff *skb)
{
	dev_queue_xmit(skb);
	return 0;
}

static int slave_xmit(struct sk_buff *skb, struct net_device *dev)
{
	int res;

	skb->dev = dev;
	skb->priority = 1; // FIXME: what does this mean?

	res = NF_HOOK(NFPROTO_BRIDGE, NF_BR_POST_ROUTING, skb, NULL, skb->dev, nf_hook_xmit);
//	res = dev_queue_xmit(skb);
	/* Buffer is consumed on errors too, so nothing to do here, really... */

	return res;
}

I believe I'm doing exactly the same thing as the bridging code (but of course I
can't be). So what is it that I'm doing wrong???


-- 
Arvid Brodin
Enea Services Stockholm AB
