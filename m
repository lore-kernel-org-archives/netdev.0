From: "David S. Miller" <davem@redhat.com>
Subject: Re: e100 "Ferguson" release
Date: Tue, 5 Aug 2003 00:16:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030805001631.2fb55f38.davem@redhat.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010222929E@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010222929E@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 4 Aug 2003 20:45:08 -0700
"Feldman, Scott" <scott.feldman@intel.com> wrote:

> > * I would love to see feedback from people testing this 
> > driver on ppc64 and sparc64, particularly.
> 
> Me too.  Things seem to work on ppc (Mac) and ia64.

This gets things building on sparc64, I'll stick an e100
into my workstation and use it for everything for a while
using this driver.

--- Makefile.~1~	2003-08-04 20:20:42.000000000 -0700
+++ Makefile	2003-08-05 00:12:29.000000000 -0700
@@ -96,10 +96,15 @@
 endif
 
 # pick a compiler
-ifneq (,$(findstring egcs-2.91.66, $(shell cat /proc/version)))
-  CC := kgcc gcc cc
+ARCH := $(shell uname -m | sed 's/i.86/i386/')
+ifeq ($(ARCH),sparc64)
+CC		:= $(shell if gcc -m64 -S -o /dev/null -xc /dev/null >/dev/null 2>&1; then echo gcc; else echo sparc64-linux-gcc; fi )
 else
-  CC := gcc cc
+  ifneq (,$(findstring egcs-2.91.66, $(shell cat /proc/version)))
+    CC := kgcc gcc cc
+  else
+    CC := gcc cc
+  endif
 endif
 test_cc = $(shell which $(cc) > /dev/null 2>&1 && echo $(cc))
 CC := $(foreach cc, $(CC), $(test_cc))
@@ -198,10 +203,30 @@
 
 # we need to know what platform the driver is being built on
 # some additional features are only built on Intel platforms
-ARCH := $(shell uname -m | sed 's/i.86/i386/')
 ifeq ($(ARCH),alpha)
   CFLAGS += -ffixed-8 -mno-fp-regs
 endif
+ifeq ($(ARCH),sparc64)
+  NEW_GCC := $(shell if $(CC) -m64 -mcmodel=medlow -S -o /dev/null -xc /dev/null >/dev/null 2>&1; then echo y; else echo n; fi; )
+  UNDECLARED_REGS := $(shell if $(CC) -c -x assembler /dev/null -Wa,--help | grep undeclared-regs > /dev/null; then echo y; else echo n; fi; )
+  INLINE_LIMIT := $(shell if $(CC) -m64 -finline-limit=100000 -S -o /dev/null -xc /dev/null >/dev/null 2>&1; then echo y; else echo n; fi; )
+  ifneq ($(UNDECLARED_REGS),y)
+    CC_UNDECL	=
+  else
+    CC_UNDECL	= -Wa,--undeclared-regs
+  endif
+  ifneq ($(NEW_GCC),y)
+    CFLAGS += -pipe -mno-fpu -mtune=ultrasparc -mmedlow \
+	      -ffixed-g4 -fcall-used-g5 -fcall-used-g7 -Wno-sign-compare
+  else
+    CFLAGS += -m64 -pipe -mno-fpu -mcpu=ultrasparc -mcmodel=medlow \
+	      -ffixed-g4 -fcall-used-g5 -fcall-used-g7 -Wno-sign-compare \
+	      $(CC_UNDECL)
+  endif
+  ifeq ($(INLINE_LIMIT),y)
+    CFLAGS := $(CFLAGS) -finline-limit=100000
+  endif
+endif
 
 # depmod version for rpm builds
 DEPVER := $(shell /sbin/depmod -V 2>/dev/null | awk 'BEGIN {FS="."} NR==1 {print $$2}')
--- e100.c.~1~	2003-08-04 20:20:42.000000000 -0700
+++ e100.c	2003-08-05 00:13:23.000000000 -0700
@@ -150,6 +150,7 @@
 #include <linux/ethtool.h>
 #include <asm/unaligned.h>
 #include <asm/uaccess.h>
+#include <asm/io.h>
 
 #include "kcompat.h"
 
