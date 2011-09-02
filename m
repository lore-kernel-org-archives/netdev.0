From: Phil Sutter <phil.sutter@viprinet.com>
Subject: [PATCH] af_packet: flush complete kernel cache in packet_sendmsg
Date: Fri,  2 Sep 2011 13:08:06 +0200
Message-ID: <1314961686-30870-1-git-send-email-phil.sutter@viprinet.com>
References: <20110505141107.GC30443@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20110505141107.GC30443@orbit.nwl.cc>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This flushes the cache before and after accessing the mmapped packet
buffer. It seems like the call to flush_dcache_page from inside
__packet_get_status is not enough on Kirkwood (or ARM in general).
---
I know this is far from an optimal solution, but it's in fact the only working
one I found. And it shouldn't interfere with unaffected target systems. So
anyone relying on a working TX_RING on Kirkwood may refer to this patch. Any
ARM/cache/Marvell/Kirkwood experts out there feel free to improve this.
---
 net/packet/af_packet.c |   24 ++++++++++++++++++++----
 1 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 243946d..d7b5c2e 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -87,6 +87,14 @@
 #include <net/inet_common.h>
 #endif
 
+/* whether we need additional cacheflushing between user- and kernel-space */
+#ifdef CONFIG_ARCH_KIRKWOOD
+#  define ENABLE_CACHEPROB_WORKAROUND
+#  define kw_extra_cache_flush()	flush_cache_all()
+#else
+#  define kw_extra_cache_flush()	/* nothing */
+#endif
+
 /*
    Assumptions:
    - if device has no dev->hard_header routine, it adds and removes ll header
@@ -1239,10 +1247,13 @@ static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock *sk = sock->sk;
 	struct packet_sock *po = pkt_sk(sk);
-	if (po->tx_ring.pg_vec)
-		return tpacket_snd(po, msg);
-	else
-		return packet_snd(sock, msg, len);
+	int rc;
+
+	kw_extra_cache_flush();
+	rc = po->tx_ring.pg_vec ? tpacket_snd(po, msg) :
+			packet_snd(sock, msg, len);
+	kw_extra_cache_flush();
+	return rc;
 }
 
 /*
@@ -2622,6 +2633,11 @@ static int __init packet_init(void)
 	sock_register(&packet_family_ops);
 	register_pernet_subsys(&packet_net_ops);
 	register_netdevice_notifier(&packet_netdev_notifier);
+
+#ifdef ENABLE_CACHEPROB_WORKAROUND
+	printk(KERN_INFO "af_packet: cache coherency workaround for kirkwood is active!\n");
+#endif
+
 out:
 	return rc;
 }
-- 
1.7.3.4
