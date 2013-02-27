From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Fw: [Bug 54491] New: UFO (UDP fragmentation offload) does not
 work if the payload size specified is within the range ( (MTU-28)  to
 (MTU-8) )
Date: Wed, 27 Feb 2013 03:20:40 +0000 (UTC)
Message-ID: <kgju27$m81$1@ger.gmane.org>
References: <20130226074606.4d16ebfb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:60483 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754541Ab3B0DVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2013 22:21:03 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UAXa4-0001eP-N5
	for netdev@vger.kernel.org; Wed, 27 Feb 2013 04:21:20 +0100
Received: from 180.129.247.79 ([180.129.247.79])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 04:21:20 +0100
Received: from xiyou.wangcong by 180.129.247.79 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 04:21:20 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Feb 2013 at 15:46 GMT, Stephen Hemminger <stephen@networkplu=
mber.org> wrote:
> For IPv4/UDP if the payload size specified is within the range ( (MTU=
-28)=20
> to (MTU-8) ) packet gets segmented in kernel even if the following ne=
tdev
> features are set:
>
> NETIF_F_SG=20
> NETIF_F_GEN_CSUM=20
> NETIF_F_UFO=20
> NETIF_F_TSO=20
> NETIF_F_GSO=20
> NETIF_F_GSO_ROBUST
>
> Analysis:
> udp_sendmsg() computes packet length by adding UDP header size to pay=
load size:
> =E2=80=9Culen +=3D sizeof(struct udphdr)=E2=80=9D
> Then the function calls ip_make_skb(), however IP header size is not =
added to
> the packet length.
> ip_make_skb() in turn calls __ip_append_data(). The same packet lengt=
h is used
> here.=20
> __ip_append_data() compares the packet length with MTU. The packet le=
ngth still
> does not include IP header size (20 bytes).
> In result, when payload size =E2=80=9Cis within the range ( (MTU-28) =
to (MTU-8) )=E2=80=9D
> standard branch is taken rather than ip_ufo_append_data(). Gso_size i=
s not
> computed, therefore IP fragmentation is triggered from ip_finish_outp=
ut().
>

I haven't looked into this deeply, it sounds like we need this fix:

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 5e12dca..3ccb704 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -845,7 +845,7 @@ static int __ip_append_data(struct sock *sk,
                csummode =3D CHECKSUM_PARTIAL;
		=20
	         cork->length +=3D length;
 -       if (((length > mtu) || (skb &&skb_is_gso(skb))) &&
 +       if (((length + fragheaderlen > mtu) || (skb &&skb_is_gso(skb))=
) &&
            (sk->sk_protocol =3D=3D IPPROTO_UDP) &&
	                (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.head=
er_len) {
                err =3D ip_ufo_append_data(sk, queue, getfrag, from,len=
gth,
