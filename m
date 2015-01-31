From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] net: sched: One function call less in em_meta_change() after
 error detection
Date: Sat, 31 Jan 2015 17:34:54 +0100
Message-ID: <54CD042E.6030606@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 31 Jan 2015 17:18:48 +0100

The meta_delete() function could be called in four cases by the
em_meta_change() function during error handling even if the passed
variable "meta" contained still a null pointer.

* This implementation detail could be improved by adjustments for jump labels.

* Let us return immediately after the first failed function call according to
  the current Linux coding style convention.

* Let us delete also unnecessary checks for the variables "err" and
  "meta" there.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/sched/em_meta.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index b5294ce..2aa67b1 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -866,23 +866,23 @@ static int em_meta_change(struct net *net, void *data, int len,
 
 	err = nla_parse(tb, TCA_EM_META_MAX, data, len, meta_policy);
 	if (err < 0)
-		goto errout;
+		return err;
 
 	err = -EINVAL;
 	if (tb[TCA_EM_META_HDR] == NULL)
-		goto errout;
+		goto exit;
 	hdr = nla_data(tb[TCA_EM_META_HDR]);
 
 	if (TCF_META_TYPE(hdr->left.kind) != TCF_META_TYPE(hdr->right.kind) ||
 	    TCF_META_TYPE(hdr->left.kind) > TCF_META_TYPE_MAX ||
 	    TCF_META_ID(hdr->left.kind) > TCF_META_ID_MAX ||
 	    TCF_META_ID(hdr->right.kind) > TCF_META_ID_MAX)
-		goto errout;
+		goto exit;
 
 	meta = kzalloc(sizeof(*meta), GFP_KERNEL);
 	if (meta == NULL) {
 		err = -ENOMEM;
-		goto errout;
+		goto exit;
 	}
 
 	memcpy(&meta->lvalue.hdr, &hdr->left, sizeof(hdr->left));
@@ -891,20 +891,20 @@ static int em_meta_change(struct net *net, void *data, int len,
 	if (!meta_is_supported(&meta->lvalue) ||
 	    !meta_is_supported(&meta->rvalue)) {
 		err = -EOPNOTSUPP;
-		goto errout;
+		goto delete_meta;
 	}
 
 	if (meta_change_data(&meta->lvalue, tb[TCA_EM_META_LVALUE]) < 0 ||
 	    meta_change_data(&meta->rvalue, tb[TCA_EM_META_RVALUE]) < 0)
-		goto errout;
+		goto delete_meta;
 
 	m->datalen = sizeof(*meta);
 	m->data = (unsigned long) meta;
 
-	err = 0;
-errout:
-	if (err && meta)
-		meta_delete(meta);
+	return 0;
+delete_meta:
+	meta_delete(meta);
+exit:
 	return err;
 }
 
-- 
2.2.2
