From: Dan McGee <dan@archlinux.org>
Subject: Re: [PATCH] Rename static setns() function
Date: Fri, 15 Jul 2011 19:02:00 -0500
Message-ID: <CAEik5nNiHdL8c9kBTNF41YBNut=L=F4Vv_QdYT3KzAh04nfe5A@mail.gmail.com>
References: <1310755099-32438-1-git-send-email-dan@archlinux.org>
	<m1d3hbm7s7.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:58549 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934Ab1GPACA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 20:02:00 -0400
Received: by pzk3 with SMTP id 3so2112175pzk.5
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 17:02:00 -0700 (PDT)
In-Reply-To: <m1d3hbm7s7.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 15, 2011 at 6:41 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> Dan can you try this patch I think it does a better job at dealing
> with libc defining setns but I don't have a brand new libc handy
> to test with.

Works perfectly (as long as one remembers to rerun ./configure first).
It also works fine with my other configure patch I sent to the list.

-Dan

> From: "Eric W. Biederman" <ebiederm@xmission.com>
> Date: Fri, 15 Jul 2011 16:36:33 -0700
> Subject: [PATCH] iproute2: Auto-detect the presence of setns in libc
>
> If libc has setns present use that version instead of
> rolling the syscall wrapper by hand.
>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
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
