From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/5] net: Move the permission check in sock_diag_put_filterinfo to packet_diag_dump
Date: Wed, 23 Apr 2014 14:26:25 -0700
Message-ID: <87wqefd9fi.fsf_-_@x220.int.ebiederm.org>
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
Received: from out02.mta.xmission.com ([166.70.13.232]:33340 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756149AbaDWV04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 17:26:56 -0400
In-Reply-To: <87a9bbeo2o.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 23 Apr 2014 14:24:47 -0700")
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
 net/packet/diag.c         | 7 ++++++-
 3 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index 302ab805b0bb..46cca4c06848 100644
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
index 9deb6abd6cf6..a4216a4c9572 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -49,7 +49,7 @@ int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attrtype)
 }
 EXPORT_SYMBOL_GPL(sock_diag_put_meminfo);
 
-int sock_diag_put_filterinfo(struct sock *sk,
+int sock_diag_put_filterinfo(bool may_report_filterinfo, struct sock *sk,
 			     struct sk_buff *skb, int attrtype)
 {
 	struct sock_fprog_kern *fprog;
@@ -58,7 +58,7 @@ int sock_diag_put_filterinfo(struct sock *sk,
 	unsigned int flen;
 	int err = 0;
 
-	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN)) {
+	if (!may_report_filterinfo) {
 		nla_reserve(skb, attrtype, 0);
 		return 0;
 	}
diff --git a/net/packet/diag.c b/net/packet/diag.c
index 435ff99ba8c7..b34d0de24091 100644
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
-	    sock_diag_put_filterinfo(sk, skb, PACKET_DIAG_FILTER))
+	    sock_diag_put_filterinfo(may_report_filterinfo, sk, skb,
+				     PACKET_DIAG_FILTER))
 		goto out_nlmsg_trim;
 
 	return nlmsg_end(skb, nlh);
@@ -188,9 +190,11 @@ static int packet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	struct packet_diag_req *req;
 	struct net *net;
 	struct sock *sk;
+	bool may_report_filterinfo;
 
 	net = sock_net(skb->sk);
 	req = nlmsg_data(cb->nlh);
+	may_report_filterinfo = ns_capable(net->user_ns, CAP_NET_ADMIN);
 
 	mutex_lock(&net->packet.sklist_lock);
 	sk_for_each(sk, &net->packet.sklist) {
@@ -200,6 +204,7 @@ static int packet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			goto next;
 
 		if (sk_diag_fill(sk, skb, req,
+				 may_report_filterinfo,
 				 sk_user_ns(NETLINK_CB(cb->skb).sk),
 				 NETLINK_CB(cb->skb).portid,
 				 cb->nlh->nlmsg_seq, NLM_F_MULTI,
-- 
1.9.1
