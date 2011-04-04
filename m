From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: [PATCH] xen: drop anti-dependency on X86_VISWS (Was: Re: [PATCH]
 xen: netfront: fix declaration order)
Date: Mon, 4 Apr 2011 10:55:55 +0100
Message-ID: <1301910955.23887.75.camel@zakaz.uk.xensource.com>
References: <20110331110136.03A1A13A6A@rere.qmqm.pl>
	 <20110401.205455.70198735.davem@davemloft.net>
	 <1301828839.2837.143.camel@edumazet-laptop>
	 <20110403.172407.91341067.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"mirq-linux@rere.qmqm.pl" <mirq-linux@rere.qmqm.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeremy Fitzhardinge <Jeremy.Fitzhardinge@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	AndreyPanin <pazke@donpac.ru>, linux-visws-devel@lists.sf.net,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:59256 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753731Ab1DDJz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 05:55:57 -0400
In-Reply-To: <20110403.172407.91341067.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-04 at 01:24 +0100, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 03 Apr 2011 13:07:19 +0200
>=20
> > [PATCH] xen: netfront: fix declaration order
> >=20
> > Must declare xennet_fix_features() and xennet_set_features() before
> > using them.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
>=20
> Ugh, it makes no sense that XEN won't make it into the x86_32
> allmodconfig build.  Those dependencies in arch/x86/xen/Kconfig
> are terrible.

You mean the "!X86_VISWS" I presume? It doesn't make sense to me either=
=2E
Or at least I'm not sure why this single X86_32_NON_STANDARD machine is
more special than the others to require an anti-dependency like this.

It seems to have originally appeared from f0f32fccbffa on
CONFIG_PARAVIRT due to a conflict around ARCH_SETUP() and subsequently
got pushed down to CONFIG_XEN. However ARCH_SETUP doesn't exist any mor=
e
and I think the subarch stuff has been much improved since then so ther=
e
should be no conflict any more.

I dropped the dependency and, with a bit of fiddling, was able to build
a kernel with both CONFIG_X86_VISWS and CONFIG_XEN which booted as a Xe=
n
domU.

tglx, Andrey, to get VISWS to build I had to comment out some code in
arch/x86/platform/visws/visws_quirks.c which seems to have been missed
during some irq_chip update or something?

          CC      arch/x86/platform/visws/visws_quirks.o
        arch/x86/platform/visws/visws_quirks.c: In function 'startup_pi=
ix4_master_irq':
        arch/x86/platform/visws/visws_quirks.c:474: warning: no return =
statement in function returning non-void
        arch/x86/platform/visws/visws_quirks.c: At top level:
        arch/x86/platform/visws/visws_quirks.c:495: error: unknown fiel=
d 'mask' specified in initializer
        arch/x86/platform/visws/visws_quirks.c:495: warning: initializa=
tion from incompatible pointer type
        arch/x86/platform/visws/visws_quirks.c: In function 'set_piix4_=
virtual_irq_type':
        arch/x86/platform/visws/visws_quirks.c:583: error: 'struct irq_=
chip' has no member named 'enable'
        arch/x86/platform/visws/visws_quirks.c:583: error: 'struct irq_=
chip' has no member named 'unmask'
        arch/x86/platform/visws/visws_quirks.c:584: error: 'struct irq_=
chip' has no member named 'disable'
        arch/x86/platform/visws/visws_quirks.c:584: error: 'struct irq_=
chip' has no member named 'mask'
        arch/x86/platform/visws/visws_quirks.c:585: error: 'struct irq_=
chip' has no member named 'unmask'
        arch/x86/platform/visws/visws_quirks.c:585: error: 'struct irq_=
chip' has no member named 'unmask'
        arch/x86/platform/visws/visws_quirks.c: In function 'visws_pre_=
intr_init':
        arch/x86/platform/visws/visws_quirks.c:602: error: expected exp=
ression before '>' token
        make[4]: *** [arch/x86/platform/visws/visws_quirks.o] Error 1

Ian

8<--------

=46rom db0ae26f479306ee8ebcfe2a08aa56a6dfe63987 Mon Sep 17 00:00:00 200=
1
=46rom: Ian Campbell <ian.campbell@citrix.com>
Date: Mon, 4 Apr 2011 10:27:47 +0100
Subject: [PATCH] xen: drop anti-dependency on X86_VISWS

This seems to have been added in f0f32fccbffa to avoid a conflict arisi=
ng from
the long deceased ARCH_SETUP() macro and subsequently pushed down to th=
e XEN
option.

As far as I can tell the conflict is no longer present and by dropping =
the
dependency I was able to build a kernel which has both CONFIG_XEN and
CONFIG_X86_VISWS enabled and boot it on Xen. I didn't try it on the VIS=
WS
platform.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: konrad.wilk@oracle.com
Cc: xen-devel@lists.xensource.com
Cc: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Andrey Panin <pazke@donpac.ru>
Cc: linux-visws-devel@lists.sf.net
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
---
 arch/x86/xen/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/x86/xen/Kconfig b/arch/x86/xen/Kconfig
index 1c7121b..65d7b13 100644
--- a/arch/x86/xen/Kconfig
+++ b/arch/x86/xen/Kconfig
@@ -6,7 +6,7 @@ config XEN
 	bool "Xen guest support"
 	select PARAVIRT
 	select PARAVIRT_CLOCK
-	depends on X86_64 || (X86_32 && X86_PAE && !X86_VISWS)
+	depends on X86_64 || (X86_32 && X86_PAE)
 	depends on X86_CMPXCHG && X86_TSC
 	help
 	  This is the Linux Xen port.  Enabling this will allow the
--=20
1.7.2.5




