From: =?UTF-8?q?Asbj=C3=B8rn=20Sloth=20T=C3=B8nnesen?=
        <asbjorn@asbjorn.st>
Subject: [PATCH iproute2 v2 4/9] l2tp: fix L2TP_ATTR_{RECV,SEND}_SEQ handling
Date: Wed, 16 Nov 2016 22:45:21 +0000
Message-ID: <20161116224526.32343-4-asbjorn@asbjorn.st>
References: <20161116224526.32343-1-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([185.38.24.25]:42769 "EHLO mail.asbjorn.biz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941172AbcKPWqg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 17:46:36 -0500
In-Reply-To: <20161116224526.32343-1-asbjorn@asbjorn.st>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

L2TP_ATTR_RECV_SEQ and L2TP_ATTR_SEND_SEQ are declared as NLA_U8
attributes in the kernel, so let's threat them accordingly.

Signed-off-by: Asbjørn Sloth Tønnesen <asbjorn@asbjorn.st>
---
 ip/ipl2tp.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index 2e0e9c7..a7cbd66 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -160,8 +160,8 @@ static int create_session(struct l2tp_parm *p)
 	addattr8(&req.n, 1024, L2TP_ATTR_L2SPEC_LEN, p->l2spec_len);
 
 	if (p->mtu)		addattr16(&req.n, 1024, L2TP_ATTR_MTU, p->mtu);
-	if (p->recv_seq)	addattr(&req.n, 1024, L2TP_ATTR_RECV_SEQ);
-	if (p->send_seq)	addattr(&req.n, 1024, L2TP_ATTR_SEND_SEQ);
+	if (p->recv_seq)	addattr8(&req.n, 1024, L2TP_ATTR_RECV_SEQ, 1);
+	if (p->send_seq)	addattr8(&req.n, 1024, L2TP_ATTR_SEND_SEQ, 1);
 	if (p->lns_mode)	addattr(&req.n, 1024, L2TP_ATTR_LNS_MODE);
 	if (p->data_seq)	addattr8(&req.n, 1024, L2TP_ATTR_DATA_SEQ, p->data_seq);
 	if (p->reorder_timeout) addattr64(&req.n, 1024, L2TP_ATTR_RECV_TIMEOUT,
@@ -304,8 +304,10 @@ static int get_response(struct nlmsghdr *n, void *arg)
 		memcpy(p->peer_cookie, RTA_DATA(attrs[L2TP_ATTR_PEER_COOKIE]),
 		       p->peer_cookie_len = RTA_PAYLOAD(attrs[L2TP_ATTR_PEER_COOKIE]));
 
-	p->recv_seq = !!attrs[L2TP_ATTR_RECV_SEQ];
-	p->send_seq = !!attrs[L2TP_ATTR_SEND_SEQ];
+	if (attrs[L2TP_ATTR_RECV_SEQ])
+		p->recv_seq = !!rta_getattr_u8(attrs[L2TP_ATTR_RECV_SEQ]);
+	if (attrs[L2TP_ATTR_SEND_SEQ])
+		p->send_seq = !!rta_getattr_u8(attrs[L2TP_ATTR_SEND_SEQ]);
 
 	if (attrs[L2TP_ATTR_RECV_TIMEOUT])
 		p->reorder_timeout = rta_getattr_u64(attrs[L2TP_ATTR_RECV_TIMEOUT]);
-- 
2.10.2
