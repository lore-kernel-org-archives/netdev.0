From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] build algorithms into the mac80211 module
Date: Thu, 26 Jun 2008 13:38:13 +0300
Message-ID: <20080626103813.GB30359@cs181140183.pp.htv.fi>
References: <20080622125553.GB22539@cs181133002.pp.htv.fi> <43e72e890806220804i347b942claae7b725231afcce@mail.gmail.com> <1214298259.8967.260.camel@johannes.berg> <20080624124311.GC16021@cs181140183.pp.htv.fi> <20080624211222.GB25892@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:36737 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753445AbYFZKkW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2008 06:40:22 -0400
Content-Disposition: inline
In-Reply-To: <20080624211222.GB25892@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2008 at 05:12:22PM -0400, John W. Linville wrote:
> On Tue, Jun 24, 2008 at 03:43:14PM +0300, Adrian Bunk wrote:
> 
> > Can we get one of either:
> > - all selected mac80211 algorithms are built into the mac80211 module or
> 
> This seems fine to me.
> 
> > - all selected mac80211 algorithms (including the default one) are in
> >   their own modules
> 
> We got here trying to avoid this one in the first place.

What about the patch below?

> John

cu
Adrian


<--  snip  -->


The old infrastructure was:
- the default algorithm is built into mac80211
- other algorithms get into their own modules

The implementation of this complicated scheme was horrible
(just look at net/mac80211/Makefile), and anyone adding a new
algorithm would most likely not get it right at his first attempt.

This patch therefore builds all enabled algorithms into the mac80211 
module.

The user interface for the rate control algorithms changes as follows:
- first the user can choose which algorithms to enable (currently only
  MAC80211_RC_PID is available)
- if more than one algorithm is enabled (currently not possible since 
  only one algorithm is present) the user then chooses the default one

Note:
- MAC80211_RC_PID is always enables for CONFIG_EMBEDDED=n

Technical changes:
- all selected algorithms get into the mac80211 module
- net/mac80211/Makefile can now become much less complicated
- support for rc80211_pid_algo.c being modular is no longer required
- this includes unexporting mesh_plink_broken

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 net/mac80211/Kconfig            |   31 +++++++++----------------------
 net/mac80211/Makefile           |   18 ++++--------------
 net/mac80211/mesh_pathtbl.c     |    1 -
 net/mac80211/rate.h             |    4 +---
 net/mac80211/rc80211_pid_algo.c |   10 ----------
 5 files changed, 14 insertions(+), 50 deletions(-)

commit 2d61eb39a63d9a4de6f4ecab85432d39d8116961
Author: Adrian Bunk <bunk@kernel.org>
Date:   Wed Jun 25 02:31:03 2008 +0300

diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index a24b459..2d5bb42 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -15,6 +15,14 @@ config MAC80211
 menu "Rate control algorithm selection"
 	depends on MAC80211 != n
 
+config MAC80211_RC_PID
+	bool "PID controller based rate control algorithm" if EMBEDDED
+	default y
+	---help---
+	  This option enables a TX rate control algorithm for
+	  mac80211 that uses a PID controller to select the TX
+	  rate.
+
 choice
 	prompt "Default rate control algorithm"
 	default MAC80211_RC_DEFAULT_PID
@@ -26,40 +34,19 @@ choice
 
 config MAC80211_RC_DEFAULT_PID
 	bool "PID controller based rate control algorithm"
-	select MAC80211_RC_PID
+	depends on MAC80211_RC_PID
 	---help---
 	  Select the PID controller based rate control as the
 	  default rate control algorithm. You should choose
 	  this unless you know what you are doing.
 
-config MAC80211_RC_DEFAULT_NONE
-	bool "No default algorithm"
-	depends on EMBEDDED
-	help
-	  Selecting this option will select no default algorithm
-	  and allow you to not build any. Do not choose this
-	  option unless you know your driver comes with another
-	  suitable algorithm.
 endchoice
 
-comment "Selecting 'y' for an algorithm will"
-comment "build the algorithm into mac80211."
-
 config MAC80211_RC_DEFAULT
 	string
 	default "pid" if MAC80211_RC_DEFAULT_PID
 	default ""
 
-config MAC80211_RC_PID
-	tristate "PID controller based rate control algorithm"
-	---help---
-	  This option enables a TX rate control algorithm for
-	  mac80211 that uses a PID controller to select the TX
-	  rate.
-
-	  Say Y or M unless you're sure you want to use a
-	  different rate control algorithm.
-
 endmenu
 
 config MAC80211_MESH
diff --git a/net/mac80211/Makefile b/net/mac80211/Makefile
index 4e5847f..268b0a7 100644
--- a/net/mac80211/Makefile
+++ b/net/mac80211/Makefile
@@ -1,13 +1,5 @@
 obj-$(CONFIG_MAC80211) += mac80211.o
 
-# objects for PID algorithm
-rc80211_pid-y := rc80211_pid_algo.o
-rc80211_pid-$(CONFIG_MAC80211_DEBUGFS) += rc80211_pid_debugfs.o
-
-# build helper for PID algorithm
-rc-pid-y := $(rc80211_pid-y)
-rc-pid-m := rc80211_pid.o
-
 # mac80211 objects
 mac80211-y := \
 	main.o \
@@ -42,10 +34,8 @@ mac80211-$(CONFIG_MAC80211_MESH) += \
 	mesh_plink.o \
 	mesh_hwmp.o
 
+# objects for PID algorithm
+rc80211_pid-y := rc80211_pid_algo.o
+rc80211_pid-$(CONFIG_MAC80211_DEBUGFS) += rc80211_pid_debugfs.o
 
-# Build rate control algorithm(s)
-CFLAGS_rc80211_pid_algo.o += -DRC80211_PID_COMPILE
-mac80211-$(CONFIG_MAC80211_RC_PID) += $(rc-pid-$(CONFIG_MAC80211_RC_PID))
-
-# Modular rate algorithms are assigned to mac80211-m - make separate modules
-obj-m += $(mac80211-m)
+mac80211-$(CONFIG_MAC80211_RC_PID) += $(rc80211_pid-y)
diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index 99c2d36..086d47f 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -264,7 +264,6 @@ void mesh_plink_broken(struct sta_info *sta)
 	}
 	rcu_read_unlock();
 }
-EXPORT_SYMBOL(mesh_plink_broken);
 
 /**
  * mesh_path_flush_by_nexthop - Deletes mesh paths if their next hop matches
diff --git a/net/mac80211/rate.h b/net/mac80211/rate.h
index 5b45f33..54aa78b 100644
--- a/net/mac80211/rate.h
+++ b/net/mac80211/rate.h
@@ -171,9 +171,7 @@ void rate_control_deinitialize(struct ieee80211_local *local);
 
 
 /* Rate control algorithms */
-#if defined(RC80211_PID_COMPILE) || \
-	(defined(CONFIG_MAC80211_RC_PID) && \
-	 !defined(CONFIG_MAC80211_RC_PID_MODULE))
+#ifdef CONFIG_MAC80211_RC_PID
 extern int rc80211_pid_init(void);
 extern void rc80211_pid_exit(void);
 #else
diff --git a/net/mac80211/rc80211_pid_algo.c b/net/mac80211/rc80211_pid_algo.c
index a849b74..68c6641 100644
--- a/net/mac80211/rc80211_pid_algo.c
+++ b/net/mac80211/rc80211_pid_algo.c
@@ -540,11 +540,6 @@ static struct rate_control_ops mac80211_rcpid = {
 #endif
 };
 
-MODULE_DESCRIPTION("PID controller based rate control algorithm");
-MODULE_AUTHOR("Stefano Brivio");
-MODULE_AUTHOR("Mattias Nissler");
-MODULE_LICENSE("GPL");
-
 int __init rc80211_pid_init(void)
 {
 	return ieee80211_rate_control_register(&mac80211_rcpid);
@@ -554,8 +549,3 @@ void rc80211_pid_exit(void)
 {
 	ieee80211_rate_control_unregister(&mac80211_rcpid);
 }
-
-#ifdef CONFIG_MAC80211_RC_PID_MODULE
-module_init(rc80211_pid_init);
-module_exit(rc80211_pid_exit);
-#endif

