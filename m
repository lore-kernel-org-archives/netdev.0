From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH/RFC v4] introduce HAVE_UNALIGNED_ACCESS_SUPPORT Kconfig
	symbol
Date: Thu, 20 Mar 2008 20:50:58 +0100
Message-ID: <1206042658.16475.158.camel@johannes.berg>
References: <1206023695.16475.137.camel@johannes.berg>
	 <20080320181310.GA17884@uranus.ravnborg.org>
	 <1206038373.16475.150.camel@johannes.berg>
	 <1206038734.16475.153.camel@johannes.berg>
	 <20080320194101.GC17884@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Linux Kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080320194101.GC17884-QabhHTsIXMSnlFQ6Q1D1Y0B+6BGkLq7r@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In many cases, especially in networking, it can be beneficial to
know at compile time whether the architecture can do unaligned
accesses. This patch introduces a new Kconfig symbol
	HAVE_UNALIGNED_ACCESS_SUPPORT
for that purpose and adds it to the powerpc and x86 architectures.
Also add some documentation about alignment and networking, and
especially one intended use of this symbol.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Acked-by: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
---
Didn't I say I was going to fix the subject? Sorry.

 Documentation/unaligned-memory-access.txt |   32 +++++++++++++++++++++++++++---
 arch/Kconfig                              |    3 ++
 arch/powerpc/Kconfig                      |    1 
 arch/x86/Kconfig                          |    1 
 4 files changed, 34 insertions(+), 3 deletions(-)

--- everything.orig/Documentation/unaligned-memory-access.txt	2008-03-20 15:30:38.000000000 +0100
+++ everything/Documentation/unaligned-memory-access.txt	2008-03-20 19:38:30.000000000 +0100
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
+made depend on CONFIG_HAVE_UNALIGNED_ACCESS_SUPPORT like so:
+
+#ifdef CONFIG_HAVE_UNALIGNED_ACCESS_SUPPORT
+	skb = original skb
+#else
+	skb = copy skb
+#endif
+
 --
-Author: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
+Authors: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
+         Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
 With help from: Alan Cox, Avuton Olrich, Heikki Orsila, Jan Engelhardt,
-Johannes Berg, Kyle McMartin, Kyle Moffett, Randy Dunlap, Robert Hancock,
-Uli Kunitz, Vadim Lobanov
+Kyle McMartin, Kyle Moffett, Randy Dunlap, Robert Hancock, Uli Kunitz,
+Vadim Lobanov
 
--- everything.orig/arch/powerpc/Kconfig	2008-03-20 15:30:38.000000000 +0100
+++ everything/arch/powerpc/Kconfig	2008-03-20 19:37:22.000000000 +0100
@@ -91,6 +91,7 @@ config PPC
 	select HAVE_OPROFILE
 	select HAVE_KPROBES
 	select HAVE_KRETPROBES
+	select HAVE_UNALIGNED_ACCESS_SUPPORT
 
 config EARLY_PRINTK
 	bool
--- everything.orig/arch/x86/Kconfig	2008-03-20 15:30:38.000000000 +0100
+++ everything/arch/x86/Kconfig	2008-03-20 19:38:08.000000000 +0100
@@ -23,6 +23,7 @@ config X86
 	select HAVE_KPROBES
 	select HAVE_KRETPROBES
 	select HAVE_KVM if ((X86_32 && !X86_VOYAGER && !X86_VISWS && !X86_NUMAQ) || X86_64)
+	select HAVE_UNALIGNED_ACCESS_SUPPORT
 
 
 config GENERIC_LOCKBREAK
--- everything.orig/arch/Kconfig	2008-03-20 19:37:26.000000000 +0100
+++ everything/arch/Kconfig	2008-03-20 19:37:34.000000000 +0100
@@ -36,3 +36,6 @@ config HAVE_KPROBES
 
 config HAVE_KRETPROBES
 	def_bool n
+
+config HAVE_UNALIGNED_ACCESS_SUPPORT
+	def_bool n


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
