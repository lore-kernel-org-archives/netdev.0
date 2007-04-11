From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [kvm-devel] QEMU PIC indirection patch for in-kernel APIC work
Date: Wed, 11 Apr 2007 13:53:13 +1000
Message-ID: <1176263593.26372.84.camel@localhost.localdomain>
References: <4613B438.60107@codemonkey.ws> <4613B89F.8090806@qumranet.com>
	 <4613BC6B.1070708@codemonkey.ws> <4613BF07.50606@qumranet.com>
	 <4613C993.9020405@codemonkey.ws> <4613CC01.1090500@qumranet.com>
	 <4613CDB2.4000903@codemonkey.ws> <4613D001.3040606@qumranet.com>
	 <20070404200112.GA6070@elte.hu> <4614098F.2030307@us.ibm.com>
	 <20070404212103.GA19026@elte.hu>
	 <1175728768.12230.593.camel@localhost.localdomain>
	 <4614A294.3000607@qumranet.com>
	 <1175821357.12230.642.camel@localhost.localdomain>
	 <46187F4E.1080807@qumranet.com>
	 <1176087018.11664.65.camel@localhost.localdomain>
	 <4619E6DC.3010804@qumranet.com>
	 <1176111984.11664.90.camel@localhost.localdomain>
	 <461A41CA.9080201@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, kvm-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: Avi Kivity <avi@qumranet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:40186 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030351AbXDKDxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 23:53:16 -0400
In-Reply-To: <461A41CA.9080201@qumranet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-04-09 at 16:38 +0300, Avi Kivity wrote:
> Moreover, some things just don't lend themselves to a userspace 
> abstraction.  If we want to expose tso (tcp segmentation offload), we 
> can easily do so with a kernel driver since the kernel interfaces are 
> all tso aware.  Tacking on tso awareness to tun/tap is doable, but at 
> the very least wierd.

It is kinda weird, yes, but it certainly makes sense.  All the arguments
for tso apply in triplicate to userspace packet sends...

> > We're dealing with the tun/tap device here, not a socket.
> 
> Hmm.  tun actually has aio_write implemented, but it seems synchronous.  
> So does the read path.
> 
> If these are made truly asynchronous, and the write path is made in 
> addition copyless, then we might have something workable.  I still 
> cringe at having a pagetable walk in order to deliver a 1500-byte packet.

Right, now we're talking!

However, it's not clear to me why creating an skb which references a kvm
guest's memory doesn't need a pagetable walk, but a packet in (other)
userspace memory does?

My conviction which started this discussion is that if we can offer an
efficient interface for kvm, we should be able to offer an efficient
interface for any (other) userspace.

As to async, I'm not *so* worried about that for the moment, although it
would probably be nicer to fail than to block.  Otherwise we could
simply set an skb destructor to wake us up.

> > Again, sendfile is a *much* harder problem than sending a single packet
> > once, which is the question here.
> 
> sendfile() is a *different* problem.  It doesn't need completion because 
> the data is assumed not to change under it.

Well, let's not argue over that, it's irrelevant.  Hopefully we can do
that over a beer or equivalent sometime.

I think the first step is to see how much worse a decent userspace net
driver is compared with the current in-kernel one.

Rusty.

