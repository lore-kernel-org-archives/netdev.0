From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 4/5] netfilter: nf_tables: fix error return code
Date: Thu,  7 Aug 2014 14:49:08 +0200
Message-ID: <1407415749-19978-5-git-send-email-Julia.Lawall@lip6.fr>
References: <1407415749-19978-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407415749-19978-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 net/netfilter/nf_tables_api.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index b8035c2..ffd063e 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -3134,8 +3134,10 @@ static int nft_del_setelem(struct nft_ctx *ctx, struct nft_set *set,
 		goto err2;
 
 	trans = nft_trans_elem_alloc(ctx, NFT_MSG_DELSETELEM, set);
-	if (trans == NULL)
+	if (trans == NULL) {
+		err = -ENOMEM;
 		goto err2;
+	}
 
 	nft_trans_elem(trans) = elem;
 	list_add_tail(&trans->list, &ctx->net->nft.commit_list);
