From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] sparc: Split BPF JIT into 32-bit and
 64-bit.
Date: Tue, 18 Apr 2017 15:35:40 -0400 (EDT)
Message-ID: <20170418.153540.1247763490407348437.davem@davemloft.net>
References: <20170418.145806.845080704857445577.davem@davemloft.net>
        <20170418193157.GA29862@ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org, ast@kernel.org,
        daniel@iogearbox.net
To: sam@ravnborg.org
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170418193157.GA29862@ravnborg.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sam Ravnborg <sam@ravnborg.org>
Date: Tue, 18 Apr 2017 21:31:57 +0200

> On Tue, Apr 18, 2017 at 02:58:06PM -0400, David Miller wrote:
>> 
>> This is in preparation for adding the 64-bit eBPF JIT.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
>>  arch/sparc/net/Makefile          |   2 +-
>>  arch/sparc/net/bpf_jit.h         |  68 ----
>>  arch/sparc/net/bpf_jit_32.h      |  68 ++++
>>  arch/sparc/net/bpf_jit_asm.S     | 208 ----------
>>  arch/sparc/net/bpf_jit_asm_32.S  | 208 ++++++++++
>>  arch/sparc/net/bpf_jit_asm_64.S  |   1 +
>>  arch/sparc/net/bpf_jit_comp.c    | 815 ---------------------------------------
>>  arch/sparc/net/bpf_jit_comp_32.c | 815 +++++++++++++++++++++++++++++++++++++++
>>  arch/sparc/net/bpf_jit_comp_64.c |   1 +
>>  9 files changed, 1094 insertions(+), 1092 deletions(-)
>>  delete mode 100644 arch/sparc/net/bpf_jit.h
>>  create mode 100644 arch/sparc/net/bpf_jit_32.h
>>  delete mode 100644 arch/sparc/net/bpf_jit_asm.S
>>  create mode 100644 arch/sparc/net/bpf_jit_asm_32.S
>>  create mode 100644 arch/sparc/net/bpf_jit_asm_64.S
>>  delete mode 100644 arch/sparc/net/bpf_jit_comp.c
>>  create mode 100644 arch/sparc/net/bpf_jit_comp_32.c
>>  create mode 100644 arch/sparc/net/bpf_jit_comp_64.c
> 
> Adding options "-M -C" to git format-patch would have helped readability
> of this patch.
> As it is now we cannot see what changes were made to the varoious files
> when they were renamed.
> 
> (I trust you have made no irrelevant but wanted to mention it anyway)

My bad, I'll remember to do this next time:

Since it's so small, here it is for reference:

====================
>From c651a5d37afed8461adc3f2824cae1d7facd2e7a Mon Sep 17 00:00:00 2001
From: "David S. Miller" <davem@davemloft.net>
Date: Mon, 17 Apr 2017 18:25:07 -0700
Subject: [PATCH 1/2] sparc: Split BPF JIT into 32-bit and 64-bit.

This is in preparation for adding the 64-bit eBPF JIT.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/net/Makefile                              | 2 +-
 arch/sparc/net/{bpf_jit.h => bpf_jit_32.h}           | 0
 arch/sparc/net/{bpf_jit_asm.S => bpf_jit_asm_32.S}   | 2 +-
 arch/sparc/net/bpf_jit_asm_64.S                      | 1 +
 arch/sparc/net/{bpf_jit_comp.c => bpf_jit_comp_32.c} | 2 +-
 arch/sparc/net/bpf_jit_comp_64.c                     | 1 +
 6 files changed, 5 insertions(+), 3 deletions(-)
 rename arch/sparc/net/{bpf_jit.h => bpf_jit_32.h} (100%)
 rename arch/sparc/net/{bpf_jit_asm.S => bpf_jit_asm_32.S} (99%)
 create mode 100644 arch/sparc/net/bpf_jit_asm_64.S
 rename arch/sparc/net/{bpf_jit_comp.c => bpf_jit_comp_32.c} (99%)
 create mode 100644 arch/sparc/net/bpf_jit_comp_64.c

diff --git a/arch/sparc/net/Makefile b/arch/sparc/net/Makefile
index 1306a58..76fa8e9 100644
--- a/arch/sparc/net/Makefile
+++ b/arch/sparc/net/Makefile
@@ -1,4 +1,4 @@
 #
 # Arch-specific network modules
 #
-obj-$(CONFIG_BPF_JIT) += bpf_jit_asm.o bpf_jit_comp.o
+obj-$(CONFIG_BPF_JIT) += bpf_jit_asm_$(BITS).o bpf_jit_comp_$(BITS).o
diff --git a/arch/sparc/net/bpf_jit.h b/arch/sparc/net/bpf_jit_32.h
similarity index 100%
rename from arch/sparc/net/bpf_jit.h
rename to arch/sparc/net/bpf_jit_32.h
diff --git a/arch/sparc/net/bpf_jit_asm.S b/arch/sparc/net/bpf_jit_asm_32.S
similarity index 99%
rename from arch/sparc/net/bpf_jit_asm.S
rename to arch/sparc/net/bpf_jit_asm_32.S
index 8c83f4b..5632cdc 100644
--- a/arch/sparc/net/bpf_jit_asm.S
+++ b/arch/sparc/net/bpf_jit_asm_32.S
@@ -1,6 +1,6 @@
 #include <asm/ptrace.h>
 
-#include "bpf_jit.h"
+#include "bpf_jit_32.h"
 
 #ifdef CONFIG_SPARC64
 #define SAVE_SZ		176
diff --git a/arch/sparc/net/bpf_jit_asm_64.S b/arch/sparc/net/bpf_jit_asm_64.S
new file mode 100644
index 0000000..6fb023f
--- /dev/null
+++ b/arch/sparc/net/bpf_jit_asm_64.S
@@ -0,0 +1 @@
+#include "bpf_jit_asm_32.S"
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp_32.c
similarity index 99%
rename from arch/sparc/net/bpf_jit_comp.c
rename to arch/sparc/net/bpf_jit_comp_32.c
index a6d9204..83fc41d 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp_32.c
@@ -8,7 +8,7 @@
 #include <asm/cacheflush.h>
 #include <asm/ptrace.h>
 
-#include "bpf_jit.h"
+#include "bpf_jit_32.h"
 
 int bpf_jit_enable __read_mostly;
 
diff --git a/arch/sparc/net/bpf_jit_comp_64.c b/arch/sparc/net/bpf_jit_comp_64.c
new file mode 100644
index 0000000..49b5f65
--- /dev/null
+++ b/arch/sparc/net/bpf_jit_comp_64.c
@@ -0,0 +1 @@
+#include "bpf_jit_comp_32.c"
-- 
2.1.2.532.g19b5d50

