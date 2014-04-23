From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 3/5] net: Add variants of capable for use on on sockets
Date: Wed, 23 Apr 2014 14:26:56 -0700
Message-ID: <87r44nd9en.fsf_-_@x220.int.ebiederm.org>
References: <CALCETrWzUQ7QjykT85ExDfX-+9eDD-D-dcxofUMPvLK=ia9arg@mail.gmail.com>
	<87r44qrt8v.fsf_-_@x220.int.ebiederm.org>
	<87r44pnk3c.fsf@x220.int.ebiederm.org>
	<20140423.153216.1388028648299605195.davem@davemloft.net>
	<87a9bbeo2o.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: vgoyal@redhat.com, ssorce@redhat.com, security@kernel.org,
	luto@amacapital.net, netdev@vger.kernel.org, serge@hallyn.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:33431 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339AbaDWV10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 17:27:26 -0400
In-Reply-To: <87a9bbeo2o.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 23 Apr 2014 14:24:47 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


sk_net_capable - The common case, operations that are safe in a network namespace.
sk_capable - Operations that are not known to be safe in a network namespace
sk_ns_capable - The general case for special cases.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/sock.h |  5 +++++
 net/core/sock.c    | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 54 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 8338a14e4805..21569cf456ed 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2255,6 +2255,11 @@ int sock_get_timestampns(struct sock *, struct timespec __user *);
 int sock_recv_errqueue(struct sock *sk, struct msghdr *msg, int len, int level,
 		       int type);
 
+bool sk_ns_capable(const struct sock *sk,
+		   struct user_namespace *user_ns, int cap);
+bool sk_capable(const struct sock *sk, int cap);
+bool sk_net_capable(const struct sock *sk, int cap);
+
 /*
  *	Enable debug/info messages
  */
diff --git a/net/core/sock.c b/net/core/sock.c
index b4fff008136f..664ee4295b6f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -145,6 +145,55 @@
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
1.9.1
