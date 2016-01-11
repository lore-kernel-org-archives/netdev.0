From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 09/53] perf: bpf: Fix build breakage due to libbpf
Date: Mon, 11 Jan 2016 13:48:00 +0000
Message-ID: <1452520124-2073-10-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>,
	"Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
	Wang Nan <wangnan0@huawei.com>,
	"Sukadev Bhattiprolu" <sukadev@linux.vnet.ibm.com>
To: <acme@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:41441 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760084AbcAKNtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 08:49:52 -0500
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>

perf build is currently (v4.4-rc5) broken on powerpc:

bpf.c:28:4: error: #error __NR_bpf not defined. libbpf does not support
your arch.
 #  error __NR_bpf not defined. libbpf does not support your arch.
    ^

Fix this by including tools/scripts/Makefile.arch for the proper
$ARCH macro. While at it, remove redundant LP64 macro definition.

Also, since libbpf require $(srctree) now, detect the path of
srctree like perf.

Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
Signed-off-by: Wang Nan <wangnan0@huawei.com>
[Use tools/scripts/Makefile.arch]
Acked-by: Jiri Olsa <jolsa@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 tools/lib/bpf/Makefile | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/tools/lib/bpf/Makefile b/tools/lib/bpf/Makefile
index 919b717..1d446a6 100644
--- a/tools/lib/bpf/Makefile
+++ b/tools/lib/bpf/Makefile
@@ -6,6 +6,12 @@ BPF_EXTRAVERSION = 1
 
 MAKEFLAGS += --no-print-directory
 
+ifeq ($(srctree),)
+srctree := $(patsubst %/,%,$(dir $(shell pwd)))
+srctree := $(patsubst %/,%,$(dir $(srctree)))
+srctree := $(patsubst %/,%,$(dir $(srctree)))
+#$(info Determined 'srctree' to be $(srctree))
+endif
 
 # Makefiles suck: This macro sets a default value of $(2) for the
 # variable named by $(1), unless the variable has been set by
@@ -31,7 +37,8 @@ INSTALL = install
 DESTDIR ?=
 DESTDIR_SQ = '$(subst ','\'',$(DESTDIR))'
 
-LP64 := $(shell echo __LP64__ | ${CC} ${CFLAGS} -E -x c - | tail -n 1)
+include $(srctree)/tools/scripts/Makefile.arch
+
 ifeq ($(LP64), 1)
   libdir_relative = lib64
 else
@@ -57,13 +64,6 @@ ifndef VERBOSE
   VERBOSE = 0
 endif
 
-ifeq ($(srctree),)
-srctree := $(patsubst %/,%,$(dir $(shell pwd)))
-srctree := $(patsubst %/,%,$(dir $(srctree)))
-srctree := $(patsubst %/,%,$(dir $(srctree)))
-#$(info Determined 'srctree' to be $(srctree))
-endif
-
 FEATURE_USER = .libbpf
 FEATURE_TESTS = libelf libelf-getphdrnum libelf-mmap bpf
 FEATURE_DISPLAY = libelf bpf
-- 
1.8.3.4
