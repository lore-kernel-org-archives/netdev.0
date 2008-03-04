From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH 2/3] partial checksum and GSO support for tun/tap.
Date: Mon, 03 Mar 2008 21:08:00 -0800
Message-ID: <47CCD930.3040200@qualcomm.com>
References: <200801240107.38929.rusty@rustcorp.com.au>
	<200801240110.45178.rusty@rustcorp.com.au>
	<47ABEAF7.8020508@qualcomm.com>
	<200803041202.17202.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
        virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <200803041202.17202.rusty@rustcorp.com.au>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Rusty Russell wrote:
> On Friday 08 February 2008 16:39:03 Max Krasnyansky wrote:
>> Rusty Russell wrote:
>>> (Changes since last time: we how have explicit IFF_RECV_CSUM and
>>> IFF_RECV_GSO bits, and some renaming of virtio_net hdr)
>>>
>>> We use the virtio_net_hdr: it is an ABI already and designed to
>>> encapsulate such metadata as GSO and partial checksums.
>>>
>>> IFF_VIRTIO_HDR means you will write and read a 'struct virtio_net_hdr'
>>> at the start of each packet.  You can always write packets with
>>> partial checksum and gso to the tap device using this header.
>>>
>>> IFF_RECV_CSUM means you can handle reading packets with partial
>>> checksums.  If IFF_RECV_GSO is also set, it means you can handle
>>> reading (all types of) GSO packets.
>>>
>>> Note that there is no easy way to detect if these flags are supported:
>>> see next patch.
>> Again sorry for delay in replying. Here are my thoughts on this.
>>
>> I like the approach in general. Certainly the part that creates skbs out of
>> the user-space pages looks good. And it's fits nicely into existing TUN
>> driver model. However I actually wanted to change the model :). In
>> particular I'm talking about "syscall per packet"
>> After messing around with things like libe1000.sf.net I'd like to make
>> TUN/TAP driver look more like modern nic's to the user-space. In other
>> words I'm thinking about introducing RX and TX rings that the user-space
>> can then mmap() and write/read packets descriptors to/from. That will saves
>> the number of system calls that the user-space app needs to do. That by
>> itself saves a lot of overhead, combined with the GSO it's be lightning
>> fast.
> 
> The problem with this approach is that for what I'm doing, the packets aren't 
> nicely arranged somewhere; they're in random process memory.
That's fine. RX/TX descriptors would not contain the data itself. They'd
contain pointers to actual packets (ie just like the NIC takes physical memory
address and DMAs data in/out).
The allows for sending/receiving packets without syscalls and fits nicely with
the async schemes like GSO.

btw The code that I sent you does indeed expect packets to be in a mmap()ed
buffer but I agree that it only works for certain cases. In general it's not
flexible. I was thinking of introducing some flags in the descriptor that tell
the kernel how to handle the packet. ie Whether it needs to be just copied
into a fresh SKB or remapped with get_user_pages().

> I thought about further abusing writev and readv to do multiple packets at 
> once.  
I actually was going to abuse them from day one. At that time Alex Kuznetsov
told me that I'm crazy and I gave up on it :)

>> Also btw why call it VIRTIO ? For example I'm actually interested in
>> speeding up tunning and general network apps. We have wireless basestation
>> apps here that need to handle packets in user-space. Those kind things have
>> nothing to with virtualization.
> 
> The structure is for virtio, I'm just borrowing it for tap because it's 
> already there.  We could rename it and move it out to its own header, but if 
> so we should do that before 2.6.25 is released.
If we do the whole enchilada with the RX/TX rings then we probably do not even
need it. I'm thinking that RX/TX descriptor would include everything you need
for the GSO and stuff.
I meant do not need it for the TUN/TAP driver that is. Is it used anywhere else ?

Max
