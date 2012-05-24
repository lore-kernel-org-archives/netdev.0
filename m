From: Arvid Brodin <Arvid.Brodin@xdin.com>
Subject: Re: [RFC] net/hsr: Add support for IEC 62439-3 High-availability
 Seamless Redundancy
Date: Thu, 24 May 2012 17:09:53 +0000
Message-ID: <4FBE6B5E.3060403@xdin.com>
References: <4F71BEAD.5080605@enea.com> <4FB14ADD.3050708@xdin.com>
 <20120514112821.526b12be@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Bruno Ferreira <balferreira@googlemail.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:50881 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933634Ab2EXRJz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 13:09:55 -0400
In-Reply-To: <20120514112821.526b12be@nehalam.linuxnetplumber.net>
Content-Language: en-US
Content-ID: <5E5FEE89B1DC644A8FBFBA1BEC68C446@redbull.xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-05-14 20:28, Stephen Hemminger wrote:
> On Mon, 14 May 2012 18:11:44 +0000
> Arvid Brodin <Arvid.Brodin@xdin.com> wrote:
> 
>> On 2012-03-27 15:20, Arvid Brodin wrote:
>>> Hi!
>>
>> *snip*
>>>
>>> 2) I have a locking problem that I haven't managed to figure out. This happens
>>>    the first time I send any packet (hsr_dev_xmit() in hsr_device.c:121, called
>>>    from hsr_device.c:147). It happens even if I set skb2 to NULL (i.e. only send
>>>    one copy):
>>>
>>> =============================================
>>> [ INFO: possible recursive locking detected ]
>>> 2.6.37 #118
>>> ---------------------------------------------
>>> swapper/0 is trying to acquire lock:
>>>  (_xmit_ETHER#2){+.-...}, at: [<901bf38e>] sch_direct_xmit+0x24/0x152
>>>
>>> but task is already holding lock:
>>>  (_xmit_ETHER#2){+.-...}, at: [<901b4d1a>] dev_queue_xmit+0x31e/0x3cc
>>>
>>> other info that might help us debug this:
>>> 4 locks held by swapper/0:
>>>  #0:  (&n->timer){+.-...}, at: [<9002bc20>] run_timer_softirq+0x98/0x184
>>>  #1:  (rcu_read_lock_bh){.+....}, at: [<901b49fc>] dev_queue_xmit+0x0/0x3cc
>>>  #2:  (_xmit_ETHER#2){+.-...}, at: [<901b4d1a>] dev_queue_xmit+0x31e/0x3cc
>>>  #3:  (rcu_read_lock_bh){.+....}, at: [<901b49fc>] dev_queue_xmit+0x0/0x3cc
>>>
>>> stack backtrace:
>>> Call trace:
>>>  [<9001c640>] dump_stack+0x18/0x20
>>>  [<90040eac>] validate_chain+0x40c/0x9ac
>>>  [<90041a58>] __lock_acquire+0x60c/0x670
>>>  [<90042f32>] lock_acquire+0x3a/0x48
>>>  [<902201a4>] _raw_spin_lock+0x20/0x44
>>>  [<901bf38e>] sch_direct_xmit+0x24/0x152
>>>  [<901b4c14>] dev_queue_xmit+0x218/0x3cc
>>>  [<9021c2e0>] slave_xmit+0x10/0x14
>>>  [<9021c540>] hsr_dev_xmit+0x88/0x8c
>>>  [<901b4942>] dev_hard_start_xmit+0x3c6/0x480
>>>  [<901b4d34>] dev_queue_xmit+0x338/0x3cc
>>>  [<901e3cd8>] arp_xmit+0x8/0xc
>>>  [<901e4436>] arp_send+0x2a/0x2c
>>>  [<901e4e74>] arp_solicit+0x15c/0x170
>>>  [<901bad0c>] neigh_timer_handler+0x1c0/0x204
>>>  [<9002bc8a>] run_timer_softirq+0x102/0x184
>>>  [<900287d8>] __do_softirq+0x64/0xe0
>>>  [<9002896a>] do_softirq+0x26/0x48
>>>  [<90028a66>] irq_exit+0x2e/0x64
>>>  [<90019f16>] do_IRQ+0x46/0x5c
>>>  [<90018428>] irq_level0+0x18/0x60
>>>  [<9021cc16>] rest_init+0x72/0x98
>>>  [<9000063c>] start_kernel+0x21c/0x258
>>>  [<00000000>] 0x0
>>>
>>>    Any idea why this happens? I need help!
>>
>>
>> I've spent a few days digging into this and the key apparently is NETIF_F_LLTX.
>>
>> The problem seems to be that HARD_TX_LOCK is called more than once, first for my virtual
>> hsr device and then, recursively, for each of the slaves in turn. (At least that's where
>> lockdep complains - at __netif_tx_lock(), that is.)
>>
>> At first I just could not understand why both the VLAN and the bonding code got away with
>> recursive calls to dev_queue_xmit() but I didn't. After some gooling (a lot, actually) I
>> found some references to the NETIF_F_LLTX flag (here's one:
>> http://lwn.net/Articles/121566/). I realised both VLAN and bonding code set this flag. And
>> sure enough, if I set it for my hsr device lockdep does not complain any more.
>>
>> But NETIF_F_LLTX is described as deprecated in both netdevice.h and in
>> Documentation/networking/netdevices.txt. Is there an alternative solution that I should
>> use instead?
>>
>> (To recap, a hsr device is a virtual device which uses two Ethernet devices as slaves.
>> This gives redundancy with instant failover, and since nodes are connected in a ring
>> topology, uses less cabling than duplication.)
>>
> 
> LLTX is deprecated (ie should not be used) for physical devices.
> 
> Also, for virtual devices, there should be non transmit queue, this
> causes mulit-queue lockless semantics to be preserved as the call passes
> through the virtual device.

(First: apologies for my late reply; your emails doesn't get through to me for some reason.)

So does this mean that it is OK to use LLTX for virtual devices? My virtual device has
zero queue length (no transmit queue), but since it calls dev_queue_xmit for its slaves, I
still get recursive locking if I don't set LLTX (just like vlan and bonding does).

-- 
Arvid Brodin | Consultant (Linux)
XDIN AB | Jan Stenbecks Torg 17 | SE-164 40 Kista | Sweden | xdin.com