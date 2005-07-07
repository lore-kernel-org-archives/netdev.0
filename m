From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: [PATCH 2.6.13-rc1 8/17] bonding: SYSFS INTERFACE (large)
Date: Thu, 7 Jul 2005 16:06:38 -0700
Message-ID: <Pine.CYG.4.58.0507071511300.3956@mawilli1-desk2.amr.corp.intel.com>
References: <Pine.LNX.4.61.0507011347060.17459@localhost.localdomain>
 <20050702081346.GA20789@kroah.com> <Pine.CYG.4.58.0507061138030.1208@mawilli1-desk2.amr.corp.intel.com>
 <20050706195232.GB18359@kroah.com> <20050707142544.GA9418@tuxdriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Greg KH <greg@kroah.com>, Mitch Williams <mitch.a.williams@intel.com>,
        Radheka Godse <radheka.godse@intel.com>, netdev@oss.sgi.com,
        bonding-devel@lists.sourceforge.net, fubar@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20050707142544.GA9418@tuxdriver.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Thu, 7 Jul 2005, John W. Linville wrote:

> On Wed, Jul 06, 2005 at 12:52:32PM -0700, Greg KH wrote:
> > On Wed, Jul 06, 2005 at 11:53:13AM -0700, Mitch Williams wrote:
>
> >
> > How about this:
> > 	bond_add - write to this to add a new bond, one value only.
> > 	bond_remove - write to this to remove a bond that is present.
> > 	bonds/bond0
> > 	bonds/bond1
> > 	bonds/bond2
> > 	...
> > 		- list of bonds currently present.  If you want, you
> > 		  could make those bondX files directories, and put
> > 		  other info about the individual bonds in there, if you
> > 		  need it (I know nothing about the bonding intrerface,
> > 		  sorry.)
> >
> > Would that work?
>
> I like that suggestion.  It keeps the interface creation/deletion a
> little more independent of each other.
>

We looked into a scheme much like this, but rejected it early on.

Actually, what Greg is proposing is two things:  1) move the individual
bond interface directories down a level, into /sys/class/net, and 2)
change bonding_masters into a set of control files, instead of one file.

Moving the individual bond directories to a bonds/ directory
is problematic.  Because each bond shows up a just another network
interface, they show up in /sys/class/net automatically.  We'd have to
make a bunch of changes to the device model to account for bonding, and
we'd break the semantics of the /sys/class/net hierarchy.

Instead, what we do is piggyback on the device model by adding new files
(attributes) to each bond device's directory (kobject).

The problem, then, becomes one of separating the bond interfaces from the
non-bond interfaces.  The bonding_masters file is a simple solution to
this problem.  Reading the file gives the set of active bonds, and writing
the file changes the set of active bonds.  As I stated before, a cursory
reading of Documentation/filesystems/sysfs.txt indicates that such a usage
is "socially acceptable".  (Or at least it was to Patrick Mochel back in
January of 2003.)

My other major difficulty with the bond_add/bond_remove scheme is that
these files would act differently than any other sysfs files, in that
their read and write semantics are not the same.

What I mean is that any given sysfs "file" will appear to contain the same
data for both read and write.  Most scripts that handle sysfs do some sort
of read-modify-write operation.  This would not be possible with the type
of scheme Greg KH has outlined.

Furthermore, what happens when you read bond_add and bond_remove?  What do
you use to get a list of existing bond interfaces?  Reading a file named
"bond_add" to get a list of bonds is counterintuitive at best, and adding
an extra read-only file just to get a list of bonds seems cumbersome.

Greg also (in another message) mentioned problems with appending to
bonding_masters.  This currently is a problem, since sysfs itself does not
handle appends properly.  Since there is no concept of a file pointer or
offset or such when the underlying methods are called, and since sysfs
happily allows seek operations to succeed, appending ends up destroying
the contents of the file.  I submitted two patches that addressed this
issue several months ago but got a frosty reception and gave up.

Of course, all our discussions don't really mean anything, since none of
us is the bonding maintainer.  I'd really like to know what Jay Vosburgh
thinks about all this.  Are you there, Jay?

-Mitch
