From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [RFC] vxlan: convert remote list to list_rcu
Date: Tue, 4 Jun 2013 20:20:22 +0300
Message-ID: <CAF1J0HPxqPinPnieVtw4oGJr9h9vdLg8EDYQmGicZKbrrJS1Qg@mail.gmail.com>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-3-git-send-email-mike.rapoport@ravellosystems.com>
	<20130530110948.GA10532@casper.infradead.org>
	<CAF1J0HP+Wu9HjEELDaXM2BMREMuKByWr_zz=PwHeNUt=EVbdvw@mail.gmail.com>
	<20130530113739.GB10532@casper.infradead.org>
	<20130531091740.70b3e077@nehalam.linuxnetplumber.net>
	<20130602102942.GA21706@zed>
	<20130603112616.3ad018e2@nehalam.linuxnetplumber.net>
	<OFE7269995.C8314337-ON85257B7F.006B4FC1-85257B7F.006F87F8@us.ibm.com>
	<20130603134512.46ce434f@nehalam.linuxnetplumber.net>
	<OFB0EFD290.FD0EF659-ON85257B7F.00733AF7-85257B7F.0077A32C@us.ibm.com>
	<CAF1J0HMD-N64Qb2v3oLF7ovsHqhbh0w730t3cWn4uD6wdcLY7Q@mail.gmail.com>
	<OFB0D808A5.49ED47B9-ON85257B80.004098A5-85257B80.004651FC@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Thomas Graf <tgraf@suug.ch>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog113.obsmtp.com ([74.125.245.94]:58113 "HELO
	na3sys010aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751795Ab3FDRUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 13:20:23 -0400
Received: by mail-oa0-f52.google.com with SMTP id o13so356424oag.25
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 10:20:22 -0700 (PDT)
In-Reply-To: <OFB0D808A5.49ED47B9-ON85257B80.004098A5-85257B80.004651FC@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 04, 2013 at 08:48:06AM -0400, David Stevens wrote:
> Mike Rapoport <mike.rapoport@ravellosystems.com> wrote on 06/04/2013
> 05:18:08 AM:
>
> Actually, we could make it an fdb and also have "use" and "updated"
> stats that way, and/or use the existing fdb code and add an entry
> with MAC "00:00:00:00:00:00" [which is disallowed via the generic
> fdb code, so can't be in the fdb table otherwise].

If I've understood you right it would be something like this:

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8111565..b7801e3 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -80,6 +80,8 @@ MODULE_PARM_DESC(log_ecn_error, "Log packets
received with corrupted ECN");

 static unsigned int vxlan_net_id;

+static u8 ALL_ZEROS_MAC[ETH_ALEN];
+
 /* per UDP socket information */
 struct vxlan_sock {
  struct hlist_node hlist;
@@ -1025,13 +1027,10 @@ static netdev_tx_t vxlan_xmit_one(struct
sk_buff *skb, struct net_device *dev,
  vni = rdst->remote_vni;
  dst = rdst->remote_ip;

- if (!dst) {
- if (did_rsc) {
- /* short-circuited back to local bridge */
- vxlan_encap_bypass(skb, vxlan, vxlan);
- return NETDEV_TX_OK;
- }
- goto drop;
+ if (did_rsc) {
+ /* short-circuited back to local bridge */
+ vxlan_encap_bypass(skb, vxlan, vxlan);
+ return NETDEV_TX_OK;
  }

  if (!skb->encapsulation) {
@@ -1174,14 +1173,19 @@ static netdev_tx_t vxlan_xmit(struct sk_buff
*skb, struct net_device *dev)
  }

  if (f == NULL) {
- rdst0 = &vxlan->default_dst;
+ f = vxlan_find_mac(vxlan, ALL_ZEROS_MAC);
+ if (f == NULL) {
+ if ((vxlan->flags & VXLAN_F_L2MISS) &&
+    !is_multicast_ether_addr(eth->h_dest))
+ vxlan_fdb_miss(vxlan, eth->h_dest);
+
+ dev->stats.tx_dropped++;
+                        dev_kfree_skb(skb);
+                        return NETDEV_TX_OK;
+ }
+ }

- if (rdst0->remote_ip == htonl(INADDR_ANY) &&
-    (vxlan->flags & VXLAN_F_L2MISS) &&
-    !is_multicast_ether_addr(eth->h_dest))
- vxlan_fdb_miss(vxlan, eth->h_dest);
- } else
- rdst0 = &f->remote;
+ rdst0 = &f->remote;

  rc = NETDEV_TX_OK;

@@ -1590,6 +1594,17 @@ static int vxlan_newlink(struct net *net,
struct net_device *dev,
  return -EEXIST;
  }

+ if (dst->remote_ip != htonl(INADDR_ANY)) {
+ err = vxlan_fdb_create(vxlan, ALL_ZEROS_MAC, dst->remote_ip,
+       NUD_REACHABLE,
+       NLM_F_EXCL|NLM_F_CREATE,
+       dst->remote_port,
+       dst->remote_vni,
+       0, NTF_SELF);
+ if (err)
+ return err;
+ }
+
  vs = vxlan_find_port(net, vxlan->dst_port);
  if (vs)
  ++vs->refcnt;

>

--
Sincerely yours,
Mike.
