From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH v2 8/8] netlink: Only check file credentials for implicit destinations
Date: Fri, 25 Jul 2014 16:22:29 +0800
Message-ID: <1406276549-6616-9-git-send-email-wangyufen@huawei.com>
References: <1406276549-6616-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	<stable@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>,
	Wang Yufen <wangyufen@huawei.com>
To: <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1406276549-6616-1-git-send-email-wangyufen@huawei.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Eric W. Biederman" <ebiederm@xmission.com>

It was possible to get a setuid root or setcap executable to write to
it's stdout or stderr (which has been set made a netlink socket) and
inadvertently reconfigure the networking stack.

To prevent this we check that both the creator of the socket and
the currentl applications has permission to reconfigure the network
stack.

Unfortunately this breaks Zebra which always uses sendto/sendmsg
and creates it's socket without any privileges.

To keep Zebra working don't bother checking if the creator of the
socket has privilege when a destination address is specified.  Instead
rely exclusively on the privileges of the sender of the socket.

Note from Andy: This is exactly Eric's code except for some comment
clarifications and formatting fixes.  Neither I nor, I think, anyone
else is thrilled with this approach, but I'm hesitant to wait on a
better fix since 3.15 is almost here.

Note to stable maintainers: This is a mess.  An earlier series of
patches in 3.15 fix a rather serious security issue (CVE-2014-0181),
but they did so in a way that breaks Zebra.  The offending series
includes:

    commit aa4cf9452f469f16cea8c96283b641b4576d4a7b
    Author: Eric W. Biederman <ebiederm@xmission.com>
    Date:   Wed Apr 23 14:28:03 2014 -0700

        net: Add variants of capable for use on netlink messages

If a given kernel version is missing that series of fixes, it's
probably worth backporting it and this patch.  if that series is
present, then this fix is critical if you care about Zebra.

Cc: stable@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 include/linux/netlink.h  | 3 ++-
 net/netlink/af_netlink.c | 7 ++++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index f4b56b7..dbf29e5 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -166,9 +166,10 @@ struct netlink_skb_parms {
 	struct ucred		creds;		/* Skb credentials	*/
 	__u32			pid;
 	__u32			dst_group;
+	__u32                   flags;
 	struct sock             *ssk;
 };
-
+#define NETLINK_SKB_DST         0x8  /* Dst set in sendto or sendmsg */
 #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
 #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 41d345b..231249e 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -603,7 +603,9 @@ retry:
 bool __netlink_ns_capable(const struct netlink_skb_parms *nsp,
 			struct user_namespace *user_ns, int cap)
 {
-	return sk_ns_capable(nsp->ssk, user_ns, cap);
+	return ((nsp->flags & NETLINK_SKB_DST) ||
+		file_ns_capable(nsp->ssk->sk_socket->file, user_ns, cap)) &&
+		ns_capable(user_ns, cap);
 }
 EXPORT_SYMBOL(__netlink_ns_capable);
 
@@ -1402,6 +1404,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sk_buff *skb;
 	int err;
 	struct scm_cookie scm;
+	u32 netlink_skb_flags = 0;
 
 	if (msg->msg_flags&MSG_OOB)
 		return -EOPNOTSUPP;
@@ -1423,6 +1426,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		if ((dst_group || dst_pid) &&
 		    !netlink_allowed(sock, NL_NONROOT_SEND))
 			goto out;
+		netlink_skb_flags |= NETLINK_SKB_DST;
 	} else {
 		dst_pid = nlk->dst_pid;
 		dst_group = nlk->dst_group;
@@ -1444,6 +1448,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 
 	NETLINK_CB(skb).pid	= nlk->pid;
 	NETLINK_CB(skb).dst_group = dst_group;
+	NETLINK_CB(skb).flags   = netlink_skb_flags;
 	memcpy(NETLINK_CREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
 
 	err = -EFAULT;
-- 
1.8.0
