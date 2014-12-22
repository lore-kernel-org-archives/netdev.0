From: Huacai Chen <chenhc@lemote.com>
Subject: [PATCH 2/2] MIPS: Hibernate: Restructure files and functions
Date: Mon, 22 Dec 2014 10:28:16 +0800
Message-ID: <1419215296-27831-2-git-send-email-chenhc@lemote.com>
References: <1419215296-27831-1-git-send-email-chenhc@lemote.com>
Cc: Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Huacai Chen <chenhc@lemote.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:49657 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753797AbaLVC3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 21:29:52 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so4898683pde.15
        for <netdev@vger.kernel.org>; Sun, 21 Dec 2014 18:29:51 -0800 (PST)
In-Reply-To: <1419215296-27831-1-git-send-email-chenhc@lemote.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch has no functional changes, it just to keep the assembler
code to a minimum. Files and functions naming is borrowed from X86.

Signed-off-by: Huacai Chen <chenhc@lemote.com>
---
 arch/mips/power/Makefile                         |    2 +-
 arch/mips/power/hibernate.c                      |   10 ++++++++++
 arch/mips/power/{hibernate.S => hibernate_asm.S} |    6 ++----
 3 files changed, 13 insertions(+), 5 deletions(-)
 create mode 100644 arch/mips/power/hibernate.c
 rename arch/mips/power/{hibernate.S => hibernate_asm.S} (90%)

diff --git a/arch/mips/power/Makefile b/arch/mips/power/Makefile
index 73d56b8..70bd788 100644
--- a/arch/mips/power/Makefile
+++ b/arch/mips/power/Makefile
@@ -1 +1 @@
-obj-$(CONFIG_HIBERNATION) += cpu.o hibernate.o
+obj-$(CONFIG_HIBERNATION) += cpu.o hibernate.o hibernate_asm.o
diff --git a/arch/mips/power/hibernate.c b/arch/mips/power/hibernate.c
new file mode 100644
index 0000000..19a9af6
--- /dev/null
+++ b/arch/mips/power/hibernate.c
@@ -0,0 +1,10 @@
+#include <asm/tlbflush.h>
+
+extern int restore_image(void);
+
+int swsusp_arch_resume(void)
+{
+	/* Avoid TLB mismatch during and after kernel resume */
+	local_flush_tlb_all();
+	return restore_image();
+}
diff --git a/arch/mips/power/hibernate.S b/arch/mips/power/hibernate_asm.S
similarity index 90%
rename from arch/mips/power/hibernate.S
rename to arch/mips/power/hibernate_asm.S
index e7567c8..b1fab95 100644
--- a/arch/mips/power/hibernate.S
+++ b/arch/mips/power/hibernate_asm.S
@@ -29,9 +29,7 @@ LEAF(swsusp_arch_suspend)
 	j swsusp_save
 END(swsusp_arch_suspend)
 
-LEAF(swsusp_arch_resume)
-	/* Avoid TLB mismatch during and after kernel resume */
-	jal local_flush_tlb_all
+LEAF(restore_image)
 	PTR_L t0, restore_pblist
 0:
 	PTR_L t1, PBE_ADDRESS(t0)   /* source */
@@ -60,4 +58,4 @@ LEAF(swsusp_arch_resume)
 	PTR_L s7, PT_R23(t0)
 	PTR_LI v0, 0x0
 	jr ra
-END(swsusp_arch_resume)
+END(restore_image)
-- 
1.7.7.3
