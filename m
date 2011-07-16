From: Dan McGee <dan@archlinux.org>
Subject: Re: [PATCH] iproute2: Auto-detect the presence of setns in libc
Date: Fri, 15 Jul 2011 19:34:04 -0500
Message-ID: <CAEik5nOO9KQoEdvPUGwLBDJqOP9OWgz=G-3KMyvwiu4nwoyb=g@mail.gmail.com>
References: <m1mxgfkr3g.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:51201 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216Ab1GPAeF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 20:34:05 -0400
Received: by pvg12 with SMTP id 12so1467320pvg.19
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 17:34:05 -0700 (PDT)
In-Reply-To: <m1mxgfkr3g.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 15, 2011 at 7:26 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> If libc has setns present use that version instead of
> rolling the syscall wrapper by hand.
>
> Dan McGee found the following compile error:
>
> =C2=A0 =C2=A0gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../inc=
lude
> =C2=A0 =C2=A0-DRESOLVE_HOSTNAMES -DLIBDIR=3D\"/usr/lib/\" =C2=A0 -c -=
o ipnetns.o ipnetns.c
> =C2=A0 =C2=A0ipnetns.c:31:12: error: static declaration of =E2=80=98s=
etns=E2=80=99 follows non-static
> =C2=A0 =C2=A0declaration
> =C2=A0 =C2=A0/usr/include/bits/sched.h:93:12: note: previous declarat=
ion of =E2=80=98setns=E2=80=99
> =C2=A0 =C2=A0was here
> =C2=A0 =C2=A0make[1]: *** [ipnetns.o] Error 1
>
> Reported-by: =C2=A0Dan McGee <dan@archlinux.org>
> Tested-by: =C2=A0Dan McGee <dan@archlinux.org>
Should mention that this was tested on glibc 2.14, where the setns
function was introduced.

> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

And I forgot to be explicit, but:
Signed-off--by:  Dan McGee <dan@archlinux.org>

> ---
> =C2=A0configure =C2=A0 =C2=A0| =C2=A0 24 ++++++++++++++++++++++++
> =C2=A0ip/Makefile =C2=A0| =C2=A0 =C2=A06 ++++++
> =C2=A0ip/ipnetns.c | =C2=A0 =C2=A02 ++
> =C2=A03 files changed, 32 insertions(+), 0 deletions(-)
>
> diff --git a/configure b/configure
> index 69797ab..cfcc82a 100755
> --- a/configure
> +++ b/configure
> @@ -163,6 +163,27 @@ check_ipt_lib_dir()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0echo "not found!"
> =C2=A0}
>
> +check_setns()
> +{
> +cat >/tmp/setnstest.c <<EOF
> +#include <sched.h>
> +int main(int argc, char **argv)
> +{
> + =C2=A0 =C2=A0 =C2=A0 (void)setns(0,0);
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +EOF
> +gcc -I$INCLUDE -o /tmp/setnstest /tmp/setnstest.c >/dev/null 2>&1
> +if [ $? -eq 0 ]
> +then
> + =C2=A0 =C2=A0 =C2=A0 echo "IP_CONFIG_SETNS:=3Dy" >>Config
> + =C2=A0 =C2=A0 =C2=A0 echo "yes"
> +else
> + =C2=A0 =C2=A0 =C2=A0 echo "no"
> +fi
> +rm -f /tmp/setnstest.c /tmp/setnstest
> +}
> +
> =C2=A0echo "# Generated config based on" $INCLUDE >Config
>
> =C2=A0echo "TC schedulers"
> @@ -178,3 +199,6 @@ check_ipt
>
> =C2=A0echo -n "iptables modules directory: "
> =C2=A0check_ipt_lib_dir
> +
> +echo -n "libc has setns: "
> +check_setns
> diff --git a/ip/Makefile b/ip/Makefile
> index 2ee4e7c..8d03993 100644
> --- a/ip/Makefile
> +++ b/ip/Makefile
> @@ -7,6 +7,12 @@ IPOBJ=3Dip.o ipaddress.o ipaddrlabel.o iproute.o ipr=
ule.o ipnetns.o \
>
> =C2=A0RTMONOBJ=3Drtmon.o
>
> +include ../Config
> +
> +ifeq ($(IP_CONFIG_SETNS),y)
> + =C2=A0 =C2=A0 =C2=A0 CFLAGS +=3D -DHAVE_SETNS
> +endif
> +
> =C2=A0ALLOBJ=3D$(IPOBJ) $(RTMONOBJ)
> =C2=A0SCRIPTS=3Difcfg rtpr routel routef
> =C2=A0TARGETS=3Dip rtmon
> diff --git a/ip/ipnetns.c b/ip/ipnetns.c
> index db7007c..dff3497 100644
> --- a/ip/ipnetns.c
> +++ b/ip/ipnetns.c
> @@ -28,6 +28,7 @@
> =C2=A0#define MNT_DETACH =C2=A0 =C2=A0 0x00000002 =C2=A0 =C2=A0 =C2=A0=
/* Just detach from the tree */
> =C2=A0#endif /* MNT_DETACH */
>
> +#ifndef HAVE_SETNS
> =C2=A0static int setns(int fd, int nstype)
> =C2=A0{
> =C2=A0#ifdef __NR_setns
> @@ -37,6 +38,7 @@ static int setns(int fd, int nstype)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return -1;
> =C2=A0#endif
> =C2=A0}
> +#endif /* HAVE_SETNS */
>
>
> =C2=A0static int touch(const char *path, mode_t mode)
> --
> 1.7.5.1.217.g4e3aa
>
>
