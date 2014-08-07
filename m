From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 3/5] drivers/atm/atmtcp.c: fix error return code
Date: Thu,  7 Aug 2014 14:49:06 +0200
Message-ID: <1407415749-19978-3-git-send-email-Julia.Lawall@lip6.fr>
References: <1407415749-19978-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:14488 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757441AbaHGMwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 08:52:21 -0400
In-Reply-To: <1407415749-19978-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>

Convert a zero return value on error to a negative one, as returned
elsewhere in the function.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
identifier ret; expression e1,e2;
@@
(
if (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
Another return value could be more appropriate.

 drivers/atm/atmtcp.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
index 0e3f8f9..c8e4fb4 100644
--- a/drivers/atm/atmtcp.c
+++ b/drivers/atm/atmtcp.c
@@ -299,6 +299,7 @@ static int atmtcp_c_send(struct atm_vcc *vcc,struct sk_buff *skb)
 	out_vcc = find_vcc(dev, ntohs(hdr->vpi), ntohs(hdr->vci));
 	read_unlock(&vcc_sklist_lock);
 	if (!out_vcc) {
+		result = -ESRCH;
 		atomic_inc(&vcc->stats->tx_err);
 		goto done;
 	}
