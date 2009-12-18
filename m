From: Michael Stone <michael@laptop.org>
Subject: [PATCH 1/3] Security: Add prctl(PR_{GET,SET}_NETWORK) interface.
	(v2)
Date: Thu, 17 Dec 2009 22:29:57 -0500
Message-ID: <20091218032957.GA23514@heat>
References: <20091218030056.GC3047@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Michael Stone <michael@laptop.org>
To: Mark Seaborn <mrs@mythic-beasts.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091218030056.GC3047@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Bernstein has observed [1] that security-conscious userland processes
may benefit from the ability to irrevocably remove their ability to create,
bind, connect to, or send messages except in the case of previously connected
sockets or AF_UNIX filesystem sockets. We provide this facility by implementing
support for a new prctl(PR_SET_NETWORK) flag named PR_NETWORK_OFF.

This facility is particularly attractive to security platforms like OLPC
Bitfrost [2] and to isolation programs like Rainbow [3] and Plash [4].

[1]: http://cr.yp.to/unix/disablenetwork.html
[2]: http://wiki.laptop.org/go/OLPC_Bitfrost
[3]: http://wiki.laptop.org/go/Rainbow
[4]: http://plash.beasts.org/

Signed-off-by: Michael Stone <michael@laptop.org>
---
  include/linux/prctl.h         |    7 +++++++
  include/linux/prctl_network.h |    7 +++++++
  include/linux/sched.h         |    2 ++
  kernel/sys.c                  |   32 ++++++++++++++++++++++++++++++++
  4 files changed, 48 insertions(+), 0 deletions(-)
  create mode 100644 include/linux/prctl_network.h

diff --git a/include/linux/prctl.h b/include/linux/prctl.h
index a3baeb2..4eb4110 100644
--- a/include/linux/prctl.h
+++ b/include/linux/prctl.h
@@ -102,4 +102,11 @@
  
  #define PR_MCE_KILL_GET 34
  
+/* Get/set process disable-network flags */
+#define PR_SET_NETWORK	35
+#define PR_GET_NETWORK	36
+# define PR_NETWORK_ON        0
+# define PR_NETWORK_OFF       1
+# define PR_NETWORK_ALL_FLAGS 1
+
  #endif /* _LINUX_PRCTL_H */
diff --git a/include/linux/prctl_network.h b/include/linux/prctl_network.h
new file mode 100644
index 0000000..2db83eb
--- /dev/null
+++ b/include/linux/prctl_network.h
@@ -0,0 +1,7 @@
+#ifndef _LINUX_PRCTL_NETWORK_H
+#define _LINUX_PRCTL_NETWORK_H
+
+extern long prctl_get_network(void);
+extern long prctl_set_network(unsigned long);
+
+#endif /* _LINUX_PRCTL_NETWORK_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5c858f3..751d372 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1395,6 +1395,8 @@ struct task_struct {
  	unsigned int sessionid;
  #endif
  	seccomp_t seccomp;
+/* Flags for limiting networking via prctl(PR_SET_NETWORK). */
+  unsigned long network;
  
  /* Thread group tracking */
     	u32 parent_exec_id;
diff --git a/kernel/sys.c b/kernel/sys.c
index 20ccfb5..411a2ff 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -35,6 +35,7 @@
  #include <linux/cpu.h>
  #include <linux/ptrace.h>
  #include <linux/fs_struct.h>
+#include <linux/prctl_network.h>
  
  #include <linux/compat.h>
  #include <linux/syscalls.h>
@@ -1576,6 +1577,12 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
  			else
  				error = PR_MCE_KILL_DEFAULT;
  			break;
+		case PR_SET_NETWORK:
+			error = prctl_set_network(arg2);
+			break;
+		case PR_GET_NETWORK:
+			error = prctl_get_network();
+			break;
  		default:
  			error = -EINVAL;
  			break;
@@ -1583,6 +1590,31 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
  	return error;
  }
  
+long prctl_get_network(void)
+{
+	return current->network;
+}
+
+long prctl_set_network(unsigned long network_flags)
+{
+	long ret;
+
+	/* only dropping access is permitted */
+	ret = -EPERM;
+        if (current->network & ~network_flags)
+		goto out;
+
+	ret = -EINVAL;
+	if (network_flags & ~PR_NETWORK_ALL_FLAGS)
+		goto out;
+
+	current->network = network_flags;
+	ret = 0;
+
+out:
+	return ret;
+}
+
  SYSCALL_DEFINE3(getcpu, unsigned __user *, cpup, unsigned __user *, nodep,
  		struct getcpu_cache __user *, unused)
  {
-- 
1.6.6.rc1
