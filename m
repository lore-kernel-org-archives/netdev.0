From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 16/21] userns: Convert cls_flow to work with user namespaces
	enabled
Date: Mon, 13 Aug 2012 13:18:30 -0700
Message-ID: <1344889115-21610-16-git-send-email-ebiederm@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<1344889115-21610-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1344889115-21610-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

The flow classifier can use uids and gids of the sockets that
are transmitting packets and do insert those uids and gids
into the packet classification calcuation.  I don't fully
understand the details but it appears that we can depend
on specific uids and gids when making traffic classification
decisions.

To work with user namespaces enabled map from kuids and kgids
into uids and gids in the initial user namespace giving raw
integer values the code can play with and depend on.

To avoid issues of userspace depending on uids and gids in
packet classifiers installed from other user namespaces
and getting confused deny all packet classifiers that
use uids or gids that are not comming from a netlink socket
in the initial user namespace.

Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Cc: Changli Gao <xiaosuo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 init/Kconfig         |    1 -
 net/sched/cls_flow.c |   16 ++++++++++++----
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 2660b31..b44c3a3 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -943,7 +943,6 @@ config UIDGID_CONVERTED
 
 	# Networking
 	depends on NET_9P = n
-	depends on NET_CLS_FLOW = n
 	depends on NETFILTER_XT_MATCH_OWNER = n
 	depends on NETFILTER_XT_MATCH_RECENT = n
 	depends on NETFILTER_XT_TARGET_LOG = n
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index ae854f3..ce82d0c 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -193,15 +193,19 @@ static u32 flow_get_rtclassid(const struct sk_buff *skb)
 
 static u32 flow_get_skuid(const struct sk_buff *skb)
 {
-	if (skb->sk && skb->sk->sk_socket && skb->sk->sk_socket->file)
-		return skb->sk->sk_socket->file->f_cred->fsuid;
+	if (skb->sk && skb->sk->sk_socket && skb->sk->sk_socket->file) {
+		kuid_t skuid = skb->sk->sk_socket->file->f_cred->fsuid;
+		return from_kuid(&init_user_ns, skuid);
+	}
 	return 0;
 }
 
 static u32 flow_get_skgid(const struct sk_buff *skb)
 {
-	if (skb->sk && skb->sk->sk_socket && skb->sk->sk_socket->file)
-		return skb->sk->sk_socket->file->f_cred->fsgid;
+	if (skb->sk && skb->sk->sk_socket && skb->sk->sk_socket->file) {
+		kgid_t skgid = skb->sk->sk_socket->file->f_cred->fsgid;
+		return from_kgid(&init_user_ns, skgid);
+	}
 	return 0;
 }
 
@@ -387,6 +391,10 @@ static int flow_change(struct sk_buff *in_skb,
 
 		if (fls(keymask) - 1 > FLOW_KEY_MAX)
 			return -EOPNOTSUPP;
+
+		if ((keymask & (FLOW_KEY_SKUID|FLOW_KEY_SKGID)) &&
+		    sk_user_ns(NETLINK_CB(in_skb).ssk) != &init_user_ns)
+			return -EOPNOTSUPP;
 	}
 
 	err = tcf_exts_validate(tp, tb, tca[TCA_RATE], &e, &flow_ext_map);
-- 
1.7.5.4
