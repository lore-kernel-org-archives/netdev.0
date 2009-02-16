From: Karl Hiramoto <karl@hiramoto.org>
Subject: Re: problem with IPoA (CLIP),  NAT, and VLANS
Date: Mon, 16 Feb 2009 16:02:02 +0100
Message-ID: <49997FEA.9040300@hiramoto.org>
References: <49942409.4080506@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org, netfilter@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <49942409.4080506@hiramoto.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Karl Hiramoto wrote:
>    
> Hi all,
>
> I have a scenario with  CLIP  IPoA(RFC1577) atm link over ADSL on the
> WAN, 801.1q  VLANs on the LAN, and  NAT/MASQUERADE   that does not work.
>
>
> Network config:
> Nat_host <-->  router <---> server
>
> a ping from the Nat_host  reaches the server on the WAN fine, and the
> ping comes back to the  router, but the ping response never reaches the
> Nat_Host.    Using TRACE rules it seems the ICMP ping response gets lost
> inside the router.   I see the same behavior with TCP and UDP.
>
>   

The problem ended up being the packet being corrupted when the vlan tag
was being added and skb_cow_head()  was being called.

Anyone know why skb_cow_head() would corrupt the packet?  Perhaps it was
not allocated correctly?     I'm using a big-endian ARM IXP435 board.

NET_SKB_PAD change was already discussed:
http://kerneltrap.org/mailarchive/linux-netdev/2009/2/7/4919204


Signed-off by: Karl Hiramoto <karl@hiramoto.org>

--- linux-2.6.28.4.a/include/linux/if_vlan.h    2009-02-06
22:47:45.000000000 +0100
+++ linux-2.6.28.4.b/include/linux/if_vlan.h    2009-02-16
13:55:35.000000000 +0100
@@ -183,9 +183,12 @@ static inline struct sk_buff *__vlan_put
 {
        struct vlan_ethhdr *veth;

-       if (skb_cow_head(skb, VLAN_HLEN) < 0) {
-               kfree_skb(skb);
-               return NULL;
+       /* If not enough headroom for vlan tag */
+       if (skb_headroom(skb) < VLAN_HLEN) {
+               if (skb_cow_head(skb, VLAN_HLEN) < 0) {
+                       kfree_skb(skb);
+                       return NULL;
+               }
        }
        veth = (struct vlan_ethhdr *)skb_push(skb, VLAN_HLEN)

--- linux-2.6.28.4.a/include/linux/skbuff.h     2009-02-06
22:47:45.000000000 +0100
+++ linux-2.6.28.4.b/include/linux/skbuff.h     2009-02-16
13:52:54.000000000 +0100
@@ -1263,7 +1263,7 @@ static inline int skb_network_offset(con
  * headroom, you should not reduce this.
  */
 #ifndef NET_SKB_PAD
-#define NET_SKB_PAD    16
+#define NET_SKB_PAD    32
 #endif
