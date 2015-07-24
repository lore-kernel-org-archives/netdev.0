From: Jinpu Wang <jinpu.wang@profitbricks.com>
Subject: [PATCH]mlx4-core: fix possible use after free in cq_completion
Date: Fri, 24 Jul 2015 10:18:48 +0200
Message-ID: <CAMGffEnvM32Ae-XHDLuwGy1V7NKqosO+eAtakbKJCcVpqKQg3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b874cda69753a051b9aa8cd
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Moni Shoua <monis@mellanox.com>,
	Yun Wang <yun.wang@profitbricks.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36748 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753882AbbGXITJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 04:19:09 -0400
Received: by wicgb10 with SMTP id gb10so17693875wic.1
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 01:19:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7b874cda69753a051b9aa8cd
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi all,

I hit bug in OFED, I report to link below:

http://marc.info/?l=3Dlinux-rdma&m=3D143634872328553&w=3D2
I checked latest mainline Linux 4.2-rc3, it has similar bug.
Here is the patch against Linux 4.2-rc3, compile test only.

I add one copy as attachment in case mail client break the patch format.

>From a9fbc1ff0768acdb260e57e3324798fc0082d194 Mon Sep 17 00:00:00 2001
From: Jack Wang <jinpu.wang@profitbricks.com>
Date: Thu, 23 Jul 2015 18:58:08 +0200
Subject: [PATCH] mlx4_core: fix possible use-after-free in cq_completion

It's possible during mlx4_cq_free, there are new cq_completion come,
and there is no spin_lock protection for cq_completion, also no
refcount protection, it will lead to use after free. So add the
spin_lock and refcount protection in cq_completion.

Signed-off-by: Jack Wang <jinpu.wang@profitbricks.com>
---
 drivers/net/ethernet/mellanox/mlx4/cq.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c
b/drivers/net/ethernet/mellanox/mlx4/cq.c
index 3348e64..8d7f405 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -99,10 +99,15 @@ static void mlx4_add_cq_to_tasklet(struct mlx4_cq *cq)

 void mlx4_cq_completion(struct mlx4_dev *dev, u32 cqn)
 {
+    struct mlx4_cq_table *cq_table =3D &mlx4_priv(dev)->cq_table;
     struct mlx4_cq *cq;

-    cq =3D radix_tree_lookup(&mlx4_priv(dev)->cq_table.tree,
-                   cqn & (dev->caps.num_cqs - 1));
+    spin_lock(&cq_table->lock);
+    cq =3D radix_tree_lookup(&cq_table->tree, cqn & (dev->caps.num_cqs - 1=
));
+    if (cq)
+        atomic_inc(&cq->refcount);
+
+    spin_unlock(&cq_table->lock);
     if (!cq) {
         mlx4_dbg(dev, "Completion event for bogus CQ %08x\n", cqn);
         return;
@@ -111,6 +116,8 @@ void mlx4_cq_completion(struct mlx4_dev *dev, u32 cqn)
     ++cq->arm_sn;

     cq->comp(cq);
+    if (atomic_dec_and_test(&cq->refcount))
+        complete(&cq->free);
 }

 void mlx4_cq_event(struct mlx4_dev *dev, u32 cqn, int event_type)
--=20
1.9.1

--=20
Mit freundlichen Gr=C3=BC=C3=9Fen,Linux 4.2-rc3
Best Regards,

Jack Wang

Linux Kernel Developer Storage
ProfitBricks GmbH  The IaaS-Company.

ProfitBricks GmbH
Greifswalder Str. 207
D - 10405 Berlin
Tel: +49 30 5770083-42
Fax: +49 30 5770085-98
Email: jinpu.wang@profitbricks.com
URL: http://www.profitbricks.de

Sitz der Gesellschaft: Berlin.
Registergericht: Amtsgericht Charlottenburg, HRB 125506 B.
Gesch=C3=A4ftsf=C3=BChrer: Andreas Gauger, Achim Weiss.

--047d7b874cda69753a051b9aa8cd
Content-Type: text/x-diff; charset=US-ASCII;
	name="0001-mlx4_core-fix-possible-use-after-free-in-cq_completi.patch"
Content-Disposition: attachment;
	filename="0001-mlx4_core-fix-possible-use-after-free-in-cq_completi.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ichcstuq0

RnJvbSBhOWZiYzFmZjA3NjhhY2RiMjYwZTU3ZTMzMjQ3OThmYzAwODJkMTk0IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBKYWNrIFdhbmcgPGppbnB1LndhbmdAcHJvZml0YnJpY2tzLmNv
bT4KRGF0ZTogVGh1LCAyMyBKdWwgMjAxNSAxODo1ODowOCArMDIwMApTdWJqZWN0OiBbUEFUQ0hd
IG1seDRfY29yZTogZml4IHBvc3NpYmxlIHVzZS1hZnRlci1mcmVlIGluIGNxX2NvbXBsZXRpb24K
Ckl0J3MgcG9zc2libGUgZHVyaW5nIG1seDRfY3FfZnJlZSwgdGhlcmUgYXJlIG5ldyBjcV9jb21w
bGV0aW9uIGNvbWUsCmFuZCB0aGVyZSBpcyBubyBzcGluX2xvY2sgcHJvdGVjdGlvbiBmb3IgY3Ff
Y29tcGxldGlvbiwgYWxzbyBubwpyZWZjb3VudCBwcm90ZWN0aW9uLCBpdCB3aWxsIGxlYWQgdG8g
dXNlIGFmdGVyIGZyZWUuIFNvIGFkZCB0aGUKc3Bpbl9sb2NrIGFuZCByZWZjb3VudCBwcm90ZWN0
aW9uIGluIGNxX2NvbXBsZXRpb24uCgpTaWduZWQtb2ZmLWJ5OiBKYWNrIFdhbmcgPGppbnB1Lndh
bmdAcHJvZml0YnJpY2tzLmNvbT4KLS0tCiBkcml2ZXJzL25ldC9ldGhlcm5ldC9tZWxsYW5veC9t
bHg0L2NxLmMgfCAxMSArKysrKysrKystLQogMSBmaWxlIGNoYW5nZWQsIDkgaW5zZXJ0aW9ucygr
KSwgMiBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9tZWxs
YW5veC9tbHg0L2NxLmMgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9tZWxsYW5veC9tbHg0L2NxLmMK
aW5kZXggMzM0OGU2NC4uOGQ3ZjQwNSAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvZXRoZXJuZXQv
bWVsbGFub3gvbWx4NC9jcS5jCisrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L21lbGxhbm94L21s
eDQvY3EuYwpAQCAtOTksMTAgKzk5LDE1IEBAIHN0YXRpYyB2b2lkIG1seDRfYWRkX2NxX3RvX3Rh
c2tsZXQoc3RydWN0IG1seDRfY3EgKmNxKQogCiB2b2lkIG1seDRfY3FfY29tcGxldGlvbihzdHJ1
Y3QgbWx4NF9kZXYgKmRldiwgdTMyIGNxbikKIHsKKwlzdHJ1Y3QgbWx4NF9jcV90YWJsZSAqY3Ff
dGFibGUgPSAmbWx4NF9wcml2KGRldiktPmNxX3RhYmxlOwogCXN0cnVjdCBtbHg0X2NxICpjcTsK
IAotCWNxID0gcmFkaXhfdHJlZV9sb29rdXAoJm1seDRfcHJpdihkZXYpLT5jcV90YWJsZS50cmVl
LAotCQkJICAgICAgIGNxbiAmIChkZXYtPmNhcHMubnVtX2NxcyAtIDEpKTsKKwlzcGluX2xvY2so
JmNxX3RhYmxlLT5sb2NrKTsKKwljcSA9IHJhZGl4X3RyZWVfbG9va3VwKCZjcV90YWJsZS0+dHJl
ZSwgY3FuICYgKGRldi0+Y2Fwcy5udW1fY3FzIC0gMSkpOworCWlmIChjcSkKKwkJYXRvbWljX2lu
YygmY3EtPnJlZmNvdW50KTsKKworCXNwaW5fdW5sb2NrKCZjcV90YWJsZS0+bG9jayk7CiAJaWYg
KCFjcSkgewogCQltbHg0X2RiZyhkZXYsICJDb21wbGV0aW9uIGV2ZW50IGZvciBib2d1cyBDUSAl
MDh4XG4iLCBjcW4pOwogCQlyZXR1cm47CkBAIC0xMTEsNiArMTE2LDggQEAgdm9pZCBtbHg0X2Nx
X2NvbXBsZXRpb24oc3RydWN0IG1seDRfZGV2ICpkZXYsIHUzMiBjcW4pCiAJKytjcS0+YXJtX3Nu
OwogCiAJY3EtPmNvbXAoY3EpOworCWlmIChhdG9taWNfZGVjX2FuZF90ZXN0KCZjcS0+cmVmY291
bnQpKQorCQljb21wbGV0ZSgmY3EtPmZyZWUpOwogfQogCiB2b2lkIG1seDRfY3FfZXZlbnQoc3Ry
dWN0IG1seDRfZGV2ICpkZXYsIHUzMiBjcW4sIGludCBldmVudF90eXBlKQotLSAKMS45LjEKCg==
--047d7b874cda69753a051b9aa8cd--
