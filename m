From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2] sctp: Change defaults on cookie hmac selection
Date: Mon, 7 Jan 2013 10:38:12 -0500
Message-ID: <20130107153812.GC31577@hmsreliant.think-freely.org>
References: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com>
 <1355534521-32719-1-git-send-email-nhorman@tuxdriver.com>
 <50EACCD3.90609@openwrt.org>
 <20130107144921.GA31577@hmsreliant.think-freely.org>
 <50EAE68C.2050300@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35551 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139Ab3AGPiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 10:38:19 -0500
Content-Disposition: inline
In-Reply-To: <50EAE68C.2050300@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 07, 2013 at 04:15:24PM +0100, Florian Fainelli wrote:
> Le 01/07/13 15:49, Neil Horman a =E9crit :
> >On Mon, Jan 07, 2013 at 02:25:39PM +0100, Florian Fainelli wrote:
> >>Hello Neil,
> >>
> >>Le 12/15/12 02:22, Neil Horman a =E9crit :
> >>>Recently I posted commit 3c68198e75 which made selection of the co=
okie hmac
> >>>algorithm selectable.  This is all well and good, but Linus noted =
that it
> >>>changes the default config:
> >>>http://marc.info/?l=3Dlinux-netdev&m=3D135536629004808&w=3D2
> >>>
> >>>I've modified the sctp Kconfig file to reflect the recommended way=
 of making
> >>>this choice, using the thermal driver example specified, and broug=
ht the
> >>>defaults back into line with the way they were prior to my origion=
al patch
> >>>
> >>>Also, on Linus' suggestion, re-adding ability to select default 'n=
one' hmac
> >>>algorithm, so we don't needlessly bloat the kernel by forcing a no=
n-none
> >>>default.  This also led me to note that we won't honor the default=
 none
> >>>condition properly because of how sctp_net_init is encoded.  Fix t=
hat up as
> >>>well.
> >>>
> >>>Tested by myself (allbeit fairly quickly).  All configuration comb=
inations seems
> >>>to work soundly.
> >>>
> >>>Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >>>CC: David Miller <davem@davemloft.net>
> >>>CC: Linus Torvalds <torvalds@linux-foundation.org>
> >>>CC: Vlad Yasevich <vyasevich@gmail.com>
> >>>CC: linux-sctp@vger.kernel.org
> >>>---
> >>>  net/sctp/Kconfig    | 27 +++++++++++++++++++++++++--
> >>>  net/sctp/protocol.c |  4 ++--
> >>>  2 files changed, 27 insertions(+), 4 deletions(-)
> >>>
> >>>diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
> >>>index a9edd2e..c262106 100644
> >>>--- a/net/sctp/Kconfig
> >>>+++ b/net/sctp/Kconfig
> >>>@@ -66,12 +66,36 @@ config SCTP_DBG_OBJCNT
> >>>  	  'cat /proc/net/sctp/sctp_dbg_objcnt'
> >>>
> >>>  	  If unsure, say N
> >>>+choice
> >>>+	prompt "Default SCTP cookie HMAC encoding"
> >>>+	default SCTP_COOKIE_HMAC_MD5
> >>Should not this be SCTP_DEFAULT_COOKIE_HMAC_MD5? I just tried to
> >>update to 3.8-rc2, and I usually build my kernel-headers with:
> >>
> >>yes '' | ARCH=3Dfoo make oldconfig
> >>
> >>and this just kept asking me for this config symbol because none
> >>could be provided.
> >>--
> >>Florian
> >>
> >No, the config mechanism is setup to offer the user the ability to c=
hoose a
> >default cookie hmac, alg, then optionally select any other hmac algs=
 you would
> >like to be made available (in the event you want to change the defau=
lt at run
> >time).  When you select the default, it eables (via the select direc=
tive), the
> >corresponding SCTP_COOKIE_HMAC_* config option, which is used in the=
 build, and
> >then prompts for the remaining values.
>=20
> Ok for the explanation, but this still breaks an oldconfig because
> we do not actually propose the user with a default choice:
>=20
>     choice[1-3?]:     Default SCTP cookie HMAC encoding
>       1. Enable optional MD5 hmac cookie generation
> (SCTP_DEFAULT_COOKIE_HMAC_MD5) (NEW)
>       2. Enable optional SHA1 hmac cookie generation
> (SCTP_DEFAULT_COOKIE_HMAC_SHA1) (NEW)
>       3. Use no hmac alg in SCTP cookie generation
> (SCTP_DEFAULT_COOKIE_HMAC_NONE) (NEW)
>=20
> I do not see any difference in what I am proposed if the default
> config symbol is SCTP_DEFAULT_COOKIE_HMAC_MD5, I can still
> optionally choose SHA1 to be supported, and I do have a valid
> default config for this choice. While if I keep SCTP_COOKIE_HMAC_MD5
No, thats the problem, your old config is no longer valid with this new=
 Kconfig
file.  Your config is telling the config utility that you want your def=
ault
Cookie hmac to be MD5, but you've explicitly told it (via your yes "" |=
 make
oldconfig command), that you want SCTP_COOKIE_HMAC_MD5 to be disabled, =
so the
config utility is left with no choice to prompt you again for a default=
 hmac,
which your command answers again by saying SCTP_DEFAULT_COOKIE_HMAC_MD5=
 (the
default choice of 1).  Thats your loop, you keep telling the config uti=
lity that
you both want the default hmac to be md5, and that you don't want to al=
low md5
to be an available hmac alg. =20

Thats not a bug.  I'm sorry if your old configuration needs manual upda=
ting, but
there are no guarantees that old configurations will 'just work' in per=
pituity.

Neil

> as the default I have to manually enter which option I want.
> --
> Florian
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
