From: Pedro Garcia <pedro.netdev@dondevamos.com>
Subject: Re: [PATCH] =?UTF-8?Q?vlan=5Fdev=3A=20VLAN=20=30=20should=20be=20treated?=
 =?UTF-8?Q?=20as=20=22no=20vlan=20tag=22=20=28=38=30=32=2E=31p=20packet=29?=
Date: Mon, 14 Jun 2010 18:49:09 +0200
Message-ID: <5c6d1ac43fd8ad25661ebfba57c02174@dondevamos.com>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com> <1276466190.14011.223.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Ben Hutchings <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 13.Red-213-97-209.staticIP.rima-tde.net ([213.97.209.13]:60955
	"EHLO smtp1.dondevamos.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754923Ab0FNQtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 12:49:12 -0400
In-Reply-To: <1276466190.14011.223.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Jun 2010 22:56:30 +0100, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> I have no particular opinion on this change, but you need to read and
> follow Documentation/SubmittingPatches.
> 
> Ben.

Sorry, first kernel patch, and I did not know about it. I resubmit with
the correct style / format:

I am using kernel 2.6.26 in a linux box, and I have another box in the
network using 802.1p (priority tagging, but no VLAN).

Without the 8021q module loaded in the kernel, all 802.1p packets are
silently discarded (probably as expected, as the protocol is not loaded in
the kernel).

When I load 8021q module, these packets are forwarded to the module, but
they are discarded also as VLAN 0 is not configured.

I think this should not be the default behaviour, as VLAN 0 is not really
a VLAN, so it should be treated differently.

I could define the VLAN 0 (ip link add link eth0 name eth0.dot1p type vlan
id 0), but then I have a lot of issues with the ARP table entries, as to
ping the other box, outgoing traffic goes through eth0, but incoming arp
reply ends up in eth0.dot1p. In the end this means I can not communicate
with the box using 802.1p unless I use 802.1p tagging for all traffic in
the network (the linux box and all other), which is not a must of the
spec.

I have developed a patch for vlan_dev.c which makes VLAN 0 to be just
reintroduced to netif_rx but with no VLAN tagging if VLAN 0 has not been
defined, so the default behaviour is to ignore the VLAN tagging and accept
the packet as if it was not tagged, and one can still define something
different for VLAN 0 if desired (so it is backwards compatible).

Signed-off-by: Pedro Garcia <pedro.netdev@dondevamos.com>
--- net/8021q/vlan_dev.c.orig   2008-07-13 23:51:29.000000000 +0200
+++ net/8021q/vlan_dev.c        2010-06-14 18:07:35.000000000 +0200
@@ -151,6 +151,7 @@ int vlan_skb_recv(struct sk_buff *skb, s
        struct vlan_hdr *vhdr;
        unsigned short vid;
        struct net_device_stats *stats;
+       struct net_device *vlan_dev;
        unsigned short vlan_TCI;
 
        skb = skb_share_check(skb, GFP_ATOMIC);
@@ -165,11 +166,23 @@ int vlan_skb_recv(struct sk_buff *skb, s
        vid = (vlan_TCI & VLAN_VID_MASK);
 
        rcu_read_lock();
-       skb->dev = __find_vlan_dev(dev, vid);
-       if (!skb->dev) {
+       vlan_dev = __find_vlan_dev(dev, vid);
+       if (vlan_dev) {
+               skb->dev = vlan_dev;
+       } else if (vid) {
                pr_debug("%s: ERROR: No net_device for VID: %u on dev:
%s\n",
                         __func__, (unsigned int)vid, dev->name);
                goto err_unlock;
+       } else {
+               /* 2010-06-13: Pedro Garcia
+                  The packet is VLAN tagged, but VID is 0 and the user
has
+                  not defined anything for VLAN 0, so it is a 802.1p
packet.
+                  We will just netif_rx it later to the original
interface,
+                  but with the skb->proto set to the wrapped proto, so we
do
+                  nothing here. */
+
+               pr_debug("%s: INFO: VLAN 0 used as default VLAN on dev:
%s\n",
+                        __func__, dev->name);
        }
 
        skb->dev->last_rx = jiffies;

