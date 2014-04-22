From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/6] net: Move the permission check in sock_diag_put_filterinfo to packet_diag_dump
Date: Tue, 22 Apr 2014 14:15:20 -0700
Message-ID: <87fvl5nk0n.fsf_-_@x220.int.ebiederm.org>
References: <CALCETrUaYhh6Dkzn0TMEUz-GEO9-6ObByk5d_xRViSMBbp5Pkg@mail.gmail.com>
	<cover.1397840611.git.luto@amacapital.net>
	<6daf425e2023266d52d181e4d2ee18747d4f1fa8.1397840611.git.luto@amacapital.net>
	<87tx9nuxf6.fsf@x220.int.ebiederm.org>
	<CALCETrUqNVRBse4rUeUKfgYt0d+9x1JrEHGcZ_DnWyq7W6Yyzw@mail.gmail.com>
	<87r44qtabz.fsf@x220.int.ebiederm.org>
	<CALCETrWzUQ7QjykT85ExDfX-+9eDD-D-dcxofUMPvLK=ia9arg@mail.gmail.com>
	<87r44qrt8v.fsf_-_@x220.int.ebiederm.org>
	<87r44pnk3c.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vivek Goyal <vgoyal@redhat.com>, Simo Sorce <ssorce@redhat.com>,
	"security\@kernel.org" <security@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	<netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:49226 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758676AbaDVVPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 17:15:52 -0400
In-Reply-To: <87r44pnk3c.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Tue, 22 Apr 2014 14:13:43 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The permission check in sock_diag_put_filterinfo is wrong, and it is so removed
from it's sources it is not clear why it is wrong.  Move the computation
into packet_diag_dump and pass a bool of the result into sock_diag_filterinfo.

This does not yet correct the capability check but instead simply moves it to make
it clear what is going on.

Reported-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/sock_diag.h | 2 +-
 net/core/sock_diag.c      | 4 ++--
 net/packet/diag.c         | 8 +++++++-
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index 54f91d35e5fd..46cca4c06848 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -23,7 +23,7 @@ int sock_diag_check_cookie(void *sk, __u32 *cookie);
 void sock_diag_save_cookie(void *sk, __u32 *cookie);
 
 int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attr);
-int sock_diag_put_filterinfo(struct user_namespace *user_ns, struct sock *sk,
+int sock_diag_put_filterinfo(bool may_report_filterinfo, struct sock *sk,
 			     struct sk_buff *skb, int attrtype);
 
 #endif
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index d7af18859322..a4216a4c9572 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -49,7 +49,7 @@ int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attrtype)
 }
 EXPORT_SYMBOL_GPL(sock_diag_put_meminfo);
 
-int sock_diag_put_filterinfo(struct user_namespace *user_ns, struct sock *sk,
+int sock_diag_put_filterinfo(bool may_report_filterinfo, struct sock *sk,
 			     struct sk_buff *skb, int attrtype)
 {
 	struct sock_fprog_kern *fprog;
@@ -58,7 +58,7 @@ int sock_diag_put_filterinfo(struct user_namespace *user_ns, struct sock *sk,
 	unsigned int flen;
 	int err = 0;
 
-	if (!ns_capable(user_ns, CAP_NET_ADMIN)) {
+	if (!may_report_filterinfo) {
 		nla_reserve(skb, attrtype, 0);
 		return 0;
 	}
diff --git a/net/packet/diag.c b/net/packet/diag.c
index 533ce4ff108a..f5ad130ee3b8 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -128,6 +128,7 @@ static int pdiag_put_fanout(struct packet_sock *po, struct sk_buff *nlskb)
 
 static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 			struct packet_diag_req *req,
+			bool may_report_filterinfo,
 			struct user_namespace *user_ns,
 			u32 portid, u32 seq, u32 flags, int sk_ino)
 {
@@ -172,7 +173,8 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 		goto out_nlmsg_trim;
 
 	if ((req->pdiag_show & PACKET_SHOW_FILTER) &&
-	    sock_diag_put_filterinfo(user_ns, sk, skb, PACKET_DIAG_FILTER))
+	    sock_diag_put_filterinfo(may_report_filterinfo, sk, skb,
+				     PACKET_DIAG_FILTER))
 		goto out_nlmsg_trim;
 
 	return nlmsg_end(skb, nlh);
@@ -188,9 +190,12 @@ static int packet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	struct packet_diag_req *req;
 	struct net *net;
 	struct sock *sk;
+	bool may_report_filterinfo;
 
 	net = sock_net(skb->sk);
 	req = nlmsg_data(cb->nlh);
+	may_report_filterinfo =
+		ns_capable(sk_user_ns(NETLINK_CB(cb->skb).sk), CAP_NET_ADMIN);
 
 	mutex_lock(&net->packet.sklist_lock);
 	sk_for_each(sk, &net->packet.sklist) {
@@ -200,6 +205,7 @@ static int packet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			goto next;
 
 		if (sk_diag_fill(sk, skb, req,
+				 may_report_filterinfo,
 				 sk_user_ns(NETLINK_CB(cb->skb).sk),
 				 NETLINK_CB(cb->skb).portid,
 				 cb->nlh->nlmsg_seq, NLM_F_MULTI,
-- 
1.9.1
