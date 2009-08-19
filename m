From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for
	vbus_driver objects
Date: Wed, 19 Aug 2009 11:23:47 -0700
Message-ID: <1250706227.27590.156.camel@haakon2.linux-iscsi.org>
References: <20090814154125.26116.70709.stgit@dev.haskins.net>
	 <20090814154308.26116.46980.stgit@dev.haskins.net>
	 <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com>
	 <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com>
	 <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com>
	 <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com>
	 <4A8AD678.7050609@redhat.com> <4A8B9B79.9050004@gmail.com>
	 <4A8BA5AE.3030308@redhat.com>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752565AbZHSSXs@vger.kernel.org>
In-Reply-To: <4A8BA5AE.3030308@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-08-19 at 10:11 +0300, Avi Kivity wrote:
> On 08/19/2009 09:28 AM, Gregory Haskins wrote:
> > Avi Kivity wrote:

<SNIP>

> > Basically, what it comes down to is both vbus and vhost need
> > configuration/management.  Vbus does it with sysfs/configfs, and vhost
> > does it with ioctls.  I ultimately decided to go with sysfs/configfs
> > because, at least that the time I looked, it seemed like the "blessed"
> > way to do user->kernel interfaces.
> >    
> 
> I really dislike that trend but that's an unrelated discussion.
> 
> >> They need to be connected to the real world somehow.  What about
> >> security?  can any user create a container and devices and link them to
> >> real interfaces?  If not, do you need to run the VM as root?
> >>      
> > Today it has to be root as a result of weak mode support in configfs, so
> > you have me there.  I am looking for help patching this limitation, though.
> >
> >    
> 
> Well, do you plan to address this before submission for inclusion?
> 

Greetings Avi and Co,

I have been following this thread, and although I cannot say that I am
intimately fimilar with all of the virtualization considerations
involved to really add anything use to that side of the discussion, I
think you guys are doing a good job of explaining the technical issues
for the non virtualization wizards following this thread.  :-)

Anyways, I was wondering if you might be interesting in sharing your
concerns wrt to configfs (conigfs maintainer CC'ed), at some point..?
As you may recall, I have been using configfs extensively for the 3.x
generic target core infrastructure and iSCSI fabric modules living in
lio-core-2.6.git/drivers/target/target_core_configfs.c and
lio-core-2.6.git/drivers/lio-core/iscsi_target_config.c, and have found
it to be extraordinarly useful for the purposes of a implementing a
complex kernel level target mode stack that is expected to manage
massive amounts of metadata, allow for real-time configuration, share
data structures (eg: SCSI Target Ports) between other kernel fabric
modules and manage the entire set of fabrics using only intrepetered
userspace code.

Using the 10000 1:1 mapped TCM Virtual HBA+FILEIO LUNs <-> iSCSI Target
Endpoints inside of a KVM Guest (from the results in May posted with
IOMMU aware 10 Gb on modern Nahelem hardware, see
http://linux-iscsi.org/index.php/KVM-LIO-Target), we have been able to
dump the entire running target fabric configfs hierarchy to a single
struct file on a KVM Guest root device using python code on the order of
~30 seconds for those 10000 active iSCSI endpoints.  In configfs terms,
this means:

*) 7 configfs groups (directories), ~50 configfs attributes (files) per
Virtual HBA+FILEIO LUN
*) 15 configfs groups (directories), ~60 configfs attributes (files per
iSCSI fabric Endpoint

Which comes out to a total of ~220000 groups and ~1100000 attributes
active configfs objects living in the configfs_dir_cache that are being
dumped inside of the single KVM guest instances, including symlinks
between the fabric modules to establish the SCSI ports containing
complete set of SPC-4 and RFC-3720 features, et al.

Also on the kernel <-> user API interaction compatibility side, I have
found the 3.x configfs enabled code adventagous over the LIO 2.9 code
(that used an ioctl for everything) because it allows us to do backwards
compat for future versions without using any userspace C code, which in
IMHO makes maintaining userspace packages for complex kernel stacks with
massive amounts of metadata + real-time configuration considerations.
No longer having ioctl compatibility issues between LIO versions as the
structures passed via ioctl change, and being able to do backwards
compat with small amounts of interpreted code against configfs layout
changes makes maintaining the kernel <-> user API really have made this
that much easier for me.

Anyways, I though these might be useful to the discussion as it releates
to potental uses of configfs on the KVM Host or other projects that
really make sense, and/or to improve the upstream implementation so that
other users (like myself) can benefit from improvements to configfs.

Many thanks for your most valuable of time,

--nab
