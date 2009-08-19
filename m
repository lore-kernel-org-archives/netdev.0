From: Avi Kivity <avi@redhat.com>
Subject: configfs/sysfs
Date: Wed, 19 Aug 2009 23:12:43 +0300
Message-ID: <4A8C5CBB.10605@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net>	 <20090814154308.26116.46980.stgit@dev.haskins.net>	 <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com>	 <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com>	 <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com>	 <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com>	 <4A8AD678.7050609@redhat.com> <4A8B9B79.9050004@gmail.com>	 <4A8BA5AE.3030308@redhat.com> <1250706227.27590.156.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Ira W. Snyder" <iws@ovro.caltech.edu>,
	Joel Becker <joel.becker@oracle.com>
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1250706227.27590.156.camel@haakon2.linux-iscsi.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/19/2009 09:23 PM, Nicholas A. Bellinger wrote:
> Anyways, I was wondering if you might be interesting in sharing your
> concerns wrt to configfs (conigfs maintainer CC'ed), at some point..?
>    

My concerns aren't specifically with configfs, but with all the text 
based pseudo filesystems that the kernel exposes.

My high level concern is that we're optimizing for the active sysadmin, 
not for libraries and management programs.  configfs and sysfs are easy 
to use from the shell, discoverable, and easily scripted.  But they 
discourage documentation, the text format is ambiguous, and they require 
a lot of boilerplate to use in code.

You could argue that you can wrap *fs in a library that hides the 
details of accessing it, but that's the wrong approach IMO.  We should 
make the information easy to use and manipulate for programs; one of 
these programs can be a fuse filesystem for the active sysadmin if 
someone thinks it's important.

Now for the low level concerns:

- efficiency

Each attribute access requires an open/read/close triplet and 
binary->ascii->binary conversions.  In contrast an ordinary 
syscall/ioctl interface can fetch all attributes of an object, or even 
all attributes of all objects, in one call.

- atomicity

One attribute per file means that, lacking userspace-visible 
transactions, there is no way to change several attributes at once.  
When you read attributes, there is no way to read several attributes 
atomically so you can be sure their values correlate.  Another example 
of a problem is when an object disappears while reading its attributes.  
Sure, openat() can mitigate this, but it's better to avoid introducing 
problem than having a fix.

- ambiguity

What format is the attribute?  does it accept lowercase or uppercase hex 
digits?  is there a newline at the end?  how many digits can it take 
before the attribute overflows?  All of this has to be documented and 
checked by the OS, otherwise we risk regressions later.  In contrast, 
__u64 says everything in a binary interface.

- lifetime and access control

If a process brings an object into being (using mkdir) and then dies, 
the object remains behind.  The syscall/ioctl approach ties the object 
into an fd, which will be destroyed when the process dies, and which can 
be passed around using SCM_RIGHTS, allowing a server process to create 
and configure an object before passing it to an unprivileged program

- notifications

It's hard to notify users about changes in attributes.  Sure, you can 
use inotify, but that limits you to watching subtrees.  Once you do get 
the notification, you run into the atomicity problem.  When do you know 
all attributes are valid?  This can be solved using sequence counters, 
but that's just gratuitous complexity.  Netlink type interfaces are much 
more robust and flexible.

- readdir

You can either list everything, or nothing.  Sure, you can have trees to 
ease searching, even multiple views of the same data, but it's painful.

You may argue, correctly, that syscalls and ioctls are not as flexible.  
But this is because no one has invested the effort in making them so.  A 
struct passed as an argument to a syscall is not extensible.  But if you 
pass the size of the structure, and also a bitmap of which attributes 
are present, you gain extensibility and retain the atomicity property of 
a syscall interface.  I don't think a lot of effort is needed to make an 
extensible syscall interface just as usable and a lot more efficient 
than configfs/sysfs.  It should also be simple to bolt a fuse interface 
on top to expose it to us commandline types.

> As you may recall, I have been using configfs extensively for the 3.x
> generic target core infrastructure and iSCSI fabric modules living in
> lio-core-2.6.git/drivers/target/target_core_configfs.c and
> lio-core-2.6.git/drivers/lio-core/iscsi_target_config.c, and have found
> it to be extraordinarly useful for the purposes of a implementing a
> complex kernel level target mode stack that is expected to manage
> massive amounts of metadata, allow for real-time configuration, share
> data structures (eg: SCSI Target Ports) between other kernel fabric
> modules and manage the entire set of fabrics using only intrepetered
> userspace code.
>
> Using the 10000 1:1 mapped TCM Virtual HBA+FILEIO LUNs<->  iSCSI Target
> Endpoints inside of a KVM Guest (from the results in May posted with
> IOMMU aware 10 Gb on modern Nahelem hardware, see
> http://linux-iscsi.org/index.php/KVM-LIO-Target), we have been able to
> dump the entire running target fabric configfs hierarchy to a single
> struct file on a KVM Guest root device using python code on the order of
> ~30 seconds for those 10000 active iSCSI endpoints.  In configfs terms,
> this means:
>
> *) 7 configfs groups (directories), ~50 configfs attributes (files) per
> Virtual HBA+FILEIO LUN
> *) 15 configfs groups (directories), ~60 configfs attributes (files per
> iSCSI fabric Endpoint
>
> Which comes out to a total of ~220000 groups and ~1100000 attributes
> active configfs objects living in the configfs_dir_cache that are being
> dumped inside of the single KVM guest instances, including symlinks
> between the fabric modules to establish the SCSI ports containing
> complete set of SPC-4 and RFC-3720 features, et al.
>    

You achieved 3 million syscalls/sec from Python code?  That's very 
impressive.

Note with syscalls you could have done it with 10K syscalls (Python 
supports packing and unpacking structs quite well, and also directly 
calling C code IIRC).

> Also on the kernel<->  user API interaction compatibility side, I have
> found the 3.x configfs enabled code adventagous over the LIO 2.9 code
> (that used an ioctl for everything) because it allows us to do backwards
> compat for future versions without using any userspace C code, which in
> IMHO makes maintaining userspace packages for complex kernel stacks with
> massive amounts of metadata + real-time configuration considerations.
> No longer having ioctl compatibility issues between LIO versions as the
> structures passed via ioctl change, and being able to do backwards
> compat with small amounts of interpreted code against configfs layout
> changes makes maintaining the kernel<->  user API really have made this
> that much easier for me.
>    

configfs is more maintainable that a bunch of hand-maintained ioctls.  
But if we put some effort into an extendable syscall infrastructure 
(perhaps to the point of using an IDL) I'm sure we can improve on that 
without the problems pseudo filesystems introduce.

> Anyways, I though these might be useful to the discussion as it releates
> to potental uses of configfs on the KVM Host or other projects that
> really make sense, and/or to improve the upstream implementation so that
> other users (like myself) can benefit from improvements to configfs.
>    

I can't really fault a project for using configfs; it's an accepted and 
recommented (by the community) interface.  I'd much prefer it though if 
there was an effort to create a usable fd/struct based alternative.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

