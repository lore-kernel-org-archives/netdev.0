From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2] tc, ipt: don't enforce iproute2 dependency on iptables-devel
Date: Tue, 18 Oct 2016 14:13:09 +0200
Message-ID: <0d5bc0c0562bf9736b95d07118965a924f553479.1476792249.git.daniel@iogearbox.net>
Cc: jhs@mojatatu.com, mikko.rapeli@iki.fi, tgraf@suug.ch,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since 5cd1adba79d3 ("Update to current iptables headers") compilation
of iproute2 broke for systems without iptables-devel package [1].
Reason is that even though we fall back to build m_ipt.c, the include
depends on a xtables-version.h header, which only ships with
iptables-devel. Machines not having this package fail compilation with:

    [...]
    CC       m_ipt.o
In file included from ../include/iptables.h:5:0,
                 from m_ipt.c:17:
../include/xtables.h:34:29: fatal error: xtables-version.h: No such file or directory
compilation terminated.
../Config:31: recipe for target 'm_ipt.o' failed
make[1]: *** [m_ipt.o] Error 1

The configure script only barks that package xtables was not found in
the pkg-config search path. The generated Config then only contains f.e.
TC_CONFIG_IPSET. In tc's Makefile we thus fall back to adding m_ipt.o
to TCMODULES. m_ipt.c then includes the local include/iptables.h header
copy, which includes the include/xtables.h copy. Latter then includes
xtables-version.h, which only ships with iptables-devel.

One way to resolve this is to skip this whole mess when pkg-config has
no xtables config available. I've carried something along these lines
locally for a while now, but it's just too annyoing. :/ Build works fine
now also when xtables.pc is not available.

  [1] http://www.spinics.net/lists/netdev/msg366162.html

Fixes: 5cd1adba79d3 ("Update to current iptables headers")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 configure   | 33 ++++++++++++++++++++++++---------
 tc/Makefile | 29 ++++++++++++++---------------
 2 files changed, 38 insertions(+), 24 deletions(-)

diff --git a/configure b/configure
index 60eb6b5..c978da3 100755
--- a/configure
+++ b/configure
@@ -57,6 +57,14 @@ EOF
     rm -f $TMPDIR/atmtest.c $TMPDIR/atmtest
 }
 
+check_xtables()
+{
+	if ! ${PKG_CONFIG} xtables --exists
+	then
+		echo "TC_CONFIG_NO_XT:=y" >>Config
+	fi
+}
+
 check_xt()
 {
     #check if we have xtables from iptables >= 1.4.5.
@@ -353,18 +361,25 @@ echo "TC schedulers"
 echo -n " ATM	"
 check_atm
 
-echo -n " IPT	"
-check_xt
-check_xt_old
-check_xt_old_internal_h
-check_ipt
+check_xtables
+if ! grep -q TC_CONFIG_NO_XT Config
+then
+	echo -n " IPT	"
+	check_xt
+	check_xt_old
+	check_xt_old_internal_h
+	check_ipt
 
-echo -n " IPSET  "
-check_ipset
+	echo -n " IPSET  "
+	check_ipset
+fi
 
 echo
-echo -n "iptables modules directory: "
-check_ipt_lib_dir
+if ! grep -q TC_CONFIG_NO_XT Config
+then
+	echo -n "iptables modules directory: "
+	check_ipt_lib_dir
+fi
 
 echo -n "libc has setns: "
 check_setns
diff --git a/tc/Makefile b/tc/Makefile
index 8917eaf..dfa875b 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -69,28 +69,27 @@ TCMODULES += q_clsact.o
 TCMODULES += e_bpf.o
 TCMODULES += f_matchall.o
 
-ifeq ($(TC_CONFIG_IPSET), y)
-  ifeq ($(TC_CONFIG_XT), y)
-    TCMODULES += em_ipset.o
-  endif
-endif
-
 TCSO :=
 ifeq ($(TC_CONFIG_ATM),y)
   TCSO += q_atm.so
 endif
 
-ifeq ($(TC_CONFIG_XT),y)
-  TCSO += m_xt.so
-else
-  ifeq ($(TC_CONFIG_XT_OLD),y)
-    TCSO += m_xt_old.so
+ifneq ($(TC_CONFIG_NO_XT),y)
+  ifeq ($(TC_CONFIG_XT),y)
+    TCSO += m_xt.so
+    ifeq ($(TC_CONFIG_IPSET),y)
+      TCMODULES += em_ipset.o
+    endif
   else
-    ifeq ($(TC_CONFIG_XT_OLD_H),y)
-	CFLAGS += -DTC_CONFIG_XT_H
-	TCSO += m_xt_old.so
+    ifeq ($(TC_CONFIG_XT_OLD),y)
+      TCSO += m_xt_old.so
     else
-      TCMODULES += m_ipt.o
+      ifeq ($(TC_CONFIG_XT_OLD_H),y)
+        CFLAGS += -DTC_CONFIG_XT_H
+        TCSO += m_xt_old.so
+      else
+        TCMODULES += m_ipt.o
+      endif
     endif
   endif
 endif
-- 
1.9.3

