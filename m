From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel problem
Date: Sun, 1 Mar 2009 15:38:01 +0800
Message-ID: <20090301073801.GA8975@gondor.apana.org.au>
References: <20090227084109.GA4156@ff.dom.local> <20090227.005907.94994126.davem@davemloft.net> <20090227091216.GB4156@ff.dom.local> <20090227.011615.104197338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, ash@sevsky.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46054 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752961AbZCAHiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 02:38:15 -0500
Content-Disposition: inline
In-Reply-To: <20090227.011615.104197338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 01:16:15AM -0800, David Miller wrote:
>
> There is some weird conditinalization of skb_bond_should_drop()'s call
> in netif_receive_skb() but that should be easy to change to suit our
> needs.  Perhaps by putting the calculation of the netdevice bonding
> pointers into that function.

I had a look at this and gave up quickly :) netif_receive_skb
is trying to deliver the packet to any ptype listeners bound
to this device if skb_bond_should_drop returns true.  This is
very different from what the other callers of skb_bond_should_drop
are trying to do.

So I'm opting for the easy way out right now.

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

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index e9db889..2886d2f 100644
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
+	if (netpoll_rx(skb))
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
