From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the tip tree
Date: Wed, 5 Oct 2011 17:25:28 +1100
Message-ID: <20111005172528.0d0a8afc65acef7ace22a24e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__5_Oct_2011_17_25_28_+1100_dhJCLRNhNAmdY4ej"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Huang Ying <ying.huang@intel.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__5_Oct_2011_17_25_28_+1100_dhJCLRNhNAmdY4ej
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the tip tree, today's linux-next build (x86_64 allmodconfig)
failed like this:

net/rds/ib_rdma.c: In function 'rds_ib_reuse_fmr':
net/rds/ib_rdma.c:272:2: error: implicit declaration of function 'llist_del=
_first' [-Werror=3Dimplicit-function-declaration]
net/rds/ib_rdma.c:272:6: warning: assignment makes pointer from integer wit=
hout a cast [enabled by default]
net/rds/ib_rdma.c: In function 'rds_ib_flush_mr_pool':
net/rds/ib_rdma.c:671:4: error: implicit declaration of function 'llist_add=
_batch' [-Werror=3Dimplicit-function-declaration]
cc1: some warnings being treated as errors

Caused by commit 1230db8e1543 ("llist: Make some llist functions inline")
interacting with commit 1bc144b62524 ("net, rds, Replace xlist in
net/rds/xlist.h with llist") from the net tree.  The former commit
removes the declarations of llist_del_first() and llist_add_batch() with
no explanation (and probably by accident since the definitions still
exist).

I have added the following patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 5 Oct 2011 17:16:29 +1100
Subject: [PATCH] llist: add back llist_add_batch and llist_del_first

Commit 1230db8e1543 ("llist: Make some llist functions inline") appears
to have deleted the definitions by accident.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/linux/llist.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/llist.h b/include/linux/llist.h
index 837fb4a..7287734 100644
--- a/include/linux/llist.h
+++ b/include/linux/llist.h
@@ -178,4 +178,10 @@ static inline struct llist_node *llist_del_all(struct =
llist_head *head)
 {
 	return xchg(&head->first, NULL);
 }
+
+extern bool llist_add_batch(struct llist_node *new_first,
+			    struct llist_node *new_last,
+			    struct llist_head *head);
+extern struct llist_node *llist_del_first(struct llist_head *head);
+
 #endif /* LLIST_H */
--=20
1.7.6.3

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__5_Oct_2011_17_25_28_+1100_dhJCLRNhNAmdY4ej
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOi/hYAAoJEECxmPOUX5FELywQAI8tJ8VUghyoz32qfScneYBq
jYdGZUms02M/9XnBjKNL369+wMqR/VDoQclZ2m0F0E86Rl6FbtI0FSkqHpqJHEgV
jnCak5BYUTUzsb6dy8dbHTC05xa8To7TU+Tc7eQDrG8WLq+zzrrRcH4VQuJw3bwc
Zxf33tdkYi6tFwg+m/1LWT6e3dLVzOUQ9/ZBQbFst1+gZRnvkpddQyGNtlFPL3D+
UahsaDF51NHAOuQMx8vK4rtQV7p+kHrEvHqLCZMksehGDVKf5nvGaG8htDnA0kVq
sHtpNIm7PyCmJTtiEBKl+X0A/g1gx4zsVS9bhKHaEJhm28nuMjWpcwdTFAo9VwjL
/IjSDWJd1ltVSh+gs0bMkdXGjMx7tIXrkI6TFVIBRe5SB5dUOCoPN400Xqx4hzYE
UGe9I/4K/DWsY38sQHMZhD4atLr/6M3VBrDH1E7BbiqrCdH/w+N+3BYiNCoeypS/
uJ9m+yWRmq+kGOHVpVOkv/9qpjCc1AH4Sq3ogTKDNmWacDAzEGE/rfmtoMxLErrM
FRMRV5K0c4IxmyXuRXze1TEfuu7iQ3CVi7kugMbpEulv6RcUyEfHjLkVD8m4Qwp9
IoTum3Low1gbX3/MEoK0IYdEdHa18mUewL2xdQX39udF03HCN4nUMy3lv2QFgFLi
YaYiZNoJ1f3zovlsSJf3
=5oyD
-----END PGP SIGNATURE-----

--Signature=_Wed__5_Oct_2011_17_25_28_+1100_dhJCLRNhNAmdY4ej--
