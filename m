From: Laurent Chavey <chavey@google.com>
Subject: Re: [RFC] ipv4: support for request type gratuitous ARP
Date: Wed, 6 Jan 2010 12:24:22 -0800
Message-ID: <97949e3e1001061224n73e6adecv83cb114b8b046807@mail.gmail.com>
References: <201001050004.45004.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:3121 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932502Ab0AFUZA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 15:25:00 -0500
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o06KOxeR024299
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 12:24:59 -0800
Received: from qyk32 (qyk32.prod.google.com [10.241.83.160])
	by kpbe19.cbf.corp.google.com with ESMTP id o06KOgTI012990
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 12:24:55 -0800
Received: by qyk32 with SMTP id 32so7216979qyk.4
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2010 12:24:42 -0800 (PST)
In-Reply-To: <201001050004.45004.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reviewed-by: Laurent Chavey <chavey@google.com>

On Mon, Jan 4, 2010 at 2:04 PM, Octavian Purdila <opurdila@ixiacom.com>=
 wrote:
>
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> ---
>
> I've noticed that even though we currently support response type grat=
uitous ARP
> [response type, source mac, dest mac, source IP, source IP] *with a c=
lean ARP table*
> we do not support the request type [request type, source mac, ff:ff:f=
f:ff:ff:ff, source IP, source IP].
>
> This patch makes request type work as well, but RFC2002 says that gra=
tuitous ARP
> (both request and response) must update the ARP table *if* the IP alr=
eady
> exists in the table:
>
> =A0 =A0 =A0 =A0 =A0In either case, for a gratuitous ARP, the ARP pack=
et MUST be
> =A0 =A0 =A0 =A0 =A0transmitted as a local broadcast packet on the loc=
al link. =A0As
> =A0 =A0 =A0 =A0 =A0specified in [16], any node receiving any ARP pack=
et (Request or
> =A0 =A0 =A0 =A0 =A0Reply) MUST update its local ARP cache with the Se=
nder Protocol
> =A0 =A0 =A0 =A0 =A0and Hardware Addresses in the ARP packet, if the r=
eceiving node
> =A0 =A0 =A0 =A0 =A0has an entry for that IP address already in its AR=
P cache. =A0This
> =A0 =A0 =A0 =A0 =A0requirement in the ARP protocol applies even for A=
RP Request
> =A0 =A0 =A0 =A0 =A0packets, and for ARP Reply packets that do not mat=
ch any ARP
> =A0 =A0 =A0 =A0 =A0Request transmitted by the receiving node [16].
>
> so, I am not sure if this is right. But current behavior for response=
 type
> gratuitous ARP does not seem to be covered by the RFC either.
>
> =A0net/ipv4/arp.c | =A0 11 +++++++++--
> =A01 files changed, 9 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index c95cd93..81ef2d5 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -811,8 +811,13 @@ static int arp_process(struct sk_buff *skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 if (arp->ar_op =3D=3D htons(ARPOP_REQUEST) &&
> - =A0 =A0 =A0 =A0 =A0 ip_route_input(skb, tip, sip, 0, dev) =3D=3D 0)=
 {
> + =A0 =A0 =A0 if (arp->ar_op =3D=3D htons(ARPOP_REQUEST)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* gratuitous ARP */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tip =3D=3D sip) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 n =3D neigh_event_ns(&a=
rp_tbl, sha, &sip, dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto update;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (ip_route_input(skb, tip, sip=
, 0, dev) !=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto update_lookup;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rt =3D skb_rtable(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0addr_type =3D rt->rt_type;
> @@ -853,6 +858,7 @@ static int arp_process(struct sk_buff *skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> +update_lookup:
> =A0 =A0 =A0 =A0/* Update our ARP tables */
>
> =A0 =A0 =A0 =A0n =3D __neigh_lookup(&arp_tbl, &sip, dev, 0);
> @@ -868,6 +874,7 @@ static int arp_process(struct sk_buff *skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0n =3D __neigh_lookup(&=
arp_tbl, &sip, dev, 1);
> =A0 =A0 =A0 =A0}
>
> +update:
> =A0 =A0 =A0 =A0if (n) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int state =3D NUD_REACHABLE;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int override;
> --
> 1.5.6.5
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
