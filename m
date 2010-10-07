From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Thu, 7 Oct 2010 12:31:04 +1100
Message-ID: <20101007123104.bf7a9808.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/caif/caif_socket.c between commit
79315068f4560f3f7bd6e9790190dcb43059770c ("caif: fix two caif_connect()
bugs") from the net-current tree and commit
b31fa5bad576cd8180a5ad70c648333b44320d44 ("net/caif: Use pr_fmt") from
the net tree.

I fixed it up (see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/caif/caif_socket.c
index 4bf28f2,abcba53..0000000
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@@ -897,23 -888,14 +889,22 @@@ static int caif_connect(struct socket *
  		cf_sk->sk.sk_state = CAIF_DISCONNECTED;
  		goto out;
  	}
 -	dev = dev_get_by_index(sock_net(sk), ifindex);
 +
 +	err = -ENODEV;
 +	rcu_read_lock();
 +	dev = dev_get_by_index_rcu(sock_net(sk), ifindex);
 +	if (!dev) {
 +		rcu_read_unlock();
 +		goto out;
 +	}
  	cf_sk->headroom = LL_RESERVED_SPACE_EXTRA(dev, headroom);
 +	mtu = dev->mtu;
 +	rcu_read_unlock();
 +
  	cf_sk->tailroom = tailroom;
 -	cf_sk->maxframe = dev->mtu - (headroom + tailroom);
 -	dev_put(dev);
 +	cf_sk->maxframe = mtu - (headroom + tailroom);
  	if (cf_sk->maxframe < 1) {
- 		pr_warning("CAIF: %s(): CAIF Interface MTU too small (%u)\n",
- 			   __func__, mtu);
 -		pr_warn("CAIF Interface MTU too small (%d)\n", dev->mtu);
 -		err = -ENODEV;
++		pr_warn("CAIF Interface MTU too small (%d)\n", mtu);
  		goto out;
  	}
  
