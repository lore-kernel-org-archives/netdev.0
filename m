From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 28/28] Kbuild: bring back -Wmaybe-uninitialized warning
Date: Tue, 18 Oct 2016 00:19:11 +0200
Message-ID: <20161017222000.1934898-1-arnd@arndb.de>
References: <20161017220342.1627073-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Heiko Carstens <heiko.carstens@de.ibm.com>, dri-devel@lists.freedesktop.org,
 linux-mtd@lists.infradead.org, Ingo Molnar <mingo@kernel.org>,
 linux-s390@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
 x86@kernel.org, Christian Borntraeger <borntraeger@de.ibm.com>,
 Ilya Dryomov <idryomov@gmail.com>, linux-ext4@vger.kernel.org,
 linux-media@vger.kernel.org, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, linux-kbuild@vger.kernel.org,
 Josh Poimboeuf <jpoimboe@redhat.com>, ceph-devel@vger.kernel.org,
 Mauro Carvalho Chehab <mchehab@kernel.org>, linux-snps-arc@lists.infradead.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-f2fs-devel@lists.sourceforge.net, netfilter-devel@vger.kernel.org,
 linux-crypto@vger.kernel.org, Vineet Gupta <vgupta@synops
To: Linus Torvalds <torvalds@linux-foundation.org>,
 Michal Marek <mmarek@suse.com>
Return-path: <linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org>
In-Reply-To: <20161017220342.1627073-1-arnd@arndb.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-snps-arc/>
List-Post: <mailto:linux-snps-arc@lists.infradead.org>
List-Help: <mailto:linux-snps-arc-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=subscribe>
Sender: "linux-snps-arc" <linux-snps-arc-bounces@lists.infradead.org>
Errors-To: linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Traditionally, we have always had warnings about uninitialized variables
enabled, as this is part of -Wall, and generally a good idea [1], but it
also always produced false positives, mainly because this is a variation
of the halting problem and provably impossible to get right in all cases
[2].

Various people have identified cases that are particularly bad for false
positives, and in commit e74fc973b6e5 ("Turn off -Wmaybe-uninitialized
when building with -Os"), I turned off the warning for any build that
was done with CC_OPTIMIZE_FOR_SIZE.  This drastically reduced the number
of false positive warnings in the default build but unfortunately had
the side effect of turning the warning off completely in 'allmodconfig'
builds, which in turn led to a lot of warnings (both actual bugs, and
remaining false positives) to go in unnoticed.

With commit 877417e6ffb9 ("Kbuild: change CC_OPTIMIZE_FOR_SIZE
definition") enabled the warning again for allmodconfig builds in v4.7
and in v4.8-rc1, I had finally managed to address all warnings I get in
an ARM allmodconfig build and most other maybe-uninitialized warnings
for ARM randconfig builds.

However, commit 6e8d666e9253 ("Disable "maybe-uninitialized" warning
globally") was merged at the same time and disabled it completely for
all configurations, because of false-positive warnings on x86 that
I had not addressed until then. This caused a lot of actual bugs to
get merged into mainline, and I sent several dozen patches for these
during the v4.9 development cycle. Most of these are actual bugs,
some are for correct code that is safe because it is only called
under external constraints that make it impossible to run into
the case that gcc sees, and in a few cases gcc is just stupid and
finds something that can obviously never happen.

I have now done a few thousand randconfig builds on x86 and collected
all patches that I needed to address every single warning I got
(I can provide the combined patch for the other warnings if anyone
is interested), so I hope we can get the warning back and let people
catch the actual bugs earlier.

Note that the majority of the patches I created are for the third kind
of problem (stupid false-positives), for one of two reasons:
- some of them only get triggered in certain combinations of config
  options, so we don't always run into them, and
- the actual bugs tend to get addressed much quicker as they also
  lead to incorrect runtime behavior.

These 27 patches address the warnings that either occur in one of the more
common configurations (defconfig, allmodconfig, or something built by the
kbuild robot or kernelci.org), or they are about a real bug. It would be
good to get these all into v4.9 if we want to turn on the warning again.
I have tested these extensively with gcc-4.9 and gcc-6 and done a bit
of testing with gcc-5, and all of these should now be fine. gcc-4.8
is much worse about the false-positive warnings and is also fairly old
now, so I'm leaving the warning disabled with that version. gcc-4.7 and
older don't understand the -Wno-maybe-uninitialized option and are not
affected by this patch either way.

I have another (smaller) series of patches for warnings that are both
harmless and not as easy to trigger, and I will send them for inclusion
in v4.10.

Link: https://rusty.ozlabs.org/?p=232 [1]
Link: https://gcc.gnu.org/wiki/Better_Uninitialized_Warnings [2]
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 Makefile               | 10 ++++++----
 arch/arc/Makefile      |  4 +++-
 scripts/Makefile.ubsan |  4 ++++
 3 files changed, 13 insertions(+), 5 deletions(-)

Cc: x86@kernel.org
Cc: linux-media@vger.kernel.org
Cc: Mauro Carvalho Chehab <mchehab@kernel.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-s390@vger.kernel.org
Cc: Ilya Dryomov <idryomov@gmail.com>
Cc: dri-devel@lists.freedesktop.org
Cc: linux-mtd@lists.infradead.org
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-crypto@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: ceph-devel@vger.kernel.org
Cc: linux-f2fs-devel@lists.sourceforge.net
Cc: linux-ext4@vger.kernel.org
Cc: netfilter-devel@vger.kernel.org

diff --git a/Makefile b/Makefile
index 512e47a..43cd3d9 100644
--- a/Makefile
+++ b/Makefile
@@ -370,7 +370,7 @@ LDFLAGS_MODULE  =
 CFLAGS_KERNEL	=
 AFLAGS_KERNEL	=
 LDFLAGS_vmlinux =
-CFLAGS_GCOV	= -fprofile-arcs -ftest-coverage -fno-tree-loop-im
+CFLAGS_GCOV	= -fprofile-arcs -ftest-coverage -fno-tree-loop-im  -Wno-maybe-uninitialized
 CFLAGS_KCOV	:= $(call cc-option,-fsanitize-coverage=trace-pc,)
 
 
@@ -620,7 +620,6 @@ ARCH_CFLAGS :=
 include arch/$(SRCARCH)/Makefile
 
 KBUILD_CFLAGS	+= $(call cc-option,-fno-delete-null-pointer-checks,)
-KBUILD_CFLAGS	+= $(call cc-disable-warning,maybe-uninitialized,)
 KBUILD_CFLAGS	+= $(call cc-disable-warning,frame-address,)
 
 ifdef CONFIG_LD_DEAD_CODE_DATA_ELIMINATION
@@ -629,15 +628,18 @@ KBUILD_CFLAGS	+= $(call cc-option,-fdata-sections,)
 endif
 
 ifdef CONFIG_CC_OPTIMIZE_FOR_SIZE
-KBUILD_CFLAGS	+= -Os
+KBUILD_CFLAGS	+= -Os $(call cc-disable-warning,maybe-uninitialized,)
 else
 ifdef CONFIG_PROFILE_ALL_BRANCHES
-KBUILD_CFLAGS	+= -O2
+KBUILD_CFLAGS	+= -O2 $(call cc-disable-warning,maybe-uninitialized,)
 else
 KBUILD_CFLAGS   += -O2
 endif
 endif
 
+KBUILD_CFLAGS += $(call cc-ifversion, -lt, 0409, \
+			$(call cc-disable-warning,maybe-uninitialized,))
+
 # Tell gcc to never replace conditional load with a non-conditional one
 KBUILD_CFLAGS	+= $(call cc-option,--param=allow-store-data-races=0)
 
diff --git a/arch/arc/Makefile b/arch/arc/Makefile
index aa82d13..19cce22 100644
--- a/arch/arc/Makefile
+++ b/arch/arc/Makefile
@@ -71,7 +71,9 @@ cflags-$(CONFIG_ARC_DW2_UNWIND)		+= -fasynchronous-unwind-tables $(cfi)
 ifndef CONFIG_CC_OPTIMIZE_FOR_SIZE
 # Generic build system uses -O2, we want -O3
 # Note: No need to add to cflags-y as that happens anyways
-ARCH_CFLAGS += -O3
+#
+# Disable the false maybe-uninitialized warings gcc spits out at -O3
+ARCH_CFLAGS += -O3 $(call cc-disable-warning,maybe-uninitialized,)
 endif
 
 # small data is default for elf32 tool-chain. If not usable, disable it
diff --git a/scripts/Makefile.ubsan b/scripts/Makefile.ubsan
index dd779c4..3b1b138 100644
--- a/scripts/Makefile.ubsan
+++ b/scripts/Makefile.ubsan
@@ -17,4 +17,8 @@ endif
 ifdef CONFIG_UBSAN_NULL
       CFLAGS_UBSAN += $(call cc-option, -fsanitize=null)
 endif
+
+      # -fsanitize=* options makes GCC less smart than usual and
+      # increase number of 'maybe-uninitialized false-positives
+      CFLAGS_UBSAN += $(call cc-option, -Wno-maybe-uninitialized)
 endif
-- 
2.9.0
