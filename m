From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 10/11] ah6: fix error return code
Date: Sun, 23 Aug 2015 02:11:21 +0200
Message-ID: <1440288682-12732-11-git-send-email-Julia.Lawall@lip6.fr>
References: <1440288682-12732-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440288682-12732-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return a negative error code on failure.

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
 net/ipv6/ah6.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index ed7d4e3..0630a4d 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -577,8 +577,10 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	work_iph = ah_alloc_tmp(ahash, nfrags + sglists, hdr_len +
 				ahp->icv_trunc_len + seqhi_len);
-	if (!work_iph)
+	if (!work_iph) {
+		err = -ENOMEM;
 		goto out;
+	}
 
 	auth_data = ah_tmp_auth((u8 *)work_iph, hdr_len);
 	seqhi = (__be32 *)(auth_data + ahp->icv_trunc_len);
