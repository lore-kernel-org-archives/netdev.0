From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: RFC: A reduced Linux network stack for small systems
Date: Tue, 6 May 2014 10:20:26 -0700
Message-ID: <CAADnVQ+nCtshedoDWN+QgiKzsCzBcojZOzrhkfzsqyXTpi4L=w@mail.gmail.com>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<CAFLxGvww8t-PpuS3B=dFvn8k3xBydk3CgA=qoLyEbkKJZJ0xhQ@mail.gmail.com>
	<1399383246.8767.99.camel@empanada>
	<CAADnVQLYiNfXRrXc=VZkGEFDbNhF63AzPg6Gyu6P1SF=6AiO7g@mail.gmail.com>
	<1399390490.8767.122.camel@empanada>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Weinberger <richard.weinberger@gmail.com>,
	Andi Kleen <andi@firstfloor.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Tom Zanussi <tom.zanussi@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:61246 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbaEFRU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 13:20:27 -0400
In-Reply-To: <1399390490.8767.122.camel@empanada>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 6, 2014 at 8:34 AM, Tom Zanussi <tom.zanussi@linux.intel.com> wrote:
> On Tue, 2014-05-06 at 08:20 -0700, Alexei Starovoitov wrote:
>> On Tue, May 6, 2014 at 6:34 AM, Tom Zanussi <tom.zanussi@linux.intel.com> wrote:
>> > On Tue, 2014-05-06 at 09:25 +0200, Richard Weinberger wrote:
>> >> On Tue, May 6, 2014 at 12:25 AM, Andi Kleen <andi@firstfloor.org> wrote:
>> >> > There has been a lot of interest recently to run Linux on very small systems,
>> >> > like Quark systems. These may have only 2-4MB memory. They are also limited
>> >> > by flash space.
>> >> >
>> >> > One problem on these small system is the size of the network stack.
>> >> > Currently enabling IPv4 costs about 400k in text, which is prohibitive on
>> >> > a 2MB system, and very expensive with 4MB.
>> >> >
>> >> > There were proposals to instead use LWIP in user space. LWIP with
>> >> > its socket interface comes in at a bit over 100k overhead per application.
>> >> >
>> >> > I maintain that the Linux network stack is actually not that bloated,
>> >> > it just has a lot of features :-)  The goal of this project was to
>> >> > subset it in a sensible way so that the native kernel stack becomes
>> >> > competitive with LWIP.
>> >> >
>> >> > It turns out that the standard stack has a couple of features that
>> >> > are not really needed on client systems. Luckily it is also
>> >> > relatively well modularized, so it becomes possible to stub
>> >> > out these features at the edge.
>> >> >
>> >> > With removing these features we still have a powerful TCP/IP stack,
>> >> > but one that fits better into small systems.
>> >> >
>> >> > It would have been prohibitive to ifdef every optional feature.
>> >> > This patchkit relies heavily on LTO to effectively remove unused
>> >> > code. This allows to disable features only at the module boundaries,
>> >> > and rely on the compiler to drop unreferenced code and data.
>> >> >
>> >> > A few features have been also reimplemented in a simpler way.
>> >> > And I shrank a number of data structures based on CONFIG_BASE_SMALL.
>> >> >
>> >> > With these changes I can get a fully featured network stack down
>> >> > to about 170k with LTO. Without LTO there are also benefits,
>> >> > but somewhat less.
>> >> >
>> >> > There are essentially three sensible configurations:
>> >> > - Full featured like today.
>> >> > - Client only subset, but still works with standard distribution userland.
>> >> > Remove some obscure features like fastopen, make all tables smaller,
>> >> > packet socket mmap code, use a simpler routing table, remove
>> >> > high speed networking features like RPX, XPS, GRO offload.
>> >> > Disable SNMP, TCP metrics
>> >> > - Minimal subset for deeply embedded systems that can use special userland.
>> >> > Remove rtnetlink (ioctl only), remove ethtool, raw sockets.
>> >> >
>> >> > Right now I'm using own Kconfigs for every removed features. I realize
>> >> > this somewhat increases the compile test matrix. It would be possible
>> >> > to hide some of the options and select them using higher level
>> >> > configurations like the ones listed above. I haven't done this
>> >> > in this version.
>> >> >
>> >> > At this point I'm mainly interested in review and comments.
>> >> >
>> >> > Git trees:
>> >> >
>> >> > git://git.kernel.org/pub/scm/linux/kernel/git/ak/linux-misc net/debloat
>> >> > Main tree
>> >> >
>> >> > git://git.kernel.org/pub/scm/linux/kernel/git/ak/linux-misc net/debloat-3.14
>> >> > 3.14 based tree.
>> >> >
>> >> > Thanks to Tom Zanussi for contributions and testing.
>> >>
>> >> What kind of userspace do you use on such a small system?
>> >> It looks like you run kernels without procfs and netlink, so not even
>> >> ps would work. :)
>> >>
>> >
>> > The microYocto 'distro' I have running with these net-diet patches
>> > doesn't use a full procfs, but a pared-down version (CONFIG_PROCFS_MIN).
>> > Keeping ps working is of course essential, and it does that (along with
>> > a couple other things like /proc/filesystems and /proc/mounts I needed
>> > to boot):
>> >
>> > https://github.com/tzanussi/linux-yocto-micro-3.14/commit/68379432afcfa82ac695d9f02892fcf48ade5ae8
>> >
>> > Anyway all the userspace and kernel bits are available for anyone who
>> > wants to build it and try it out:
>> >
>> > https://github.com/tzanussi/meta-galileo/blob/daisy/meta-galileo/README
>> >
>> > It's very much a work-in-progress with a lot of rough edges, but it is a
>> > fully functional system on real hardware (Galileo board/Quark processor)
>> > with a usable shell (ps too!) and web server running on a kernel with
>> > native networking and ~ 750k text size.
>>
>> Intel Galileo datasheet says:
>> - 400MHz 32bit Intel
>> - 512 KBytes of on-die embedded SRAM
>> - 256 MByte DRAM, enabled by the firmware by default
>>
>> where did 2-4Mbyte restriction come from?
>>
>
> General 'order-of-magnitude' difference from the typical 'tiny distro'
> which typically targets about 16MB, so sort of arbitrary, but it's a
> nice round goal for similar systems I'm sure are coming.
>
> Actually, a better goal would be to run only on the 512k SRAM, but let's
> start with something more achievable for a first cut.
>
>> Anyway, with all these hacks you get a half functional kernel with "a
>> lot of rough edges"
>
> 'work-in-progress' see above.
>
>> that is likely working only for the given very limited set of applications.
>> Kernel function profiling can potentially achieve the same thing.
>> Profile the kernel with the set of apps and then prune all cold
>> functions out of kernel.
>
> Right, and are Profile-Guided-Optimization results now reproduceable?
> Better change it to Trace-Guided-Optimization.  But yeah, for a

not quite. I'm saying: no extra optimizations, no GCC changes.
Compile kernel as-is. Most functions have a stub for mcount() already.
Use it to track whether kernel function was called or not.
Collect this data in userspace (as perf already does), add few
more functions that had 'notrace' attribute on them, and feed this into
special linker that unpacks existing vmlinux, throws away cold functions,
relocates the rest and here you have tiny vmlinux without recompilation.

> single-purpose system where it's known exactly what will run for the
> lifetime of the system, it makes sense to get rid of all the codepaths
> that will never be hit.
>
>> config explosion and LTO is unnecessary. Just some linker hacks.
>> Obviously such kernel will also be half functional,
>> but you'll get big reduction in .text that it seems is the goal of this project.
>
>
