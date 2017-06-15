From: David Daney <david.daney@cavium.com>
Subject: [PATCH RFC 3/3] MIPS: Include file changes to enable building BPF code with llvm
Date: Thu, 15 Jun 2017 15:35:43 -0700
Message-ID: <20170615223543.22867-4-david.daney@cavium.com>
References: <20170615223543.22867-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org, Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615223543.22867-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When building for the eBPF target archecture. Inline asm cannot be
used as MIPS instructions are fundamentally incompatible with eBPF
bytecode.  The preprocessor symbol __EMITTING_BPF__ is used to gate
the inclusion of inline asm in constructs used the by the BPF
programs.

Also make the Makefile symbol LINUXINCLUDE contain the
asm/mach-MACHINE directory so that the BPF compilation process can
pull in the necessary include files.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/mips/Makefile                | 1 +
 arch/mips/cavium-octeon/Platform  | 3 +++
 arch/mips/include/asm/checksum.h  | 2 +-
 arch/mips/include/uapi/asm/swab.h | 2 +-
 4 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/arch/mips/Makefile b/arch/mips/Makefile
index 02a1787c888c..ca968415597f 100644
--- a/arch/mips/Makefile
+++ b/arch/mips/Makefile
@@ -247,6 +247,7 @@ entry-y				= 0x$(shell $(NM) vmlinux 2>/dev/null \
 					| grep "\bkernel_entry\b" | cut -f1 -d \ )
 
 cflags-y			+= -I$(srctree)/arch/mips/include/asm/mach-generic
+LINUXINCLUDE			+= -I$(srctree)/arch/mips/include/asm/mach-generic
 drivers-$(CONFIG_PCI)		+= arch/mips/pci/
 
 #
diff --git a/arch/mips/cavium-octeon/Platform b/arch/mips/cavium-octeon/Platform
index 45be853700e6..9ef3e4074099 100644
--- a/arch/mips/cavium-octeon/Platform
+++ b/arch/mips/cavium-octeon/Platform
@@ -4,4 +4,7 @@
 platform-$(CONFIG_CAVIUM_OCTEON_SOC)	+= cavium-octeon/
 cflags-$(CONFIG_CAVIUM_OCTEON_SOC)	+=				\
 		-I$(srctree)/arch/mips/include/asm/mach-cavium-octeon
+ifdef CONFIG_CAVIUM_OCTEON_SOC
+LINUXINCLUDE	+= -I$(srctree)/arch/mips/include/asm/mach-cavium-octeon
+endif
 load-$(CONFIG_CAVIUM_OCTEON_SOC)	+= 0xffffffff81100000
diff --git a/arch/mips/include/asm/checksum.h b/arch/mips/include/asm/checksum.h
index 77cad232a1c6..f8fff2ced216 100644
--- a/arch/mips/include/asm/checksum.h
+++ b/arch/mips/include/asm/checksum.h
@@ -12,7 +12,7 @@
 #ifndef _ASM_CHECKSUM_H
 #define _ASM_CHECKSUM_H
 
-#ifdef CONFIG_GENERIC_CSUM
+#if defined(CONFIG_GENERIC_CSUM) || defined(__EMITTING_BPF__)
 #include <asm-generic/checksum.h>
 #else
 
diff --git a/arch/mips/include/uapi/asm/swab.h b/arch/mips/include/uapi/asm/swab.h
index 23cd9b118c9e..42ed70015c70 100644
--- a/arch/mips/include/uapi/asm/swab.h
+++ b/arch/mips/include/uapi/asm/swab.h
@@ -13,7 +13,7 @@
 
 #define __SWAB_64_THRU_32__
 
-#if !defined(__mips16) &&					\
+#if !defined(__mips16) && !defined(__EMITTING_BPF__) &&			\
 	((defined(__mips_isa_rev) && (__mips_isa_rev >= 2)) ||	\
 	 defined(_MIPS_ARCH_LOONGSON3A))
 
-- 
2.11.0
