From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: configfs/sysfs
Date: Wed, 19 Aug 2009 14:19:09 -0700
Message-ID: <1250716749.27590.248.camel@haakon2.linux-iscsi.org>
References: <20090814154125.26116.70709.stgit@dev.haskins.net>
	 <20090814154308.26116.46980.stgit@dev.haskins.net>
	 <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com>
	 <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com>
	 <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com>
	 <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com>
	 <4A8AD678.7050609@redhat.com> <4A8B9B79.9050004@gmail.com>
	 <4A8BA5AE.3030308@redhat.com>
	 <1250706227.27590.156.camel@haakon2.linux-iscsi.org>
	 <4A8C5CBB.10605@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Ira W. Snyder" <iws@ovro.caltech.edu>,
	Joel Becker <joel.becker@oracle.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A8C5CBB.10605@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-08-19 at 23:12 +0300, Avi Kivity wrote:
> On 08/19/2009 09:23 PM, Nicholas A. Bellinger wrote:
> > Anyways, I was wondering if you might be interesting in sharing your
> > concerns wrt to configfs (conigfs maintainer CC'ed), at some point..?
> >    
> 
> My concerns aren't specifically with configfs, but with all the text 
> based pseudo filesystems that the kernel exposes.
> 

<nod>

> My high level concern is that we're optimizing for the active sysadmin, 
> not for libraries and management programs.  configfs and sysfs are easy 
> to use from the shell, discoverable, and easily scripted.  But they 
> discourage documentation, the text format is ambiguous, and they require 
> a lot of boilerplate to use in code.
> 
> You could argue that you can wrap *fs in a library that hides the 
> details of accessing it, but that's the wrong approach IMO.  We should 
> make the information easy to use and manipulate for programs; one of 
> these programs can be a fuse filesystem for the active sysadmin if 
> someone thinks it's important.
> 
> Now for the low level concerns:
> 
> - efficiency
> 
> Each attribute access requires an open/read/close triplet and 
> binary->ascii->binary conversions.  In contrast an ordinary 
> syscall/ioctl interface can fetch all attributes of an object, or even 
> all attributes of all objects, in one call.
> 

I agree that syscalls/ioctls can, given enough coding effort, use a
potentially much smaller amount of total syscalls than a pseudo
filesystem such as configfs.  In the case of the configfs enabled
generic target engine, I have not found this to be particularly limiting
in terms of management on modern x86_64 virtualized hardware inside of
KVM Guests with my development so far..

> - atomicity
> 
> One attribute per file means that, lacking userspace-visible 
> transactions, there is no way to change several attributes at once.  
> When you read attributes,

Actually, something like this can be done in struct
config_item_type->ct_attrs[] by changing the attributes you want, but
not making them active until pulling a seperate configfs item 'trigger'
in the group to make the changes take effect.

I am doing something similar to this now during fabric bringup while
each iSCSI Target module is configured, and then a enable trigger throw
to allow iSCSI Initiators to actually login to the endpoint, and to
prevent endpoints from being active before all of the Ports and ACLs
have been configured for each configured iSCSI endpoint.

This logic is not built into ConfigFS of course, but it does give the
same effect.

>  there is no way to read several attributes 
> atomically so you can be sure their values correlate.

In this case, even though adding multiple values per attribute is
discouraged per the upstream sysfs layout, using a single configfs
attribute to read multiple values of another individual attributes that
need to be read atomically is primary option today wrt existing code.

Not ideal with configfs, but it is easy to do.

>   Another example 
> of a problem is when an object disappears while reading its attributes.  
> Sure, openat() can mitigate this, but it's better to avoid introducing 
> problem than having a fix.
> 

<not sure on this one..>

> - ambiguity
> 
> What format is the attribute?  does it accept lowercase or uppercase hex 
> digits?  is there a newline at the end?  how many digits can it take 
> before the attribute overflows?  All of this has to be documented and 
> checked by the OS, otherwise we risk regressions later.  In contrast, 
> __u64 says everything in a binary interface.
> 

Yes, you need to make strict_str*() calls on the configfs attribute
store() functions with casts to locally defined variable types.  Using
strtoul() and strtoull() have been working fine for me in the context of
the generic target engine, but point taken about the usefulness in
having access to the format metadata of a given attribute.

> - lifetime and access control
> 
> If a process brings an object into being (using mkdir) and then dies, 
> the object remains behind. 

I think this depends on how the struct configfs_item_grops->make_group()
and ->drop_item() are being used.  For example, I typically allocate a
TCM related data structure during the make_group() call containing a
struct config_group member that is registered with
config_group_init_type_name() upon a successful mkdir(2) call.

When drop_item() is called via rmdir(2), that references the struct
config_group, the original data structure containing the struct
config_group is released with config_item_put(), and the TCM allocated
data structure released.

While in use, the registered struct config_group can be pinned with
configfs_depend_item(), which has some interesting limitiations of its
own.

>  The syscall/ioctl approach ties the object 
> into an fd, which will be destroyed when the process dies, and which can 
> be passed around using SCM_RIGHTS, allowing a server process to create 
> and configure an object before passing it to an unprivileged program
> 

<nod>  I have not personally had this requirement so I can't add much
here..

> - notifications
> 
> It's hard to notify users about changes in attributes.  Sure, you can 
> use inotify, but that limits you to watching subtrees.  Once you do get 
> the notification, you run into the atomicity problem.  When do you know 
> all attributes are valid?  This can be solved using sequence counters, 
> but that's just gratuitous complexity.  Netlink type interfaces are much 
> more robust and flexible.
> 

nor the notifiy case either..

> - readdir
> 
> You can either list everything, or nothing.  Sure, you can have trees to 
> ease searching, even multiple views of the same data, but it's painful.
> 
> You may argue, correctly, that syscalls and ioctls are not as flexible.  
> But this is because no one has invested the effort in making them so.

I think that new syscalls are great when you can get them merged (as KVM
is quite important, that means not a problem), and I am sure you guys
can make an ioctl contort into all manner of positions.

Perhaps it is just that I think that the code to manage complex ioctl
interaction can get quite ugly from my experience, and doing backwards
compat with interpreted code makes life for easier, at least for me.

>   A 
> struct passed as an argument to a syscall is not extensible.  But if you 
> pass the size of the structure, and also a bitmap of which attributes 
> are present, you gain extensibility and retain the atomicity property of 
> a syscall interface.  I don't think a lot of effort is needed to make an 
> extensible syscall interface just as usable and a lot more efficient 
> than configfs/sysfs.

Good point, however in terms of typical mangement scenarios in my
experience with TCM/LIO 3.x, I have not found the lost efficiently of
using configfs compared to legacy IOCTL for controlling the fabric in
typical usage cases.

That said, I am sure there must be particular cases in the
virtualization world where having those syscalls is critical, for which
a configfs enabled generic target does not make sense.

>   It should also be simple to bolt a fuse interface 
> on top to expose it to us commandline types.
>

That would be interesting..

> > As you may recall, I have been using configfs extensively for the 3.x
> > generic target core infrastructure and iSCSI fabric modules living in
> > lio-core-2.6.git/drivers/target/target_core_configfs.c and
> > lio-core-2.6.git/drivers/lio-core/iscsi_target_config.c, and have found
> > it to be extraordinarly useful for the purposes of a implementing a
> > complex kernel level target mode stack that is expected to manage
> > massive amounts of metadata, allow for real-time configuration, share
> > data structures (eg: SCSI Target Ports) between other kernel fabric
> > modules and manage the entire set of fabrics using only intrepetered
> > userspace code.
> >
> > Using the 10000 1:1 mapped TCM Virtual HBA+FILEIO LUNs<->  iSCSI Target
> > Endpoints inside of a KVM Guest (from the results in May posted with
> > IOMMU aware 10 Gb on modern Nahelem hardware, see
> > http://linux-iscsi.org/index.php/KVM-LIO-Target), we have been able to
> > dump the entire running target fabric configfs hierarchy to a single
> > struct file on a KVM Guest root device using python code on the order of
> > ~30 seconds for those 10000 active iSCSI endpoints.  In configfs terms,
> > this means:
> >
> > *) 7 configfs groups (directories), ~50 configfs attributes (files) per
> > Virtual HBA+FILEIO LUN
> > *) 15 configfs groups (directories), ~60 configfs attributes (files per
> > iSCSI fabric Endpoint
> >
> > Which comes out to a total of ~220000 groups and ~1100000 attributes
> > active configfs objects living in the configfs_dir_cache that are being
> > dumped inside of the single KVM guest instances, including symlinks
> > between the fabric modules to establish the SCSI ports containing
> > complete set of SPC-4 and RFC-3720 features, et al.
> >    
> 
> You achieved 3 million syscalls/sec from Python code?  That's very 
> impressive.

Well, that is dumping the running configfs for everything.  In more
typical usage cases of the TCM/LIO configfs fabric, specific Virtual
HBAs+LUNs and iSCSI Fabric endpoints would be changing individually, as
each Virtual HBA and iSCSI endpoint are completely independent of each
other and are intended to be administrated that way.

You can even run multiple for loops from different shell procceses to
create the endpoints in parallel using UUID and iSCSI WWN naming for
doing multithreaded configfs fabric bringup.

> 
> Note with syscalls you could have done it with 10K syscalls (Python 
> supports packing and unpacking structs quite well, and also directly 
> calling C code IIRC).
> 
> > Also on the kernel<->  user API interaction compatibility side, I have
> > found the 3.x configfs enabled code adventagous over the LIO 2.9 code
> > (that used an ioctl for everything) because it allows us to do backwards
> > compat for future versions without using any userspace C code, which in
> > IMHO makes maintaining userspace packages for complex kernel stacks with
> > massive amounts of metadata + real-time configuration considerations.
> > No longer having ioctl compatibility issues between LIO versions as the
> > structures passed via ioctl change, and being able to do backwards
> > compat with small amounts of interpreted code against configfs layout
> > changes makes maintaining the kernel<->  user API really have made this
> > that much easier for me.
> >    
> 
> configfs is more maintainable that a bunch of hand-maintained ioctls.  

<nod>

> But if we put some effort into an extendable syscall infrastructure 
> (perhaps to the point of using an IDL) I'm sure we can improve on that 
> without the problems pseudo filesystems introduce.
> 

Understood, while I think configfs is grand for a number of purposes, I
am certainly not foolish enough to think it is perfect for everything

> > Anyways, I though these might be useful to the discussion as it releates
> > to potental uses of configfs on the KVM Host or other projects that
> > really make sense, and/or to improve the upstream implementation so that
> > other users (like myself) can benefit from improvements to configfs.
> >    
> 
> I can't really fault a project for using configfs; it's an accepted and 
> recommented (by the community) interface.  I'd much prefer it though if 
> there was an effort to create a usable fd/struct based alternative.
> 

Thanks for your great comments Avi!

--nab




