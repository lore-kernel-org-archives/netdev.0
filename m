From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH/RFC] introduce ARCH_CAN_UNALIGNED_ACCESS Kconfig symbol
Date: Thu, 20 Mar 2008 15:34:55 +0100
Message-ID: <1206023695.16475.137.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:56810 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920AbYCTOfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 10:35:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In many cases, especially in networking, it can be beneficial to
know at compile time whether the architecture can do unaligned
accesses. This patch introduces a new Kconfig symbol
	ARCH_CAN_UNALIGNED_ACCESS
for that purpose and adds it to the powerpc and x86 architectures.
Also add some documentation about alignment and networking, and
especially one intended use of this symbol.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
Users will be added later, especially wireless networking can benefit.

 Documentation/unaligned-memory-access.txt |   32 +++++++++++++++++++++++++++---
 arch/powerpc/Kconfig                      |    3 ++
 arch/x86/Kconfig                          |    3 ++
 3 files changed, 35 insertions(+), 3 deletions(-)

--- everything.orig/Documentation/unaligned-memory-access.txt	2008-03-20 15:19:06.000000000 +0100
+++ everything/Documentation/unaligned-memory-access.txt	2008-03-20 15:29:13.000000000 +0100
@@ -218,9 +218,35 @@ If use of such macros is not convenient,
 where the source or destination (or both) are of type u8* or unsigned char*.
 Due to the byte-wise nature of this operation, unaligned accesses are avoided.
 
+
+Alignment vs. Networking
+========================
+
+On architectures that require aligned loads, networking requires that the IP
+header is aligned on a four-byte boundary to optimise the IP stack. For
+regular ethernet hardware, the constant NET_IP_ALIGN is used, on most
+architectures this constant has the value 2 because the normal ethernet
+header is 14 bytes long, so in order to get proper alignment one needs to
+DMA to an address that is can be expressed as 4*n + 2. One notable exception
+here is powerpc which defines NET_IP_ALIGN to 0 because DMA to unaligned
+addresses can be very expensive and dwarf the cost of unaligned loads.
+
+For some ethernet hardware that cannot DMA to unaligned addresses like
+4*n+2 or non-ethernet hardware, this can be a problem, and it is then
+required to copy the incoming frame into an aligned buffer. Because this is
+unnecessary on architectures that can do unaligned accesses, the code can be
+made depend on CONFIG_ARCH_CAN_UNALIGNED_ACCESS like so:
+
+#ifdef CONFIG_ARCH_CAN_UNALIGNED_ACCESS
+	skb = copy skb
+#else
+	skb = original skb
+#endif
+
 --
-Author: Daniel Drake <dsd@gentoo.org>
+Authors: Daniel Drake <dsd@gentoo.org>,
+         Johannes Berg <johannes@sipsolutions.net>
 With help from: Alan Cox, Avuton Olrich, Heikki Orsila, Jan Engelhardt,
-Johannes Berg, Kyle McMartin, Kyle Moffett, Randy Dunlap, Robert Hancock,
-Uli Kunitz, Vadim Lobanov
+Kyle McMartin, Kyle Moffett, Randy Dunlap, Robert Hancock, Uli Kunitz,
+Vadim Lobanov
 
--- everything.orig/arch/powerpc/Kconfig	2008-03-20 15:17:50.000000000 +0100
+++ everything/arch/powerpc/Kconfig	2008-03-20 15:19:00.000000000 +0100
@@ -84,6 +84,9 @@ config GENERIC_FIND_NEXT_BIT
 config ARCH_NO_VIRT_TO_BUS
 	def_bool PPC64
 
+config ARCH_CAN_UNALIGNED_ACCESS
+	def_bool y
+
 config PPC
 	bool
 	default y
--- everything.orig/arch/x86/Kconfig	2008-03-20 15:29:31.000000000 +0100
+++ everything/arch/x86/Kconfig	2008-03-20 15:29:49.000000000 +0100
@@ -144,6 +144,9 @@ config AUDIT_ARCH
 config ARCH_SUPPORTS_AOUT
 	def_bool y
 
+config ARCH_CAN_UNALIGNED_ACCESS
+	def_bool y
+
 # Use the generic interrupt handling code in kernel/irq/:
 config GENERIC_HARDIRQS
 	bool


