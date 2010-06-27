From: Pedro Garcia <pedro.netdev@dondevamos.com>
Subject: Re: [PATCH] =?UTF-8?Q?vlan=5Fdev=3A=20VLAN=20=30=20should=20be=20treated?=
 =?UTF-8?Q?=20as=20=22no=20vlan=20tag=22=20=28=38=30=32=2E=31p=20packet=29?=
Date: Mon, 28 Jun 2010 01:21:19 +0200
Message-ID: <c38a6e1add643eb78bd0d28ee3984cf4@dondevamos.com>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com> <1276466190.14011.223.camel@localhost> <5c6d1ac43fd8ad25661ebfba57c02174@dondevamos.com> <1276534945.2074.11.camel@achroite.uk.solarflarecom.com> <4C1662C3.3070708@trash.net> <1276542772.2444.13.camel@edumazet-laptop> <311b59aee7d648c6124a84b5ca06ac60@dondevamos.com> <1276679284.2632.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 13.Red-213-97-209.staticIP.rima-tde.net ([213.97.209.13]:60822
	"EHLO smtp1.dondevamos.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750828Ab0F0XVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jun 2010 19:21:24 -0400
In-Reply-To: <1276679284.2632.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Jun 2010 11:08:04 +0200, Eric Dumazet <eric.dumazet@gmail.co=
m>
wrote:
> Le mercredi 16 juin 2010 =C3=A0 10:49 +0200, Pedro Garcia a =C3=A9cri=
t :
>> On Mon, 14 Jun 2010 21:12:52 +0200, Eric Dumazet <eric.dumazet@gmail=
=2Ecom>
>=20
>> > Good luck for your first patch !
>>=20
>> Here it is again. I added the modifications in
>> http://kerneltrap.org/mailarchive/linux-netdev/2010/5/23/6277868 for=
 HW
>> accelerated incoming packets (it did not apply cleanly on the last
>> version of
>> the kernel, so I applied manually). Now, if the VLAN 0 is not explic=
itly
>> created by the user, VLAN 0 packets will be treated as no VLAN (802.=
1p
>> packets), instead of dropping them.
>>=20
>> The patch is now for two files: vlan_core (accel) and vlan_dev (non
>> accel)
>>=20
>> I can not test on HW accelerated devices, so if someone can check it=
 I
>> will appreciate (even though in the thread above it looked like yes)=
=2E For
>> non accel I tessted in 2.6.26. Now the patch is for
>> net-next-2.6, and it compiles OK, but I a have to setup a test
>> environment to check it is still OK (should, but better to test).
>>=20
>> Signed-off-by: Pedro Garcia <pedro.netdev@dondevamos.com>
>=20
> OK, the patch itself is correct.
>=20
> Now, could you please send it again with a proper changelog ?
>=20
> In this changelog, please explain why patch is needed, and
> keep lines short (< 72 chars), like the one you did in your first mai=
l.
>=20
> I'll then add my Signed-off-by, since I wrote the accelerated part ;)
>=20
> Note : I wonder if another patch is needed, in case 8021q module is
> _not_ loaded. We probably should accept vlan 0 frames in this case ?

Last version of the patch. Now I think it is OK, of course pending=20
Eric's signed-off-by for the accel HW part.

If this is too long for a changelog, tell me and I will try to sum it
up:

- Without the 8021q module loaded in the kernel, all 802.1p packets=20
(VLAN 0 but QoS tagging) are silently discarded (as expected, as=20
the protocol is not loaded).

- Without this patch in 8021q module, these packets are forwarded to=20
the module, but they are discarded also if VLAN 0 is not configured,
which should not be the default behaviour, as VLAN 0 is not really
a VLANed packet but a 802.1p packet. Defining VLAN 0 makes it almost
impossible to communicate with mixed 802.1p and non 802.1p devices on
the same network due to arp table issues.

- Changed logic to skip vlan specific code in vlan_skb_recv if VLAN=20
is 0 and we have not defined a VLAN with ID 0, but we accept the=20
packet with the encapsulated proto and pass it later to netif_rx.

- In the vlan device event handler, added some logic to add VLAN 0=20
to HW filter in devices that support it (this prevented any traffic
in VLAN 0 to reach the stack in e1000e with HW filter under 2.6.35,
and probably also with other HW filtered cards, so we fix it here).

- In the vlan unregister logic, prevent the elimination of VLAN 0=20
in devices with HW filter.

- The default behaviour is to ignore the VLAN 0 tagging and accept
the packet as if it was not tagged, but we can still define a=20
VLAN 0 if desired (so it is backwards compatible).

Signed-off-by: Pedro Garcia <pedro.netdev@dondevamos.com>
--
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 3c1c8c1..d9abc43 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -155,9 +155,10 @@ void unregister_vlan_dev(struct net_device *dev, s=
truct list_head *head)
        BUG_ON(!grp);
=20
        /* Take it out of our own structures, but be sure to interlock =
with
-        * HW accelerating devices or SW vlan input packet processing.
+        * HW accelerating devices or SW vlan input packet processing i=
f
+        * VLAN is not 0 (leave it there for 802.1p).
         */
-       if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
+       if (vlan_id && (real_dev->features & NETIF_F_HW_VLAN_FILTER))
                ops->ndo_vlan_rx_kill_vid(real_dev, vlan_id);
=20
        grp->nr_vlans--;
@@ -419,6 +420,14 @@ static int vlan_device_event(struct notifier_block=
 *unused, unsigned long event,
        if (is_vlan_dev(dev))
                __vlan_device_event(dev, event);
=20
+       if ((event =3D=3D NETDEV_UP) &&
+           (dev->features & NETIF_F_HW_VLAN_FILTER) &&
+           (dev->netdev_ops->ndo_vlan_rx_add_vid)) {
+               pr_info("8021q: adding VLAN 0 to HW filter on device %s=
\n",
+                       dev->name);
+               dev->netdev_ops->ndo_vlan_rx_add_vid(dev, 0);
+       }
+
        grp =3D __vlan_find_group(dev);
        if (!grp)
                goto out;
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 50f58f5..daaca31 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -8,6 +8,9 @@
 int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
                      u16 vlan_tci, int polling)
 {
+       struct net_device *vlan_dev;
+       u16 vlan_id;
+
        if (netpoll_rx(skb))
                return NET_RX_DROP;
=20
@@ -16,10 +19,14 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct v=
lan_group *grp,
=20
        skb->skb_iif =3D skb->dev->ifindex;
        __vlan_hwaccel_put_tag(skb, vlan_tci);
-       skb->dev =3D vlan_group_get_device(grp, vlan_tci & VLAN_VID_MAS=
K);
+       vlan_id =3D vlan_tci & VLAN_VID_MASK;
+       vlan_dev =3D vlan_group_get_device(grp, vlan_id);
=20
-       if (!skb->dev)
-               goto drop;
+       if (vlan_dev)
+               skb->dev =3D vlan_dev;
+       else
+               if (vlan_id)
+                       goto drop;
=20
        return (polling ? netif_receive_skb(skb) : netif_rx(skb));
=20
@@ -82,16 +89,22 @@ vlan_gro_common(struct napi_struct *napi, struct vl=
an_group *grp,
                unsigned int vlan_tci, struct sk_buff *skb)
 {
        struct sk_buff *p;
+       struct net_device *vlan_dev;
+       u16 vlan_id;
=20
        if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
                skb->deliver_no_wcard =3D 1;
=20
        skb->skb_iif =3D skb->dev->ifindex;
        __vlan_hwaccel_put_tag(skb, vlan_tci);
-       skb->dev =3D vlan_group_get_device(grp, vlan_tci & VLAN_VID_MAS=
K);
-
-       if (!skb->dev)
-               goto drop;
+       vlan_id =3D vlan_tci & VLAN_VID_MASK;
+       vlan_dev =3D vlan_group_get_device(grp, vlan_id);
+
+       if (vlan_dev)
+               skb->dev =3D vlan_dev;
+       else
+               if (vlan_id)
+                       goto drop;
=20
        for (p =3D napi->gro_list; p; p =3D p->next) {
                NAPI_GRO_CB(p)->same_flow =3D
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 5298426..21f7229 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -142,6 +142,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_d=
evice *dev,
 {
        struct vlan_hdr *vhdr;
        struct vlan_rx_stats *rx_stats;
+       struct net_device *vlan_dev;
        u16 vlan_id;
        u16 vlan_tci;
=20
@@ -157,53 +158,69 @@ int vlan_skb_recv(struct sk_buff *skb, struct net=
_device *dev,
        vlan_id =3D vlan_tci & VLAN_VID_MASK;
=20
        rcu_read_lock();
-       skb->dev =3D __find_vlan_dev(dev, vlan_id);
-       if (!skb->dev) {
-               pr_debug("%s: ERROR: No net_device for VID: %u on dev: =
%s\n",
-                        __func__, vlan_id, dev->name);
-               goto err_unlock;
-       }
-
-       rx_stats =3D per_cpu_ptr(vlan_dev_info(skb->dev)->vlan_rx_stats=
,
-                              smp_processor_id());
-       rx_stats->rx_packets++;
-       rx_stats->rx_bytes +=3D skb->len;
-
-       skb_pull_rcsum(skb, VLAN_HLEN);
-
-       skb->priority =3D vlan_get_ingress_priority(skb->dev, vlan_tci)=
;
+       vlan_dev =3D __find_vlan_dev(dev, vlan_id);
=20
-       pr_debug("%s: priority: %u for TCI: %hu\n",
-                __func__, skb->priority, vlan_tci);
-
-       switch (skb->pkt_type) {
-       case PACKET_BROADCAST: /* Yeah, stats collect these together.. =
*/
-               /* stats->broadcast ++; // no such counter :-( */
-               break;
-
-       case PACKET_MULTICAST:
-               rx_stats->multicast++;
-               break;
+       /* If the VLAN device is defined, we use it.
+        * If not, and the VID is 0, it is a 802.1p packet (not
+        * really a VLAN), so we will just netif_rx it later to the
+        * original interface, but with the skb->proto set to the
+        * wrapped proto: we do nothing here.
+        */
=20
-       case PACKET_OTHERHOST:
-               /* Our lower layer thinks this is not local, let's make=
 sure.
-                * This allows the VLAN to have a different MAC than th=
e
-                * underlying device, and still route correctly.
-                */
-               if (!compare_ether_addr(eth_hdr(skb)->h_dest,
-                                       skb->dev->dev_addr))
-                       skb->pkt_type =3D PACKET_HOST;
-               break;
-       default:
-               break;
+       if (!vlan_dev) {
+               if (vlan_id) {
+                       pr_debug("%s: ERROR: No net_device for VID: %u =
on dev: %s\n",
+                                __func__, vlan_id, dev->name);
+                       goto err_unlock;
+               }
+               rx_stats =3D NULL;
+       } else {
+               skb->dev =3D vlan_dev;
+
+               rx_stats =3D per_cpu_ptr(vlan_dev_info(skb->dev)->vlan_=
rx_stats,
+                                       smp_processor_id());
+               rx_stats->rx_packets++;
+               rx_stats->rx_bytes +=3D skb->len;
+
+               skb->priority =3D vlan_get_ingress_priority(skb->dev, v=
lan_tci);
+
+               pr_debug("%s: priority: %u for TCI: %hu\n",
+                        __func__, skb->priority, vlan_tci);
+
+               switch (skb->pkt_type) {
+               case PACKET_BROADCAST:
+                       /* Yeah, stats collect these together.. */
+                       /* stats->broadcast ++; // no such counter :-( =
*/
+                       break;
+
+               case PACKET_MULTICAST:
+                       rx_stats->multicast++;
+                       break;
+
+               case PACKET_OTHERHOST:
+                       /* Our lower layer thinks this is not local, le=
t's make
+                       * sure.
+                       * This allows the VLAN to have a different MAC =
than the
+                       * underlying device, and still route correctly.
+                       */
+                       if (!compare_ether_addr(eth_hdr(skb)->h_dest,
+                                               skb->dev->dev_addr))
+                               skb->pkt_type =3D PACKET_HOST;
+                       break;
+               default:
+                       break;
+               }
        }
=20
+       skb_pull_rcsum(skb, VLAN_HLEN);
        vlan_set_encap_proto(skb, vhdr);
=20
-       skb =3D vlan_check_reorder_header(skb);
-       if (!skb) {
-               rx_stats->rx_errors++;
-               goto err_unlock;
+       if (vlan_dev) {
+               skb =3D vlan_check_reorder_header(skb);
+               if (!skb) {
+                       rx_stats->rx_errors++;
+                       goto err_unlock;
+               }
        }
=20
        netif_rx(skb);

