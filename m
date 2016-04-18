From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 18 Apr 2016 11:31:16 +1000
Message-ID: <20160418113116.6f7f8740@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Craig Gallek <kraig@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/ipv4/udp.c

between commit:

  d894ba18d4e4 ("soreuseport: fix ordering for mixed v4/v6 sockets")

from the net tree and commit:

  ca065d0cf80f ("udp: no longer use SLAB_DESTROY_BY_RCU")

from the net-next tree.

I tried to fixed it up (see below).  Unfortunately,
hlist_add_tail_rcu() does not exist.  So instead I have reverted commit
d894ba18d4e4 ("soreuseport: fix ordering for mixed v4/v6 sockets") for
today.

-- 
Cheers,
Stephen Rothwell

diff --cc net/ipv4/udp.c
index a2e7f55a1f61,f1863136d3e4..000000000000
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@@ -339,13 -336,8 +336,13 @@@ found
  
  		hslot2 = udp_hashslot2(udptable, udp_sk(sk)->udp_portaddr_hash);
  		spin_lock(&hslot2->lock);
 -		hlist_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
 -					 &hslot2->head);
 +		if (IS_ENABLED(CONFIG_IPV6) && sk->sk_reuseport &&
 +			sk->sk_family == AF_INET6)
- 			hlist_nulls_add_tail_rcu(&udp_sk(sk)->udp_portaddr_node,
- 						 &hslot2->head);
++			hlist_add_tail_rcu(&udp_sk(sk)->udp_portaddr_node,
++					   &hslot2->head);
 +		else
- 			hlist_nulls_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
- 						 &hslot2->head);
++			hlist_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
++					   &hslot2->head);
  		hslot2->count++;
  		spin_unlock(&hslot2->lock);
  	}
