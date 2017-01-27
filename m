From: Jarno Rajahalme <jarno.rajahalme@gmail.com>
Subject: Re: [net-next] openvswitch: Simplify do_execute_actions().
Date: Thu, 26 Jan 2017 18:17:41 -0800
Message-ID: <903F5859-296D-4872-BE6F-B689C5E1E0D6@gmail.com>
References: <1485408261-31999-1-git-send-email-azhou@ovn.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: Andy Zhou <azhou@ovn.org>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34174 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752796AbdA0CRt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 21:17:49 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so5984018pgj.1
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 18:17:48 -0800 (PST)
In-Reply-To: <1485408261-31999-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nice clean-up.

Acked-by: Jarno Rajahalme <jarno@ovn.org>

> On Jan 25, 2017, at 9:24 PM, Andy Zhou <azhou@ovn.org> wrote:
>=20
> do_execute_actions() implements a worthwhile optimization: in case
> an output action is the last action in an action list, skb_clone()
> can be avoided by outputing the current skb. However, the
> implementation is more complicated than necessary.  This patch
> simplify this logic.
>=20
> Signed-off-by: Andy Zhou <azhou@ovn.org>
> ---
> net/openvswitch/actions.c | 40 =
+++++++++++++++++++---------------------
> 1 file changed, 19 insertions(+), 21 deletions(-)
>=20
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 514f7bc..3866608 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -830,6 +830,9 @@ static void do_output(struct datapath *dp, struct =
sk_buff *skb, int out_port,
> {
> 	struct vport *vport =3D ovs_vport_rcu(dp, out_port);
>=20
> +	if (unlikely(!skb))
> +		return;
> +
> 	if (likely(vport)) {
> 		u16 mru =3D OVS_CB(skb)->mru;
> 		u32 cutlen =3D OVS_CB(skb)->cutlen;
> @@ -1141,12 +1144,6 @@ static int do_execute_actions(struct datapath =
*dp, struct sk_buff *skb,
> 			      struct sw_flow_key *key,
> 			      const struct nlattr *attr, int len)
> {
> -	/* Every output action needs a separate clone of 'skb', but the =
common
> -	 * case is just a single output action, so that doing a clone =
and
> -	 * then freeing the original skbuff is wasteful.  So the =
following code
> -	 * is slightly obscure just to avoid that.
> -	 */
> -	int prev_port =3D -1;
> 	const struct nlattr *a;
> 	int rem;
>=20
> @@ -1154,20 +1151,25 @@ static int do_execute_actions(struct datapath =
*dp, struct sk_buff *skb,
> 	     a =3D nla_next(a, &rem)) {
> 		int err =3D 0;
>=20
> -		if (unlikely(prev_port !=3D -1)) {
> -			struct sk_buff *out_skb =3D skb_clone(skb, =
GFP_ATOMIC);
> +		switch (nla_type(a)) {
> +		case OVS_ACTION_ATTR_OUTPUT: {
> +			int port =3D nla_get_u32(a);
>=20
> -			if (out_skb)
> -				do_output(dp, out_skb, prev_port, key);
> +			/* Every output action needs a separate clone
> +			 * of 'skb', In case the output action is the
> +			 * last action, cloning can be avoided.
> +			 */
> +			if (nla_is_last(a, rem)) {
> +				do_output(dp, skb, port, key);
> +				/* 'skb' has been used for output.
> +				 */
> +				return 0;
> +			}
>=20
> +			do_output(dp, skb_clone(skb, GFP_ATOMIC), port, =
key);
> 			OVS_CB(skb)->cutlen =3D 0;
> -			prev_port =3D -1;
> -		}
> -
> -		switch (nla_type(a)) {
> -		case OVS_ACTION_ATTR_OUTPUT:
> -			prev_port =3D nla_get_u32(a);
> 			break;
> +		}
>=20
> 		case OVS_ACTION_ATTR_TRUNC: {
> 			struct ovs_action_trunc *trunc =3D nla_data(a);
> @@ -1257,11 +1259,7 @@ static int do_execute_actions(struct datapath =
*dp, struct sk_buff *skb,
> 		}
> 	}
>=20
> -	if (prev_port !=3D -1)
> -		do_output(dp, skb, prev_port, key);
> -	else
> -		consume_skb(skb);
> -
> +	consume_skb(skb);
> 	return 0;
> }
>=20
> --=20
> 1.8.3.1
>=20
