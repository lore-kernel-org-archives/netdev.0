From: Gerd Hoffmann <kraxel@suse.de>
Subject: [patch] bridge netfilter bug
Date: Fri, 18 Aug 2006 10:23:35 +0200
Message-ID: <44E57907.8000500@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070303060808070102050009"
Cc: Xen devel list <xen-devel@lists.xensource.com>,
	Jan Beulich <jbeulich@novell.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
To: netdev@vger.kernel.org
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070303060808070102050009
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

  Hi,

The bridging code copies 16 bytes unconditionally, where as the ethernet
header is 14 bytes only.  In most cases it works ok nevertheless due to
NET_IP_ALIGN, sometimes it doesn't though.  Fix is attached below.

please apply,

  Gerd

-- 
Gerd Hoffmann <kraxel@suse.de>
http://www.suse.de/~kraxel/julika-dora.jpeg

--------------070303060808070102050009
Content-Type: text/plain;
 name="nf_bridge-header-size"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nf_bridge-header-size"

Subject: nf_bridge: ethernet header is 14 not 16 bytes
From: jbeulich@novell.com
Acked-by: kraxel@suse.de
References: 150410

The bridge netfilter code saves two more bytes that it should.
In most cases it doesn't hurt because many drivers use NET_IP_ALIGN
to make the IP header aligned, so there are two extra bytes head room
available.

Some drivers don't do that though (sky2 for example), so copying
accesses data outside the skbuff data allocation.  On xen kernels
this can kill the machine with a page fault due to the way how
skbuffs are allocated and the memory is managed.

---
 include/linux/netfilter_bridge.h |    2 +-
 net/bridge/br_netfilter.c        |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.17.orig/include/linux/netfilter_bridge.h
+++ linux-2.6.17/include/linux/netfilter_bridge.h
@@ -57,7 +57,7 @@ void nf_bridge_maybe_copy_header(struct 
 			memcpy(skb->data - 18, skb->nf_bridge->data, 18);
 			skb_push(skb, 4);
 		} else
-			memcpy(skb->data - 16, skb->nf_bridge->data, 16);
+			memcpy(skb->data - 14, skb->nf_bridge->data, 14);
 	}
 }
 
--- linux-2.6.17.orig/net/bridge/br_netfilter.c
+++ linux-2.6.17/net/bridge/br_netfilter.c
@@ -124,7 +124,7 @@ static inline struct nf_bridge_info *nf_
 
 static inline void nf_bridge_save_header(struct sk_buff *skb)
 {
-        int header_size = 16;
+        int header_size = 14;
 
 	if (skb->protocol == htons(ETH_P_8021Q))
 		header_size = 18;

--------------070303060808070102050009
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xensource.com
http://lists.xensource.com/xen-devel

--------------070303060808070102050009--
