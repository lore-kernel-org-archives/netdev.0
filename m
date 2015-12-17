From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm-current tree with the net-next
 tree
Date: Thu, 17 Dec 2015 16:31:58 +1100
Message-ID: <20151217163158.19359f6a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Weiner <hannes@cmpxchg.org>,
	Lorenzo Colitti <lorenzo@google.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Today's linux-next merge of the akpm-current tree got a conflict in:

  include/net/sock.h
  net/ipv4/tcp_ipv4.c

between commit:

  64be0aed59ad ("net: diag: Add the ability to destroy a socket.")

from the net-next tree and commit:

  0e2cde9cf7b6 ("net: tcp_memcontrol: simplify linkage between socket and page counter")

from the akpm-current tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/net/sock.h
index f772b8245cae,edd552ef8e38..000000000000
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@@ -309,8 -292,8 +293,8 @@@ struct cg_proto
    *	@sk_send_head: front of stuff to transmit
    *	@sk_security: used by security modules
    *	@sk_mark: generic packet mark
 -  *	@sk_classid: this socket's cgroup classid
 +  *	@sk_cgrp_data: cgroup data for this cgroup
-   *	@sk_cgrp: this socket's cgroup-specific proto data
+   *	@sk_memcg: this socket's memory cgroup association
    *	@sk_write_pending: a write to stream socket waits to start
    *	@sk_state_change: callback to indicate change in the state of the sock
    *	@sk_data_ready: callback to indicate there is data to be processed
@@@ -444,8 -428,11 +428,8 @@@ struct sock 
  #ifdef CONFIG_SECURITY
  	void			*sk_security;
  #endif
 -	__u32			sk_mark;
 -#ifdef CONFIG_CGROUP_NET_CLASSID
 -	u32			sk_classid;
 -#endif
 +	struct sock_cgroup_data	sk_cgrp_data;
- 	struct cg_proto		*sk_cgrp;
+ 	struct mem_cgroup	*sk_memcg;
  	void			(*sk_state_change)(struct sock *sk);
  	void			(*sk_data_ready)(struct sock *sk);
  	void			(*sk_write_space)(struct sock *sk);
@@@ -1051,19 -1036,6 +1035,7 @@@ struct proto 
  #ifdef SOCK_REFCNT_DEBUG
  	atomic_t		socks;
  #endif
- #ifdef CONFIG_MEMCG_KMEM
- 	/*
- 	 * cgroup specific init/deinit functions. Called once for all
- 	 * protocols that implement it, from cgroups populate function.
- 	 * This function has to setup any files the protocol want to
- 	 * appear in the kmem cgroup filesystem.
- 	 */
- 	int			(*init_cgroup)(struct mem_cgroup *memcg,
- 					       struct cgroup_subsys *ss);
- 	void			(*destroy_cgroup)(struct mem_cgroup *memcg);
- 	struct cg_proto		*(*proto_cgroup)(struct mem_cgroup *memcg);
- #endif
 +	int			(*diag_destroy)(struct sock *sk, int err);
  };
  
  int proto_register(struct proto *prot, int alloc_slab);
diff --cc net/ipv4/tcp_ipv4.c
index 205e6745393f,34c26782e114..000000000000
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@@ -2336,12 -2339,6 +2338,7 @@@ struct proto tcp_prot = 
  	.compat_setsockopt	= compat_tcp_setsockopt,
  	.compat_getsockopt	= compat_tcp_getsockopt,
  #endif
- #ifdef CONFIG_MEMCG_KMEM
- 	.init_cgroup		= tcp_init_cgroup,
- 	.destroy_cgroup		= tcp_destroy_cgroup,
- 	.proto_cgroup		= tcp_proto_cgroup,
- #endif
 +	.diag_destroy		= tcp_abort,
  };
  EXPORT_SYMBOL(tcp_prot);
  
