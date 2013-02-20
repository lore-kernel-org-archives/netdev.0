From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the akpm tree
Date: Wed, 20 Feb 2013 17:28:31 +1100
Message-ID: <20130220172831.cf0bcb1b3bdc5e404d85f100@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__20_Feb_2013_17_28_31_+1100_mNwQZuB=X/Wq_Vux"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__20_Feb_2013_17_28_31_+1100_mNwQZuB=X/Wq_Vux
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

After merging the akpm tree, today's linux-next build (x86_64
allmodconfig) failed like this:

drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c: In function 'qlcnic_prune_l=
b_filters':
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:607:63: error: macro "hlist_=
for_each_entry_safe" passed 5 arguments, but takes just 4
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:607:3: error: 'hlist_for_eac=
h_entry_safe' undeclared (first use in this function)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c:608:3: error: expected ';' b=
efore '{' token

Caused by commit c4b75b428da3 ("hlist: drop the node parameter from
iterators") interacting with commit 53643a75b147 ("qlcnic: fix ping
resumption to a VM after a live migration") from the net-next tree.

I applied this merge fix:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 20 Feb 2013 17:17:54 +1100
Subject: [PATCH] hlist-drop-the-node-parameter-from-iterators-qlnic-fix

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/e=
thernet/qlogic/qlcnic/qlcnic_hw.c
index a5422cd..f89cc7a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -604,7 +604,7 @@ void qlcnic_prune_lb_filters(struct qlcnic_adapter *ada=
pter)
 	for (i =3D 0; i < adapter->rx_fhash.fbucket_size; i++) {
 		head =3D &(adapter->rx_fhash.fhead[i]);
=20
-		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode)
+		hlist_for_each_entry_safe(tmp_fil, n, head, fnode)
 		{
 			time =3D tmp_fil->ftime;
 			if (jiffies > (QLCNIC_FILTER_AGE * HZ + time)) {
--=20
1.8.1

which then lead to these erroes:

drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c: In function 'qlcnic_add_lb_=
filter':
drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c:182:63: error: macro "hlist_=
for_each_entry_safe" passed 5 arguments, but takes just 4
drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c:182:3: error: 'hlist_for_eac=
h_entry_safe' undeclared (first use in this function)
drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c:182:65: error: expected ';' =
before '{' token
drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c:208:63: error: macro "hlist_=
for_each_entry_safe" passed 5 arguments, but takes just 4
drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c:208:65: error: expected ';' =
before '{' token

for which I applied this merge fix patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 20 Feb 2013 17:25:26 +1100
Subject: [PATCH] hlist-drop-the-node-parameter-from-iterators-qlnic-2-fix

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/e=
thernet/qlogic/qlcnic/qlcnic_io.c
index 27196ed..0e63006 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -162,7 +162,7 @@ void qlcnic_add_lb_filter(struct qlcnic_adapter *adapte=
r, struct sk_buff *skb,
 {
 	struct ethhdr *phdr =3D (struct ethhdr *)(skb->data);
 	struct qlcnic_filter *fil, *tmp_fil;
-	struct hlist_node *tmp_hnode, *n;
+	struct hlist_node *n;
 	struct hlist_head *head;
 	unsigned long time;
 	u64 src_addr =3D 0;
@@ -179,7 +179,7 @@ void qlcnic_add_lb_filter(struct qlcnic_adapter *adapte=
r, struct sk_buff *skb,
 			 (adapter->fhash.fbucket_size - 1);
 		head =3D &(adapter->rx_fhash.fhead[hindex]);
=20
-		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode) {
+		hlist_for_each_entry_safe(tmp_fil, n, head, fnode) {
 			if (!memcmp(tmp_fil->faddr, &src_addr, ETH_ALEN) &&
 			    tmp_fil->vlan_id =3D=3D vlan_id) {
 				time =3D tmp_fil->ftime;
@@ -205,7 +205,7 @@ void qlcnic_add_lb_filter(struct qlcnic_adapter *adapte=
r, struct sk_buff *skb,
 			 (adapter->fhash.fbucket_size - 1);
 		head =3D &(adapter->rx_fhash.fhead[hindex]);
 		spin_lock(&adapter->rx_mac_learn_lock);
-		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode) {
+		hlist_for_each_entry_safe(tmp_fil, n, head, fnode) {
 			if (!memcmp(tmp_fil->faddr, &src_addr, ETH_ALEN) &&
 			    tmp_fil->vlan_id =3D=3D vlan_id) {
 				found =3D 1;
--=20
1.8.1

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__20_Feb_2013_17_28_31_+1100_mNwQZuB=X/Wq_Vux
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRJG0PAAoJEECxmPOUX5FEnA4P/iEpplQ4dbAk+WbKsoUhfglk
ECbWwr/82eYudZxkV/HZbYbn3cKAPRajy2JJPLYIW7B9dp5cLLKWr9G4R3xT1M8g
q8CW+3Pa4YMh6BqMA1mMJG6v84c4A/e/AH7I1ZDzBbpyCbOD48kpOvYQU2G6EdSm
7nlnLEd6ByVerzX1DOwUvoeGn+l2rFmW83B8p+WUQCSVp2HL5DUYq2dLV7JP4Vw4
84qCKPVKjaYtTeH/GHMCfFf/+H+lJRMQaYWbQHZmaNydqJnTlxsNNpJhIxqnDEdB
zxG35y9tzUaPZmOS0bnNMgZcnDrgnQaQBDEg2uSTpPPUnHhTpKE13rAGLpCwVvto
hA/eGD9WsNZuoJNySoSUAcBhIRfyp1E2YfBn/zs9+LzR9b0Ia3dV+v+dMXcwlxtz
Niyx78f8m2scp1RpedDBFvDxICRW0yH4iC/HPUAigyFMCvYWNk07xqaNUQJ6Qir2
67Up1RN27Nvuyk6qKlsqANugNKLDwNSGHG4ucL8gAArqQAc+7EIwTG7ajXlBvX7S
NTCMUr9/Qn7TOy5Mr3WcPvNVE0crYW/8VXndhyhBzHaqsHnXW+TYBjCI+NTr4fBy
U1PkLRCkZ7WVOsjiIGbCdzzJetQ8T6OdJbUlum99tH1ExTxx3+jTjmBag+TXtmAH
84bKpUOwFzE6htQONWo1
=GAdh
-----END PGP SIGNATURE-----

--Signature=_Wed__20_Feb_2013_17_28_31_+1100_mNwQZuB=X/Wq_Vux--
