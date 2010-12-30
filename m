From: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 00/12] make rpc_pipefs be mountable multiple time
Date: Thu, 30 Dec 2010 13:45:14 +0200
Message-ID: <20101230114514.GA31976@shutemov.name>
References: <1293628470-28386-1-git-send-email-kas@openvz.org>
 <AANLkTi=AXz21wDeE1vPVD-6cEtj6faXN9x09eHDCsTkB@mail.gmail.com>
 <20101230085139.GA29697@shutemov.name>
 <4D1C4C7C.6050606@parallels.com>
 <20101230094433.GB29697@shutemov.name>
 <4D1C5953.6020200@parallels.com>
 <20101230104416.GA31824@shutemov.name>
 <AANLkTim2QrkSW0HufD5wp=-8ikwydN5SUS+fdWK6JHqb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirill A. Shutemov" <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTim2QrkSW0HufD5wp=-8ikwydN5SUS+fdWK6JHqb-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 30, 2010 at 05:05:22AM -0600, Rob Landley wrote:
> On Thu, Dec 30, 2010 at 4:44 AM, Kirill A. Shutemov <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> =
wrote:
> > On Thu, Dec 30, 2010 at 04:05:07AM -0600, Rob Landley wrote:
> >> On 12/30/2010 03:44 AM, Kirill A. Shutemov wrote:
> >> >>> If no rpcmount mountoption, no rpc_pipefs was found at
> >> >>> '/var/lib/nfs/rpc_pipefs' and we are in init's mount namespace=
, we use
> >> >>> init_rpc_pipefs.
> >> >>
> >> >> It's the "we are in init's mount namespace" that I was wonderin=
g about.
> >> >>
> >> >> So if I naievely chroot, nfs mount stops working the way it did=
 before I
> >> >> chrooted unless I do an extra setup step?
> >> >
> >> > No. It will work as before since you are still in init's mount n=
amespace.
> >> > Creating new mount namespace changes rules.
> >>
> >> Ah, CLONE_NEWNS and then you need /var/lib/nfs/rpc_pipefs. =A0Got =
it.
> >>
> >> I'm kind of surprised that the kernel cares about a specific path =
under
> >> /var/lib. =A0(Seems like policy in the kernel somehow.)
> >
> > Yep. It's bad, but there is way to overwrite the default.
> >
> > Other way is to leave 'rpcmount' mountoption without default.
> > get_rpc_pipefs(NULL) in init's mount namespace will always return
> > init_rpc_pipefs, without filesystem lookup.
> > get_rpc_pipefs(NULL) in non-init's mount namespace will always retu=
rn
> > error.
> >
> > So you will have to specify 'rpcmount' mountoption for every nfs mo=
unt in
> > container. Hmm, I guess, it may confuse user.
> >
> > Or we can try to move the default to userspace. /sbin/mount.nfs?
>=20
> /proc/sys/kernel/hotplug exists to tell the kernel where to find the =
hotplug
> binary.  Once upon a time /sys/hotplug was the default value, and tha=
t was
> there to overwrite it.  (They changed the default to blank (disabled)=
 not due
> to policy reasons, but due to adding the netlink hotplug notification
> mechanism and making that the default.)
>=20
> I bring that up to point out that the general consensus about policy =
in the
> kernel seems to be "when you really really can't avoid having any, ma=
ke a
> sane default the user can override".
>=20
> (Of course adding another entry to the crawling horror of /proc may n=
ot
> be an improvement.  But individual overrides at the mount -o level se=
em
> like a non-optimal granularity for this...)

Do you propose to implement default as sysctl parameter?

> >> Can't it just
> >> check the current process's mount list to see if an instance of
> >> rpc_pipefs is mounted in the current namespace the way lxc looks f=
or
> >> cgroups? =A0Or are there potential performance/scalability issues =
with that?
> >
> > What should we do if we have several rpc_pipefs mounts in the names=
pace?
>=20
> You mean more than one inside a given process's view of the filesyste=
m, taking
> into account chroot like /proc/mounts does?
>=20
> Before this patch series, there was one instance systemwide.  The pat=
ch changed
> that to look a fixed location in the filesystem relative to the
> current chroot.  Either
> way, there was one instance available to a given process doing an nfs=
 mount.
>=20
> What's the use case for having more than one visible to a given proce=
ss?
> (NUMA scalability?  Some sort of multipath/VPN routing context?)

It's no so obvious for me why we should restrict it. ;)

Currently, there is no association between rpc_pipefs and mount namespa=
ce,
so I don't see simple way to restrict number of rpc_pipefs per mount
namespace. Associating mount namespace with rpc_pipefs is not a good id=
ea,
I think.

--=20
 Kirill A. Shutemov
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
