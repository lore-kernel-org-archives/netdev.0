From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] xfrm: Report user triggered expirations against the users socket
Date: Sat, 08 Sep 2012 00:17:17 -0700
Message-ID: <87pq5xhtky.fsf_-_@xmission.com>
References: <87a9x1j9qh.fsf@xmission.com> <871uidj8so.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jamal Hadi Salim <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:33433 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323Ab2IHHR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2012 03:17:28 -0400
In-Reply-To: <871uidj8so.fsf@xmission.com> (Eric W. Biederman's message of
	"Sat, 08 Sep 2012 00:03:19 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When a policy expiration is triggered from user space the request
travles through km_policy_expired and ultimately into
xfrm_exp_policy_notify which calls build_polexpire.  build_polexpire
uses the netlink port passed to km_policy_expired as the source port for
the netlink message it builds.

When a state expiration is triggered from user space the request travles
through km_state_expired and ultimately into xfrm_exp_state_notify which
calls build_expire.  build_expire uses the netlink port passed to
km_state_expired as the source port for the netlink message it builds.

Pass nlh->nlmsg_pid from the user generated netlink message that
requested the expiration to km_policy_expired and km_state_expired
instead of current->pid which is not a netlink port number.

Cc: Jamal Hadi Salim <hadi@cyberus.ca>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/xfrm/xfrm_user.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 4801c81..c1fbdbf 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1930,7 +1930,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		// reset the timers here?
 		WARN(1, "Dont know what to do with soft policy expire\n");
 	}
-	km_policy_expired(xp, p->dir, up->hard, current->pid);
+	km_policy_expired(xp, p->dir, up->hard, nlh->nlmsg_pid);
 
 out:
 	xfrm_pol_put(xp);
@@ -1958,7 +1958,7 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	err = -EINVAL;
 	if (x->km.state != XFRM_STATE_VALID)
 		goto out;
-	km_state_expired(x, ue->hard, current->pid);
+	km_state_expired(x, ue->hard, nlh->nlmsg_pid);
 
 	if (ue->hard) {
 		uid_t loginuid = audit_get_loginuid(current);
-- 
1.7.5.4
