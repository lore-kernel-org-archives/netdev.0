From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/2] [NETLINK] Introduce NLMSG_NEW macro to better handle netlink flags
Date: Fri, 27 May 2005 19:00:41 +0200
Message-ID: <20050527170041.GD15391@postel.suug.ch>
References: <1117197157.6688.24.camel@localhost.localdomain> <20050527125010.GO15391@postel.suug.ch> <1117202331.6383.39.camel@localhost.localdomain> <20050527141320.GQ15391@postel.suug.ch> <1117206091.6383.73.camel@localhost.localdomain> <20050527151913.GA15391@postel.suug.ch> <1117209466.6383.106.camel@localhost.localdomain> <20050527165935.GC15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20050527165935.GC15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Introduces a new macro NLMSG_NEW which extends NLMSG_PUT but takes
a flags argument. NLMSG_PUT stays there for compatibility but now
calls NLMSG_NEW with flags == 0. NLMSG_PUT_ANSWER is renamed to
NLMSG_NEW_ANSWER which now also takes a flags argument.

Also converts the users of NLMSG_PUT_ANSWER to use NLMSG_NEW_ANSWER
and fixes the two direct users of __nlmsg_put to either provide
the flags or use NLMSG_NEW(_ANSWER).

Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit 1eb85f52f4e0d23996f6aa49009ce02fc0579658
tree debb58e5f900a6551f751b457226250cfccc3c75
parent fde09d4989b6c7b5183ffb3ec2076ff53dd6fa78
author Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 17:43:09 +0200
committer Thomas Graf <tgraf@suug.ch> Fri, 27 May 2005 17:43:09 +0200

 include/linux/netlink.h  |   17 ++++++++++-------
 net/core/neighbour.c     |    8 ++++----
 net/netlink/af_netlink.c |    8 +++++---
 3 files changed, 19 insertions(+), 14 deletions(-)

Index: include/linux/netlink.h
===================================================================
--- b032d0d440d93aac252e656bd41df32ff5461e3a/include/linux/netlink.h  (mode:100644)
+++ debb58e5f900a6551f751b457226250cfccc3c75/include/linux/netlink.h  (mode:100644)
@@ -156,7 +156,7 @@
 };
 
 static __inline__ struct nlmsghdr *
-__nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len)
+__nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
 {
 	struct nlmsghdr *nlh;
 	int size = NLMSG_LENGTH(len);
@@ -164,20 +164,23 @@
 	nlh = (struct nlmsghdr*)skb_put(skb, NLMSG_ALIGN(size));
 	nlh->nlmsg_type = type;
 	nlh->nlmsg_len = size;
-	nlh->nlmsg_flags = 0;
+	nlh->nlmsg_flags = flags;
 	nlh->nlmsg_pid = pid;
 	nlh->nlmsg_seq = seq;
 	return nlh;
 }
 
-#define NLMSG_PUT(skb, pid, seq, type, len) \
+#define NLMSG_NEW(skb, pid, seq, type, len, flags) \
 ({	if (skb_tailroom(skb) < (int)NLMSG_SPACE(len)) \
 		goto nlmsg_failure; \
-	__nlmsg_put(skb, pid, seq, type, len); })
+	__nlmsg_put(skb, pid, seq, type, len, flags); })
+
+#define NLMSG_PUT(skb, pid, seq, type, len) \
+	NLMSG_NEW(skb, pid, seq, type, len, 0)
 
-#define NLMSG_PUT_ANSWER(skb, cb, type, len) \
-	NLMSG_PUT(skb, NETLINK_CB((cb)->skb).pid, \
-		  (cb)->nlh->nlmsg_seq, type, len)
+#define NLMSG_NEW_ANSWER(skb, cb, type, len, flags) \
+	NLMSG_NEW(skb, NETLINK_CB((cb)->skb).pid, \
+		  (cb)->nlh->nlmsg_seq, type, len, flags)
 
 #define NLMSG_END(skb, nlh) \
 ({	(nlh)->nlmsg_len = (skb)->tail - (unsigned char *) (nlh); \
Index: net/core/neighbour.c
===================================================================
--- b032d0d440d93aac252e656bd41df32ff5461e3a/net/core/neighbour.c  (mode:100644)
+++ debb58e5f900a6551f751b457226250cfccc3c75/net/core/neighbour.c  (mode:100644)
@@ -1588,8 +1588,8 @@
 	struct nlmsghdr *nlh;
 	struct ndtmsg *ndtmsg;
 
-	nlh = NLMSG_PUT_ANSWER(skb, cb, RTM_NEWNEIGHTBL, sizeof(struct ndtmsg));
-	nlh->nlmsg_flags |= NLM_F_MULTI;
+	nlh = NLMSG_NEW_ANSWER(skb, cb, RTM_NEWNEIGHTBL, sizeof(struct ndtmsg),
+			       NLM_F_MULTI);
 
 	ndtmsg = NLMSG_DATA(nlh);
 
@@ -1673,8 +1673,8 @@
 	struct ndtmsg *ndtmsg;
 	struct nlmsghdr *nlh;
 
-	nlh = NLMSG_PUT_ANSWER(skb, cb, RTM_NEWNEIGHTBL, sizeof(struct ndtmsg));
-	nlh->nlmsg_flags |= NLM_F_MULTI;
+	nlh = NLMSG_NEW_ANSWER(skb, cb, RTM_NEWNEIGHTBL, sizeof(struct ndtmsg),
+			       NLM_F_MULTI);
 
 	ndtmsg = NLMSG_DATA(nlh);
 
Index: net/netlink/af_netlink.c
===================================================================
--- b032d0d440d93aac252e656bd41df32ff5461e3a/net/netlink/af_netlink.c  (mode:100644)
+++ debb58e5f900a6551f751b457226250cfccc3c75/net/netlink/af_netlink.c  (mode:100644)
@@ -1095,8 +1095,7 @@
 		return 0;
 	}
 
-	nlh = __nlmsg_put(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq, NLMSG_DONE, sizeof(int));
-	nlh->nlmsg_flags |= NLM_F_MULTI;
+	nlh = NLMSG_NEW_ANSWER(skb, cb, NLMSG_DONE, sizeof(len), NLM_F_MULTI);
 	memcpy(NLMSG_DATA(nlh), &len, sizeof(len));
 	skb_queue_tail(&sk->sk_receive_queue, skb);
 	sk->sk_data_ready(sk, skb->len);
@@ -1107,6 +1106,9 @@
 
 	netlink_destroy_callback(cb);
 	return 0;
+
+nlmsg_failure:
+	return -ENOBUFS;
 }
 
 int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
@@ -1178,7 +1180,7 @@
 	}
 
 	rep = __nlmsg_put(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
-			  NLMSG_ERROR, sizeof(struct nlmsgerr));
+			  NLMSG_ERROR, sizeof(struct nlmsgerr), 0);
 	errmsg = NLMSG_DATA(rep);
 	errmsg->error = err;
 	memcpy(&errmsg->msg, nlh, err ? nlh->nlmsg_len : sizeof(struct nlmsghdr));
