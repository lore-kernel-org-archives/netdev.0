From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 26/29] netfilter: use nf_conntrack_helpers_register when possible
Date: Fri, 30 Jun 2017 00:53:24 +0200
Message-ID: <1498776807-11124-27-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <zlpnobody@gmail.com>

amanda_helper, nf_conntrack_helper_ras and nf_conntrack_helper_q931 are
all arrays, so we can use nf_conntrack_helpers_register to register
the ct helper, this will help us to eliminate some "goto errX"
statements.

Also introduce h323_helper_init/exit helper function to register the ct
helpers, this is prepared for the followup patch, which will add net
namespace support for ct helper.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_amanda.c    | 12 +++----
 net/netfilter/nf_conntrack_h323_main.c | 63 +++++++++++++++++++---------------
 2 files changed, 40 insertions(+), 35 deletions(-)

diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index 03d2ccffa9fa..20edd589fe06 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -197,8 +197,8 @@ static void __exit nf_conntrack_amanda_fini(void)
 {
 	int i;
 
-	nf_conntrack_helper_unregister(&amanda_helper[0]);
-	nf_conntrack_helper_unregister(&amanda_helper[1]);
+	nf_conntrack_helpers_unregister(amanda_helper,
+					ARRAY_SIZE(amanda_helper));
 	for (i = 0; i < ARRAY_SIZE(search); i++)
 		textsearch_destroy(search[i].ts);
 }
@@ -218,16 +218,12 @@ static int __init nf_conntrack_amanda_init(void)
 			goto err1;
 		}
 	}
-	ret = nf_conntrack_helper_register(&amanda_helper[0]);
+	ret = nf_conntrack_helpers_register(amanda_helper,
+					    ARRAY_SIZE(amanda_helper));
 	if (ret < 0)
 		goto err1;
-	ret = nf_conntrack_helper_register(&amanda_helper[1]);
-	if (ret < 0)
-		goto err2;
 	return 0;
 
-err2:
-	nf_conntrack_helper_unregister(&amanda_helper[0]);
 err1:
 	while (--i >= 0)
 		textsearch_destroy(search[i].ts);
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 3bcdc718484e..f71f0d2558fd 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -1815,14 +1815,44 @@ static struct nf_conntrack_helper nf_conntrack_helper_ras[] __read_mostly = {
 	},
 };
 
+static int __init h323_helper_init(void)
+{
+	int ret;
+
+	ret = nf_conntrack_helper_register(&nf_conntrack_helper_h245);
+	if (ret < 0)
+		return ret;
+	ret = nf_conntrack_helpers_register(nf_conntrack_helper_q931,
+					ARRAY_SIZE(nf_conntrack_helper_q931));
+	if (ret < 0)
+		goto err1;
+	ret = nf_conntrack_helpers_register(nf_conntrack_helper_ras,
+					ARRAY_SIZE(nf_conntrack_helper_ras));
+	if (ret < 0)
+		goto err2;
+
+	return 0;
+err2:
+	nf_conntrack_helpers_unregister(nf_conntrack_helper_q931,
+					ARRAY_SIZE(nf_conntrack_helper_q931));
+err1:
+	nf_conntrack_helper_unregister(&nf_conntrack_helper_h245);
+	return ret;
+}
+
+static void __exit h323_helper_exit(void)
+{
+	nf_conntrack_helpers_unregister(nf_conntrack_helper_ras,
+					ARRAY_SIZE(nf_conntrack_helper_ras));
+	nf_conntrack_helpers_unregister(nf_conntrack_helper_q931,
+					ARRAY_SIZE(nf_conntrack_helper_q931));
+	nf_conntrack_helper_unregister(&nf_conntrack_helper_h245);
+}
+
 /****************************************************************************/
 static void __exit nf_conntrack_h323_fini(void)
 {
-	nf_conntrack_helper_unregister(&nf_conntrack_helper_ras[1]);
-	nf_conntrack_helper_unregister(&nf_conntrack_helper_ras[0]);
-	nf_conntrack_helper_unregister(&nf_conntrack_helper_q931[1]);
-	nf_conntrack_helper_unregister(&nf_conntrack_helper_q931[0]);
-	nf_conntrack_helper_unregister(&nf_conntrack_helper_h245);
+	h323_helper_exit();
 	kfree(h323_buffer);
 	pr_debug("nf_ct_h323: fini\n");
 }
@@ -1837,32 +1867,11 @@ static int __init nf_conntrack_h323_init(void)
 	h323_buffer = kmalloc(65536, GFP_KERNEL);
 	if (!h323_buffer)
 		return -ENOMEM;
-	ret = nf_conntrack_helper_register(&nf_conntrack_helper_h245);
+	ret = h323_helper_init();
 	if (ret < 0)
 		goto err1;
-	ret = nf_conntrack_helper_register(&nf_conntrack_helper_q931[0]);
-	if (ret < 0)
-		goto err2;
-	ret = nf_conntrack_helper_register(&nf_conntrack_helper_q931[1]);
-	if (ret < 0)
-		goto err3;
-	ret = nf_conntrack_helper_register(&nf_conntrack_helper_ras[0]);
-	if (ret < 0)
-		goto err4;
-	ret = nf_conntrack_helper_register(&nf_conntrack_helper_ras[1]);
-	if (ret < 0)
-		goto err5;
 	pr_debug("nf_ct_h323: init success\n");
 	return 0;
-
-err5:
-	nf_conntrack_helper_unregister(&nf_conntrack_helper_ras[0]);
-err4:
-	nf_conntrack_helper_unregister(&nf_conntrack_helper_q931[1]);
-err3:
-	nf_conntrack_helper_unregister(&nf_conntrack_helper_q931[0]);
-err2:
-	nf_conntrack_helper_unregister(&nf_conntrack_helper_h245);
 err1:
 	kfree(h323_buffer);
 	return ret;
-- 
2.1.4

