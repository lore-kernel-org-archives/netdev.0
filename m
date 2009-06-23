From: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
Subject: [PATCH 10/10] nf_conntrack: Use rcu_barrier().
Date: Tue, 23 Jun 2009 17:04:44 +0200
Message-ID: <20090623150444.22490.27931.stgit@localhost>
References: <20090623150330.22490.87327.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>,
	"Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dougthompson-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bluesmoke-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, "Patrick McHardy" <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	christine.caulfield-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tytso-3s7WtUTddSA@public.gmane.org, adilger-xsfywfwIY+M@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090623150330.22490.87327.stgit@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I'm not sure which is are most optimal place to call rcu_barrier().
The patch probably calls rcu_barrier() too much, but its a better
safe than sorry approach.

There is embedded some comments that I would like Patrick McHardy
to look at.

Signed-off-by: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
---

 net/netfilter/nf_conntrack_core.c       |    5 +++++
 net/netfilter/nf_conntrack_standalone.c |    2 ++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 5f72b94..cea4537 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1084,6 +1084,8 @@ static void nf_conntrack_cleanup_init_net(void)
 {
 	nf_conntrack_helper_fini();
 	nf_conntrack_proto_fini();
+	rcu_barrier();
+	/* Need to wait for call_rcu() before dealloc the kmem_cache */
 	kmem_cache_destroy(nf_conntrack_cachep);
 }
 
@@ -1118,6 +1120,9 @@ void nf_conntrack_cleanup(struct net *net)
 	/* This makes sure all current packets have passed through
 	   netfilter framework.  Roll on, two-stage module
 	   delete... */
+	/* hawk-4UpuNZONu4c@public.gmane.org 2009-06-20: Think this should be replaced by a
+          rcu_barrier() ???
+	*/
 	synchronize_net();
 
 	nf_conntrack_cleanup_net(net);
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 1935153..29c6cd0 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -500,6 +500,8 @@ static void nf_conntrack_net_exit(struct net *net)
 	nf_conntrack_standalone_fini_sysctl(net);
 	nf_conntrack_standalone_fini_proc(net);
 	nf_conntrack_cleanup(net);
+	/* hawk-4UpuNZONu4c@public.gmane.org: Think rcu_barrier() should to be called earlier? */
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
 static struct pernet_operations nf_conntrack_net_ops = {

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
