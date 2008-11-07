From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Fri, 7 Nov 2008 09:19:07 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com>
References: <1225450706.5301.94.camel@localhost>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CB5@NASANEXMB10.na.qualcomm.com>
	 <1225838743.6116.20.camel@fry>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F56@NASANEXMB10.na.qualcomm.com>
	 <20081106080316.GA32337@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com>
	 <20081106194032.GB31673@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
 <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:2625 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbYKGRTN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 12:19:13 -0500
In-Reply-To: <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann,

> -----Original Message-----
> From: Johann Baudy [mailto:johaahn@gmail.com]
> Sent: November-07-08 8:36 AM
> To: Lovich, Vitali
> Cc: Evgeniy Polyakov; netdev@vger.kernel.org
> Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> > Which brings up a possible bug in the proposed patch - the mapped
> atomic int field should be part of the struct containing a ring buffer
> - each ring buffer has a different number of mappings.  Otherwise,
> there will be issues trying to create both a tx & rx ring.
> 
> Could you please clarify?
> tx_pending_skb is only used for TX process.
Right, but I'm referring to the mapped variable in struct packet_sock.  It should actually be part of packet_ring_buffer - otherwise after mapping a tx-ring, mapped will be non-0, so packet_set_ring actually won't work - relevant condition is:
if (closing || atomic_read(&po->mapped) == 0)
 // create mapping

Similarly, what Evgeniy was saying is that packet_set_ring shouldn't succeed if there are pending packets.  This would also mean we have to acquire the same lock that sending does.
> 
> > Are there any consequences to bypassing qdisc (other than not
> participating in any load balancing)?  Also, since any users using the
> tx ring approach would have to write new code, it would be part of the
> documentation that the send behaviour is optimized for the least
> latency and highest throughput, thus no guarantees and assumptions can
> be made about the path the data takes through the stack.
> >
> > I agree with you about not using the cb - I was just looking at all
> possible alternatives of how this can be solved.  I'm liking my
> approach of using the frag list because it's the least intrusive
> (doesn't require modification of the skb_buff structure) and the seems
> to be the most resilient (trying to hide data in some unused skb field
> and hope no one overwrites it)
> >
> 
> My feeling is that all socket families have to use the same interface.
> We must not bypass it, otherwise we're gonna make a mess.
It's not going to be a mess - qdisc is for load balancing only as far as I'm aware.  Either qdisc will pass it on directly to dev_hard_start_xmit or it'll schedule a softirq to do this.  Either way, it's just an intermediary layer to control the flow of traffic.  Particularly since the MMAP is meant to be as high-performing as possible, I don't see why we should participate in flow control which will only increase latency & cpu usage while decreasing throughput - if we put this in the documentation that usage of the mmap approach to sending bypasses flow control, I think it's 

Am I missing the point for qdisc?
 
> I think we must not care about skb frags/device management to get
> tpacket_hdr pointer back from skb. If it is changing tomorrow, we will
> be in trouble. 
I'm a bit confused about the point you are trying to make here.  Could you please clarify?

> 
> A generic solution could be to forward a void* argument as the skb
> destructor is forwarded through layers. Kind of:
> skb->destructor(skb->desctructor_arg) when executing the callback. A
> backup copy of destructor/destruct_arg pair should be performed if
> someone needs to replace it.
> This way all entities/layers could use this field to give an argument
> to their destructor without adding a new field in sk_buff struct.
This would require a massive change in the kernel to add a feature that up till now no one has needed.  Certainly, I don't think it's wise to introduce such a wide-spread change when we could just as well accomplish it through other means.  Here are my problems with this approach:

1.  There's no need to actually pass the argument through the destructor - it could just be part of the skb (after all, since the callback only happens in one place, it's not like we could customize that argument - it would always be skb->destructor_arg).  That way whoever needs to use would use it,  but there's no need to change all existing destructor code.

2.  Backing up this field isn't really possible since where would you place that backup?

3.  You're increasing the size of the structure for everyone, even if they have disabled PACKET_MMAP (and since no-one else uses this, it doesn't really make sense).  So if it is decided that the correct approach is to store the pointer in the skb, then we should continue doing what other protocols do in the situation where they need custom data in the skb and just add our own custom pointer surrounded by an #ifdef/#endif for PACKET_MMAP. 

Thanks,
Vitali
