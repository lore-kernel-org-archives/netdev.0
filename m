From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [PATCH/RFC] make unregister_netdev() delete more than 4 interfaces per second
Date: Sun, 18 Oct 2009 14:21:44 -0400
Message-ID: <20091018182144.GC23395@kvack.org>
References: <20091017221857.GG1925@kvack.org> <4ADA98EE.9040509@gmail.com> <20091018161356.GA23395@kvack.org> <4ADB55BC.5020107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:60766 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754494AbZJRSVk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Oct 2009 14:21:40 -0400
Content-Disposition: inline
In-Reply-To: <4ADB55BC.5020107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 18, 2009 at 07:51:56PM +0200, Eric Dumazet wrote:
> You forgot af_packet sendmsg() users, and heavy routers where route cache
> is stressed or disabled. I know several of them, they even added mmap TX 
> support to get better performance. They will be disapointed by your patch.

If that's a problem, the cacheline overhead is a more serious issue.  
AF_PACKET should really keep the reference on the device between syscalls.  
Do you have a benchmark in mind that would show the overhead?

> atomic_dec_and_test() is definitly more expensive, because of strong barrier
> semantics and added test after the decrement.
> refcnt being close to zero or not has not impact, even on 2 years old cpus.

At least on x86, the atomic_dec_and_test() cost is pretty much identical to 
atomic_dec().  If this really is a performance bottleneck, people should be 
complaining about the cache miss overhead and lock overhead which will dwarf 
the atomic_dec_and_test() cost vs atomic_dec().  Granted, I'm not saying 
that it isn't an issue on other architectures, but for x86 the lock prefix 
is what's expensive, not checking the flags or not after doing the operation.

If your complaint is about uninlining dev_put(), I'm indifferent to keeping 
it inline or out of line and can change the patch to suit.

> Machines hardly had to dismantle a netdevice in a normal lifetime, so maybe
> we were lazy with this insane msleep(250). This came from old linux times,
> when cpus were soooo slow and programers soooo lazy :)

It's only now that machines can actually route one or more 10Gbps links 
that it really becomes an issue.  I've been hacking around it for some 
time, but fixing it properly is starting to be a real requirement.

> The msleep(250) should be tuned first. Then if this is really necessary
> to dismantle 100.000 netdevices per second, we might have to think a bit more.
> 
> Just try msleep(1 or 2), it should work quite well.

My goal is tearing down 100,000 interfaces in a few seconds, which really is 
necessary.  Right now we're running about 40,000 interfaces on a not yet 
saturated 10Gbps link.  Going to dual 10Gbps links means pushing more than 
100,000 subscriber interfaces, and it looks like a modern dual socket system 
can handle that.

A bigger concern is rtnl_lock().  It is a huge impediment to scaling up 
interface creation/deletion on multicore systems.  That's going to be a 
lot more invasive to fix, though.

		-ben
