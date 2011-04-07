From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH] xen: drop anti-dependency on X86_VISWS
Date: Thu, 7 Apr 2011 07:58:03 +0100
Message-ID: <1302159483.31620.36.camel@localhost.localdomain>
References: <1301828839.2837.143.camel@edumazet-laptop>
	 <20110403.172407.91341067.davem@davemloft.net>
	 <1301910955.23887.75.camel@zakaz.uk.xensource.com>
	 <20110406.144515.235693855.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"mirq-linux@rere.qmqm.pl" <mirq-linux@rere.qmqm.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeremy Fitzhardinge <Jeremy.Fitzhardinge@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"randy.dunlap@oracle.com" <randy.dunlap@oracle.com>,
	"pazke@donpac.ru" <pazke@donpac.ru>,
	"linux-visws-devel@lists.sf.net" <linux-visws-devel@lists.sf.net>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:18761 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186Ab1DGG6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 02:58:06 -0400
In-Reply-To: <20110406.144515.235693855.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-06 at 22:45 +0100, David Miller wrote:
> From: Ian Campbell <Ian.Campbell@eu.citrix.com>
> Date: Mon, 4 Apr 2011 10:55:55 +0100
> 
> > You mean the "!X86_VISWS" I presume? It doesn't make sense to me either.
> 
> No, I think 32-bit x86 allmodconfig elides XEN because of it's X86_TSC dependency.

TSC is a real dependency of the Xen interfaces.

> And, well, you could type "make allmodconfig" on your tree and see for
> yourself instead of asking me :-)

True.

X86_TSC not being enabled appears to due to CONFIG_ELAN being enabled
which causes the processor selection option (which defaults to M686,
which is a sane choice and enables TSC etc) to be gated at the top level
in arch/x86/Kconfig.cpu. Disabling the ELAN option then leaves X86_TSC
gated on !CONFIG_NUMAQ but removing that results in a generally useful
looking config.

It's a shame that these sorts of minority options cause allmodconfig to
omit support for more interesting configurations, such as modern
processors. Other than negating the semantics of such options I'm not
really sure what can be done about it though. On the other hand
compiling all the unusual stuff in an allmodconfig is probably a
positive thing.

I'm not sure why ELAN belongs in the EXTENDED_PLATFORM option space
rather than in the CPU choice option, since its only impact seems to be
on -march, MODULE_PROC_FAMILY and some cpufreq drivers which doesn't
sound like an extended platform to me but does it appear to be
deliberate (see 9e111f3e167a "x86: move ELAN to the
NON_STANDARD_PLATFORM section", that was the old name for
EXTENDED_PLATFORM).

Hrm, what about the following? (doesn't actually make a difference to
Xen since allmodconfig chooses HIGHMEM4G instead of HIGHMEM64G in the !
NUMAQ case but I stopped worrying about that several paragraphs ago)

8<--------

x86: invert X86_EXTENDED_PLATFORM to X86_STANDARD_PLATFORM

Having the =y choice be the more "standard" configuration causes
all*config to provide greater coverage of usual configurations.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index cc6c53a..6d8a404 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -299,15 +299,15 @@ config X86_BIGSMP
 	  This option is needed for the systems that have more than 8 CPUs
 
 if X86_32
-config X86_EXTENDED_PLATFORM
-	bool "Support for extended (non-PC) x86 platforms"
+config X86_STANDARD_PLATFORM
+	bool "Restrict support to standard (PC) x86 platforms"
 	default y
 	---help---
-	  If you disable this option then the kernel will only support
+	  If you enable this option then the kernel will only support
 	  standard PC platforms. (which covers the vast majority of
 	  systems out there.)
 
-	  If you enable this option then you'll be able to select support
+	  If you disable this option then you'll be able to select support
 	  for the following (non-PC) 32 bit x86 platforms:
 		AMD Elan
 		NUMAQ (IBM/Sequent)
@@ -318,25 +318,25 @@ config X86_EXTENDED_PLATFORM
 		Moorestown MID devices
 
 	  If you have one of these systems, or if you want to build a
-	  generic distribution kernel, say Y here - otherwise say N.
+	  generic distribution kernel, say N here - otherwise say Y.
 endif
 
 if X86_64
-config X86_EXTENDED_PLATFORM
-	bool "Support for extended (non-PC) x86 platforms"
+config X86_STANDARD_PLATFORM
+	bool "Restrict support to standard (PC) x86 platforms"
 	default y
 	---help---
-	  If you disable this option then the kernel will only support
+	  If you enable this option then the kernel will only support
 	  standard PC platforms. (which covers the vast majority of
 	  systems out there.)
 
-	  If you enable this option then you'll be able to select support
+	  If you disable this option then you'll be able to select support
 	  for the following (non-PC) 64 bit x86 platforms:
 		ScaleMP vSMP
 		SGI Ultraviolet
 
 	  If you have one of these systems, or if you want to build a
-	  generic distribution kernel, say Y here - otherwise say N.
+	  generic distribution kernel, say N here - otherwise say Y.
 endif
 # This is an alphabetically sorted list of 64 bit extended platforms
 # Please maintain the alphabetic order if and when there are additions
@@ -346,7 +346,7 @@ config X86_VSMP
 	select PARAVIRT_GUEST
 	select PARAVIRT
 	depends on X86_64 && PCI
-	depends on X86_EXTENDED_PLATFORM
+	depends on !X86_STANDARD_PLATFORM
 	---help---
 	  Support for ScaleMP vSMP systems.  Say 'Y' here if this kernel is
 	  supposed to run on these EM64T-based machines.  Only choose this option
@@ -355,7 +355,7 @@ config X86_VSMP
 config X86_UV
 	bool "SGI Ultraviolet"
 	depends on X86_64
-	depends on X86_EXTENDED_PLATFORM
+	depends on !X86_STANDARD_PLATFORM
 	depends on NUMA
 	depends on X86_X2APIC
 	---help---
@@ -368,7 +368,7 @@ config X86_UV
 config X86_ELAN
 	bool "AMD Elan"
 	depends on X86_32
-	depends on X86_EXTENDED_PLATFORM
+	depends on !X86_STANDARD_PLATFORM
 	---help---
 	  Select this for an AMD Elan processor.
 
@@ -381,7 +381,7 @@ config X86_INTEL_CE
 	depends on PCI
 	depends on PCI_GODIRECT
 	depends on X86_32
-	depends on X86_EXTENDED_PLATFORM
+	depends on !X86_STANDARD_PLATFORM
 	select X86_REBOOTFIXUPS
 	select OF
 	select OF_EARLY_FLATTREE
@@ -395,7 +395,7 @@ config X86_MRST
 	depends on PCI
 	depends on PCI_GOANY
 	depends on X86_32
-	depends on X86_EXTENDED_PLATFORM
+	depends on !X86_STANDARD_PLATFORM
 	depends on X86_IO_APIC
 	select APB_TIMER
 	select I2C
@@ -413,7 +413,7 @@ config X86_MRST
 config X86_RDC321X
 	bool "RDC R-321x SoC"
 	depends on X86_32
-	depends on X86_EXTENDED_PLATFORM
+	depends on !X86_STANDARD_PLATFORM
 	select M486
 	select X86_REBOOTFIXUPS
 	---help---
@@ -424,7 +424,7 @@ config X86_RDC321X
 config X86_32_NON_STANDARD
 	bool "Support non-standard 32-bit SMP architectures"
 	depends on X86_32 && SMP
-	depends on X86_EXTENDED_PLATFORM
+	depends on !X86_STANDARD_PLATFORM
 	---help---
 	  This option compiles in the NUMAQ, Summit, bigsmp, ES7000, default
 	  subarchitectures.  It is intended for a generic binary kernel.


