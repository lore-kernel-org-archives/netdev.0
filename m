From: Ben Greear <greearb@candelatech.com>
Subject: =?UTF-8?Q?Re:_veth_regression_with_=22don=e2=80=99t_modify_ip=5fsum?=
 =?UTF-8?Q?med;_doing_so_treats_packets_with_bad_checksums_as_good.=22?=
Date: Thu, 24 Mar 2016 18:11:18 -0700
Message-ID: <56F49036.8050902@candelatech.com>
References: <56F463D6.7080406@candelatech.com>
 <CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com>
 <56F4810A.9060904@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Vijay P <vijayp@vijayp.ca>, Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:56499 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbcCYBLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 21:11:20 -0400
In-Reply-To: <56F4810A.9060904@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2016 05:06 PM, Ben Greear wrote:
> On 03/24/2016 04:56 PM, Cong Wang wrote:
>> On Thu, Mar 24, 2016 at 3:01 PM, Ben Greear <greearb@candelatech.com> wrote:
>>> I have an application that creates two pairs of veth devices.
>>>
>>> a <-> b       c <-> d
>>>
>>> b and c have a raw packet socket opened on them and I 'bridge' frames
>>> between b and c to provide network emulation (ie, configurable delay).
>>>
>>
>> IIUC, you create two raw sockets in order to bridge these two veth pairs?
>> That is, to receive packets on one socket and deliver packets on the other?
>
> Yes.
>
>>> I put IP 1.1.1.1/24 on a, 1.1.1.2/24 on d, and then create a UDP connection
>>> (using policy based routing to ensure frames are sent on the appropriate
>>> interfaces).
>>>
>>> This is user-space only app, and kernel in this case is completely
>>> unmodified.
>>>
>>> The commit below breaks this feature:  UDP frames are sniffed on both a and
>>> d ports
>>> (in both directions), but the UDP socket does not receive frames.
>>>
>>> Using normal ethernet ports, this network emulation feature works fine, so
>>> it is
>>> specific to VETH.
>>>
>>> A similar test with just sending UDP between a single veth pair:  e <-> f
>>> works fine.  Maybe it has something to do with raw packets?
>>>
>>
>> Yeah, I have the same feeling. Could you trace kfree_skb() to see
>> where these packets are dropped? At UDP layer?
>
> Since reverting the patch fixes this, it almost certainly has to be due to some
> checksum checking logic.  Since UDP sockets (between single veth pair)
> works, it would appear to be related to my packet bridge, so maybe
> it is specific to raw packets and/or sendmmsg api.
>
> I'll investigate it better tomorrow.

So, I found time to poke at it this evening:

Sending between two veth pairs, no packet bridge involved.

UDP:  ip_summed is 3 (CHECKSUM_PARTIAL)   # Works fine.
raw packet frames, custom ether protocol (0x1111 type):  ip_summed is 0 (NONE) # Works fine.

When I try to send UDP through the veth pairs & pkt bridge, I see this:

(pkt-bridge connects to the 'b' side of the veth pairs)

Mar 24 17:59:34 ben-ota-1 kernel: dev: rddVR0  rcv: rddVR0b  ip_summed: 3  rcv-features: 0x184074011e9
Mar 24 17:59:34 ben-ota-1 kernel: dev: rddVR1b  rcv: rddVR1  ip_summed: 0  rcv-features: 0x184075b59e9
Mar 24 17:59:34 ben-ota-1 kernel: dev: rddVR1  rcv: rddVR1b  ip_summed: 3  rcv-features: 0x184074011e9
Mar 24 17:59:34 ben-ota-1 kernel: dev: rddVR0b  rcv: rddVR0  ip_summed: 0  rcv-features: 0x184075b59e9
Mar 24 17:59:34 ben-ota-1 kernel: dev: rddVR0  rcv: rddVR0b  ip_summed: 3  rcv-features: 0x184074011e9
Mar 24 17:59:34 ben-ota-1 kernel: dev: rddVR1b  rcv: rddVR1  ip_summed: 0  rcv-features: 0x184075b59e9
Mar 24 17:59:35 ben-ota-1 kernel: dev: rddVR1  rcv: rddVR1b  ip_summed: 3  rcv-features: 0x184074011e9
Mar 24 17:59:35 ben-ota-1 kernel: dev: rddVR0b  rcv: rddVR0  ip_summed: 0  rcv-features: 0x184075b59e9
Mar 24 17:59:35 ben-ota-1 kernel: dev: rddVR0  rcv: rddVR0b  ip_summed: 3  rcv-features: 0x184074011e9
Mar 24 17:59:35 ben-ota-1 kernel: dev: rddVR1b  rcv: rddVR1  ip_summed: 0  rcv-features: 0x184075b59e9
Mar 24 17:59:35 ben-ota-1 kernel: dev: rddVR1  rcv: rddVR1b  ip_summed: 3  rcv-features: 0x184074011e9
Mar 24 17:59:35 ben-ota-1 kernel: dev: rddVR0b  rcv: rddVR0  ip_summed: 0  rcv-features: 0x184075b59e9
Mar 24 17:59:35 ben-ota-1 kernel: dev: rddVR0  rcv: rddVR0b  ip_summed: 3  rcv-features: 0x184074011e9
Mar 24 17:59:35 ben-ota-1 kernel: dev: rddVR1b  rcv: rddVR1  ip_summed: 0  rcv-features: 0x184075b59e9
Mar 24 17:59:35 ben-ota-1 kernel: dev: rddVR1  rcv: rddVR1b  ip_summed: 3  rcv-features: 0x184074011e9
Mar 24 17:59:35 ben-ota-1 kernel: dev: rddVR0b  rcv: rddVR0  ip_summed: 0  rcv-features: 0x184075b59e9
Mar 24 17:59:35 ben-ota-1 kernel: dev: rddVR0  rcv: rddVR0b  ip_summed: 3  rcv-features: 0x184074011e9


I am guessing the issue is that when my pkt bridge sends a raw frame that is actually a UDP packet,
the fact that it has ip_summed == 0 in the kernel causes the frame to be dropped.


I modified veth.c like this for this test:

static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
{
	struct veth_priv *priv = netdev_priv(dev);
	struct net_device *rcv;
	int length = skb->len;

	rcu_read_lock();
	rcv = rcu_dereference(priv->peer);
	if (unlikely(!rcv)) {
		kfree_skb(skb);
		goto drop;
	}

	pr_err("dev: %s  rcv: %s  ip_summed: %d  rcv-features: 0x%llx\n",
	       dev->name, rcv->name, skb->ip_summed, (unsigned long long)rcv->features);
#if 0
	/* don't change ip_summed == CHECKSUM_PARTIAL, as that
	 * will cause bad checksum on forwarded packets
	 */
	if (skb->ip_summed == CHECKSUM_NONE &&
	    rcv->features & NETIF_F_RXCSUM)
		skb->ip_summed = CHECKSUM_UNNECESSARY;
#endif


Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
