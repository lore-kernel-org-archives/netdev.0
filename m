From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 9/11] inet_diag: Introduce socket family checks
Date: Tue, 06 Dec 2011 21:59:15 +0400
Message-ID: <4EDE57F3.1030505@parallels.com>
References: <4EDE573A.6040607@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:31210 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267Ab1LFR7V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 12:59:21 -0500
In-Reply-To: <4EDE573A.6040607@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new API will specify family to work with. Teach the existing
socket walking code to bypass not interesting ones.

To preserve compatibility with existing behavior the _compat code
sets interesting family to AF_UNSPEC to dump them all.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/ipv4/inet_diag.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index d655f0a..f1aaaec 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -743,6 +743,10 @@ static int __inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 					continue;
 				}
 
+				if (r->sdiag_family != AF_UNSPEC &&
+						sk->sk_family != r->sdiag_family)
+					goto next_listen;
+
 				if (r->id.idiag_sport != inet->inet_sport &&
 				    r->id.idiag_sport)
 					goto next_listen;
@@ -808,6 +812,9 @@ skip_listen_ht:
 				goto next_normal;
 			if (!(r->idiag_states & (1 << sk->sk_state)))
 				goto next_normal;
+			if (r->sdiag_family != AF_UNSPEC &&
+					sk->sk_family != r->sdiag_family)
+				goto next_normal;
 			if (r->id.idiag_sport != inet->inet_sport &&
 			    r->id.idiag_sport)
 				goto next_normal;
@@ -830,6 +837,9 @@ next_normal:
 
 				if (num < s_num)
 					goto next_dying;
+				if (r->sdiag_family != AF_UNSPEC &&
+						tw->tw_family != r->sdiag_family)
+					goto next_dying;
 				if (r->id.idiag_sport != tw->tw_sport &&
 				    r->id.idiag_sport)
 					goto next_dying;
@@ -873,7 +883,7 @@ static int inet_diag_dump_compat(struct sk_buff *skb, struct netlink_callback *c
 	struct nlattr *bc = NULL;
 	int hdrlen = sizeof(struct inet_diag_req_compat);
 
-	req.sdiag_family = rc->idiag_family;
+	req.sdiag_family = AF_UNSPEC; /* compatibility */
 	req.sdiag_protocol = inet_diag_type2proto(cb->nlh->nlmsg_type);
 	req.idiag_ext = rc->idiag_ext;
 	req.idiag_states = rc->idiag_states;
-- 
1.5.5.6
