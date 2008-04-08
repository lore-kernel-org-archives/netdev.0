From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH RFC 3/5] tun: vringfd receive support.
Date: Tue, 08 Apr 2008 12:49:15 -0700
Message-ID: <47FBCC3B.7080104@qualcomm.com>
References: <200804052202.09157.rusty@rustcorp.com.au> <200804052204.28518.rusty@rustcorp.com.au> <200804052205.43824.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:49471 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772AbYDHTtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 15:49:18 -0400
In-Reply-To: <200804052205.43824.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> This patch modifies tun to allow a vringfd to specify the receive
> buffer.  Because we can't copy to userspace in bh context, we queue
> like normal then use the "pull" hook to actually do the copy.
> 
> More thought needs to be put into the possible races with ring
> registration and a simultaneous close, for example (see FIXME).
> 
> We use struct virtio_net_hdr prepended to packets in the ring to allow
> userspace to receive GSO packets in future (at the moment, the tun
> driver doesn't tell the stack it can handle them, so these cases are
> never taken).

In general the code looks good. The only thing I could not convince myself in
is whether having generic ring buffer makes sense or not.
At least the TUN driver would be more efficient if it had its own simple ring
 implementation. Less indirection, fewer callbacks, fewer if()s, etc. TUN
already has the file descriptor and having two additional fds for rx and tx
ring is a waste (think of a VPN server that has to have a bunch of TUN fds).
Also as I mentioned before Jamal and I wanted to expose some of the SKB fields
through TUN device. With the rx/tx rings the natural way of doing that would
be the ring descriptor itself. It can of course be done the same way we copy
proto info (PI) and GSO stuff before the packet but that means more
copy_to_user() calls and yet more checks.

So. What am I missing ? Why do we need generic ring for the TUN ? I looked at
the lguest code a bit and it seems that we need a bunch of network specific
code anyway. The cool thing is that you can now mmap the rings into the guest
 directly but the same thing can be done with TUN specific rings.

Max



