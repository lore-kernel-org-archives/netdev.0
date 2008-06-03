From: David Dillow <dillowda@ornl.gov>
Subject: Re: [ofa-general] Re: [PATCH v3 08/13] QLogic VNIC: sysfs	interface
	implementation for the driver
Date: Tue, 03 Jun 2008 14:45:03 -0400
Message-ID: <1212518703.2217.22.camel@lap75545.ornl.gov>
References: <20080529095126.9943.84692.stgit@localhost.localdomain>
	<20080529095754.9943.27936.stgit@localhost.localdomain>
	<20080529103003.010c4a08@extreme> <20080529174805.GA10903@kroah.com>
	<c8028d330806031125x4181d8e3p9cdaf1f4c79e88c6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, rdreier@cisco.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	poornima.kamath@qlogic.com
To: Amar Mudrankit <amar.mudrankit@qlogic.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-reply-to: <c8028d330806031125x4181d8e3p9cdaf1f4c79e88c6@mail.gmail.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


On Tue, 2008-06-03 at 23:55 +0530, Amar Mudrankit wrote:
> On Thu, May 29, 2008 at 11:18 PM, Greg KH <greg@kroah.com> wrote:
> > On Thu, May 29, 2008 at 10:30:03AM -0700, Stephen Hemminger wrote:
> > > No sysfs is supposed to be one value per file use separate
> > > attributes for each one. This also eliminates the parsing code.
>         
> > And yes, multiple values per sysfs file are not allowed, sorry,
> > please change this.  If you need to configure your device through an
> > interface like this, consider using configfs instead, that is what
> > it is there for.
>  
> Documentation/filesystems/configfs/configfs.txt <<snip>>
> 
> [Using configfs]
> 
> Like sysfs, attributes should be ASCII text files, preferably
> with only one value per file.  The same efficiency caveats from sysfs
> apply.  Don't mix more than one attribute in one attribute file.
> 
> 
> It looks like configfs also does not allow multiple attributes per
> file.  So, in that case, shall we modify our sysfs code to support one
> value per sysfs file? With this approach, the impact on user space
> applications that we have which depend on the qlgc_vnic driver sysfs
> interface will be less.

The idea would be to have a separate file per attribute, ie ioc_guid in
a file, dgid in a file, pkey in a file, and so on. Userspace would make
a directory for the new connection in /configfs/qlogic-device (or what
ever you call it), and configfs will populate it with default values for
those attributes.

Or so the theory goes. Unfortunately, you need all that information
before you can create the connection. The configfs guys have thought
about that, but not implemented yet:

> [Committable Items]
> NOTE: Committable items are currently unimplemented.
>
> Some config_items cannot have a valid initial state.  That is, no
> default values can be specified for the item's attributes such that
> the item can do its work.  Userspace must configure one or more
> attributes, after which the subsystem can start whatever entity this
> item represents.
> [snip]
> Any group that provides the ct_group_ops->commit_item() method has
> committable items.  When this group appears in configfs, mkdir(2) will
> not work directly in the group.  Instead, the group will have two
> subdirectories: "live" and "pending".  The "live" directory does not
> support mkdir(2) or rmdir(2) either.  It only allows rename(2).  The
> "pending" directory does allow mkdir(2) and rmdir(2).  An item is
> created in the "pending" directory.  Its attributes can be modified at
> will.  Userspace commits the item by renaming it into the "live"
> directory.  At this point, the subsystem receives the ->commit_item()
> callback.  If all required attributes are filled to satisfaction, the
> method returns zero and the item is moved to the "live" directory.

It looks like the design for what you'd need is there, but no code -- ag
grep for 'commit' in the fs/configfs directory doesn't give me anything,
though I just did a cursory glance when it was suggested that SRP use
this.

So, I don't think configfs is ready for your use case just yet. Perhaps
you can contact the configfs guys and see where they are at on this.

I suppose you could also implement a special "activate" attribute that
tells your code that all the attributes are set when it gets written,
but that seems counter to the intended usage, and there are some
possible obj lifetime rules to deal with then. The commitable item
concept seems like a much better fit.
-- 
Dave Dillow
National Center for Computational Science
Oak Ridge National Laboratory
(865) 241-6602 office
