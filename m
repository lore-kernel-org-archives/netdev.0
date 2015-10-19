From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Mon, 19 Oct 2015 22:03:17 +0200
Message-ID: <1445284997.621186.414538017.6E35B341@webmail.messagingengine.com>
References: <cover.1444956943.git.daniel@iogearbox.net>
 <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net>
 <1445016105.1251655.412231129.6574D430@webmail.messagingengine.com>
 <5621371C.2000507@plumgrid.com> <56213A61.40509@iogearbox.net>
 <87d1welkp8.fsf@x220.int.ebiederm.org> <56214FAC.5060704@plumgrid.com>
 <87y4f2io9l.fsf@x220.int.ebiederm.org> <5621649A.80403@plumgrid.com>
 <87mvviidku.fsf@x220.int.ebiederm.org> <5621B5BC.8020204@plumgrid.com>
 <56223F00.5030203@iogearbox.net> <562301F9.1030702@plumgrid.com>
 <5623B4B4.2010703@iogearbox.net> <5623CD8D.7000500@iogearbox.net>
 <56240814.8020105@plumgrid.com>
 <1445240171.3728424.413797809.230D716F@webmail.messagingengine.com>
 <5624BD0C.3070404@iogearbox.net> <5624FCDF.3090601@iogearbox.net>
 <562518B8.2070401@plumgrid.com> <56252A43.3000706@iogearbox.net>
 <56253335.9000206@plumgrid.com>
 <1445280385.602530.414418777.63627F89@webmail.messagingengine.com>
 <562545AA.2080207@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <562545AA.2080207@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alexei,

On Mon, Oct 19, 2015, at 21:34, Alexei Starovoitov wrote:
> On 10/19/15 11:46 AM, Hannes Frederic Sowa wrote:
> > Hi,
> >
> > On Mon, Oct 19, 2015, at 20:15, Alexei Starovoitov wrote:
> >> On 10/19/15 10:37 AM, Daniel Borkmann wrote:
> >>> An eBPF program or map loading/destruction is *not* by any means to be
> >>> considered fast-path. We currently hold a global mutex during loading.
> >>> So, how can that be considered fast-path? Similarly, socket creation/
> >>> destruction is also not fast-path, etc. Do you expect that applications
> >>> would create/destroy these devices within milliseconds? I'd argue that
> >>> something would be seriously wrong with that application, then. Such
> >>> persistent maps are to be considered rather mid-long living objects in
> >>> the system. The fast-path surely is the data-path of them.
> >>
> >> consider seccomp that loads several programs for every tab, then
> >> container use case where we're loading two for each as well.
> >> Who knows what use cases will come up in the future.
> >> It's obviously not a fast path that is being hit million times a second,
> >> but why add overhead when it's unnecessary?
> >
> > But the browser using seccomp does not need persistent maps at all. It
> 
> today it doesn't, but if it was a light weight feature, it could
> have been used much more broadly.
> Currently we're using user agent for networking and it's a pain.

I doubt it will stay a lightweight feature as it should not be in the
responsibility of user space to provide those debug facilities.

> >>>> completely unnecessary here. The kernel will consume more memory for
> >>>> no real reason other than cdev are used to keep prog/maps around.
> >>>
> >>> I don't consider this a big issue, and well worth the trade-off. You'll
> >>> have an infrastructure that integrates *nicely* into the *existing* kernel
> >>> model *and* tooling with the proposed patch. This is a HUGE plus. The
> >>> UAPI of this is simple and minimal. And to me, these are in-fact special
> >>> files, not regular ones.
> >>
> >> Seriously? Syscall to create/destory cdevs is a nice api?
> >
> > It is pretty normal to do. They don't use syscall but ioctl on a special
> > pseudo device node (lvm2/device-mapper, tun, etc.). Same thing, very
> > overloaded syscall. Also I don't see a reason to not make the creation
> > possible via sysfs, which would be even nicer but not orthogonal to the
> > current creation of maps, which is nowadays set in stone by uapi.
> 
> Isn't it your point going against cdev? ioctls on devs are overloaded,
> whereas here we have clean bpf syscall with no extra baggage.
> Going old-school to device model goes against that clean syscall
> approach.

The bpf syscall is still used to create the pseudo nodes. If they should
be persistent they just get registered in the sysfs class hierarchy.

> > sysfs already has infrastructure to ensure supportability and
> > debugability. Dependency graphs can be created to see which programs
> > depend on which bpf_progs. kobjects are singeltons in sysfs
> > representation. If you have multiple ebpf filesystems, even maybe
> > referencing the same hashtable with gigabytes of data multiple times,
> > there needs to be some way to help administrators to check resource
> > usage, statistics, tweak and tune the rhashtable. All this needs to be
> > handled as well in the future. It doesn't really fit the filesystem
> > model, but representing a kobject seems to be a good fit to me.
> 
> quite the opposite. The way cdev patch is done now, there is no way
> to extend it to create a hierarchy without breaking users,
> whereas fs style with initial Daniel's patch can be extended.
> Doing 'resource stats' via sysfs requires bpf to add to sysfs, which
> is not this cdev approach.

This is not yet part of the patch, but I think this would be added.
Daniel?

> > Policy can be done by user space with help of udev. Selinux policies can
> > easily being extended to allow specific domains access. Namespace
> > "passthrough" is defined for devices already.
> 
> that's an interesting point, but isn't it better done with fs?
> you can go much more fine-grained with directory permissions in fs.
> With different users/namespaces having their own hierarchies and mounts
> whereas cdev dumps everything into one spot.

Policy can already be defined in terms of cgroups:
<http://lxr.free-electrons.com/source/Documentation/cgroups/devices.txt>

I don't think there are broad differences. But in case a namespaces uses
huge number of maps with tons of data, the admin in the initial
namespace might want to debug that without searching all mountpoints and
find dependencies between processes etc. IMHO sysfs approach can be
better extended here.
 
> >> where do you see 'over-design' in fs? It's a straightforward code and
> >> most of it is boilerplate like all other fs.
> >> Kill rmdir/mkdir ops, term bit and options and the fs diff will shrink
> >> by another 200+ lines.
> >
> > I don't think that only a filesystem will do it in the foreseeable
> > future. You want to have tools like lsof reporting which map and which
> > program has references to each other. Those file nodes will need more
> > metadata attached in future anyway, so currently just comparing lines of
> > codes seems not to be a good way for arguing.
> 
> my point was that both have roughly the same number, but the lines of
> code will grow in either approach and when cdev starts as a hack I can
> only see more hacks added in the future, whereas fs gives us
> full flexibility to do any type of file access and user visible
> representation.
> Also I don't buy the point of reinventing sysfs. bpffs is not doing
> sysfs. I don't want to see _every_ bpf object in sysfs. It's way too
> much overhead. Classic doesn't have sysfs and everyone have been
> using it just fine.

But classic bpf does not have persistence for maps and data. ;) There is
a 1:1 relationship between socket and bpf_prog for example.

> bpffs is solving the need to 'pin_fd' when user process exits.
> That's it. Let's solve that and not go into any of this sysfs stuff.

But how can the filesystem be extended in terms of tunables and
information? File attributes? Wouldn't it need the same infrastructure
otherwise as sysfs? Some third-party lookup filesystem or ioctl? This
char dev approach also pins maps and progs while giving more policy in
hand of central user space programs we are currently using (udev,
systemd, whatever, etc.).

Bye,
Hannes
