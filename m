From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for
	vbus_driver objects
Date: Wed, 19 Aug 2009 12:34:13 -0700
Message-ID: <1250710453.27590.192.camel@haakon2.linux-iscsi.org>
References: <20090814154125.26116.70709.stgit@dev.haskins.net>
	 <20090814154308.26116.46980.stgit@dev.haskins.net>
	 <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com>
	 <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com>
	 <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com>
	 <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com>
	 <4A8AD678.7050609@redhat.com> <4A8B9B79.9050004@gmail.com>
	 <4A8BA5AE.3030308@redhat.com>
	 <1250706227.27590.156.camel@haakon2.linux-iscsi.org>
	 <4A8C46FF.1070107@gmail.com>
	 <1250709574.27590.178.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Ira W. Snyder" <iws@ovro.caltech.edu>,
	Joel Becker <joel.becker@oracle.com>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1250709574.27590.178.camel@haakon2.linux-iscsi.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-08-19 at 12:19 -0700, Nicholas A. Bellinger wrote:
> On Wed, 2009-08-19 at 14:39 -0400, Gregory Haskins wrote:
> > Hi Nicholas
> > 
> > Nicholas A. Bellinger wrote:
> > > On Wed, 2009-08-19 at 10:11 +0300, Avi Kivity wrote:
> > >> On 08/19/2009 09:28 AM, Gregory Haskins wrote:
> > >>> Avi Kivity wrote:
> > > 
> > > <SNIP>
> > > 
> > >>> Basically, what it comes down to is both vbus and vhost need
> > >>> configuration/management.  Vbus does it with sysfs/configfs, and vhost
> > >>> does it with ioctls.  I ultimately decided to go with sysfs/configfs
> > >>> because, at least that the time I looked, it seemed like the "blessed"
> > >>> way to do user->kernel interfaces.
> > >>>    
> > >> I really dislike that trend but that's an unrelated discussion.
> > >>
> > >>>> They need to be connected to the real world somehow.  What about
> > >>>> security?  can any user create a container and devices and link them to
> > >>>> real interfaces?  If not, do you need to run the VM as root?
> > >>>>      
> > >>> Today it has to be root as a result of weak mode support in configfs, so
> > >>> you have me there.  I am looking for help patching this limitation, though.
> > >>>
> > >>>    
> > >> Well, do you plan to address this before submission for inclusion?
> > >>
> > > 
> > > Greetings Avi and Co,
> > > 
> > > I have been following this thread, and although I cannot say that I am
> > > intimately fimilar with all of the virtualization considerations
> > > involved to really add anything use to that side of the discussion, I
> > > think you guys are doing a good job of explaining the technical issues
> > > for the non virtualization wizards following this thread.  :-)
> > > 
> > > Anyways, I was wondering if you might be interesting in sharing your
> > > concerns wrt to configfs (conigfs maintainer CC'ed), at some point..?
> > 
> > So for those tuning in, the reference here is the use of configfs for
> > the management of this component of AlacrityVM, called "virtual-bus"
> > 
> > http://developer.novell.com/wiki/index.php/Virtual-bus
> > 
> > > As you may recall, I have been using configfs extensively for the 3.x
> > > generic target core infrastructure and iSCSI fabric modules living in
> > > lio-core-2.6.git/drivers/target/target_core_configfs.c and
> > > lio-core-2.6.git/drivers/lio-core/iscsi_target_config.c, and have found
> > > it to be extraordinarly useful for the purposes of a implementing a
> > > complex kernel level target mode stack that is expected to manage
> > > massive amounts of metadata, allow for real-time configuration, share
> > > data structures (eg: SCSI Target Ports) between other kernel fabric
> > > modules and manage the entire set of fabrics using only intrepetered
> > > userspace code.
> > 
> > I concur.  Configfs provided me a very natural model to express
> > resource-containers and their respective virtual-device objects.
> > 
> > > 
> > > Using the 10000 1:1 mapped TCM Virtual HBA+FILEIO LUNs <-> iSCSI Target
> > > Endpoints inside of a KVM Guest (from the results in May posted with
> > > IOMMU aware 10 Gb on modern Nahelem hardware, see
> > > http://linux-iscsi.org/index.php/KVM-LIO-Target), we have been able to
> > > dump the entire running target fabric configfs hierarchy to a single
> > > struct file on a KVM Guest root device using python code on the order of
> > > ~30 seconds for those 10000 active iSCSI endpoints.  In configfs terms,
> > > this means:
> > > 
> > > *) 7 configfs groups (directories), ~50 configfs attributes (files) per
> > > Virtual HBA+FILEIO LUN
> > > *) 15 configfs groups (directories), ~60 configfs attributes (files per
> > > iSCSI fabric Endpoint
> > > 
> > > Which comes out to a total of ~220000 groups and ~1100000 attributes
> > > active configfs objects living in the configfs_dir_cache that are being
> > > dumped inside of the single KVM guest instances, including symlinks
> > > between the fabric modules to establish the SCSI ports containing
> > > complete set of SPC-4 and RFC-3720 features, et al.
> > > 
> > > Also on the kernel <-> user API interaction compatibility side, I have
> > > found the 3.x configfs enabled code adventagous over the LIO 2.9 code
> > > (that used an ioctl for everything) because it allows us to do backwards
> > > compat for future versions without using any userspace C code, which in
> > > IMHO makes maintaining userspace packages for complex kernel stacks with
> > > massive amounts of metadata + real-time configuration considerations.
> > > No longer having ioctl compatibility issues between LIO versions as the
> > > structures passed via ioctl change, and being able to do backwards
> > > compat with small amounts of interpreted code against configfs layout
> > > changes makes maintaining the kernel <-> user API really have made this
> > > that much easier for me.
> > > 
> > > Anyways, I though these might be useful to the discussion as it releates
> > > to potental uses of configfs on the KVM Host or other projects that
> > > really make sense, and/or to improve the upstream implementation so that
> > > other users (like myself) can benefit from improvements to configfs.
> > > 
> > > Many thanks for your most valuable of time,
> > 
> > Thank you for the explanation of your setup.
> > 
> > Configfs mostly works for the vbus project "as is".  As Avi pointed out,
> > I currently have a limitation w.r.t. perms.  Forgive me if what I am
> > about to say is overly simplistic.  Its been quite a few months since I
> > worked on the configfs portion of the code, so my details may be fuzzy.
> > 
> > What it boiled down to is I need is a way to better manage perms
> 
> I have not looked at implementing this personally, so I am not sure how
> this would look in fs/configfs/ off the top of my head..  Joel, have you
> had any thoughts on this..?
> 

Actually, something that I have been using is for simple stuff is:

	if (!capable(CAP_SYS_ADMIN))

for controlling I/O to configfs attributes from non priviledged users
for iSCSI authentication information living in struct
config_item_operations lio_target_nacl_auth_cit, the code is here:

http://git.kernel.org/?p=linux/kernel/git/nab/lio-core-2.6.git;a=blob;f=drivers/lio-core/iscsi_target_configfs.c;h=1230b74577076a184b756b3883fb56c6050c7d87;hb=HEAD#l803

I am also using the CONFIGFS Extended Macros, CONFIGS_EATTR() which I
created to allow me to use more than one struct config_groups per parent
structure, and use less lines of code when defining configfs attributes
using generic store() and show() functions:

http://git.kernel.org/?p=linux/kernel/git/nab/lio-core-2.6.git;a=blob;f=include/target/configfs_macros.h

--nab


