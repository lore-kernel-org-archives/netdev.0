From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: BUG: Bisected Gianfar in bridge not forwarding packets (was:
 3.0-rc1 Bridge not forwarding unicast packages)
Date: Wed, 10 Aug 2011 13:19:48 +0200
Message-ID: <20110810111947.GC1909@minipsycho.brq.redhat.com>
References: <CAMvAeqOA0=FnjB2oPPCEYpkXdKrmqOs+MwAqszV5sTGys_a3mQ@mail.gmail.com>
 <20110810090014.GB1909@minipsycho.brq.redhat.com>
 <CAMvAeqO2bLaPwmdW+c+7hz-ec=-tF6Z0EFBv=FA7+rU_QZ_wDA@mail.gmail.com>
 <CAMvAeqM-oH1UzxEp9PgO6ZP-AKtqosuMg5za25_X8DpPJMDX2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, sebastian.belden@googlemail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
To: Michael Guntsche <mguntsche@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMvAeqM-oH1UzxEp9PgO6ZP-AKtqosuMg5za25_X8DpPJMDX2w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Aug 10, 2011 at 12:30:16PM CEST, mguntsche@gmail.com wrote:
>On Wed, Aug 10, 2011 at 11:59 AM, Michael Guntsche <mguntsche@gmail.co=
m> wrote:
><snip>
>>>>Offload parameters for lan_wire:
>>>>rx-checksumming: off
>>>>tx-checksumming: off
>>>>scatter-gather: off
>>>>tcp-segmentation-offload: off
>>>>udp-fragmentation-offload: off
>>>>generic-segmentation-offload: off
>>>>generic-receive-offload: on
>>>>large-receive-offload: off
>>>>rx-vlan-offload: off
>>>>tx-vlan-offload: off
>>>>ntuple-filters: off
>>>>receive-hashing: off
>>>>
>>>>The Bridge device on the other hand....
>>>>
>>>>Offload parameters for lan:
>>>>rx-checksumming: on
>>>>tx-checksumming: on
>>>>scatter-gather: off
>>>>tcp-segmentation-offload: off
>>>>udp-fragmentation-offload: off
>>>>generic-segmentation-offload: off
>>>>generic-receive-offload: on
>>>>large-receive-offload: off
>>>>rx-vlan-offload: off
>>>>tx-vlan-offload: on
>>> =A0^^^^^^^^^^^^^^^^^^^ is this gfar?
>> No the "Lan" nic is the bridge itself. The gfar in question is lan_w=
ire.
>>
>> /Michael
>>
>
>Ok I would have saved hours of bisecting if I had just used the -e
>switch with tcpdump from the beginning.
>Jiri first of all the patch makes the connection work again. I can
>ping the client on the wlan from the server and vice-versa. Taking a
>look at the tcpdump (WITH -e) makes it obvious why it fails with the
>non patched version...
>
>This is a capture from the gfar lan port on the bridge with no patch a=
pplied
>12:13:24.011492 00:13:d4:4f:a2:dc (oui Unknown) > b4:07:f9:70:b7:c1
>(oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 19, p 0,
>ethertype IPv4, gibson.comsick.at > 192.168.42.55: ICMP echo request,
>id 23567, seq 74, length 64
>
>As you can see we get a VLAN package????

Ugh, this is what I expected. Patch to fix:

Subject: [patch net-2.6] gianfar: prevent buggy hw rx vlan tagging

On some buggy chips, "vlan tag present" flag is set which causes packet
loss. Fix this by checking if rx vlan accel is enabled in features.

Reported-by: Michael Guntsche <mguntsche@gmail.com>
Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/gianfar.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 2659daa..31d5c57 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2710,8 +2710,13 @@ static int gfar_process_frame(struct net_device =
*dev, struct sk_buff *skb,
 	/* Tell the skb what kind of packet this is */
 	skb->protocol =3D eth_type_trans(skb, dev);
=20
-	/* Set vlan tag */
-	if (fcb->flags & RXFCB_VLN)
+	/*
+	 * There's need to check for NETIF_F_HW_VLAN_RX here.
+	 * Even if vlan rx accel is disabled, on some chips
+	 * RXFCB_VLN is pseudo randomly set.
+	 */
+	if (dev->features & NETIF_F_HW_VLAN_RX &&
+	    fcb->flags & RXFCB_VLN)
 		__vlan_hwaccel_put_tag(skb, fcb->vlctl);
=20
 	/* Send the packet up the stack */
--=20
1.7.6
