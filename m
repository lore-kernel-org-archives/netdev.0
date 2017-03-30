From: Eric Dumazet <edumazet@google.com>
Subject: Re: [net-next v2] vxlan: fix ND proxy when skb doesn't have transport
 header offset
Date: Thu, 30 Mar 2017 06:36:43 -0700
Message-ID: <CANn89i+Ms_vvuowjmgERsA3=rMdTm_Cux3XTVJ19ewTz-TtBOw@mail.gmail.com>
References: <20170329204704.26087-1-vincent@bernat.im> <m360irs1u8.fsf@luffy.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>, netdev <netdev@vger.kernel.org>
To: Vincent Bernat <vincent@bernat.im>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:35233 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933489AbdC3Ngq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 09:36:46 -0400
Received: by mail-lf0-f42.google.com with SMTP id j90so26715697lfk.2
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 06:36:45 -0700 (PDT)
In-Reply-To: <m360irs1u8.fsf@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 29, 2017 at 11:41 PM, Vincent Bernat <vincent@bernat.im> wrote:
>  =E2=9D=A6 29 mars 2017 22:47 +0200, Vincent Bernat <vincent@bernat.im> :
>
>> Parsing of neighbor discovery options is done earlier to ignore the
>> whole packet in case of a malformed option. Moreover, the assumption the
>> skb was linear is removed and options are extracted with
>> skb_header_pointer() as well. The check on the source link-layer address
>> option is also more strict (for Ethernet, we expect the length field to
>> be 1).
>
> There is some parsing implemented in net/ipv6/ndisc.c, notably
> ndisc_parse_options(). I don't know if this is a good idea to reuse
> that: it may have the expectation that some IP processing has already
> been done (for example, the IPv6 length has already been checked, the
> SKB is expected to be linear).

Forcing ICMP being linear is probably fine.

Prior to 91269e390d062b52 ("vxlan: using pskb_may_pull as early as possible=
")
this was happening (at the wrong place) in neigh_reduce() doing a :
if (!pskb_may_pull(skb, skb->len))
     goto out;

So the following would be ok (while incomplete of course)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bdb6ae16d4a85bf9539199e189011bce104ba51a..cd032819d4a36d5ca94739f20f9=
47f3f5a31aba3
100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2243,12 +2243,13 @@ static netdev_tx_t vxlan_xmit(struct sk_buff
*skb, struct net_device *dev)
                        return arp_reduce(dev, skb, vni);
 #if IS_ENABLED(CONFIG_IPV6)
                else if (ntohs(eth->h_proto) =3D=3D ETH_P_IPV6 &&
-                        pskb_may_pull(skb, sizeof(struct ipv6hdr)
-                                      + sizeof(struct nd_msg)) &&
+                        skb->len >=3D sizeof(struct ipv6hdr) +
+                                    sizeof(struct nd_msg) &&
+                        pskb_may_pull(skb, skb->len) &&
                         ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_ICMPV6) {
                                struct nd_msg *msg;

-                               msg =3D (struct nd_msg
*)skb_transport_header(skb);
+                               msg =3D (struct nd_msg *)(ipv6_hdr(skb) + 1=
);
                                if (msg->icmph.icmp6_code =3D=3D 0 &&
                                    msg->icmph.icmp6_type =3D=3D
NDISC_NEIGHBOUR_SOLICITATION)
                                        return neigh_reduce(dev, skb, vni);
