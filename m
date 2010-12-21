From: Solar Designer <solar@openwall.com>
Subject: Re: [RFC] ipv4: add ICMP socket kind
Date: Wed, 22 Dec 2010 00:32:12 +0300
Message-ID: <20101221213212.GA26006@openwall.com>
References: <20101221181800.GA8166@albatros> <AANLkTikS6rs-AFGmtTfuRdELJ5+y=o4g1i0Xk9KDFRiv@mail.gmail.com> <20101221194606.GA25359@openwall.com> <AANLkTin6_fck1SbCbX5tLvY8CPzJstqmpkJuVF-B6oC6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vasiliy Kulikov <segooon@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pavel Kankovsky <peak@argo.troja.mff.cuni.cz>
To: Colin Walters <walters@verbum.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTin6_fck1SbCbX5tLvY8CPzJstqmpkJuVF-B6oC6@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 21, 2010 at 03:46:15PM -0500, Colin Walters wrote:
> On Tue, Dec 21, 2010 at 2:46 PM, Solar Designer <solar@openwall.com> =
wrote:
> > We intend to have this sysctl'able and to have it restricted to a g=
roup
> > by default (the sysctl would set the GID) on our Linux distro,
> > Openwall GNU/*/Linux. =9AHowever, we figured that it'd be tough for=
 us to
> > get this complication accepted into mainstream, so we opted to have=
 the
> > patch posted for comment without it.
>=20
> Right, a sysctl was the obvious thing to have.

If others don't mind either, we'd be very happy for this to get in.
Vasiliy can include it in the next revision of the patch he posts.

> >> If you really have a burning desire to get rid of setuid /bin/ping=
,
> >> why not just do it in userspace via message passing to/from a
> >> privileged process, and avoid a lot of code in the kernel?
> >
> > Yes, we thought of that, and we don't like this solution.
>=20
> ...because?

The helper daemon process would need to be constantly running, and it
would consume somewhat more resources than just a piece of extra kernel
code would.  Its complexity would be slightly higher.  It may get
OOM-killed or the like (the cause may be external to it), after which
point the functionality will disappear.  We use OpenVZ containers
heavily, and we don't want to run an instance of such process per
container (up to a few hundred per system).  We also don't want to
introduce a container to host channel for this (would be a hack).  We
already have the process to kernel interface, which works equally well
from containers, so we prefer to just use that.

> >=9AWe similarly
> > (but for different reasons) don't like using fscaps to grant CAP_NE=
T_RAW
> > to ping.
>=20
> I am (learning now) about the fscaps drawbacks...

Here's some info on the topic:

http://www.openwall.com/lists/oss-security/2010/11/08/3

You may also want to read the follow-ups ("thread-next").  Unfortunatel=
y,
I failed to find time to continue that discussion thread myself, althou=
gh
I still hope to.

> > We share your concern about the size of net/ipv4/ping.c introduced =
by
> > this patch, yet this is our current proposal.
>=20
> To be clear I have no personal stake in the size of net/; my concern
> is more about the set of permissions granted by the default kernel
> configuration.  Both from an OS developer standpoint, and also just s=
o
> I feel I can continue to explain to someone who's learning about Linu=
x
> all the interactions between the uid/gid, capabilities, SELinux, etc.
> If the kernel starts adding extensions to things it historically
> didn't, that gets even more complicated.

Oh, this is a very minor change from this point of view.  There was
already a related change in 2.3.x that permitted Olaf Kirch's
implementation of traceroute to work as non-root on Linux 2.4+ (ability
to receive ICMP errors).  We only want the extra bits of functionality
needed for ping available as well.

> > We figured that there's little point behind such restrictions. =9AJ=
ust how
> > is an ICMP echo request any worse than a UDP packet of the same siz=
e?
> > Anyone can send the latter with current kernels.
>=20
> Clearly if we could go back in time and make some changes to the
> default Unix security model, one of those would probably be making
> allocating TCP/UDP sockets a privileged operation in some way.  But
> the ship has sailed there...

I see no problem here.  It is OK to have this available to all users by
default, but then to allow, say, a privsep child process in a daemon to
give up some of the "privileges" of a traditional Unix process -
including socket allocation.

> > Yet, as I have mentioned, we're in fact going to restrict this to a
> > group by default and to have ping SGID - just not to expose the ext=
ra
> > kernel code for direct attack by a local user. =9AThat's in case th=
ere's a
> > vulnerability in the added code.
>=20
> So wait...this whole patch is to remove the setuid bit, but then
> you're going to go back and add setgid?  How is that really
> compellingly different and better?

ping would otherwise be either available to root only or SUID root.
If there are no other SUID root programs - like there are not in a
default install of Owl 3.0 (our passwd, crontab, at work without SUID
due to changes we made elsewhere) - then it means that ping's SUIDness
would expose the program startup code in ld/libc/kernel to potential
attacks.  There were numerous relevant vulnerabilities in the past.

SGID would not actually be a problem.  On the contrary, it would
introduce a second layer of security - protecting the kernel code
related to ICMP sockets from direct attacks.  If there's a vulnerabilit=
y
in ld/libc/ping that results in a compromise of the group, this merely
removes this second layer of security.  It does not result in a
compromise of the system on its own.

You might want to refer to the following pages for info on how our
SUID-less userland is possible (without fscaps):

http://www.openwall.com/Owl/
http://www.openwall.com/tcb/
http://www.openwall.com/presentations/Owl/mgp00013.html
http://www.openwall.com/presentations/Owl/mgp00020.html
http://www.openwall.com/presentations/Owl/mgp00021.html
http://www.openwall.com/presentations/Owl/mgp00022.html
http://www.openwall.com/presentations/Owl/mgp00023.html

ping is the only problem we have not solved yet.  On Owl 3.0, we instal=
l
it mode 700 by default for this reason, and the "control ping public"
command makes it mode 4711 (re-introducing the risk).  Thus, this ICMP
sockets feature is fairly important for us.  It's the last missing bit.

ping also appears to be the only program that would benefit from fscaps
for real.  (In other cases, different solutions are possible and/or the
capability set would be root-equivalent.)  Rather than have the system
depend on fscaps, which is inconvenient (e.g., backup/restore issues),
we can address the specific case of ping.

Alexander
