From: Andi Kleen <ak@suse.de>
Subject: Re: Zero copy transmit
Date: Tue, 29 Apr 2003 22:39:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429203945.GD349@Wotan.suse.de>
References: <3EAEC7FF.4040504@sgi.com> <20030429192041.GC17413@Wotan.suse.de> <3EAED567.2090006@sgi.com> <20030429195924.GC349@Wotan.suse.de> <3EAEDBE9.1060405@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: modica@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <3EAEDBE9.1060405@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Don't get me wrong, we would certainly drop any notions of this if we 
> found that it was slower and I will be glad to post any results. The 
> goal is to take advantage of the hardware to make things faster.

You have no hardware to make the remote TLB flushes fast ;)

I'm sure you can show it being an advantage with a single threaded process.
But when you run it on a multithreaded application just with two threads
it may look very different.

> Going back to your example above, don't solaris and hpux also do COW for 
> write and send? (I don't have their sources)  If so, why would they do 
> it if it's slower?

I don't know if they do. The only Unix I'm aware of that has zero copy
sendmsg() is NetBSD and their focus does not seem to be SMP scalability.

I observed the problem recently just with swapping a big (10GB) process
whose working set slightly exceeded the available memory.
kswapd was running on one CPU; the process on another. kswapd 
was aging the pages of the memory hog all the time, which requires an unmapping
and a remote TLB flush in the process' page tables. The result 
was that two CPUs were 100% tied up in the kernel, just spinning on the 
page_table_lock of the mm and processing TLB IPIs (spinlock was ~50%; IPI 
overhead 40% or so). I predict that your proposed TLB flushing write will
cause the same problem with lots of writes. It's more or less the same thing,
except that kswapd has a builtin rate limit and runs only on a single CPU 
and write() has not.

Also last time I checked most Linux ports still used an single global
spinlock for the TLB flush IPI. You would add a nice new hot lock
to the network path.

-Andi
