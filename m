From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: configfs/sysfs
Date: Wed, 19 Aug 2009 18:15:06 -0400
Message-ID: <4A8C796A.5060600@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net>	 <20090814154308.26116.46980.stgit@dev.haskins.net>	 <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com>	 <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com>	 <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com>	 <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com>	 <4A8AD678.7050609@redhat.com> <4A8B9B79.9050004@gmail.com>	 <4A8BA5AE.3030308@redhat.com> <1250706227.27590.156.camel@haakon2.linux-iscsi.org> <4A8C5CBB.10605@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig42A12452E3C9300CB0DB64B9"
Cc: "Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Ira W. Snyder" <iws@ovro.caltech.edu>,
	Joel Becker <joel.becker@oracle.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753310AbZHSWPO@vger.kernel.org>
In-Reply-To: <4A8C5CBB.10605@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig42A12452E3C9300CB0DB64B9
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 08/19/2009 09:23 PM, Nicholas A. Bellinger wrote:
>> Anyways, I was wondering if you might be interesting in sharing your
>> concerns wrt to configfs (conigfs maintainer CC'ed), at some point..?
>>   =20
>=20
> My concerns aren't specifically with configfs, but with all the text
> based pseudo filesystems that the kernel exposes.
>=20
> My high level concern is that we're optimizing for the active sysadmin,=

> not for libraries and management programs.  configfs and sysfs are easy=

> to use from the shell, discoverable, and easily scripted.  But they
> discourage documentation, the text format is ambiguous, and they requir=
e
> a lot of boilerplate to use in code.
>=20
> You could argue that you can wrap *fs in a library that hides the
> details of accessing it, but that's the wrong approach IMO.  We should
> make the information easy to use and manipulate for programs; one of
> these programs can be a fuse filesystem for the active sysadmin if
> someone thinks it's important.
>=20
> Now for the low level concerns:
>=20
> - efficiency
>=20
> Each attribute access requires an open/read/close triplet and
> binary->ascii->binary conversions.  In contrast an ordinary
> syscall/ioctl interface can fetch all attributes of an object, or even
> all attributes of all objects, in one call.

I can only speak for vbus, but *fs access efficiency is not a problem.
Its all slow-path anyway.

>=20
> - atomicity
>=20
> One attribute per file means that, lacking userspace-visible
> transactions, there is no way to change several attributes at once.=20

Actually, I do think configfs has some rudimentary, but incomplete IIUC,
support for transactional commits of updates.  In lieu of formal
support, this is also not generally a problem:  You can just put your
own transaction in by the form of an explicit attribute.  For instance,
see the "enabled" attribute in venet-tap.  This lets you set all the
parameters and then hit "enabled" to turn it act on the other settings
atomically.

For sysfs kernel updates, I think you can update the values under a
lock.  For sysfs userspace updates, I suppose you could do a similar
"explicit commit" attribute if it was needed.

> When you read attributes, there is no way to read several attributes
> atomically so you can be sure their values correlate.

This isn't a valid concern for configfs, unless you have multiple
userspace applications updating concurrently.  IIUC, configfs is only
changed by userspace, not the kernel.  So I suppose if you were
concerned about supporting this, you could use an advisory flock or
something.

For sysfs, this is a valid concern.  Generally, I do not think *fs
interfaces are a good match if you need that type of behavior (atomic
read of rapidly changing attributes), however.  FWIW, vbus does not need
this (the parameters do not generally change once established).

> Another example
> of a problem is when an object disappears while reading its attributes.=
=20
> Sure, openat() can mitigate this, but it's better to avoid introducing
> problem than having a fix.

Again, that can only happen if another userspace app did that to you.
Possible solutions might be advisory locking.


>=20
> - ambiguity
>=20
> What format is the attribute?  does it accept lowercase or uppercase he=
x
> digits?  is there a newline at the end?  how many digits can it take
> before the attribute overflows?  All of this has to be documented and
> checked by the OS, otherwise we risk regressions later.  In contrast,
> __u64 says everything in a binary interface.

I don't think this is a legit concern.  I would thing you have to
understand the ABI to use the interface regardless, no matter the
transport.  And either way, the kernel has to validate the input.

>=20
> - lifetime and access control
>=20
> If a process brings an object into being (using mkdir) and then dies,
> the object remains behind.

This is one of the big problems with configfs, I agree.  I guess you
could argue that the ioctl approach has the opposite problem (resource
goes if the owner goes), which is to say it requires the app to hang
around.  Syscall is kind of in the middle, since it doesn't expressly
have a policy against a given resource if a task dies.  You can
certainly modify kernel/exit.c to add such a policy, I suppose.  But
ioctl has a distinct advantage in this regard.

All in all, I think ioctl wins here.

> The syscall/ioctl approach ties the object
> into an fd, which will be destroyed when the process dies, and which ca=
n
> be passed around using SCM_RIGHTS, allowing a server process to create
> and configure an object before passing it to an unprivileged program
>=20
> - notifications
>=20
> It's hard to notify users about changes in attributes.  Sure, you can
> use inotify, but that limits you to watching subtrees.

Whats worse, inotify doesn't seem to work very well against *fs from
what I hear.

>  Once you do get
> the notification, you run into the atomicity problem.  When do you know=

> all attributes are valid?  This can be solved using sequence counters,
> but that's just gratuitous complexity.  Netlink type interfaces are muc=
h
> more robust and flexible.
>=20
> - readdir
>=20
> You can either list everything, or nothing.  Sure, you can have trees t=
o
> ease searching, even multiple views of the same data, but it's painful.=


I do not see the problem here.  *fs structures dirs as objects, and
files as attributes.  A logical presentation of the data from that
perspective ensues.  Why is "readdir" a problem?  It gets all the
attributes of an "object" (sans potential consistency problems, as you
point out above).

>=20
> You may argue, correctly, that syscalls and ioctls are not as flexible.=
=20
> But this is because no one has invested the effort in making them so.  =
A
> struct passed as an argument to a syscall is not extensible.  But if yo=
u
> pass the size of the structure, and also a bitmap of which attributes
> are present, you gain extensibility and retain the atomicity property o=
f
> a syscall interface.  I don't think a lot of effort is needed to make a=
n
> extensible syscall interface just as usable and a lot more efficient
> than configfs/sysfs.  It should also be simple to bolt a fuse interface=

> on top to expose it to us commandline types.

I think the strongest argument about having *fs like models, is its a
way to keep the "management tool" coupled with the kernel that
understands it.  This is quite nice in practice.

Its true that the interface exposed by *fs could be construed as an
"ABI", but that is generally more of an issue for userspace tools that
would turn around and read it, as opposed to a human sitting at the
shell.  So therefore, both *fs and syscall/ioctl approaches suffer from
ABI mis-sync issues w.r.t. tools.  But the *fs wins here because
generally a human can adapt dynamically to the change (e.g. by running
'tree' and looking for something recognizable), whereas syscall/ioctl
have no choice...they are hosed.

It's true you could make an extensible syscall/ioctl interface, but do
note you can use similar techniques (e.g. only add new attributes to
existing objects) on the *fs front as well.  So to me it comes down to
more or less the lifetime question (ioctl wins), vs the
auto-synchronized tool (*fs wins) benefit.  I am honestly not sure what
is better.


>=20
>> As you may recall, I have been using configfs extensively for the 3.x
>> generic target core infrastructure and iSCSI fabric modules living in
>> lio-core-2.6.git/drivers/target/target_core_configfs.c and
>> lio-core-2.6.git/drivers/lio-core/iscsi_target_config.c, and have foun=
d
>> it to be extraordinarly useful for the purposes of a implementing a
>> complex kernel level target mode stack that is expected to manage
>> massive amounts of metadata, allow for real-time configuration, share
>> data structures (eg: SCSI Target Ports) between other kernel fabric
>> modules and manage the entire set of fabrics using only intrepetered
>> userspace code.
>>
>> Using the 10000 1:1 mapped TCM Virtual HBA+FILEIO LUNs<->  iSCSI Targe=
t
>> Endpoints inside of a KVM Guest (from the results in May posted with
>> IOMMU aware 10 Gb on modern Nahelem hardware, see
>> http://linux-iscsi.org/index.php/KVM-LIO-Target), we have been able to=

>> dump the entire running target fabric configfs hierarchy to a single
>> struct file on a KVM Guest root device using python code on the order =
of
>> ~30 seconds for those 10000 active iSCSI endpoints.  In configfs terms=
,
>> this means:
>>
>> *) 7 configfs groups (directories), ~50 configfs attributes (files) pe=
r
>> Virtual HBA+FILEIO LUN
>> *) 15 configfs groups (directories), ~60 configfs attributes (files pe=
r
>> iSCSI fabric Endpoint
>>
>> Which comes out to a total of ~220000 groups and ~1100000 attributes
>> active configfs objects living in the configfs_dir_cache that are bein=
g
>> dumped inside of the single KVM guest instances, including symlinks
>> between the fabric modules to establish the SCSI ports containing
>> complete set of SPC-4 and RFC-3720 features, et al.
>>   =20
>=20
> You achieved 3 million syscalls/sec from Python code?  That's very
> impressive.
>=20
> Note with syscalls you could have done it with 10K syscalls (Python
> supports packing and unpacking structs quite well, and also directly
> calling C code IIRC).
>=20
>> Also on the kernel<->  user API interaction compatibility side, I have=

>> found the 3.x configfs enabled code adventagous over the LIO 2.9 code
>> (that used an ioctl for everything) because it allows us to do backwar=
ds
>> compat for future versions without using any userspace C code, which i=
n
>> IMHO makes maintaining userspace packages for complex kernel stacks wi=
th
>> massive amounts of metadata + real-time configuration considerations.
>> No longer having ioctl compatibility issues between LIO versions as th=
e
>> structures passed via ioctl change, and being able to do backwards
>> compat with small amounts of interpreted code against configfs layout
>> changes makes maintaining the kernel<->  user API really have made thi=
s
>> that much easier for me.
>>   =20
>=20
> configfs is more maintainable that a bunch of hand-maintained ioctls.=20
> But if we put some effort into an extendable syscall infrastructure
> (perhaps to the point of using an IDL) I'm sure we can improve on that
> without the problems pseudo filesystems introduce.
>=20
>> Anyways, I though these might be useful to the discussion as it releat=
es
>> to potental uses of configfs on the KVM Host or other projects that
>> really make sense, and/or to improve the upstream implementation so th=
at
>> other users (like myself) can benefit from improvements to configfs.
>>   =20
>=20
> I can't really fault a project for using configfs; it's an accepted and=

> recommented (by the community) interface.  I'd much prefer it though if=

> there was an effort to create a usable fd/struct based alternative.

Yeah, doing it manually with all the CAP bits gets old, fast, so I agree
 that improvement here is welcome.

Kind Regards,
-Greg


--------------enig42A12452E3C9300CB0DB64B9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqMeWoACgkQP5K2CMvXmqFRJgCdF1cabyKazlhud2j6EJ0RlEL5
VFwAn0ligJdrPSnAPJBSOiJdPdFyjZ1O
=zhV4
-----END PGP SIGNATURE-----

--------------enig42A12452E3C9300CB0DB64B9--
