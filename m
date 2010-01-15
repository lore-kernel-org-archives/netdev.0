From: Michael Stone <michael@laptop.org>
Subject: disablenetwork (v5): Require CAP_SETPCAP to enable disablenetwork.
Date: Fri, 15 Jan 2010 03:13:08 -0500
Message-ID: <20100115081308.GA14443@heat>
References: <20100115081028.GA14004@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
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
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Pavel Machek <pavel@ucw.cz>,
	Al Viro <viro@ZenIV.linux.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754852Ab0AOIKv@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100115081028.GA14004@heat>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We implement this check by allocating a new flag bit in task_struct->network
and by propagating its semantics throughout the disablenetwork facility.

Signed-off-by: Michael Stone <michael@laptop.org>
---
  include/linux/prctl.h     |    8 +++++---
  kernel/sys.c              |   14 +++++++++++++-
  security/disablenetwork.c |   15 ++++++++-------
  3 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/include/linux/prctl.h b/include/linux/prctl.h
index 4eb4110..4fdb417 100644
--- a/include/linux/prctl.h
+++ b/include/linux/prctl.h
@@ -105,8 +105,10 @@
  /* Get/set process disable-network flags */
  #define PR_SET_NETWORK	35
  #define PR_GET_NETWORK	36
-# define PR_NETWORK_ON        0
-# define PR_NETWORK_OFF       1
-# define PR_NETWORK_ALL_FLAGS 1
+# define PR_NETWORK_ON		0
+# define PR_NETWORK_ENABLE_DN	1
+# define PR_NETWORK_OFF	2
+# define PR_NETWORK_ALL_FLAGS	3
+# define PR_NETWORK_DN_FLAGS	3
  
  #endif /* _LINUX_PRCTL_H */
diff --git a/kernel/sys.c b/kernel/sys.c
index 1fadf10..4c7ef83 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1608,7 +1608,19 @@ long prctl_set_network(unsigned long network_flags)
  	if (current->network & ~network_flags)
  		return -EPERM;
  
-	current->network = network_flags;
+	/* Only the superuser may permit a process to enable disablenetwork. */
+	if (!(current->network & PR_NETWORK_ENABLE_DN) &&
+		network_flags & PR_NETWORK_ENABLE_DN &&
+		!capable(CAP_SETPCAP))
+		return -EPERM;
+
+	/* Only dn-enabled processes may activate disablenetwork. */
+	if (!(current->network & PR_NETWORK_OFF) &&
+		network_flags & PR_NETWORK_OFF &&
+		!(current->network & PR_NETWORK_ENABLE_DN))
+		return -EPERM;
+
+	current->network |= network_flags;
  	return 0;
  }
  
diff --git a/security/disablenetwork.c b/security/disablenetwork.c
index 27b88d7..02c0150 100644
--- a/security/disablenetwork.c
+++ b/security/disablenetwork.c
@@ -19,10 +19,11 @@
  #include <net/sock.h>
  #include <linux/socket.h>
  #include <linux/disablenetwork.h>
+#include <linux/prctl.h>
  
-static inline int maybe_allow(void)
+static inline int maybe_allow(unsigned long network_flags)
  {
-	if (current->network)
+	if ((network_flags & PR_NETWORK_DN_FLAGS) == PR_NETWORK_DN_FLAGS)
  		return -EPERM;
  	return 0;
  }
@@ -32,7 +33,7 @@ int disablenetwork_security_socket_create(int family, int type,
  {
  	if (family == AF_UNIX)
  		return 0;
-	return maybe_allow();
+	return maybe_allow(current->network);
  }
  
  int disablenetwork_security_socket_bind(struct socket * sock,
@@ -41,7 +42,7 @@ int disablenetwork_security_socket_bind(struct socket * sock,
  {
  	if (address->sa_family == AF_UNIX)
  		return 0;
-	return maybe_allow();
+	return maybe_allow(current->network);
  }
  
  int disablenetwork_security_socket_connect(struct socket * sock,
@@ -50,7 +51,7 @@ int disablenetwork_security_socket_connect(struct socket * sock,
  {
  	if (address->sa_family == AF_UNIX)
  		return 0;
-	return maybe_allow();
+	return maybe_allow(current->network);
  }
  
  int disablenetwork_security_socket_sendmsg(struct socket * sock,
@@ -59,14 +60,14 @@ int disablenetwork_security_socket_sendmsg(struct socket * sock,
  	/* permit sockets which are PF_UNIX or connected; check others. */
  	if (sock->sk->sk_family == PF_UNIX || msg->msg_name == NULL)
  		return 0;
-	return maybe_allow();
+	return maybe_allow(current->network);
  }
  
  int disablenetwork_security_ptrace_access_check(struct task_struct *child,
                                                  unsigned int mode)
  {
  	/* does current have networking restrictions not shared by child? */
-	if (current->network & ~child->network)
+	if (maybe_allow(current->network) && !maybe_allow(child->network))
  		return -EPERM;
  	return 0;
  }
-- 
1.6.6.rc2
