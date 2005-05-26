From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/4] [NETLINK] New message building macros
Date: Thu, 26 May 2005 20:54:02 +0200
Message-ID: <20050526185402.GX15391@postel.suug.ch>
References: <20050526185306.GW15391@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050526185306.GW15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 NLMSG_PUT_ANSWER(skb, nlcb, type, length)
   Start a new netlink message as answer to a request,
   returns the message header.

 NLMSG_END(skb, nlh)
   End a netlink message, fixes total message length,
   returns skb->len.

 NLMSG_CANCEL(skb, nlh)
   Cancel the building process and trim whole message
   from skb again, returns -1.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

---
commit 88e04e26d887e806372014a2f7b33c6a7ea64741
tree 031c0e0d63096ca2dff2203940b90460f1db5c68
parent d1faeaeb95a05275cf0c5b51b88f2fa833434625
author Thomas Graf <tgraf@suug.ch> Thu, 26 May 2005 18:21:36 +0200
committer Thomas Graf <tgraf@suug.ch> Thu, 26 May 2005 18:21:36 +0200

 include/linux/netlink.h |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

Index: include/linux/netlink.h
===================================================================
--- c6f827347b3c6c28bc55a8eb1e62ea2659202cab/include/linux/netlink.h  (mode:100644)
+++ 031c0e0d63096ca2dff2203940b90460f1db5c68/include/linux/netlink.h  (mode:100644)
@@ -171,8 +171,21 @@
 }
 
 #define NLMSG_PUT(skb, pid, seq, type, len) \
-({ if (skb_tailroom(skb) < (int)NLMSG_SPACE(len)) goto nlmsg_failure; \
-   __nlmsg_put(skb, pid, seq, type, len); })
+({	if (skb_tailroom(skb) < (int)NLMSG_SPACE(len)) \
+		goto nlmsg_failure; \
+	__nlmsg_put(skb, pid, seq, type, len); })
+
+#define NLMSG_PUT_ANSWER(skb, cb, type, len) \
+	NLMSG_PUT(skb, NETLINK_CB((cb)->skb).pid, \
+		  (cb)->nlh->nlmsg_seq, type, len)
+
+#define NLMSG_END(skb, nlh) \
+({	(nlh)->nlmsg_len = (skb)->tail - (unsigned char *) (nlh); \
+	(skb)->len; })
+
+#define NLMSG_CANCEL(skb, nlh) \
+({	skb_trim(skb, (unsigned char *) (nlh) - (skb)->data); \
+	-1; })
 
 extern int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 			      struct nlmsghdr *nlh,
