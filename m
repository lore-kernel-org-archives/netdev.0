From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: allow tx of pre-formatted vlan tagged packets
Date: Mon, 7 Dec 2009 12:50:01 -0800
Message-ID: <9929d2390912071250j7d2dcea7y9ddb62ee0c826df9@mail.gmail.com>
References: <1259961156.4198.163.camel@gshetty>
	 <9929d2390912041345g4557770bh1467db58b8ade572@mail.gmail.com>
	 <1260216128.4226.18.camel@gshetty> <1260216295.4226.21.camel@gshetty>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arthur Jones <Arthur.Jones@riverbed.com>
To: Gurucharan Shetty <gshetty@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:47573 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935574AbZLGUty convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 15:49:54 -0500
Received: by pzk26 with SMTP id 26so4210544pzk.4
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2009 12:50:01 -0800 (PST)
In-Reply-To: <1260216295.4226.21.camel@gshetty>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 7, 2009 at 12:04, Gurucharan Shetty <gshetty@riverbed.com> =
wrote:
> ixgbe: allow tx of pre-formatted vlan tagged packets
>
> When the 82598 is fed 802.1q packets, it chokes with
> an error of the form:
>
> ixgbe: eth0: ixgbe_tx_csum: partial checksum but proto=3D81!
>
> As the logic there was not smart enough to look into
> the vlan header to pick out the encapsulated protocol.
>
> There are times when we'd like to send these packets
> out without having to configure a vlan on the interface.
> Here we check for the vlan tag and allow the packet to
> go out with the correct hardware checksum.
>
> This patch is a clone of a previously submitted patch by
> Arthur Jones <ajones@riverbed.com> for igb (Commit -
> fa4a7ef36ec834fee1719636b30d2f28f4cb0166).
>
> Signed-off-by: Gurucharan Shetty <gshetty@riverbed.com>
> Signed-off-by: Arthur Jones <ajones@riverbed.com>
>
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe=
_main.c
> index 77b0381..4eff407 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -4810,7 +4810,18 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter=
 *adapter,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0IXGBE_ADVTXD_DT=
YP_CTXT);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (skb->ip_su=
mmed =3D=3D CHECKSUM_PARTIAL) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 switch (skb->protocol) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 __be16 protocol;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 if (skb->protocol =3D=3D cpu_to_be16(ETH_P_8021Q)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct vlan_ethhdr *vhdr =3D
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (const =
struct vlan_ethhdr *)skb->data;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 protocol =3D vhdr->h_vlan_encapsula=
ted_proto;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 } else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 protocol =3D skb->protocol;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 switch (protocol) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0case cpu_to_be16(ETH_P_IP):
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0type_tucmd_mlhl |=3D IXGBE_AD=
VTXD_TUCMD_IPV4;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ip_hdr(skb)->protocol =3D=
=3D IPPROTO_TCP)
>
>

Thanks, I have updated the patch in my queue.

--=20
Cheers,
Jeff
