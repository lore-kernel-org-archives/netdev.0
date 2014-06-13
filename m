From: Xiangyu Lu <luxiangyu@huawei.com>
Subject: [PATCH 2/5] net: Move the permission check in sock_diag_put_filterinfo to packet_diag_dump
Date: Fri, 13 Jun 2014 01:31:07 +0000
Message-ID: <1402623070-26549-3-git-send-email-luxiangyu@huawei.com>
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

commit a53b72c83a4216f2eb883ed45a0cbce014b8e62d upstream.

The permission check in sock_diag_put_filterinfo is wrong, and it is so removed
from it's sources it is not clear why it is wrong.  Move the computation
into packet_diag_dump and pass a bool of the result into sock_diag_filterinfo.

This does not yet correct the capability check but instead simply moves it to make
it clear what is going on.

Reported-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Xiangyu Lu <luxiangyu@huawei.com>
---
 include/linux/sock_diag.h | 2 +-
 net/core/sock_diag.c      | 4 ++--
 net/packet/diag.c         | 7 ++++++-
 3 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index 302ab80..46cca4c 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -23,7 +23,7 @@ int sock_diag_check_cookie(void *sk, __u32 *cookie);
 void sock_diag_save_cookie(void *sk, __u32 *cookie);
 
 int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attr);
-int sock_diag_put_filterinfo(struct sock *sk,
+int sock_diag_put_filterinfo(bool may_report_filterinfo, struct sock *sk,
 			     struct sk_buff *skb, int attrtype);
 
 #endif
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 6a7fae2..c38e7a2 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -49,7 +49,7 @@ int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attrtype)
 }
 EXPORT_SYMBOL_GPL(sock_diag_put_meminfo);
 
-int sock_diag_put_filterinfo(struct sock *sk,
+int sock_diag_put_filterinfo(bool may_report_filterinfo, struct sock *sk,
 			     struct sk_buff *skb, int attrtype)
 {
 	struct nlattr *attr;
@@ -57,7 +57,7 @@ int sock_diag_put_filterinfo(struct sock *sk,
 	unsigned int len;
 	int err = 0;
 
-	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN)) {
+	if (!may_report_filterinfo) {
 		nla_reserve(skb, attrtype, 0);
 		return 0;
 	}
diff --git a/net/packet/diag.c b/net/packet/diag.c
index ec8b6e8..cbf7391 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -127,6 +127,7 @@ static int pdiag_put_fanout(struct packet_sock *po, struct sk_buff *nlskb)
 
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 			struct packet_diag_req *req,
+			bool may_report_filterinfo,
 			struct user_namespace *user_ns,
 			u32 portid, u32 seq, u32 flags, int sk_ino)
 {
@@ -171,7 +172,8 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 		goto out_nlmsg_trim;
 
 	if ((req->pdiag_show & PACKET_SHOW_FILTER) &&
-	    sock_diag_put_filterinfo(sk, skb, PACKET_DIAG_FILTER))
+	    sock_diag_put_filterinfo(may_report_filterinfo, sk, skb,
+			 PACKET_DIAG_FILTER))
 		goto out_nlmsg_trim;
 
 	return nlmsg_end(skb, nlh);
@@ -187,9 +189,11 @@ static int packet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	struct packet_diag_req *req;
 	struct net *net;
 	struct sock *sk;
+	bool may_report_filterinfo;
 
 	net = sock_net(skb->sk);
 	req = nlmsg_data(cb->nlh);
+	may_report_filterinfo = ns_capable(net->user_ns, CAP_NET_ADMIN);
 
 	mutex_lock(&net->packet.sklist_lock);
 	sk_for_each(sk, &net->packet.sklist) {
@@ -199,6 +203,7 @@ static int packet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			goto next;
 
 		if (sk_diag_fill(sk, skb, req,
+				 may_report_filterinfo,
 				 sk_user_ns(NETLINK_CB(cb->skb).sk),
 				 NETLINK_CB(cb->skb).portid,
 				 cb->nlh->nlmsg_seq, NLM_F_MULTI,
-- 
1.8.3.4
