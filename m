From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: [PATCH v3 2/7] atm: add owner of push() callback to atmvcc
Date: Tue,  6 Nov 2012 23:16:57 +0100
Message-ID: <1352240222-363-3-git-send-email-krzysiek@podlesie.net>
References: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
Cc: linux-kernel@vger.kernel.org,
	Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	David Woodhouse <David.Woodhouse@intel.com>,
	davem@davemloft.net, Krzysztof Mazur <krzysiek@podlesie.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The atm is using atmvcc->push(vcc, NULL) callback to notify protocol
that vcc will be closed and protocol must detach from it. This callback
is usually used by protocol to decrement module usage count by module_put(),
but it leaves small window then module is still used after module_put().

Now the owner of push() callback is kept in atmvcc and
module_put(atmvcc->owner) is called after the protocol is detached from vcc.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
 include/linux/atmdev.h | 1 +
 net/atm/common.c       | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index 06fd4bb..31c16c6 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -315,6 +315,7 @@ struct atm_vcc {
 	void		*dev_data;	/* per-device data */
 	void		*proto_data;	/* per-protocol data */
 	struct k_atm_aal_stats *stats;	/* pointer to AAL stats group */
+	struct module *owner;		/* owner of ->push function */
 	/* SVC part --- may move later ------------------------------------- */
 	short		itf;		/* interface number */
 	struct sockaddr_atmsvc local;
diff --git a/net/atm/common.c b/net/atm/common.c
index a0e4411..ea952b2 100644
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
@@ -173,6 +174,7 @@ static void vcc_destroy_socket(struct sock *sk)
 	if (vcc->dev) {
 		if (vcc->push)
 			vcc->push(vcc, NULL); /* atmarpd has no push */
+		module_put(vcc->owner);
 		if (vcc->dev->ops->close)
 			vcc->dev->ops->close(vcc);
 
-- 
1.8.0.233.g54991f2
