From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: configfs/sysfs
Date: Wed, 19 Aug 2009 16:54:07 -0700
Message-ID: <1250726047.27590.295.camel@haakon2.linux-iscsi.org>
References: <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu>
	 <4A89B08A.4010103@gmail.com> <4A8A674E.8070200@redhat.com>
	 <4A8ABEC9.6090006@gmail.com> <4A8AD678.7050609@redhat.com>
	 <4A8B9B79.9050004@gmail.com> <4A8BA5AE.3030308@redhat.com>
	 <1250706227.27590.156.camel@haakon2.linux-iscsi.org>
	 <4A8C5CBB.10605@redhat.com>  <20090819221654.GA29503@mail.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Ira W. Snyder" <iws@ovro.caltech.edu>
To: Joel Becker <Joel.Becker@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753545AbZHSXyK@vger.kernel.org>
In-Reply-To: <20090819221654.GA29503@mail.oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-08-19 at 15:16 -0700, Joel Becker wrote:
> On Wed, Aug 19, 2009 at 11:12:43PM +0300, Avi Kivity wrote:
> > On 08/19/2009 09:23 PM, Nicholas A. Bellinger wrote:
> > >Anyways, I was wondering if you might be interesting in sharing your
> > >concerns wrt to configfs (conigfs maintainer CC'ed), at some point..?
> > 
> > My concerns aren't specifically with configfs, but with all the text
> > based pseudo filesystems that the kernel exposes.
> 
> 	Phew!  It's not just me :-)
> 
> > My high level concern is that we're optimizing for the active
> > sysadmin, not for libraries and management programs.  configfs and
> > sysfs are easy to use from the shell, discoverable, and easily
> > scripted.  But they discourage documentation, the text format is
> > ambiguous, and they require a lot of boilerplate to use in code.
> 
> 	I don't think they "discourage documentation" anymore than any
> ioctl we've ever had.  At least you can look at the names and values and
> take a good stab at it (configfs is better than sysfs at this, by virtue
> of what it does, but discoverability is certainly not as good as real
> documentation).
> 	With an ioctl() that isn't (well) documented, you have to go
> read the structure and probably even read the code that uses the
> structure to be sure what you are doing.
> 

Good point..

> 
> > You could argue that you can wrap *fs in a library that hides the
> > details of accessing it, but that's the wrong approach IMO.  We
> > should make the information easy to use and manipulate for programs;
> > one of these programs can be a fuse filesystem for the active
> > sysadmin if someone thinks it's important.
> 
> 	You are absolutely correct that they are a boon to the sysadmin,
> where in theory programs can do better with binary interfaces.  Except
> what programs?  I can't do an ioctl or a syscall from a shell script
> (no, using bash's network capabilities to talk to netlink does not
> count).  Same with perl/python/whatever where you have to write
> boilerplate to create binary structures.

<nod>, then I suppose it then begins to get down to how easy those
boilderplates can be used to add new groups and attributes for
developers..  In my experience using the CONFIGFS_EATTR() macros with
multiple struct config_groups hanging of the same make_group() allocated
internal TCM structure, this has been very easy for me once I figured
out why I really needed the extended macro set (again, to hang multiple
differently named struct config_groups off a single internally allocated
structure).  Joel, I know that you have been keeping the configfs macros
in sync with the parameters used for original matching sysfs macros (and
that I have been using my own configfs macro that can be used together
with existing code) but I really do think the extended macro set has
benefit for users of configfs who put a little bit of effort to
understand how they work.


> 	These interfaces have two opposing forces acting on them.  They
> provide a reasonably nice way to cross the user<->kernel boundary, so
> people want to use them.  Programmatic things, like a power management
> daemon for example, don't want sysadmins touching anything.  It's just
> an interface for the daemon.  Conversely, some things are really knobs
> for the sysadmin.  There's nothing else to it.  Why should they have to
> code up a C program just to turn a knob?  Configfs, as its name implies,
> really does exist for that second case. 

I think this is a very good point that really shows the benefits of a
configfs based design for real world admin useablility and
configurability (CLI building blocks for higher level UIs).  Having the
ability to modify non compiled code to suit their needs on top of a user
defined configfs directory structure of groups/directories (assuming
config groups have some sort of project defined naming requrements in
each defined struct configfs_item_operations->make_group()) with
synchronization done on a individual configfs group context for
creation/deletion and optionally the I/O access of attributes within
said group.

>  It turns out that it's quite
> nice to use for the first case too, but if folks wanted to go the
> syscall route, no worries.
> 	I've said it many times.  We will never come up with one
> over-arching solution to all the disparate use cases.  Instead, we
> should use each facility - syscalls, ioctls, sysfs, configfs, etc - as
> appropriate.  Even in the same program or subsystem.
> 
> > - atomicity
> > 
> > One attribute per file means that, lacking userspace-visible
> > transactions, there is no way to change several attributes at once.
> > When you read attributes, there is no way to read several attributes
> > atomically so you can be sure their values correlate.  Another
> > example of a problem is when an object disappears while reading its
> > attributes.  Sure, openat() can mitigate this, but it's better to
> > avoid introducing problem than having a fix.
> 
> 	configfs has some atomicity capabilities, but not full
> atomicity.  It's not the right too for that sort of thing.
> 
> > - ambiguity
> > 
> > What format is the attribute?  does it accept lowercase or uppercase
> > hex digits?  is there a newline at the end?  how many digits can it
> > take before the attribute overflows?  All of this has to be
> > documented and checked by the OS, otherwise we risk regressions
> > later.  In contrast, __u64 says everything in a binary interface.
> 
> 	Um, is that __u64 a pointer to a userspace object?  A key to a
> lookup table?  A file descriptor that is padded out?  It's no less
> ambiguous.
> 
> > - lifetime and access control
> > 
> > If a process brings an object into being (using mkdir) and then
> > dies, the object remains behind.  The syscall/ioctl approach ties
> > the object into an fd, which will be destroyed when the process
> > dies, and which can be passed around using SCM_RIGHTS, allowing a
> > server process to create and configure an object before passing it
> > to an unprivileged program
> 
> 	Most things here do *not* want to be tied to the lifetime of one
> process.  We don't want our cpu_freq governor changing just because the
> power manager died.
> 
>  
> > You may argue, correctly, that syscalls and ioctls are not as
> > flexible.  But this is because no one has invested the effort in
> > making them so.  A struct passed as an argument to a syscall is not
> > extensible.  But if you pass the size of the structure, and also a
> > bitmap of which attributes are present, you gain extensibility and
> > retain the atomicity property of a syscall interface.  I don't think
> > a lot of effort is needed to make an extensible syscall interface
> > just as usable and a lot more efficient than configfs/sysfs.  It
> > should also be simple to bolt a fuse interface on top to expose it
> > to us commandline types.
> 
> 	Your extensible syscall still needs to be known.  The
> flexibility provided by configfs and sysfs is of generic access to
> non-generic things.  It's different.
> 	The follow-ups regarding the perf_counter call are a good
> example.  If you know the perf_counter call, you can code up a C program
> that asks what attributes or things are there.  But if you don't, you've
> first got to find out that there's a perf_counter call, then learn how
> to use it.  With configfs/sysfs, you notice that there's now a
> perf_counter directory under a tree, and you can figure out what
> attributes and items are there.
> 	But this is not the be-all-end-all.  Our syscalls should be more
> flexible in the perf_counter way.  Not everything really needs to be
> listable by some yokel sysadmin.
> 
> > configfs is more maintainable that a bunch of hand-maintained
> > ioctls.  But if we put some effort into an extendable syscall
> > infrastructure (perhaps to the point of using an IDL) I'm sure we
> > can improve on that without the problems pseudo filesystems
> > introduce.
> 
> 	Oh, boy, IDL :-)  Seriously, if you can solve the "how do I just
> poke around without actually writing C code or installing a
> domain-specific binary" problem, you will probably get somewhere.
>  

Also, having the configfs directory hierarchy that is based on names
provided by user that can be accessed by higher level code or directly
by the shell, 'tree' and friends is pretty nice too if you are the admin
running the box.  ;-)

> > I can't really fault a project for using configfs; it's an accepted
> > and recommented (by the community) interface.  I'd much prefer it
> > though if there was an effort to create a usable fd/struct based
> > alternative.
> 
> 	Oh, and configfs was explicitly designed to be interface
> agnostic to the client.  The filesystem portions, to the best of my
> ability, are not exposed to client drivers.  So you can replace the
> configfs filesystem interface with a system call set that does the same
> operations, and no configfs user will actually need to change their
> code (if you want to change from text values to non-text, that would
> require changing the show/store operation prototypes, but that's about
> it).
> 

Wow really..?  I was wondering if something like this was possible in
terms of different client interfaces for configfs ops, and where it
would (ever..?) make sense..

--nab

> Joel
> 
