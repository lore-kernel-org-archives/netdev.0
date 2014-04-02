From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] sh: add missing fpscr_values
Date: Tue,  1 Apr 2014 19:54:04 -0700
Message-ID: <1396407244-26771-1-git-send-email-ast@plumgrid.com>
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Paul Mundt <lethal@linux-sh.org>,
	Fengguang Wu <fengguang.wu@intel.com>,
	linux-sh@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

GCC on SuperH for the following program:
int foo(int i)
{
	static const void *table[2] = {
		[0] = &&label1,
		[1] = &&label2,
	};
	goto *table[i & 1];

	label1:
		return 1;
	label2:
		return 2;
}
generates code:
	mov.l   .L9,r1
	mov     #1,r0
	rts
	lds.l   @r1+,fpscr
.L9:
	.long   __fpscr_values+4

so kernel has to provide body of fpscr_values just like glibc does

Fixes: bd4cf0ed331a ("net: filter: rework/optimize internal BPF interpreter's instruction set")
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
---

kernel modules can hit the same problem, so export it

 arch/sh/lib/Makefile       |    2 +-
 arch/sh/lib/fpscr_values.c |    4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)
 create mode 100644 arch/sh/lib/fpscr_values.c

diff --git a/arch/sh/lib/Makefile b/arch/sh/lib/Makefile
index 3baff31e58cf..0d0c7ae21cfe 100644
--- a/arch/sh/lib/Makefile
+++ b/arch/sh/lib/Makefile
@@ -8,7 +8,7 @@ lib-y  = delay.o memmove.o memchr.o \
 # Extracted from libgcc
 obj-y += movmem.o ashldi3.o ashrdi3.o lshrdi3.o \
 	 ashlsi3.o ashrsi3.o ashiftrt.o lshrsi3.o \
-	 udiv_qrnnd.o
+	 udiv_qrnnd.o fpscr_values.o
 
 udivsi3-y			:= udivsi3_i4i-Os.o
 
diff --git a/arch/sh/lib/fpscr_values.c b/arch/sh/lib/fpscr_values.c
new file mode 100644
index 000000000000..58153272aba1
--- /dev/null
+++ b/arch/sh/lib/fpscr_values.c
@@ -0,0 +1,4 @@
+#include <linux/module.h>
+
+long __fpscr_values[2] = { 0L, 0x80000L };
+EXPORT_SYMBOL(__fpscr_values);
-- 
1.7.9.5

