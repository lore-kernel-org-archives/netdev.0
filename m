From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PATCH: rtnetlink explicit flags setting
Date: Fri, 27 May 2005 14:50:10 +0200
Message-ID: <20050527125010.GO15391@postel.suug.ch>
References: <1117197157.6688.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1117197157.6688.24.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1117197157.6688.24.camel@localhost.localdomain> 2005-05-27 08:32
> 
> I think i may have missed a few spots.
> 
> Thomas it would be worth creating a macro which takes flags as input as
> well to replace things along the lines of:
>         nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
>         nlh->nlmsg_flags = flags;
> Since theres a sufficient number of them.

Right, proposal:

--- 6204e59b7aa59cf79632003c621e521db1297b1b/include/linux/netlink.h  (mode:100644)
+++ uncommitted/include/linux/netlink.h  (mode:100644)
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
-       nlh->nlmsg_flags = 0;
+       nlh->nlmsg_flags = flags;
        nlh->nlmsg_pid = pid;
        nlh->nlmsg_seq = seq;
        return nlh;
 }
 
-#define NLMSG_PUT(skb, pid, seq, type, len) \
+#define NLMSG_NEW(skb, pid, seq, type, len, flags) \
 ({     if (skb_tailroom(skb) < (int)NLMSG_SPACE(len)) \
                goto nlmsg_failure; \
-       __nlmsg_put(skb, pid, seq, type, len); })
+       __nlmsg_put(skb, pid, seq, type, len, flags); })
+
+#define NLMSG_PUT(skb, pid, seq, type, len) \
+       NLMSG_NEW(skb, pid, seq, type, len, 0)
 
-#define NLMSG_PUT_ANSWER(skb, cb, type, len) \
-       NLMSG_PUT(skb, NETLINK_CB((cb)->skb).pid, \
-                 (cb)->nlh->nlmsg_seq, type, len)
+#define NLMSG_NEW_ANSWER(skb, cb, type, len, flags) \
+       NLMSG_NEW(skb, NETLINK_CB((cb)->skb).pid, \
+                 (cb)->nlh->nlmsg_seq, type, len, flags)
 
 #define NLMSG_END(skb, nlh) \
 ({     (nlh)->nlmsg_len = (skb)->tail - (unsigned char *) (nlh); \


I'd be especially happy with this because __nlmsg_put keeps control
over the flags ;->
