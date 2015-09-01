From: Laurent Georget <laurent.georget-vbcOdlJ0SulGWvitb5QawA@public.gmane.org>
Subject: Re: [PATCH] man2: adjtimex.2 : add info about Clock source
Date: Tue, 1 Sep 2015 09:53:51 +0200
Message-ID: <55E5598F.4090909@supelec.fr>
References: <1440935457-16478-1-git-send-email-punitvara@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Punit Vara <punitvara-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1440935457-16478-1-git-send-email-punitvara-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello!

I'm not sure that this is what is meant by "Clock source" in struct tim=
ex.h.
STA_CLK can take only two values ("A" and "B"), and is read-only.
It was added in commit ee9851b218b8bafa22942b5404505ff3d2d34324
(kernel 2.6.25) at the same time MOD_CLKA and MOD_CLKB were removed.

> tree 581f455e02ed3d03e543642b5d54b83dc75d47c7
> parent ee9851b218b8bafa22942b5404505ff3d2d34324
> author Roman Zippel <zippel-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org> Thu May 1 04:34:33 2008 -=
0700
> committer Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> Thu May 1 08=
:03:58 2008 -0700
>
> ntp: NTP4 user space bits update
>
> This adds a few more things from the ntp nanokernel related to user s=
pace.
> It's now possible to select the resolution used of some values via ST=
A_NANO
> and the kernel reports in which mode it works (pll/fll).
>
> If some values for adjtimex() are outside the acceptable range, they =
are now
> simply normalized instead of letting the syscall fail.  I removed
> MOD_CLKA/MOD_CLKB as the mapping didn't really makes any sense, the k=
ernel
> doesn't support setting the clock.
>
> Signed-off-by: Roman Zippel <zippel-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
> Cc: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

Originally, A and B were present to distinguish two modes of functionin=
g:
whether an external clock is present or not. If an external clock syste=
m adjusts
the local clock, then NTP is not used. In the case of Linux, I think th=
is
distinction between sources "A" and "B" is present for historical reaso=
ns, and
because it was present in the reference implementation for ntp but I do=
n't see
where it's used in the kernel. See this for example of use of STA_CLK i=
n another
implementation:
http://www.slac.stanford.edu/comp/unix/package/rtems/src/ssrlApps/ntpNa=
noclock/api.htm
And this for the NTP standard, version 4:
http://www.eecis.udel.edu/~mills/ntp/html/extern.html

In Linux, there are two ways to adjust the clock. If it's not by NTP, t=
hen it can
be through the use of system call clock_adjtime(2) (for which there is =
no man
page yet, see clock_settime(2) to get an idea of the interface) which u=
ses a
function pointer clock_adj declared in a k_clock struct, which can be i=
nitialised
to function posix_clock_realtime_adj. (Everything is in kernel/time/pos=
ix-timers.c.)
Eventually, this boils down to using do_adjtimex, just as adjtimex(2) d=
oes.
I guess STA_CLK should be set/reset with one of the method and not the =
other, if
my understanding is correct, but it's not. Maybe because it's unused an=
yway?

Laurent

Le 30/08/2015 13:50, Punit Vara a =E9crit :
> 	This is a patch to the adjtimex.2 file that add more
> 	detail about clock source in man page which is asked to be fixed.
> 	I got this information from standard document RFC5909 which is
> 	available at https://tools.ietf.org/html/rfc5905#appendix-A.5.5.1
> Signed-off-by: Punit Vara <punitvara-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  man2/adjtimex.2 | 24 ++++++++++++++++++++++--
>  1 file changed, 22 insertions(+), 2 deletions(-)
>
> diff --git a/man2/adjtimex.2 b/man2/adjtimex.2
> index 04b53b1..77b4e30 100644
> --- a/man2/adjtimex.2
> +++ b/man2/adjtimex.2
> @@ -276,8 +276,28 @@ Mode (0 =3D Phase Locked Loop, 1 =3D Frequency L=
ocked Loop; read-only).
>  .\" commit eea83d896e318bda54be2d2770d2c5d6668d11db
>  .\" Author: Roman Zippel <zippel-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
>  Clock source (0 =3D A, 1 =3D B; read-only).
> -.\" FIXME It would be helpful to have some explanation of what
> -.\"       "Clock source" is.
> +Clock source is used to synchronized the time.It can be any standard=
 clock=20
> +sources like :
> +
> +Geosynchronous Orbit Environment Satellite
> +Global Position System
> +Galileo Positioning System
> +Generic pulse-per-second
> +Inter-Range Instrumentation Group
> +LF Radio WWVB Ft. Collins, CO 60 kHz
> +LF Radio DCF77 Mainflingen, DE 77.5 kHz
> +LF Radio HBG Prangins, HB 75 kHz=20
> +LF Radio MSF Anthorn, UK 60 kHz
> +LF Radio JJY Fukushima, JP 40 kHz, Saga, JP 60 kHz
> +MF Radio LORAN C station, 100 kHz
> +MF Radio Allouis, FR 162 kHz
> +HF Radio CHU Ottawa, Ontario
> +HF Radio WWV Ft. Collins, CO
> +HF Radio WWVH Kauai, HI
> +NIST telephone modem
> +NIST telephone modem
> +USNO telephone modem
> +European telephone modem
>  .PP
>  Attempts to set read-only
>  .I status
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
