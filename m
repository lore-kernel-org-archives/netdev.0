From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/8] netfilter: conntrack: adjust nf_conntrack_buckets default value
Date: Wed, 14 Jan 2015 21:34:42 +0100
Message-ID: <1421267689-24894-2-git-send-email-pablo@netfilter.org>
References: <1421267689-24894-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1421267689-24894-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcelo Leitner <mleitner@redhat.com>

Manually bumping either nf_conntrack_buckets or nf_conntrack_max has
become a common task as our Linux servers tend to serve more and more
clients/applications, so let's adjust nf_conntrack_buckets this to a
more updated value.

Now for systems with more than 4GB of memory, nf_conntrack_buckets
becomes 65536 instead of 16384, resulting in nf_conntrack_max=256k
entries.

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 Documentation/networking/nf_conntrack-sysctl.txt |    3 ++-
 net/netfilter/nf_conntrack_core.c                |   11 ++++++++---
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/nf_conntrack-sysctl.txt b/Documentation/networking/nf_conntrack-sysctl.txt
index 70da508..f55599c 100644
--- a/Documentation/networking/nf_conntrack-sysctl.txt
+++ b/Documentation/networking/nf_conntrack-sysctl.txt
@@ -11,7 +11,8 @@ nf_conntrack_buckets - INTEGER (read-only)
 	Size of hash table. If not specified as parameter during module
 	loading, the default size is calculated by dividing total memory
 	by 16384 to determine the number of buckets but the hash table will
-	never have fewer than 32 or more than 16384 buckets.
+	never have fewer than 32 and limited to 16384 buckets. For systems
+	with more than 4GB of memory it will be 65536 buckets.
 
 nf_conntrack_checksum - BOOLEAN
 	0 - disabled
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index a116748..da58cd4 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1624,13 +1624,18 @@ int nf_conntrack_init_start(void)
 	for (i = 0; i < CONNTRACK_LOCKS; i++)
 		spin_lock_init(&nf_conntrack_locks[i]);
 
-	/* Idea from tcp.c: use 1/16384 of memory.  On i386: 32MB
-	 * machine has 512 buckets. >= 1GB machines have 16384 buckets. */
 	if (!nf_conntrack_htable_size) {
+		/* Idea from tcp.c: use 1/16384 of memory.
+		 * On i386: 32MB machine has 512 buckets.
+		 * >= 1GB machines have 16384 buckets.
+		 * >= 4GB machines have 65536 buckets.
+		 */
 		nf_conntrack_htable_size
 			= (((totalram_pages << PAGE_SHIFT) / 16384)
 			   / sizeof(struct hlist_head));
-		if (totalram_pages > (1024 * 1024 * 1024 / PAGE_SIZE))
+		if (totalram_pages > (4 * (1024 * 1024 * 1024 / PAGE_SIZE)))
+			nf_conntrack_htable_size = 65536;
+		else if (totalram_pages > (1024 * 1024 * 1024 / PAGE_SIZE))
 			nf_conntrack_htable_size = 16384;
 		if (nf_conntrack_htable_size < 32)
 			nf_conntrack_htable_size = 32;
-- 
1.7.10.4

