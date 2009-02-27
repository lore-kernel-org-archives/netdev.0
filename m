From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel problem
Date: Fri, 27 Feb 2009 12:11:36 +0800
Message-ID: <20090227041136.GA21468@gondor.apana.org.au>
References: <20090226093902.GA12753@gondor.apana.org.au> <20090226105616.GA5754@ff.dom.local> <20090226115604.GA13592@gondor.apana.org.au> <20090226.041037.134928084.davem@davemloft.net> <20090226130631.GA14125@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, ash@sevsky.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55600 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754032AbZB0ELs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 23:11:48 -0500
Content-Disposition: inline
In-Reply-To: <20090226130631.GA14125@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2009 at 09:06:31PM +0800, Herbert Xu wrote:
>
> OK after much head scratching and staring, it turns out that
> this is caused by the VLAN path not doing the netpoll check
> which would normally drop the packets when a printk is active.

Note that this patch doesn't apply to net-next-2.6 as GRO has
changed there.  But it should be easy to manually slot it in.
Let me know if there are any problems.

netpoll: Add drop checks to all entry points

The netpoll entry checks are required to ensure that we don't
receive normal packets when invoked via netpoll.  Unfortunately
it only ever worked for the netif_receive_skb/netif_rx entry
points.  The VLAN (and subsequently GRO) entry point didn't
have the check and therefore can trigger all sorts of weird
problems.

This patch adds the netpoll check to all entry points.

I'm still uneasy with receiving at all under netpoll (which
apparently is only used by the out-of-tree kdump code).  The
reason is it is perfectly legal to receive all data including
headers into highmem if netpoll is off, but if you try to do
that with netpoll on and someone gets a printk in an IRQ handler
you're going to get a nice BUG_ON.

Fortunately I don't think anyone is receiving everything into
highmem as it stands.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index e9db889..a37782d 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -1,12 +1,16 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/if_vlan.h>
+#include <linux/netpoll.h>
 #include "vlan.h"
 
 /* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
 int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 		      u16 vlan_tci, int polling)
 {
+	if (netpoll_receive_skb(skb))
+		return NET_RX_DROP;
+
 	if (skb_bond_should_drop(skb))
 		goto drop;
 
@@ -100,6 +104,9 @@ int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
 {
 	int err = NET_RX_SUCCESS;
 
+	if (netpoll_receive_skb(skb))
+		return NET_RX_DROP;
+
 	switch (vlan_gro_common(napi, grp, vlan_tci, skb)) {
 	case -1:
 		return netif_receive_skb(skb);
@@ -126,6 +133,9 @@ int vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 	if (!skb)
 		goto out;
 
+	if (netpoll_receive_skb(skb))
+		goto out;
+
 	err = NET_RX_SUCCESS;
 
 	switch (vlan_gro_common(napi, grp, vlan_tci, skb)) {
diff --git a/net/core/dev.c b/net/core/dev.c
index a17e006..72b0d26 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2488,6 +2488,9 @@ static int __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 
 int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
+	if (netpoll_receive_skb(skb))
+		return NET_RX_DROP;
+
 	switch (__napi_gro_receive(napi, skb)) {
 	case -1:
 		return netif_receive_skb(skb);
@@ -2558,6 +2561,9 @@ int napi_gro_frags(struct napi_struct *napi, struct napi_gro_fraginfo *info)
 	if (!skb)
 		goto out;
 
+	if (netpoll_receive_skb(skb))
+		goto out;
+
 	err = NET_RX_SUCCESS;
 
 	switch (__napi_gro_receive(napi, skb)) {

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
