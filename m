From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2 net-next 3/8] tun: report orphan frags errors to zero copy
	callback
Date: Wed, 31 Oct 2012 12:31:15 +0200
Message-ID: <753585407bf5ab8b757921d4d7182a08668f7713.1351679008.git.mst@redhat.com>
References: <cover.1351679008.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <cover.1351679008.git.mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

When tun transmits a zero copy skb, it orphans the frags
which might need to allocate extra memory, in atomic context.
If that fails, notify ubufs callback before freeing the skb
as a hint that device should disable zerocopy mode.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/tun.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 3157519..613f826 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -433,6 +433,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 
 drop:
 	dev->stats.tx_dropped++;
+	skb_tx_error(skb, -ENOMEM);
 	kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
-- 
MST
