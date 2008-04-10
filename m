From: Max Krasnyanskiy <maxk@qualcomm.com>
Subject: Re: [PATCH RFC 3/5] tun: vringfd receive support.
Date: Thu, 10 Apr 2008 10:18:52 -0700
Message-ID: <47FE4BFC.6000705@qualcomm.com>
References: <200804052202.09157.rusty@rustcorp.com.au> <200804052205.43824.rusty@rustcorp.com.au> <47FBCC3B.7080104@qualcomm.com> <200804101544.17736.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:28579 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753404AbYDJRSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 13:18:54 -0400
In-Reply-To: <200804101544.17736.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> On Wednesday 09 April 2008 05:49:15 Max Krasnyansky wrote:
>> Rusty Russell wrote:
>>> This patch modifies tun to allow a vringfd to specify the receive
>>> buffer.  Because we can't copy to userspace in bh context, we queue
>>> like normal then use the "pull" hook to actually do the copy.
>>>
>>> More thought needs to be put into the possible races with ring
>>> registration and a simultaneous close, for example (see FIXME).
>>>
>>> We use struct virtio_net_hdr prepended to packets in the ring to allow
>>> userspace to receive GSO packets in future (at the moment, the tun
>>> driver doesn't tell the stack it can handle them, so these cases are
>>> never taken).
>> In general the code looks good. The only thing I could not convince myself
>> in is whether having generic ring buffer makes sense or not.
>> At least the TUN driver would be more efficient if it had its own simple
>> ring implementation. Less indirection, fewer callbacks, fewer if()s, etc.
>> TUN already has the file descriptor and having two additional fds for rx
>> and tx ring is a waste (think of a VPN server that has to have a bunch of
>> TUN fds). Also as I mentioned before Jamal and I wanted to expose some of
>> the SKB fields through TUN device. With the rx/tx rings the natural way of
>> doing that would be the ring descriptor itself. It can of course be done
>> the same way we copy proto info (PI) and GSO stuff before the packet but
>> that means more copy_to_user() calls and yet more checks.
>>
>> So. What am I missing ? Why do we need generic ring for the TUN ? I looked
>> at the lguest code a bit and it seems that we need a bunch of network
>> specific code anyway. The cool thing is that you can now mmap the rings
>> into the guest directly but the same thing can be done with TUN specific
>> rings.
> 
> I started modifying tun to do this directly, but it ended up with a whole heap 
> of code just for the rings, and a lot of current code (eg. read, write, poll) 
> ended up inside an 'if (tun->rings) ... else {'.  Having a natural poll() 
> interface for the rings made more sense, so being their own fds fell out 
> naturally.
Hmm, the version that I sent you awhile ago (remember I sent you an attachment 
with prototype of the new tun driver and user space code) was not that bad in 
that area. It mean it did not touch existing read()/write() path. The 
difference was that it allocated the rings and the data buffer in the kernel 
and mapped into the user-space. Which is not what you guys need but that's a 
separate thing.

The fd thing could be an issue. As I mentioned the example would be a VPN 
server (OpenVPN, etc) with a bunch of client connection (typically tun per 
connection).

> I decided to float this version because it does minimal damage to tun, and I
> know that other people have wanted rings before: I'd like to know if this is
> likely to be generic enough for them.
I see.

I'll try to spend some time on this in a near future and take a crack at the 
version with the TUN specific rings. Although I said that many times now and 
it may not happen in the near enough future :). In the mean time if your 
current version helps you guys a lot I do not mind us putting it in. We can 
always add another mode or something that uses internal rings and gradually 
obsolete old read()/write() and generic rings.

Max
