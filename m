From: Nick Carter <ncarter100@gmail.com>
Subject: Re: [PATCH 2/2] bridge: pass through 802.1X & co. in 'dumb' mode
Date: Wed, 29 Jun 2011 23:56:18 +0100
Message-ID: <BANLkTinJCtr8ZTYHZVc=+oWJGHjq3W3HhQ@mail.gmail.com>
References: <20110628214637.GE2121496@jupiter.n2.diac24.net>
	<1309298599-11266-1-git-send-email-equinox@diac24.net>
	<1309298599-11266-2-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	davem@davemloft.net
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:34624 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990Ab1F2W4T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 18:56:19 -0400
Received: by pvg12 with SMTP id 12so1121138pvg.19
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2011 15:56:18 -0700 (PDT)
In-Reply-To: <1309298599-11266-2-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 June 2011 23:03, David Lamparter <equinox@diac24.net> wrote:
> when operating without STP, we're a dumb switch and should be able to
> forward ethernet management protocols like 802.1X, LLDP and GVRP.
I don't like the idea of tying STP on / off with the forwarding of
these other protocols.  These other protocols are not dependent on
STP.  These diffs change the default behaviour so that if someone
writes an 802.1X authenticator in userspace then all deployments will
have to turn STP on to be able to use it !!

If I was a sysadmin and I configured 'bridge_stp off' in say
/etc/interfaces, i would be very surprised and alarmed to find I had
turned *on* forwarding a load of protocols.

Also many of these addresses are reserved for future use.  Do we
really want to forward them before we know what they will be used for
?
Nick
>
> if this is not desired, it can be enacted as local policy through
> ebtables.
>
> if we're in STP mode we basically claim to be an intelligent switch a=
nd
> should implement these protocols properly (in userspace).
>
> Signed-off-by: David Lamparter <equinox@diac24.net>
> ---
> compile-tested only
>
> =A0net/bridge/br_input.c | =A0 =A09 ++++++---
> =A01 files changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index c873db5..4cee1b5 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -167,16 +167,19 @@ rx_handler_result_t br_handle_frame(struct sk_b=
uff **pskb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (dest[5] =3D=3D 0x01 || dest[5] =3D=
=3D 0x02)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return RX_HANDLER_PASS=
;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If STP is turned off, then forward *=
/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p->br->stp_enabled =3D=3D BR_NO_STP=
 && dest[5] =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If STP is turned off, we're a dumb s=
witch and therefore
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* forward the remaining link-locals.=
 (STP, 802.1X, LLDP,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* GVRP & co.) */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p->br->stp_enabled =3D=3D BR_NO_STP=
)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto forward;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCA=
L_IN, skb, skb->dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NULL, br_handl=
e_local_finish)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return RX_HANDLER_CONS=
UMED; /* consumed by filter */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* stay on physdev for =
userspace implementation */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*pskb =3D skb;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return RX_HANDLER_PASS;=
 /* continue processing */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return RX_HANDLER_PASS;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> --
> 1.7.5.3
>
>
