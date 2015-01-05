From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Mon, 05 Jan 2015 14:02:58 +0800
Message-ID: <54AA2912.6090903@gmail.com>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com> <1417158128.3268.2@smtp.corp.redhat.com> <5A90DA2E42F8AE43BC4A093BF0678848DED92B@SHSMSX104.ccr.corp.intel.com> <20141201135225.GA16814@casper.infradead.org> <20141202154839.GB5344@t520.home> <20141202170927.GA9457@casper.infradead.org> <20141202173401.GB4126@redhat.com> <20141202174158.GB9457@casper.infradead.org> <5A90DA2E42F8AE43BC4A093BF0678848DEDFDB@SHSMSX104.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	'Jason Wang' <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	"pshelar@nicira.com" <pshelar@nicira.com>
To: "Du, Fan" <fan.du@intel.com>, Thomas Graf <tgraf@suug.ch>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jesse@nicira.com" <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:33299 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959AbbAEGGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 01:06:33 -0500
Received: by mail-pd0-f173.google.com with SMTP id ft15so27444854pdb.18
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 22:06:33 -0800 (PST)
In-Reply-To: <5A90DA2E42F8AE43BC4A093BF0678848DEDFDB@SHSMSX104.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2014=E5=B9=B412=E6=9C=8803=E6=97=A5 10:31, Du, Fan =E5=86=99=E9=
=81=93:
>
>
>> -----Original Message-----
>> From: Thomas Graf [mailto:tgr@infradead.org] On Behalf Of Thomas Gra=
f
>> Sent: Wednesday, December 3, 2014 1:42 AM
>> To: Michael S. Tsirkin
>> Cc: Du, Fan; 'Jason Wang'; netdev@vger.kernel.org; davem@davemloft.n=
et;
>> fw@strlen.de; dev@openvswitch.org; jesse@nicira.com; pshelar@nicira.=
com
>> Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger =
than MTU
>>
>> On 12/02/14 at 07:34pm, Michael S. Tsirkin wrote:
>>> On Tue, Dec 02, 2014 at 05:09:27PM +0000, Thomas Graf wrote:
>>>> On 12/02/14 at 01:48pm, Flavio Leitner wrote:
>>>>> What about containers or any other virtualization environment tha=
t
>>>>> doesn't use Virtio?
>>>>
>>>> The host can dictate the MTU in that case for both veth or OVS
>>>> internal which would be primary container plumbing techniques.
>>>
>>> It typically can't do this easily for VMs with emulated devices:
>>> real ethernet uses a fixed MTU.
>>>
>>> IMHO it's confusing to suggest MTU as a fix for this bug, it's an
>>> unrelated optimization.
>>> ICMP_DEST_UNREACH/ICMP_FRAG_NEEDED is the right fix here.
>>
>> PMTU discovery only resolves the issue if an actual IP stack is runn=
ing inside the
>> VM. This may not be the case at all.
>   ^^^^^^^^^^^^^^^^^^^^^^^^^^^
>
> Some thoughts here:
>
> Think otherwise, this is indeed what host stack should forge a ICMP_D=
EST_UNREACH/ICMP_FRAG_NEEDED
> message with _inner_ skb network and transport header, do whatever ty=
pe of encapsulation,
> and thereafter push such packet upward to Guest/Container, which make=
 them feel, the intermediate node
> or the peer send such message. PMTU should be expected to work correc=
t.
> And such behavior should be shared by all other encapsulation tech if=
 they are also suffered.

Hi David, Jesse and Thomas

As discussed in here: https://www.marc.info/?l=3Dlinux-netdev&m=3D14176=
4712631150&w=3D4 and
quotes from Jesse:
My proposal would be something like this:
  * For L2, reduce the VM MTU to the lowest common denominator on the s=
egment.
  * For L3, use path MTU discovery or fragment inner packet (i.e.
normal routing behavior).
  * As a last resort (such as if using an old version of virtio in the
guest), fragment the tunnel packet.


=46or L2, it's a administrative action
=46or L3, PMTU approach looks better, because once the sender is alerte=
d the reduced MTU,
packet size after encapsulation will not exceed physical MTU, so no add=
itional fragments
efforts needed.
=46or "As a last resort... fragment the tunnel packet", the original pa=
tch:
https://www.marc.info/?l=3Dlinux-netdev&m=3D141715655024090&w=3D4 did t=
he job, but seems it's
not welcomed.

Below raw patch adopts PMTU approach, please review! Any kind of commen=
ts/suggestions
is welcomed.

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e9f81d4..4d1b221 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1771,6 +1771,130 @@ static void vxlan_xmit_one(struct sk_buff *skb,=
 struct net_device *dev,
  		tos =3D ip_tunnel_ecn_encap(tos, old_iph, skb);
  		ttl =3D ttl ? : ip4_dst_hoplimit(&rt->dst);

+		if (skb_is_gso(skb)) {
+			unsigned int inner_l234_hdrlen;
+			unsigned int outer_l34_hdrlen;
+			unsigned int gso_seglen;
+			struct net_device *phy_dev =3D rt->dst.dev;
+
+			inner_l234_hdrlen =3D skb_transport_header(skb) - skb_mac_header(sk=
b);
+			if (skb_shinfo(skb)->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))
+				inner_l234_hdrlen +=3D tcp_hdrlen(skb);
+			if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
+				inner_l234_hdrlen +=3D sizeof(struct udphdr);
+
+			outer_l34_hdrlen =3D sizeof(struct iphdr) + sizeof(struct udphdr) +=
 sizeof(struct vxlanhdr);
+			/* gso_seglen is the GSO-ed skb packet len, adjust gso_size
+			 * to fit into physical netdev MTU
+			 */
+			gso_seglen =3D outer_l34_hdrlen + inner_l234_hdrlen + skb_shinfo(sk=
b)->gso_size;
+			if (gso_seglen > phy_dev->mtu) {
+				struct sk_buff *reply;
+				struct ethhdr *orig_eth;
+				struct ethhdr *new_eth;
+				struct ethhdr *tnl_eth;
+				struct iphdr *orig_ip;
+				struct iphdr *new_ip;
+				struct iphdr *tnl_ip;
+				struct icmphdr *new_icmp;
+				unsigned int room;
+				unsigned int data_len;
+				unsigned int reply_l234_hdrlen;
+				unsigned int vxlan_tnl_hdrlen;
+				struct vxlanhdr *vxh;
+				struct udphdr *uh;
+				__wsum csum;
+
+				/* How much room to store orignal message */
+				room =3D (skb->len > 576) ? 576 : skb->len;
+				room -=3D sizeof(struct iphdr) + sizeof(struct icmphdr);
+
+				/* Ethernet payload len */
+				data_len =3D skb->len - skb_network_offset(skb);
+				if (data_len > room)
+					data_len =3D room;
+
+				reply_l234_hdrlen =3D LL_RESERVED_SPACE(phy_dev) + phy_dev->needed=
_tailroom +
+									sizeof(struct iphdr) + sizeof(struct icmphdr);
+				vxlan_tnl_hdrlen =3D LL_RESERVED_SPACE(phy_dev) + phy_dev->needed_=
tailroom +
+									sizeof(struct iphdr) + sizeof(struct udphdr) + sizeof(struct =
vxlanhdr);
+
+				reply =3D alloc_skb(vxlan_tnl_hdrlen + reply_l234_hdrlen + data_le=
n, GFP_ATOMIC);
+				reply->dev =3D phy_dev;
+				skb_reserve(reply, vxlan_tnl_hdrlen + reply_l234_hdrlen);
+
+				new_icmp =3D (struct icmphdr *)__skb_push(reply, sizeof(struct icm=
phdr));
+				new_icmp->type =3D ICMP_DEST_UNREACH;
+				new_icmp->code =3D ICMP_FRAG_NEEDED;
+				new_icmp->un.frag.mtu =3D htons(phy_dev->mtu - outer_l34_hdrlen);
+				new_icmp->checksum =3D 0;
+
+				new_ip =3D (struct iphdr *)__skb_push(reply, sizeof(struct iphdr))=
;
+				orig_ip =3D ip_hdr(skb);
+				new_ip->ihl =3D 5;
+				new_ip->version =3D 4;
+				new_ip->ttl =3D 32;
+				new_ip->tos =3D 1;
+				new_ip->protocol =3D IPPROTO_ICMP;
+				new_ip->saddr =3D orig_ip->daddr;
+				new_ip->daddr =3D orig_ip->saddr;
+				new_ip->frag_off =3D 0;
+				new_ip->tot_len =3D htons(sizeof(struct iphdr) + sizeof(struct icm=
phdr) + data_len);
+				ip_send_check(new_ip);
+
+				new_eth =3D (struct ethhdr *)__skb_push(reply, sizeof(struct ethhd=
r));
+				orig_eth =3D eth_hdr(skb);
+				ether_addr_copy(new_eth->h_dest, orig_eth->h_source);
+				ether_addr_copy(new_eth->h_source, orig_eth->h_dest);
+				new_eth->h_proto =3D htons(ETH_P_IP);
+				reply->ip_summed =3D CHECKSUM_UNNECESSARY;
+				reply->pkt_type =3D PACKET_HOST;
+				reply->protocol =3D htons(ETH_P_IP);
+				memcpy(skb_put(reply, data_len), skb_network_header(skb), data_len=
);
+				new_icmp->checksum =3D csum_fold(csum_partial(new_icmp, sizeof(str=
uct icmphdr) + data_len, 0));
+
+				/* vxlan encapuslation */
+				vxh =3D (struct vxlanhdr *)__skb_push(reply, sizeof(*vxh));
+				vxh->vx_flags =3D htonl(VXLAN_FLAGS);
+				vxh->vx_vni =3D htonl(vni << 8);
+
+				__skb_push(reply, sizeof(*uh));
+				skb_reset_transport_header(reply);
+				uh =3D udp_hdr(reply);
+				uh->dest =3D dst_port;
+				uh->source =3D src_port;
+				uh->len =3D htons(reply->len);
+				uh->check =3D 0;
+				csum =3D skb_checksum(reply, 0, reply->len, 0);
+				uh->check =3D udp_v4_check(reply->len, fl4.saddr, dst->sin.sin_add=
r.s_addr, csum);
+
+				tnl_ip =3D (struct iphdr *)__skb_push(reply, sizeof(struct iphdr))=
;
+				skb_reset_network_header(reply);
+				tnl_ip->ihl =3D 5;
+				tnl_ip->version =3D 4;
+				tnl_ip->ttl =3D 32;
+				tnl_ip->tos =3D 1;
+				tnl_ip->protocol =3D IPPROTO_UDP;
+				tnl_ip->saddr =3D dst->sin.sin_addr.s_addr;
+				tnl_ip->daddr =3D fl4.saddr;
+				tnl_ip->frag_off =3D 0;
+				tnl_ip->tot_len =3D htons(reply->len);
+				ip_send_check(tnl_ip);
+
+				/* fill with nosense mac header */
+				tnl_eth =3D (struct ethhdr *)__skb_push(reply, sizeof(struct ethhd=
r));
+				skb_reset_mac_header(reply);
+				orig_eth =3D eth_hdr(skb);
+				ether_addr_copy(tnl_eth->h_dest, orig_eth->h_source);
+				ether_addr_copy(tnl_eth->h_source, orig_eth->h_dest);
+				tnl_eth->h_proto =3D htons(ETH_P_IP);
+				__skb_pull(reply, skb_network_offset(reply));
+
+				/* push encapuslated ICMP message back to sender */
+				netif_rx_ni(reply);
+			}
+		}
  		err =3D vxlan_xmit_skb(vxlan->vn_sock, rt, skb,
  				     fl4.saddr, dst->sin.sin_addr.s_addr,
  				     tos, ttl, df, src_port, dst_port,



--=20
No zuo no die but I have to try.
