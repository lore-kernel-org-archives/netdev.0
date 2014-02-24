From: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Subject: Re: TX_RING and VLAN : (packet size is too long 1518 > 1514)
Date: Mon, 24 Feb 2014 10:03:05 +0100
Message-ID: <530B0AC9.9080003@fokus.fraunhofer.de>
References: <5309D59A.1020304@fokus.fraunhofer.de> <5309FE75.8030802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <jbrouer@redhat.com>, <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-relay04-dus.antispameurope.com ([94.100.134.204]:55953 "EHLO
	mx-relay04-dus.antispameurope.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751603AbaBXJDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 04:03:23 -0500
In-Reply-To: <5309FE75.8030802@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

I've manually merged your patch into 3.10.32 since this is what I'm usi=
ng right now.

Yes, it works here. We can now send full-sized VLAN-tagged frames via T=
X_RING.

Another question in this context:

Is there a convention regarding sbk->protocol for VLAN-tagged frames ? =
Should it be=20
8021Q (VLAN) or should it indicate the 'inner' protocol (i.e IPV4) ?

Depending on the use case, I can find pros and cons for either one.

Cheers,

Mathias



'On 02/23/2014 02:58 PM, Daniel Borkmann wrote:
> On 02/23/2014 12:03 PM, Mathias Kretschmer wrote:
>> Hi Daniel, all
>>
>> we're running into the above error when sending full-sized VLAN-tagg=
ed frames via
>> TX_RING (Kernel 3.10.31, but same code seems to be present in 3.14).
>>
>> For the regular send() calls, there seems to be code in place to han=
dle
>> VLAN-tagged frames, but in tpacket_fill_skb() there is no such check=
=2E
>>
>> I came up with fix for this, but can only verify this tomorrow.
>> If it works, I'd send you a patch, but someone with more insights in=
to the
>> networking code should probably fix this properly ;-)
>
> Looks like the logic was added only to packet_snd() path when there w=
as no TX_RING
> implementation available yet.
>
> Does that patch work for you?
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 48a6a93..9deb991 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2257,8 +2257,7 @@ static int tpacket_snd(struct packet_sock *po, =
struct msghdr
> *msg)
>       if (unlikely(!(dev->flags & IFF_UP)))
>           goto out_put;
>
> -    reserve =3D dev->hard_header_len;
> -
> +    reserve =3D dev->hard_header_len + VLAN_HLEN;
>       size_max =3D po->tx_ring.frame_size
>           - (po->tp_hdrlen - sizeof(struct sockaddr_ll));
>
> @@ -2285,8 +2284,7 @@ static int tpacket_snd(struct packet_sock *po, =
struct msghdr
> *msg)
>               goto out_status;
>
>           tp_len =3D tpacket_fill_skb(po, skb, ph, dev, size_max, pro=
to,
> -                addr, hlen);
> -
> +                      addr, hlen);
>           if (unlikely(tp_len < 0)) {
>               if (po->tp_loss) {
>                   __packet_set_status(po, ph,
> @@ -2300,6 +2298,21 @@ static int tpacket_snd(struct packet_sock *po,=
 struct msghdr
> *msg)
>                   goto out_status;
>               }
>           }
> +        if (tp_len > (dev->mtu + dev->hard_header_len)) {
> +            struct ethhdr *ehdr;
> +            /* Earlier code assumed this would be a VLAN pkt,
> +             * double-check this now that we have the actual
> +             * packet in hand.
> +             */
> +
> +            skb_reset_mac_header(skb);
> +            ehdr =3D eth_hdr(skb);
> +            if (ehdr->h_proto !=3D htons(ETH_P_8021Q)) {
> +                status =3D TP_STATUS_WRONG_FORMAT;
> +                err =3D -EMSGSIZE;
> +                goto out_status;
> +            }
> +        }
>
>           packet_pick_tx_queue(dev, skb);
>


--=20
Dr. Mathias Kretschmer, Head of Competence Center
=46raunhofer FOKUS Network Research
A Schloss Birlinghoven, 53754 Sankt Augustin, Germany
T +49-2241-14-3466, F +49-2241-14-1050
E mathias.kretschmer@fokus.fraunhofer.de
W http://www.fokus.fraunhofer.de/en/net

---> Visit us @ =84The Rural Broadband Day 2014=94, Feb 13th, Fraunhofe=
r FOKUS, Berlin
---> Visit us @ =93Cebit 2014=94, March 10th =96 14th, Trade Fair, Hann=
over
