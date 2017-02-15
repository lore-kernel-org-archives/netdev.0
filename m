From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH] netfilter: ipset: Null pointer exception in ipset list:set
Date: Wed, 15 Feb 2017 17:45:26 -0500
Message-ID: <1487198726-21866-1-git-send-email-vpai@akamai.com>
Cc: Vishwanath Pai <vpai@akamai.com>, johunt@akamai.com,
        pai.vishwain@gmail.com, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If we use before/after to add an element to an empty list it will cause
a kernel panic.

$> cat crash.restore
create a hash:ip
create b hash:ip
create test list:set timeout 5 size 4
add test b before a

$> ipset -R < crash.restore

Executing the above will crash the kernel.

Signed-off-by: Vishwanath Pai <vpai@akamai.com>
Reviewed-by: Josh Hunt <johunt@akamai.com>
---
 net/netfilter/ipset/ip_set_list_set.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 51077c5..178d4eb 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -260,11 +260,14 @@ struct list_set {
 		else
 			prev = e;
 	}
+
+	/* If before/after is used on an empty set */
+	if ((d->before > 0 && !next) ||
+	    (d->before < 0 && !prev))
+		return -IPSET_ERR_REF_EXIST;
+
 	/* Re-add already existing element */
 	if (n) {
-		if ((d->before > 0 && !next) ||
-		    (d->before < 0 && !prev))
-			return -IPSET_ERR_REF_EXIST;
 		if (!flag_exist)
 			return -IPSET_ERR_EXIST;
 		/* Update extensions */
-- 
1.9.1

