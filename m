From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 26 Nov 2015 11:01:05 +1100
Message-ID: <20151126110105.60ec3ddc@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  kernel/bpf/syscall.c

between commit:

  c9da161c6517 ("bpf: fix clearing on persistent program array maps")

from the net tree and commit:

  f99bf205dab0 ("bpf: add show_fdinfo handler for maps")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc kernel/bpf/syscall.c
index 4a8f3c1d7da6,6d1407bc1531..000000000000
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@@ -101,15 -93,34 +101,32 @@@ void bpf_map_put(struct bpf_map *map
  	}
  }
  
+ #ifdef CONFIG_PROC_FS
+ static void bpf_map_show_fdinfo(struct seq_file *m, struct file *filp)
+ {
+ 	const struct bpf_map *map = filp->private_data;
+ 
+ 	seq_printf(m,
+ 		   "map_type:\t%u\n"
+ 		   "key_size:\t%u\n"
+ 		   "value_size:\t%u\n"
+ 		   "max_entries:\t%u\n",
+ 		   map->map_type,
+ 		   map->key_size,
+ 		   map->value_size,
+ 		   map->max_entries);
+ }
+ #endif
+ 
 -static int bpf_map_release(struct inode *inode, struct file *filp)
 +void bpf_map_put_with_uref(struct bpf_map *map)
  {
 -	struct bpf_map *map = filp->private_data;
 -
 -	if (map->map_type == BPF_MAP_TYPE_PROG_ARRAY)
 -		/* prog_array stores refcnt-ed bpf_prog pointers
 -		 * release them all when user space closes prog_array_fd
 -		 */
 -		bpf_fd_array_map_clear(map);
 -
 +	bpf_map_put_uref(map);
  	bpf_map_put(map);
 +}
 +
 +static int bpf_map_release(struct inode *inode, struct file *filp)
 +{
 +	bpf_map_put_with_uref(filp->private_data);
  	return 0;
  }
  
