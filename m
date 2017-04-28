From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net-next] lwtunnel: fix error path in lwtunnel_fill_encap()
Date: Fri, 28 Apr 2017 16:03:48 +0300
Message-ID: <20170428130347.53hagk77wh6scmcs@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>,
        Tom Herbert <tom@herbertland.com>,
        David Lebrun <david.lebrun@uclouvain.be>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Pan Bian <bianpan2016@163.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We recently added a check to see if nla_nest_start() fails.  There are
two issues with that.  First, if it fails then I don't think we should
call nla_nest_cancel().  Second, it's slightly convoluted but the
current code returns success but we should return -EMSGSIZE instead.

Fixes: a50fe0ffd76f ("lwtunnel: check return value of nla_nest_start")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index 5cbed3816229..cfae3d5fe11f 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -203,7 +203,7 @@ int lwtunnel_fill_encap(struct sk_buff *skb, struct lwtunnel_state *lwtstate)
 {
 	const struct lwtunnel_encap_ops *ops;
 	struct nlattr *nest;
-	int ret = -EINVAL;
+	int ret;
 
 	if (!lwtstate)
 		return 0;
@@ -212,10 +212,11 @@ int lwtunnel_fill_encap(struct sk_buff *skb, struct lwtunnel_state *lwtstate)
 	    lwtstate->type > LWTUNNEL_ENCAP_MAX)
 		return 0;
 
-	ret = -EOPNOTSUPP;
 	nest = nla_nest_start(skb, RTA_ENCAP);
 	if (!nest)
-		goto nla_put_failure;
+		return -EMSGSIZE;
+
+	ret = -EOPNOTSUPP;
 	rcu_read_lock();
 	ops = rcu_dereference(lwtun_encaps[lwtstate->type]);
 	if (likely(ops && ops->fill_encap))
