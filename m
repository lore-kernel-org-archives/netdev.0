From: Andi Kleen <ak@suse.de>
Subject: zero copy TX in benchmarks was Re: [Prism54-devel] Re: TxDescriptors -> 1024 default. Please not for every NIC!
Date: Thu, 20 May 2004 19:13:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040520171300.GA24379@wotan.suse.de>
References: <OF72607111.CD0234C8-ON85256DA1.0068861B-86256DA1.0068FF60@us.ibm.com> <Pine.LNX.4.58.0405151354220.9894@fcat> <Pine.LNX.4.58.0405190256010.30653@fcat> <20040519102700.GA16465@ee.oulu.fi> <20040520141111.GR13898@ruslug.rutgers.edu> <20040520163811.GA15832@bougret.hpl.hp.com> <20040520164516.GA9913@irc.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tomasz Torcz <zdzichu@irc.pl>
Content-Disposition: inline
In-Reply-To: <20040520164516.GA9913@irc.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 20, 2004 at 06:45:16PM +0200, Tomasz Torcz wrote:
> On Thu, May 20, 2004 at 09:38:11AM -0700, Jean Tourrilhes wrote:
> > 	I personally would stick with 100. The IrDA stack runs
> > perfectly fine with 15 buffers at 4 Mb/s. If 100 is not enough, I
> > think the problem is not the number of buffers, but somewhere else.

Not sure why you post this to this thread? It has nothing to do
with the previous message.
> 
>  I don't know how much trollish or true is that comment:
> http://bsd.slashdot.org/comments.pl?sid=106258&cid=9049422

Linux sk_buffs and BSD mbufs are not very different anymore today.
The BSD mbufs have been getting more sk_buff'ish over time,
and sk_buffs have grown some properties of mbufs. They both
have changed to optionally pass references of memory around instead of 
copying always, which is what counts here.

> but it suggest, that Linux' stack having no BSD like mbuf functionality,
> is not perfect for fast transmission. Maybe some network guru
> cna comment ?

I have not read all the details, but I suppose they used sendmsg() 
instead of sendfile() for this test. NetBSD can use zero copy TX
in this case; Linux can only with sendfile and sendmsg will copy. 
Obvious linux will be slower then because a copy can cost quite
a lot of CPU. Or rather it is not really the CPU cost that is the
problem here, but the bandwidth usage - very high speed networking i
s essentially memory bandwidth limited and copying over the CPU 
adds additional bandwidth requirements to the memory subsystem.

There was an implementation of zero copy sendmsg() for linux long ago, 
but it was removed because it was fundamentally incompatible with good 
SMP scaling, because it would require remote TLB flushes over possible
many CPUs (if you search the archives of this list you will find 
long threads about it). It would not be very hard to readd (Linux
has all the low level infrastructure needed for it), but 
it doesn't make sense. NetBSD may have the luxury to not care
about MP scaling, but Linux doesn't.

The disadvantage of sendfile is that you can only transmit files
directly; if you want to transmit data directly out of an process'
address space you have to put them into a file mmap and sendfile
from there. This may be a bit inconvenient if the basic unit
of data in your program isn't files.

There was an plan suggested to fix that (implement zero copy TX for 
POSIX AIO instead of BSD sockets), which would not have this problem.
POSIX AIO has all the infrastructure to do zero copy IO without 
problematic and slow TLB flushes. Just so far nobody implemented that.

In practice it is not a too big issue because many tuned servers 
(your typical ftpd, httpd or samba server) use sendfile already.

-Andi
