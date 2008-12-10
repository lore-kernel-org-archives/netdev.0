From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: [PATCH][RFC 0/23] New SCSI target framework (SCST) and 4 target drivers
Date: Wed, 10 Dec 2008 21:26:31 +0300
Message-ID: <494009D7.4020602@vlnb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Jeff Garzik <jeff@garzik.org>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net,
	Vu Pham <huongvp@yahoo.com>,
	Bart Van Assche <bart.vanassche@gmail.com>,
	linux-driver@qlogic.com,
	Richard Sharpe <realrichardsharpe@gmail.com>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org
To: linux-scsi@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756010AbYLJS3T@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please review this new (although, perhaps, the oldest) SCSI target 
framework for Linux SCST and 4 target drivers for it: for Qlogic 
22xx/23xx cards (qla2x00t), for iSCSI (iscsi-scst), for Infiniband SRP 
(srpt) and for local access to SCST provided backend for purpose of 
testing and creating target drivers in user space (scst_local).

The activity on the mailing lists of the existing Linux SCSI storage 
target implementations shows that many people are using Linux to build a 
networked storage solutions. We believe that a SCSI storage target 
implementation should run inside the Linux kernel and not in user space. 
It would be a great service to the users of SCSI target software to 
include a mature and high-performance SCSI target framework in the 
mainline kernel. We are convinced that SCST is the implementation that 
is best suited for inclusion in the mainline Linux kernel. The current 
SCST implementation and selected target drivers posted here as a series 
of patches to gather feedback about how inclusion in the mainline kernel 
should proceed. Any comments and suggestions would be greatly appreciated.

The posted modules are almost ready for inclusion into the kernel, the 
main thing is left to be done is change of the interface with user space 
from procfs to sysfs. If procfs-based interface was allowed for new 
kernel modules, SCST and above target drivers could be called fully 
mainline ready. See SCST proc interface patch below for description of 
the proposed sysfs interface replacement.

The strengths of SCST are explained below by comparing SCST with STGT. 
Although we have a lot of respect for the STGT project and the people 
who have worked on it, the STGT SCSI framework doesn't satisfy its users 
in the following areas:

I. Performance.

Especially many questions have risen about performance of STGT. 
Architecture of STGT has SCSI target state machine and memory management 
in user space. This approach isn't too well suitable, if target driver 
has to be written in kernel space. In this case incoming SCSI commands 
should many times during processing pass user-kernel space boundary with 
all the related overhead, which increases the commands processing 
latency and limits the resulting performance. See, for instance, 
http://thread.gmane.org/gmane.linux.iscsi.tgt.devel/219 thread as well 
as http://lkml.org/lkml/2008/1/29/387 or 
http://lists.wpkg.org/pipermail/stgt/2007-December/001211.html.

Modern SCSI transports, e.g. Infiniband, have link latency in range 1-3 
microseconds. This is the same order of magnitude as the time needed for 
a system call on a modern system (between 1 and 4 microseconds) and not 
much more than the time needed for an empty system call (about 0.1 
microseconds). So, only ten empty syscalls or one context switch add the 
same latency as the link. Even 1Gbps Ethernet has less than 100 
microseconds of round-trip latency.

For instance, recently there was comparison using SCST SRP target driver 
and NULLIO backend between processing done in a thread and processing 
done in SIRQ context (tasklet). Load was multithreaded 4K random writes 
from a single initiator. Advantage of SIRQ processing was quite impressive:

   - 1 drive - 57% improvement (140K vs 89K IOPS)

   - 2 drives - 51% improvement (155K vs 102K IOPS)

   - 3 drives - 47% improvement (173K vs 118K IOPS)

Note, that 173K IOPS on 4K blocks means ~700MB/s of throughput and 118K 
means ~470MB/s. I.e., elimination of few context switches from commands 
processing brings 230MB/s increase!

Another source of additional unavoidable latency with the user space 
approach is copying data to and from the page cache. Modern memory has 
about 2.5GB/s copy throughput. So, with a high speed interface, like 
20Gbps Infiniband, memory copy almost doubles the overall latency. With 
the fully kernel space approach, the page cache can be used directly in 
zero-copy manner, including by user space backend handlers (see below). 
The only way how zero-copy cache can be implemented in STGT is to 
completely duplicate functionality of page-cache, including read-ahead, 
in user space.

In the past there have been objections to the above argumentation 
arguing that the latency of backing storage (e.g. rotating magnetic 
disks) is a lot more than one microsecond, especially for seek-intensive 
workloads. This argument is void however: system operators know very 
well that in order to reach an acceptable performance, a network storage 
device has to run in write-back mode and has to be equipped with 
sufficient RAM memory. Nothing prevents a target from having 8 or even 
64GB of cache, so most even random accesses could be served by it.

II. Microkernel-like architecture and overall simplicity.

The general architecture of STGT doesn't suit too well to the widely 
acknowledged Linux paradigm to avoid microkernel-like distributed 
processing. This is because STGT has two parts: an in-kernel 
"microkernel" and a user space part, which does most of the job, but not 
all. For a SCSI target, especially with hardware target card, data 
arrives in the kernel and eventually served by kernel, which does the 
actual I/O or get/put data from/to cache. Dividing the requests 
processing job between user and kernel spaces creates unnecessary 
interface boundary and effectively makes the requests processing job 
distributed with all its complexity and reliability problems. As an 
example, what will currently happen in STGT if the user space part 
suddenly dies? Will the kernel part gracefully recover from it? How much 
effort will be needed to implement that?

Yes, such architecture allows to create less kernel code, but at the 
expense of more complex user space code, more complex interface between 
kernel and user spaces and, hence, more complicated maintenance of the 
combined code. See http://lkml.org/lkml/2007/4/24/364 for the perfect 
description of why.

III. Complete pass-through mode.

When a SCSI target provides direct access to its backend SCSI devices in 
pass-through mode to comply with SAM it must intercept coming commands 
and emulate some functionality of a SCSI host. This is necessary, 
because backend devices see only a single nexus (SCSI target host), not 
each initiator as separate nexuses. See 
http://thread.gmane.org/gmane.linux.scsi/31288 for more details.

Particularly, access to the exported local backend SCSI devices locally 
from the target should be from a separate nexus as well. To achieve that 
all commands to those devices should go through the SCSI target engine 
to allow it to make all the necessary emulation. Definitely, passing all 
local commands through a user space process is absolutely unacceptable, 
because it would ruin performance of the system. But with in-kernel SCSI 
target it can be done simply and painlessly.


SCST addresses all the above issues. It has the best performance, solid 
processing architecture and allows straightforward, high performance 
implementation of the local nexus handling. But it also:

1. Has more target drivers, which cover most of SCSI transports: Fibre 
Channel, iSCSI, Infiniband SRP, parallel SCSI and SAS (most likely).

2. Has additional features. Particularly:

  - Faster backend handlers in user space. The architecture where the 
SCSI target state machine and memory management are in kernel, allows 
user space backend handlers to handle SCSI commands with 1 
syscall/command, no additional context switches (no kernel threads 
involved in processing) and no need to map/unmap user space pages. In 
future, it is possible to add an splice-like interface, which allows 
complete zero-copy with page cache. (At the moment zero-copy is only on 
the target side, i.e. between SCST and user space handlers; backend IO 
side with cache has to be done by the handlers using regular 
read()/write() calls, which copy data.)

  - Near complete 1:N pass-through mode.

  - Advanced per-initiator device visibility management (LUN masking), 
which allows different initiators to see different set of devices with 
different access permissions. For instance, initiator A could see 
exported from target T devices X and Y read-writable, and initiator B 
from the same target T could see devices Y read-only and Z read-writable.

3. Stable, mature and complete for all necessary basic functionality[*]. 
At least 3 companies already have designed and are selling products
with SCST-based engines (for instance, 
http://www.mellanox.com/content/pages.php?pg=products_dyn&product_family=35&menu_section=34; 
unfortunately, I don't have rights to name others) and, at least, 5 
companies are developing their SCST-based products in areas of HA 
solutions, VTLs, FC/iSCSI bridges, thin provisioning appliances, regular 
SANs, etc. How many are there commercially sold STGT-based products? 
Also you can compare yourself how widely and production-wise used SCST 
and STGT by simply looking at their mail lists archives: 
http://sourceforge.net/mailarchive/forum.php?forum_name=scst-devel for 
SCST and http://lists.wpkg.org/pipermail/stgt. In the SCST's archive you 
can find many questions from people actively using it in production or 
developing own SCST-based products. In the STGT's archive you can find 
that people implementing basic things, like management interface, and 
fixing basic problems, like crash when there are more than 40 LUNs per 
target (SCST successfully tested with >4000 LUNs). (STGT developers, no 
personal offense here, please.)

Neither STGT nor LIO can claim that they are complete in the basic 
functionality area. For instance, both lack support for transports, 
which don't supply expected transfer values, e.g. parallel SCSI/SAS, and 
this feature requires a major code surgery to be added. But SCST can do 
it *now*. Sure, there are still several areas for improvement (see, 
e.g., http://scst.sourceforge.net/contributing.html), but those are 
pretty advanced features, like zero-copy cache IO, persistent 
reservations, dynamic flow control, etc.


Thus, we believe, that SCST should replace STGT in the kernel. From the 
kernel point of view STGT doesn't have any advantage over SCST, because 
SCST also allows creating backend devices handlers and target mode 
drivers in user space. The only exception is in-kernel target driver for 
IBM virtual SCSI (ibmvscsi), which is done for STGT and doesn't support 
SCST. So, until it is changed to work with SCST, I guess, both SCSI 
target frameworks should coexist.

Target driver for iSER is completely user space, so it will not be 
affected. And such drivers is the place where SCST and user space part 
of STGT can (and should) supplement each other. User space part of STGT 
is a good framework/library for creation of user space target drivers 
and together with scst_local driver SCST can be a good backend for them. 
It would allow to exploit all SCST's features, including pass-through 
mode and user space backend handlers. Overhead of such architecture 
would be (per command):

1. For pass-through mode - 2 context switches (to backend thread and 
back), which can be avoided (see below).

2. For vdisk mode (FILEIO/BLOCKIO) - overhead of SG/BSG driver, SCSI 
subsystem/block layer, 2 context switches, which can be avoided (see 
below) and minus own STGT overhead, which it currently has to submit 
requests in this mode using pthreads (quite high, in fact).

3. For user space backend handlers - overhead of SG/BSG driver, SCSI 
subsystem/block layer and 2 context switches.

In all three cases data would be passed in zero-copy manner, for user 
space backend handlers - using shared memory.

In all the cases I don't count SCST overhead, because, basically, STGT 
at the moment does about the same processing. If the duplicated code 
removed, this overhead would be almost completely eliminated.

The referred in (1) and (2) context switches are necessary, because at 
the moment queuecommand() is called under host_lock and IRQs disabled. 
If we can find a way to drop that lock and reenable IRQs, those context 
switches wouldn't be needed.

Thus, since, when people decide to do something in user space, they are 
willing to accept some performance loss, overhead of SG/BSG driver and 
SCSI subsystem/block layer should be very acceptable for them.


This set of patches places SCST in drivers/scst. It isn't 
drivers/scsi/scst, as one might expect, because, in fact, SCST shares 
almost nothing with the Linux SCSI subsystem. Relation between them is 
the same as between client and server. For instance, between Apache 
(HTTP server) and Firefox (HTTP client). Or between NFS client and 
server. How much is it shared code between them? Near zero? For 
instance, in Linux 2.6.27:

$ find fs/nfs/ -name *.[ch] | xargs wc -l
...
30004 total

$ find fs/nfsd/ -name *.[ch] | xargs wc -l
...
19905 total

$ find fs/nfs_common/ -name *.[ch] | xargs wc -l
...
277 total

I.e., between NFS client and server shared only 277 lines of code among 
almost 50000 (<0.6%).

The same is true for SCSI target and initiator. The only code I see can 
be made shared between them is scsi_alloc_sgtable(), if it is made 
exported, not static as at the moment. Usage of this function would 
allow to make scst_alloc() more robust, because of usage of mempool. 
Scst_alloc() used for buffers allocation in corner cases processing. 
Everything else, including memory management, serves different needs, so 
making them shared would only make them more complicated for no gain. 
Particularly, nothing of SCSI target code can be used by SCSI initiator 
code. For example, SCSI initiator subsystem deals with memory already 
mapped from user space or allocated by VM layer. Then, after the 
corresponding command completed, that memory can't be reused by it. In 
contrast, SCSI target subsystem always manages memory itself and then, 
after the corresponding command completed, reuse of that memory is a 
good chance to gain some performance. If you object me and think that 
there is much more code, which can be shared, please be specific and 
point out to *exact* functions to share.

STGT gives another example, why coupling SCSI target and initiators 
subsystems together is a bad idea. Consider, if I make a general purpose 
kernel, for which 1% of users would run target mode. I would have to 
enable as module "SCSI target support" as well as "SCSI target support 
for transport attributes". Now 99% of users of my kernel, who don't need 
SCSI target, but need SCSI initiator drivers, would have to have 
scsi_tgt loaded, because transport attribute drivers would depend on it:

# lsmod
Module                  Size  Used by
qla2xxx               130844  0
firmware_class          8064  1 qla2xxx
scsi_transport_fc      40900  1 qla2xxx
scsi_tgt               12196  1 scsi_transport_fc
brd                     6924  0
xfs                   511280  1
dm_mirror              24368  0
dm_mod                 51148  1 dm_mirror
uhci_hcd               21400  0
sg                     31784  0
e1000                 114536  0
pcspkr                  3328  0

No target functionality is needed, but target mode subsystem is needed. 
Is it a good design? SCST doesn't have such issue.

At last, why SCST and not LIO. Most important reasons:

1. LIO is terribly overengineered, hence the code isn't clear and very 
hard (near to impossible, actually) to review and audit. Its interfaces 
a lot more complicated, than SCST's ones, with, basically, the same 
functionality.

2. LIO only supports software iSCSI target and is iSCSI centric by 
design. There is a lot of work to do to allow non-iSCSI target driver be 
ran with none iSCSI-specific code loaded.

3. LIO supports neither user space backend, nor user space target drivers.

...

Also, few years ago one of the main reasons to reject the core-iscsi 
iSCSI initiator from being included in the kernel was its support for 
MC/S. Then, to be accepted, support for MC/S was removed from 
open-iscsi. LIO iSCSI target  supports MC/S and I'm not sure that times 
have changed so much so now MC/S become an advantage from the inclusion 
in the kernel POV.

SCST, in contrast, has clear, well commented and documented (see 
http://scst.sourceforge.net/scst_pg.html) code, supports many target 
drivers, transport-neutral by design, supports user space backend/target 
drivers and has not overcomplicated by MC/S iSCSI target driver.

So, those patches add completely new subsystem to Linux. The code layout 
was made by the referred above example of NFS: client is in 
drivers/scsi, server is in drivers/scst. Possible future shared code can 
be places in drivers/scsi_common.

Currently SCST is maintained separately from the kernel, so the patches 
sometimes have code, which isn't needed, if SCST included in the kernel. 
This code will be removed in the next iteration.

Those patches were ran through checkpatch and sparse (huge thanks to 
Bart!). See 
http://sourceforge.net/mailarchive/forum.php?thread_name=e2e108260811261131k52d248bs10d52064273620e%40mail.gmail.com&forum_name=scst-devel. 
All the warnings and errors either acknowledged by the checkpatch 
authors false positives, or acknowledged problems in the latest 
development sparse (see http://lkml.org/lkml/2008/12/2/256 thread), or 
harmless and acceptable in our opinion.

The patches in this iteration are made against 2.6.27.x. In the next 
iteration they will be prepared against the necessary kernel version as 
we will be told (linux-next, I guess?)

The patch set is quite big, but self-containing and does only minimal, 
straightforward changes in other parts of the kernel. The only exception 
is put_page_callback patch, which implements in TCP notifications about 
completion of data transmit. This patch is an optimization necessary to 
implement zero-copy data transfer by iSCSI-SCST from user space backend 
handlers. But this patch isn't required. Without it data from the user 
space backend handlers will be transferred on the regular way with data 
copy to TCP send buffers, i.e. on the same way as STGT iSCSI target 
driver does. Data from in-kernel backend will still be transmitted 
zero-copy.

Here is the list of patches. They depend on each other, only 
put_page_callback.diff is independent and optional.

[PATCH][RFC 1/23]: SCST public headers
[PATCH][RFC 2/23]: SCST core
[PATCH][RFC 3/23]: SCST core docs
[PATCH][RFC 4/23]: SCST debug support
[PATCH][RFC 5/23]: SCST /proc interface
[PATCH][RFC 6/23]: SCST SGV cache
[PATCH][RFC 7/23]: SCST integration into the kernel
[PATCH][RFC 8/23]: SCST pass-through backend handlers
[PATCH][RFC 9/23]: SCST virtual disk backend handler
[PATCH][RFC 10/23]: SCST user space backend handler
[PATCH][RFC 11/23]: Makefile for SCST backend handlers
[PATCH][RFC 12/23]: Patch to add necessary support for SCST pass-through
[PATCH][RFC 13/23]: Export of alloc_io_context() function
[PATCH][RFC 14/23]: Necessary functionality in qla2xxx driver to support 
target mode
[PATCH][RFC 15/23]: Qlogic target driver
[PATCH][RFC 16/23]: Documentation for Qlogic target driver
[PATCH][RFC 17/23]: InfiniBand SRP target driver
[PATCH][RFC 18/23]: Documentation for SRP target driver
[PATCH][RFC 19/23]: scst_local target driver
[PATCH][RFC 20/23]: Documentation for scst_local driver
[PATCH][RFC 21/23]: iSCSI target driver
[PATCH][RFC 22/23]: Documentation for iSCSI-SCST
[PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user space data

This patchset contains more than 15 patches as required. Sorry for that,
but I don't see how to make it smaller, except either by making each particular
patch bigger, or excluding some target drivers.

See further comments in descriptions of each patch.

SCST home page is http://scst.sourceforge.net. You can always find the 
latest complete SCST source code with additional target drivers in its 
SVN repository by command:

$ svn co https://scst.svn.sourceforge.net/svnroot/scst/trunk

Thanks in advance,
Vlad

[*] The only area, which can *possibly* be not fully complete, is 
handling of various target hardware limitations, like transfer length 
alignment. etc. But I think it's completed, because:

1. SCST allocates page aligned data buffers, so they should satisfy the 
buffers alignment requirements.

2. It looks like if a SCSI card is modern, i.e. it is possible to
buy it from its manufacturer (hence it is worth writing a driver for 
it), and it supports target mode, then it's sufficiently advanced to 
have sane limitations, like support for full 64-bit addressing space, no 
length alignment, etc. At least, so far I've not seen exceptions.

In Linux it was always accepted that only features for real life needs 
should be implemented, but "just in case" features with no real life 
reflection should be rejected. Hence, I will start thinking about 
handling more hardware restrictions when there is such target hardware, 
not earlier. Until that I'd prefer memory management simplicity. See 
section 2 subsection 4 in SubmittingPatches: "Don't over-design".

Also I don't believe that the lack of SG chaining support in SCST is 
something to be fixed, because this is one of the areas, where 
requirements for target and initiator are completely opposite. To 
minimize latency, initiator should build commands with as much data to 
transfer as possible, but target should transfer those data with as 
small chunks as possible. This technique called pipelining and widely 
used in many areas, especially in modern CPUs. All SCSI transports I 
know, including iSCSI, Fibre Channel, SRP, parallel SCSI and SAS, 
support pipelining. So, per page limit of 512K is more than satisfying 
for an SCSI target. I can elaborate more, if someone's interested.

P.S. SCST can also be used with non-SCSI transports, like AoE. It is 
possible, since those transports' commands can be AFAIK seen as a subset 
of SCSI. So, the only thing necessary to use them with SCST is to 
convert their internal commands to the corresponding SCSI commands, then 
send to SCST, and on the way back from SCST convert SCSI sense codes to 
their internal status codes.
