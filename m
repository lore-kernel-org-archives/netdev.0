From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 0/2] fix kernel crash with macvtap on top
	of LRO
Date: Thu, 07 Feb 2013 11:25:13 +0800
Message-ID: <51131E99.8080400@gmail.com>
References: <cover.1360191528.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Sony Chacko <sony.chacko@qlogic.com>, bhutchings@solarflare.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>, linux-driver@qlogic.com,
	"David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1360191528.git.mst@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 02/07/2013 07:02 AM, Michael S. Tsirkin wrote:
> At the moment, macvtap crashes are observed if macvtap is attached
> to an interface with LRO enabled.
> The crash in question is BUG() in macvtap_skb_to_vnet_hdr.
> This happens because several drivers set gso_size but not gso_type
> in incoming skbs.
> The following patches fix this for
> Additionally, cbf1de72324a8105ddcc3d9ce9acbc613faea17e is required
> to fix this for broadcom - would it make sense to cherry-pick
> this patch into 3.8?


Doesn't macvtap need to call skb_warn_if_lro() too like bridge and 
openvswitch? Something like...

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index b181dfb..b2c6227 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -253,6 +253,9 @@ static int macvtap_forward(struct net_device *dev, 
struct sk_buff *skb)
         if (!q)
                 goto drop;

+       if (unlikely(skb_warn_if_lro(skb)))
+               goto drop;
+
         if (skb_queue_len(&q->sk.sk_receive_queue) >= dev->tx_queue_len)
                 goto drop;


I am not saying these drivers don't need to fix, I am just saying if we 
need to fix LRO case.

Thanks.

------------------------------------------------------------------------------
Free Next-Gen Firewall Hardware Offer
Buy your Sophos next-gen firewall before the end March 2013 
and get the hardware for free! Learn more.
http://p.sf.net/sfu/sophos-d2d-feb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
