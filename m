From: Josh Hunt <johunt@akamai.com>
Subject: nft hash set expansion problem
Date: Sun, 08 Feb 2015 13:38:59 -0600
Message-ID: <54D7BB53.2050203@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nft hash sets are unable to expand past the initial # of buckets. This 
is b/c nft hash sets don't define the max_shift parameter and so 
rht_grow_above_75():

         return atomic_read(&ht->nelems) > (new_size / 4 * 3) &&
                (ht->p.max_shift && atomic_read(&ht->shift) < 
ht->p.max_shift);

can't return true.

It's not clear to me if this is intentional; requiring users of 
rhashtables define a max_shift in order to support expansion, or a bug 
in the grow decision function?

Here's a possible fix if it's the latter. Let me know and I can submit 
something formal if that's the case.

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index e96fc00..2c51617 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -250,7 +250,7 @@ bool rht_grow_above_75(const struct rhashtable *ht, 
size_t new_size)
  {
         /* Expand table when exceeding 75% load */
         return atomic_read(&ht->nelems) > (new_size / 4 * 3) &&
-              (ht->p.max_shift && atomic_read(&ht->shift) < 
ht->p.max_shift);
+              (ht->p.max_shift ? atomic_read(&ht->shift) < 
ht->p.max_shift : 1);
  }
  EXPORT_SYMBOL_GPL(rht_grow_above_75);

Thanks
Josh


