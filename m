From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 01/17] atm: add owner of push() callback to atmvcc
Date: Fri, 30 Nov 2012 00:35:20 +0000
Message-ID: <1354235736-26833-2-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:47041
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755028Ab2K3Agl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:41 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Mazur <krzysiek@podlesie.net>

The atm is using atmvcc->push(vcc, NULL) callback to notify protocol
that vcc will be closed and protocol must detach from it. This callback
is usually used by protocol to decrement module usage count by module_put(),
but it leaves small window then module is still used after module_put().

Now the owner of push() callback is kept in atmvcc and
module_put(atmvcc->owner) is called after the protocol is detached from vcc.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>
---
 include/linux/atmdev.h | 1 +
 net/atm/common.c       | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index 22ef21c..72db2af 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -106,6 +106,7 @@ struct atm_vcc {
 	void		*dev_data;	/* per-device data */
 	void		*proto_data;	/* per-protocol data */
 	struct k_atm_aal_stats *stats;	/* pointer to AAL stats group */
+	struct module *owner;		/* owner of ->push function */
 	/* SVC part --- may move later ------------------------------------- */
 	short		itf;		/* interface number */
 	struct sockaddr_atmsvc local;
diff --git a/net/atm/common.c b/net/atm/common.c
index 0c0ad93..2421664 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -156,6 +156,7 @@ int vcc_create(struct net *net, struct socket *sock, int protocol, int family)
 	atomic_set(&sk->sk_rmem_alloc, 0);
 	vcc->push = NULL;
 	vcc->pop = NULL;
+	vcc->owner = NULL;
 	vcc->push_oam = NULL;
 	vcc->vpi = vcc->vci = 0; /* no VCI/VPI yet */
 	vcc->atm_options = vcc->aal_options = 0;
@@ -175,6 +176,7 @@ static void vcc_destroy_socket(struct sock *sk)
 			vcc->dev->ops->close(vcc);
 		if (vcc->push)
 			vcc->push(vcc, NULL); /* atmarpd has no push */
+		module_put(vcc->owner);
 
 		while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
 			atm_return(vcc, skb->truesize);
-- 
1.8.0
