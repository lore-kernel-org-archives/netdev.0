From: Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>
Subject: [PATCH v5 3/7] fs/splice: support compiling out
	splice-family syscalls
Date: Tue, 25 Nov 2014 08:19:38 +0100
Message-ID: <1416899996-21315-4-git-send-email-pieter@boesman.nl>
References: <1416899996-21315-1-git-send-email-pieter@boesman.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Bertrand Jacquin <beber-2YnHqweIUXrk1uMJSBkQmQ@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?=E8=94=A1=E6=AD=A3=E9=BE=99?= <zhenglong.cai-TJRtMXcVgQTM1kAEIRd3EQ@public.gmane.org>,
	Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>,
	Peter Foley <pefoley2-lY0TAiDIAFlBDgjK7y7TUQ@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Xiao Guangrong <xiaoguangrong-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
	Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, Matt Turner <mattst88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"open list:FUSE: FILESYSTEM..." <fuse-devel-5NWGOfrQmneRv+LV9MX5uuRhgaa4a2kL@public.gmane.org
To: pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org
Return-path: <fuse-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1416899996-21315-1-git-send-email-pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/fuse-devel>,
	<mailto:fuse-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=fuse-devel>
List-Post: <mailto:fuse-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:fuse-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/fuse-devel>,
	<mailto:fuse-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: fuse-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Many embedded systems will not need the splice-family syscalls (splice,
vmsplice, tee and sendfile). Omitting them saves space.  This adds a new EXPERT
config option CONFIG_SYSCALL_SPLICE (default y) to support compiling them out.

The goal is to completely compile out fs/splice along with the syscalls. To
achieve this, the remaining patch-set will deal with fs/splice exports. As far
as possible, the impact on other device drivers will be minimized so as to
reduce the overal maintenance burden of CONFIG_SYSCALL_SPLICE.

The use of exported functions will be solved by transparently mocking them out
with static inlines. Uses of the exported pipe_buf_operations struct however
require direct modification in fs/fuse and net/core. The next two patches will
deal with this.

The last change required before fs/splice can be comipled out is making fs/nfsd
aware of the lacking splice support in file-systems when CONFIG_SYSCALL_SPLICE
is undefined.

The bloat benefit of this patch given a tinyconfig is:

add/remove: 0/16 grow/shrink: 2/5 up/down: 114/-3693 (-3579)
function                                     old     new   delta
splice_direct_to_actor                       348     416     +68
splice_to_pipe                               371     417     +46
splice_from_pipe_next                        107     106      -1
fdput                                         11       -     -11
signal_pending                                39      26     -13
fdget                                         56      42     -14
user_page_pipe_buf_ops                        20       -     -20
user_page_pipe_buf_steal                      25       -     -25
file_end_write                                58      29     -29
file_start_write                              68      34     -34
pipe_to_user                                  43       -     -43
wakeup_pipe_readers                           54       -     -54
do_splice_to                                  87       -     -87
ipipe_prep.part                               92       -     -92
opipe_prep.part                              119       -    -119
sys_sendfile                                 122       -    -122
sys_sendfile64                               126       -    -126
sys_vmsplice                                 137       -    -137
vmsplice_to_user                             205       -    -205
sys_tee                                      491       -    -491
do_sendfile                                  492       -    -492
vmsplice_to_pipe                             558       -    -558
sys_splice                                  1020       -   -1020

Signed-off-by: Pieter Smith <pieter-qeJ+1H9vRZbz+pZb47iToQ@public.gmane.org>
---
 fs/splice.c     |  2 ++
 init/Kconfig    | 10 ++++++++++
 kernel/sys_ni.c |  8 ++++++++
 3 files changed, 20 insertions(+)

diff --git a/fs/splice.c b/fs/splice.c
index 44b201b..7c4c695 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1316,6 +1316,7 @@ long do_splice_direct(struct file *in, loff_t *ppos, struct file *out,
 	return ret;
 }
 
+#ifdef CONFIG_SYSCALL_SPLICE
 static int splice_pipe_to_pipe(struct pipe_inode_info *ipipe,
 			       struct pipe_inode_info *opipe,
 			       size_t len, unsigned int flags);
@@ -2200,4 +2201,5 @@ COMPAT_SYSCALL_DEFINE4(sendfile64, int, out_fd, int, in_fd,
 	return do_sendfile(out_fd, in_fd, NULL, count, 0);
 }
 #endif
+#endif
 
diff --git a/init/Kconfig b/init/Kconfig
index d811d5f..dec9819 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1571,6 +1571,16 @@ config NTP
 	  system clock to an NTP server, you can disable this option to save
 	  space.
 
+config SYSCALL_SPLICE
+	bool "Enable splice/vmsplice/tee/sendfile syscalls" if EXPERT
+	default y
+	help
+	  This option enables the splice, vmsplice, tee and sendfile syscalls. These
+	  are used by applications to: move data between buffers and arbitrary file
+	  descriptors; "copy" data between buffers; or copy data from userspace into
+	  buffers. If building an embedded system where no applications use these
+	  syscalls, you can disable this option to save space.
+
 config PCI_QUIRKS
 	default y
 	bool "Enable PCI quirk workarounds" if EXPERT
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index d2f5b00..25d5551 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -170,6 +170,14 @@ cond_syscall(sys_fstat);
 cond_syscall(sys_stat);
 cond_syscall(sys_uname);
 cond_syscall(sys_olduname);
+cond_syscall(sys_vmsplice);
+cond_syscall(sys_splice);
+cond_syscall(sys_tee);
+cond_syscall(sys_sendfile);
+cond_syscall(sys_sendfile64);
+cond_syscall(compat_sys_vmsplice);
+cond_syscall(compat_sys_sendfile);
+cond_syscall(compat_sys_sendfile64);
 
 /* arch-specific weak syscall entries */
 cond_syscall(sys_pciconfig_read);
-- 
2.1.0


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
