From: Xiangyu Lu <luxiangyu@huawei.com>
Subject: [PATCH 3/5] net: Add variants of capable for use on on sockets
Date: Fri, 13 Jun 2014 01:31:08 +0000
Message-ID: <1402623070-26549-4-git-send-email-luxiangyu@huawei.com>
References: <1402623070-26549-1-git-send-email-luxiangyu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stable@vger.kernel.org>, <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Xiangyu Lu <luxiangyu@huawei.com>
To: <gregkh@linuxfoundation.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1402623070-26549-1-git-send-email-luxiangyu@huawei.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm@xmission.com>

commit a3b299da869d6e78cf42ae0b1b41797bcb8c5e4b upstream.

sk_net_capable - The common case, operations that are safe in a network namespace.
sk_capable - Operations that are not known to be safe in a network namespace
sk_ns_capable - The general case for special cases.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Xiangyu Lu <luxiangyu@huawei.com>
---
 include/net/sock.h |  5 +++++
 net/core/sock.c    | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 54 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 8f32b77..72f710d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2248,6 +2248,11 @@ extern void sock_enable_timestamp(struct sock *sk, int flag);
 extern int sock_get_timestamp(struct sock *, struct timeval __user *);
 extern int sock_get_timestampns(struct sock *, struct timespec __user *);
 
+bool sk_ns_capable(const struct sock *sk,
+		   struct user_namespace *user_ns, int cap);
+bool sk_capable(const struct sock *sk, int cap);
+bool sk_net_capable(const struct sock *sk, int cap);
+
 /*
  *	Enable debug/info messages
  */
diff --git a/net/core/sock.c b/net/core/sock.c
index d743099..af65d17 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -142,6 +142,55 @@
 static DEFINE_MUTEX(proto_list_mutex);
 static LIST_HEAD(proto_list);
 
+/**
+ * sk_ns_capable - General socket capability test
+ * @sk: Socket to use a capability on or through
+ * @user_ns: The user namespace of the capability to use
+ * @cap: The capability to use
+ *
+ * Test to see if the opener of the socket had when the socket was
+ * created and the current process has the capability @cap in the user
+ * namespace @user_ns.
+ */
+bool sk_ns_capable(const struct sock *sk,
+		   struct user_namespace *user_ns, int cap)
+{
+	return file_ns_capable(sk->sk_socket->file, user_ns, cap) &&
+		ns_capable(user_ns, cap);
+}
+EXPORT_SYMBOL(sk_ns_capable);
+
+/**
+ * sk_capable - Socket global capability test
+ * @sk: Socket to use a capability on or through
+ * @cap: The global capbility to use
+ *
+ * Test to see if the opener of the socket had when the socket was
+ * created and the current process has the capability @cap in all user
+ * namespaces.
+ */
+bool sk_capable(const struct sock *sk, int cap)
+{
+	return sk_ns_capable(sk, &init_user_ns, cap);
+}
+EXPORT_SYMBOL(sk_capable);
+
+/**
+ * sk_net_capable - Network namespace socket capability test
+ * @sk: Socket to use a capability on or through
+ * @cap: The capability to use
+ *
+ * Test to see if the opener of the socket had when the socke was created
+ * and the current process has the capability @cap over the network namespace
+ * the socket is a member of.
+ */
+bool sk_net_capable(const struct sock *sk, int cap)
+{
+	return sk_ns_capable(sk, sock_net(sk)->user_ns, cap);
+}
+EXPORT_SYMBOL(sk_net_capable);
+
+
 #ifdef CONFIG_MEMCG_KMEM
 int mem_cgroup_sockets_init(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
-- 
1.8.3.4
