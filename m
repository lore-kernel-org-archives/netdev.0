From: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Subject: Re: QEMU PIC indirection patch for in-kernel APIC work
Date: Wed, 11 Apr 2007 07:26:08 +0300
Message-ID: <461C6360.1060908@qumranet.com>
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
	<1176263593.26372.84.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-reply-to: <1176263593.26372.84.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Rusty Russell wrote:
> On Mon, 2007-04-09 at 16:38 +0300, Avi Kivity wrote:
>   
>> Moreover, some things just don't lend themselves to a userspace 
>> abstraction.  If we want to expose tso (tcp segmentation offload), we 
>> can easily do so with a kernel driver since the kernel interfaces are 
>> all tso aware.  Tacking on tso awareness to tun/tap is doable, but at 
>> the very least wierd.
>>     
>
> It is kinda weird, yes, but it certainly makes sense.  All the arguments
> for tso apply in triplicate to userspace packet sends...
>
>   

Well, write() with a large buffer is a sort of tso device.  The problem
is tso breaks through several layers (like I'm advocating in the other
thread :), pushing tcp functionality into ethernet.  Well, we've seen worse.


>>> We're dealing with the tun/tap device here, not a socket.
>>>       
>> Hmm.  tun actually has aio_write implemented, but it seems synchronous.  
>> So does the read path.
>>
>> If these are made truly asynchronous, and the write path is made in 
>> addition copyless, then we might have something workable.  I still 
>> cringe at having a pagetable walk in order to deliver a 1500-byte packet.
>>     
>
> Right, now we're talking!
>
> However, it's not clear to me why creating an skb which references a kvm
> guest's memory doesn't need a pagetable walk, but a packet in (other)
> userspace memory does?
>   

Currently guest pages are stashed in a kernel array, as well as being
mmap()ed into user space.

That's not a very strong argument though, as I'd like to be map
userspace memory into the guest, or map address_spaces to the guest, or
something, so accessing guest physical memory will become more expensive
in time.

> My conviction which started this discussion is that if we can offer an
> efficient interface for kvm, we should be able to offer an efficient
> interface for any (other) userspace.
>   

Fully agreed.  It's mostly a question of who and when.  Designing and
implementing this interface is going to be difficult, require deep
knowledge of Linux networking, and consume a lot of time.

> As to async, I'm not *so* worried about that for the moment, although it
> would probably be nicer to fail than to block.  Otherwise we could
> simply set an skb destructor to wake us up.
>   

Nope.  Being async is critical for copyless networking:

- in the transmit path, so need to stop the sender (guest) from touching
the memory until it's on the wire.  This means 100% of packets sent will
be blocked.
- in the receive path, you could separate receive notification from the
single copy that must be done (like poll() + read()), but to make use of
dma engines you need to provide the end address beforehand.

> I think the first step is to see how much worse a decent userspace net
> driver is compared with the current in-kernel one.
>   

A userspace net interface needs to provide the following:

- true async operations
- multiple packets per operation (for interrupt mitigation) (like
lio_listio)
- scatter/gather packets (iovecs)
- configurable wakeup (by packet count/timeout) for queue management
- hacks (tso)

Most of these can be provided by a combination of the pending aio work,
the pending aio/fd integration, and the not-so-pending tap aio work.  As
the first two are available as patches and the third is limited to the
tap device, it is not unreasonable to try it out.  Maybe it will turn
out not to be as difficult as I predicted just a few lines above.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
