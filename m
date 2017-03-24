From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Fri, 24 Mar 2017 11:05:14 +1100
Message-ID: <20170324110514.0376c46f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Alexei Starovoitov <ast@fb.com>,
        Martin KaFai Lau <kafai@fb.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  kernel/bpf/hashtab.c

between commit:

  8c290e60fa2a ("bpf: fix hashmap extra_elems logic")

from Linus' tree and commit:

  bcc6b1b7ebf8 ("bpf: Add hash of maps support")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc kernel/bpf/hashtab.c
index 361a69dfe543,343fb5394c95..000000000000
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@@ -582,7 -609,20 +616,15 @@@ static void htab_elem_free_rcu(struct r
  
  static void free_htab_elem(struct bpf_htab *htab, struct htab_elem *l)
  {
+ 	struct bpf_map *map = &htab->map;
+ 
+ 	if (map->ops->map_fd_put_ptr) {
+ 		void *ptr = fd_htab_map_get_ptr(map, l);
+ 
+ 		map->ops->map_fd_put_ptr(ptr);
+ 	}
+ 
 -	if (l->state == HTAB_EXTRA_ELEM_USED) {
 -		l->state = HTAB_EXTRA_ELEM_FREE;
 -		return;
 -	}
 -
 -	if (!(htab->map.map_flags & BPF_F_NO_PREALLOC)) {
 +	if (htab_is_prealloc(htab)) {
  		pcpu_freelist_push(&htab->freelist, &l->fnode);
  	} else {
  		atomic_dec(&htab->count);
