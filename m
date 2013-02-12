From: Peter Lieven <pl@dlhnet.de>
Subject: Re: [Qemu-devel] tap devices not receiving packets from a bridge
Date: Tue, 12 Feb 2013 10:10:24 +0100
Message-ID: <056542E4-18E4-4C9F-AC96-60661768D6AF@dlhnet.de>
References: <50AE36E0.8000307@dlhnet.de> <20121123070211.GC22787@stefanha-thinkpad.hitronhub.home> <E85C6011-548D-4507-A776-1028DD3E3515@dlhnet.de> <20121123110146.GC7051@redhat.com> <50FE5607.9020405@dlhnet.de> <20130123100312.GA8108@redhat.com> <5119E9DC.3000505@dlhnet.de> <20130212090850.GB22029@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Stefan Hajnoczi <stefanha@gmail.com>, qemu-devel@nongnu.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ssl.dlhnet.de ([91.198.192.8]:44486 "EHLO ssl.dlh.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932131Ab3BLJK1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 04:10:27 -0500
In-Reply-To: <20130212090850.GB22029@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Am 12.02.2013 um 10:08 schrieb "Michael S. Tsirkin" <mst@redhat.com>:

> On Tue, Feb 12, 2013 at 08:06:04AM +0100, Peter Lieven wrote:
>> On 23.01.2013 11:03, Michael S. Tsirkin wrote:
>>> On Tue, Jan 22, 2013 at 10:04:07AM +0100, Peter Lieven wrote:
>>>> On 23.11.2012 12:01, Michael S. Tsirkin wrote:
>>>>> On Fri, Nov 23, 2012 at 10:41:21AM +0100, Peter Lieven wrote:
>>>>>> 
>>>>>> Am 23.11.2012 um 08:02 schrieb Stefan Hajnoczi:
>>>>>> 
>>>>>>> On Thu, Nov 22, 2012 at 03:29:52PM +0100, Peter Lieven wrote:
>>>>>>>> is anyone aware of a problem with the linux network bridge that in very rare circumstances stops
>>>>>>>> a bridge from sending pakets to a tap device?
>>>>>>>> 
>>>>>>>> My problem occurs in conjunction with vanilla qemu-kvm-1.2.0 and Ubuntu Kernel 3.2.0-34.53
>>>>>>>> which is based on Linux 3.2.33.
>>>>>>>> 
>>>>>>>> I was not yet able to reproduce the issue, it happens in really rare cases. The symptom is that
>>>>>>>> the tap does not have any TX packets. RX is working fine. I see the packets coming in at
>>>>>>>> the physical interface on the host, but they are not forwarded to the tap interface.
>>>>>>>> The bridge itself has learnt the mac address of the vServer that is connected to the tap interface.
>>>>>>>> It does not help to toggle the bridge link status,  the tap interface status or the interface in the vServer.
>>>>>>>> It seems that problem occurs if a tap interface that has previously been used, but set to nonpersistent
>>>>>>>> is set persistent again and then is by chance assigned to the same vServer (=same mac address on same
>>>>>>>> bridge) again. Unfortunately it seems not to be reproducible.
>>>>>>> 
>>>>>>> Not sure but this patch from Michael Tsirkin may help - it solves an
>>>>>>> issue with persistent tap devices:
>>>>>>> 
>>>>>>> http://patchwork.ozlabs.org/patch/198598/
>>>>>> 
>>>>>> Hi Stefan,
>>>>>> 
>>>>>> thanks for the pointer. I have seen this patch, but I have neglected it because it was dealing
>>>>>> with persistent taps. But maybe the taps in the kernel are not deleted directly.
>>>>>> Can you remember what the syptomps of the above issue have been? Sorry for
>>>>>> being vague, but I currently have no clue whats going on.
>>>>>> 
>>>>>> Can someone who has more internal knowledge of the bridging/tap code say if qemu can
>>>>>> be responsible at all if the tap device is not receiving packets from the bridge.
>>>>>> 
>>>>>> If I have the following config. Lets say packets coming in via physical interface eth1.123,
>>>>>> and a bridge called br123.I further have a virtual machine with tap0. Both eth1.123
>>>>>> and tap0 are member of br123.
>>>>>> 
>>>>>> If the issue occurs the vServer has no network connectivity inbound. If I sent a ping
>>>>>> from the vServer I see it on tap0 and leaving on eth1.123. I see further the arp reply coming
>>>>>> in via eth1.123, but the reply can't be seen on tap0.
>>>>>> 
>>>>>> Peter
>>>>> 
>>>>> If guest is not consuming packets, a TX queue in tap device
>>>>> will with time overrun (there's space for 1000 packets there).
>>>>> This is code from tun:
>>>>> 
>>>>>        if (skb_queue_len(&tfile->socket.sk->sk_receive_queue)
>>>>>> = dev->tx_queue_len / tun->numqueues){
>>>>>                if (!(tun->flags & TUN_ONE_QUEUE)) {
>>>>>                        /* Normal queueing mode. */
>>>>>                        /* Packet scheduler handles dropping of further
>>>>> * packets. */
>>>>>                        netif_stop_subqueue(dev, txq);
>>>>> 
>>>>>                        /* We won't see all dropped packets
>>>>> * individually, so overrun
>>>>>                         * error is more appropriate. */
>>>>>                        dev->stats.tx_fifo_errors++;
>>>>> 
>>>>> 
>>>>> So you can detect that this triggered by looking at fifo errors counter in device.
>>>>> 
>>>>> Once this happens TX queue is stopped, then you hit this path:
>>>>> 
>>>>>                        if (!netif_xmit_stopped(txq)) {
>>>>>                                __this_cpu_inc(xmit_recursion);
>>>>>                                rc = dev_hard_start_xmit(skb, dev, txq);
>>>>>                                __this_cpu_dec(xmit_recursion);
>>>>>                                if (dev_xmit_complete(rc)) {
>>>>>                                        HARD_TX_UNLOCK(dev, txq);
>>>>>                                        goto out;
>>>>>                                }
>>>>>                        }
>>>>> 
>>>>> so packets are not passed to device anymore.
>>>>> It will stay this way until guest consumes some packets and
>>>>> queue is restarted.
>>>> 
>>>> After some time I again have a vServer in this state. It seems not like there
>>>> are no TX errors.
>>>> 
>>>> # ifconfig tap10
>>>> tap10     Link encap:Ethernet  HWaddr 7a:59:20:6f:e7:e5
>>>>          inet6 addr: fe80::7859:20ff:fe6f:e7e5/64 Scope:Link
>>>>          UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
>>>>          RX packets:197431 errors:0 dropped:0 overruns:0 frame:0
>>>>          TX packets:264309 errors:0 dropped:0 overruns:2 carrier:0
>>>>          collisions:0 txqueuelen:500
>>>>          RX bytes:13842063 (13.8 MB)  TX bytes:35092821 (35.0 MB)
>>>> 
>>>> It seems like the bridge is not forwarding any packets to the tap device anymore altough it has learnt
>>>> the MAC-Adresses and there are also broadcast packets coming in.
>>>> 
>>>> Any more ideas where I could debug?
>>>> 
>>>> Peter
>>>> 
>>>>> 
>>>>>>> 
>>>>>>> Stefan
>>> 
>>> Hmm. So there are two overrun errors that triggered, so
>>> it's possible after the second one the queue got stuck in an xoff state.
>>> You'd have to use something like systemtap or kdb to poke at the
>>> queue state to see whether xoff flag is set and/or look
>>> at the receive queue length.
>>> 
>>> For future, we can try to set TUN_ONE_QUEUE flag on the interface,
>>> or try applying this patch
>>> 5d097109257c03a71845729f8db6b5770c4bbedc
>>> in kernel see if this helps.
>>> 
>> 
>> If have set this option for 2 weeks now and not seen this problem again.
>> How does this flag work with the recently added tap multiqueue support?
>> 
>> Peter
> 
> This will be the only option in 3.8.

Ok, but wouldn`t it be good to set it in qemu for kernels <3.8?

Peter

> 
> -- 
> MST
