From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 3/5] genetlink: Add rcu_dereference_genl and
	genl_dereference.
Date: Mon, 21 Nov 2011 13:30:27 -0800
Message-ID: <1321911029-20707-4-git-send-email-jesse@nicira.com>
References: <1321911029-20707-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1321911029-20707-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

This adds rcu_dereference_genl and genl_dereference, which are genl
variants of the RTNL functions to enforce proper locking with lockdep
and sparse.

Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
v2: New patch.
---
 include/linux/genetlink.h |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/include/linux/genetlink.h b/include/linux/genetlink.h
index 59311ad..73c28de 100644
--- a/include/linux/genetlink.h
+++ b/include/linux/genetlink.h
@@ -89,6 +89,27 @@ extern void genl_unlock(void);
 extern int lockdep_genl_is_held(void);
 #endif
 
+/**
+ * rcu_dereference_genl - rcu_dereference with debug checking
+ * @p: The pointer to read, prior to dereferencing
+ *
+ * Do an rcu_dereference(p), but check caller either holds rcu_read_lock()
+ * or genl mutex. Note : Please prefer genl_dereference() or rcu_dereference()
+ */
+#define rcu_dereference_genl(p)					\
+	rcu_dereference_check(p, lockdep_genl_is_held())
+
+/**
+ * genl_dereference - fetch RCU pointer when updates are prevented by genl mutex
+ * @p: The pointer to read, prior to dereferencing
+ *
+ * Return the value of the specified RCU-protected pointer, but omit
+ * both the smp_read_barrier_depends() and the ACCESS_ONCE(), because
+ * caller holds genl mutex.
+ */
+#define genl_dereference(p)					\
+	rcu_dereference_protected(p, lockdep_genl_is_held())
+
 #endif /* __KERNEL__ */
 
 #endif	/* __LINUX_GENERIC_NETLINK_H */
-- 
1.7.5.4
