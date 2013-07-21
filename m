From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [BUG] ipv6, rawv6_close(): BUG: unable to handle kernel paging request
Date: Sun, 21 Jul 2013 22:53:52 +0200
Message-ID: <20130721205352.GB15442@order.stressinduktion.org>
References: <51EC283D.5010208@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51EC283D.5010208@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 21, 2013 at 11:58:13PM +0530, Srivatsa S. Bhat wrote:
> I'm seeing this on every boot.
> 
> Version: Latest mainline (commit ea45ea70b)

Thanks for the report! Could you try the following patch?

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 583e8d4..373906c 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1601,9 +1601,9 @@ int ip6mr_sk_done(struct sock *sk)
 	struct mr6_table *mrt;
 
 	rtnl_lock();
+	write_lock_bh(&mrt_lock);
 	ip6mr_for_each_table(mrt, net) {
 		if (sk == mrt->mroute6_sk) {
-			write_lock_bh(&mrt_lock);
 			mrt->mroute6_sk = NULL;
 			net->ipv6.devconf_all->mc_forwarding--;
 			inet6_netconf_notify_devconf(net,
@@ -1611,14 +1611,14 @@ int ip6mr_sk_done(struct sock *sk)
 						     NETCONFA_IFINDEX_ALL,
 						     net->ipv6.devconf_all);
 			write_unlock_bh(&mrt_lock);
-
 			mroute_clean_tables(mrt);
 			err = 0;
-			break;
+			goto out;
 		}
 	}
+	write_unlock_bh(&mrt_lock);
+out:
 	rtnl_unlock();
-
 	return err;
 }
 
