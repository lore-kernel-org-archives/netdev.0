From: Michael Stone <michael@laptop.org>
Subject: disablenetwork (v5): Remove a TOCTTOU race by passing flags by
	value.
Date: Fri, 15 Jan 2010 03:12:26 -0500
Message-ID: <20100115081226.GA14409@heat>
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
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100115081028.GA14004@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When network_flags is passed by pointer to memory shared among several tasks,
one of those tasks could change the pointed-to value after it was checked by
security_prctl() and before it was used by prctl_set_network().

Also, since no cleanup is needed in prctl_set_network(), simplify its
return-value conventions.

Signed-off-by: Michael Stone <michael@laptop.org>
---
  include/linux/prctl_network.h |    2 +-
  kernel/sys.c                  |   24 ++++++------------------
  2 files changed, 7 insertions(+), 19 deletions(-)

diff --git a/include/linux/prctl_network.h b/include/linux/prctl_network.h
index d18f8cb..2c03292 100644
--- a/include/linux/prctl_network.h
+++ b/include/linux/prctl_network.h
@@ -2,6 +2,6 @@
  #define _LINUX_PRCTL_NETWORK_H
  
  extern long prctl_get_network(unsigned long*);
-extern long prctl_set_network(unsigned long*);
+extern long prctl_set_network(unsigned long);
  
  #endif /* _LINUX_PRCTL_NETWORK_H */
diff --git a/kernel/sys.c b/kernel/sys.c
index b48f021..1fadf10 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1580,7 +1580,7 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
  				error = PR_MCE_KILL_DEFAULT;
  			break;
  		case PR_SET_NETWORK:
-			error = prctl_set_network((unsigned long*)arg2);
+			error = prctl_set_network(arg2);
  			break;
  		case PR_GET_NETWORK:
  			error = prctl_get_network((unsigned long*)arg2);
@@ -1599,29 +1599,17 @@ long prctl_get_network(unsigned long* user)
  	return put_user(current->network, user);
  }
  
-long prctl_set_network(unsigned long* user)
+long prctl_set_network(unsigned long network_flags)
  {
-	unsigned long network_flags;
-	long ret;
-
-	ret = -EFAULT;
-	if (copy_from_user(&network_flags, user, sizeof(network_flags)))
-		goto out;
-
-	ret = -EINVAL;
  	if (network_flags & ~PR_NETWORK_ALL_FLAGS)
-		goto out;
+		return -EINVAL;
  
  	/* only dropping access is permitted */
-	ret = -EPERM;
-        if (current->network & ~network_flags)
-		goto out;
+	if (current->network & ~network_flags)
+		return -EPERM;
  
  	current->network = network_flags;
-	ret = 0;
-
-out:
-	return ret;
+	return 0;
  }
  
  #else
-- 
1.6.6.rc2
