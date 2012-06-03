From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH 01/21] datapath: tunnelling: Replace tun_id with tun_key
Date: Sun, 3 Jun 2012 18:15:04 +0900
Message-ID: <CAEP_g=9hkP-7fuFK3zSJcR=2BTK0feq7qUa8LHs3dbGQBy+suw@mail.gmail.com>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au> <1337850554-10339-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:41592 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752759Ab2FCJP0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jun 2012 05:15:26 -0400
Received: by ghrr18 with SMTP id r18so4220405ghr.14
        for <netdev@vger.kernel.org>; Sun, 03 Jun 2012 02:15:24 -0700 (PDT)
In-Reply-To: <1337850554-10339-2-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 24, 2012 at 6:08 PM, Simon Horman <horms@verge.net.au> wrot=
e:
> this is a first pass at providing a tun_key which can be used
> as the basis for flow-based tunnelling. The tun_key includes and
> replaces the tun_id in both struct ovs_skb_cb and struct sw_tun_key.
>
> In ovs_skb_cb tun_key is a pointer as it is envisaged that it will gr=
ow
> when support for IPv6 to an extent that inlining the structure will r=
esult
> in ovs_skb_cb being larger than the 48 bytes available in skb->cb.
>
> As OVS does not support IPv6 as the outer transport protocol for tunn=
els
> the IPv6 portions of this change, which appeared in the previous revi=
sion,
> have been dropped in order to limit the scope and size of this patch.
>
> This patch does not make any effort to retain the existing tun_id beh=
aviour
> nor does it fully implement flow-based tunnels. As such it it is inco=
mplete
> and can't be used in its current form (other than to break OVS tunnel=
ling).
>
> ** Please do not apply **
>
> Cc: Kyle Mestery <kmestery@cisco.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Thanks and sorry again about being so slow to look at this.

Overall, this looks pretty good to me.  The main difficulty that I had
was in figuring out what should go with the old behavior and what
should go with the new since it's at an intermediate point between the
two but I understand that it's difficult to break it up in a way that
both encapsulates a particular set of functionality and isn't too
large.  Otherwise, I noticed a few specific things that I noted below.

> diff --git a/datapath/flow.c b/datapath/flow.c
> index d07337c..49c0dd8 100644
> --- a/datapath/flow.c
> +++ b/datapath/flow.c
> @@ -1162,14 +1166,15 @@ int ovs_flow_from_nlattrs(struct sw_flow_key =
*swkey, int *key_lenp,
> =C2=A0* get the metadata, that is, the parts of the flow key that can=
not be
> =C2=A0* extracted from the packet itself.
> =C2=A0*/
> -int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port, __be=
64 *tun_id,
> +int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ovs_key_ipv4_tu=
nnel *tun_key,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct nlattr *=
attr)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct nlattr *nla;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int rem;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*in_port =3D DP_MAX_PORTS;
> - =C2=A0 =C2=A0 =C2=A0 *tun_id =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 tun_key->tun_id =3D 0;

I think we probably want to memset the entire tun_key to zero to avoid
having potentially uninitialized data in the flow.

> @@ -1204,15 +1210,21 @@ int ovs_flow_metadata_from_nlattrs(u32 *prior=
ity, u16 *in_port, __be64 *tun_id,
> =C2=A0int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct=
 sk_buff *skb)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ovs_key_ethernet *eth_key;
> + =C2=A0 =C2=A0 =C2=A0 struct ovs_key_ipv4_tunnel *tun_key;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct nlattr *nla, *encap;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (swkey->phy.priority &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nla_put_u32(skb, OVS_KEY_ATT=
R_PRIORITY, swkey->phy.priority))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto nla_put_f=
ailure;
>
> - =C2=A0 =C2=A0 =C2=A0 if (swkey->phy.tun_id !=3D cpu_to_be64(0) &&
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nla_put_be64(skb, OVS_KEY_ATTR_T=
UN_ID, swkey->phy.tun_id))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto nla_put_failu=
re;
> + =C2=A0 =C2=A0 =C2=A0 if (swkey->phy.tun_key.ipv4_dst) {

It's probably OK to use DIP equal to zero as a not present marker but
we need to enforce that it's always true - for example we shouldn't
allow somebody to setup a flow that way or receive packets with a zero
address.  Alternately, we may be able to find a spare bit to indicate
this, like is done with vlans.

In any case, I think we need to do some additional validation when
setting up flows to check reserved space, for example, as otherwise
that will never match.

> diff --git a/datapath/flow.h b/datapath/flow.h
> index 5be481e..bab5363 100644
> --- a/datapath/flow.h
> +++ b/datapath/flow.h
> @@ -42,7 +42,7 @@ struct sw_flow_actions {
>
> =C2=A0struct sw_flow_key {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __be64 =C2=A0tun_i=
d; =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Encapsulating tunnel ID. */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ovs_key_ipv=
4_tunnel tun_key; =C2=A0/* Encapsulating tunnel key. */

This is an optimization but as we get closer I'd like to put the
tun_key at the end of struct sw_flow_key so that packets that didn't
come from a tunnel don't have to pay the cost during the lookup (this
is especially true as we add support for IPv6 tunnels).

In a similar vein, struct ovs_key_ipv4_tunnel contains some fields
that I think can never apply for lookup such as the flags so it would
be nice if we could remove that for lookup.

> @@ -150,6 +150,7 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies=
);
> =C2=A0* =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 ------ =C2=A0--- =C2=A0------ =C2=A0-----
> =C2=A0* =C2=A0OVS_KEY_ATTR_PRIORITY =C2=A0 =C2=A0 =C2=A04 =C2=A0 =C2=A0=
-- =C2=A0 =C2=A0 4 =C2=A0 =C2=A0 =C2=A08
> =C2=A0* =C2=A0OVS_KEY_ATTR_TUN_ID =C2=A0 =C2=A0 =C2=A0 =C2=A08 =C2=A0=
 =C2=A0-- =C2=A0 =C2=A0 4 =C2=A0 =C2=A0 12
> + * =C2=A0OVS_KEY_ATTR_IPV4_TUNNEL =C2=A018 =C2=A0 =C2=A0 2 =C2=A0 =C2=
=A0 4 =C2=A0 =C2=A0 24

If my math is correct, I think the size of the base struct
ova_key_ipv4_tunnel is 24 bytes.

> +static inline void tun_key_swap_addr(struct ovs_key_ipv4_tunnel *tun=
_key)
> +{
> + =C2=A0 =C2=A0 =C2=A0 __be32 ndst =3D tun_key->ipv4_src;
> + =C2=A0 =C2=A0 =C2=A0 tun_key->ipv4_src =3D tun_key->ipv4_dst;
> + =C2=A0 =C2=A0 =C2=A0 tun_key->ipv4_dst =3D ndst;
> +}

I'm not quite sure when we would need to swap the addresses in a
tunnel and I didn't see any uses of this function.

> +static inline void tun_key_init(struct ovs_key_ipv4_tunnel *tun_key,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct iphdr *iph, __be64 tun=
_id)
> +{
> + =C2=A0 =C2=A0 =C2=A0 tun_key->tun_id =3D tun_id;
> + =C2=A0 =C2=A0 =C2=A0 tun_key->ipv4_src =3D iph->saddr;
> + =C2=A0 =C2=A0 =C2=A0 tun_key->ipv4_dst =3D iph->daddr;
> + =C2=A0 =C2=A0 =C2=A0 tun_key->ipv4_tos =3D iph->tos;
> + =C2=A0 =C2=A0 =C2=A0 tun_key->ipv4_ttl =3D iph->ttl;
> +}

Aren't there some fields that we need to zero out to avoid problems in
the lookup?

> diff --git a/datapath/tunnel.c b/datapath/tunnel.c
> index d651c11..010e513 100644
> --- a/datapath/tunnel.c
> +++ b/datapath/tunnel.c
> @@ -367,9 +367,9 @@ struct vport *ovs_tnl_find_port(struct net *net, =
__be32 saddr, __be32 daddr,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;
> =C2=A0}
>
> -static void ecn_decapsulate(struct sk_buff *skb, u8 tos)
> +static void ecn_decapsulate(struct sk_buff *skb)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 if (unlikely(INET_ECN_is_ce(tos))) {
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(INET_ECN_is_ce(OVS_CB(skb)->tun_k=
ey->ipv4_tos))) {

This might come in a later patch, although I didn't see it in a quick
scan, but it should be possible to implement all the ECN encapsulation
and decapsulation in userspace, just like we can do with the rest of
the ToS and TTL.

> =C2=A0bool ovs_tnl_frag_needed(struct vport *vport,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 const struct tnl_mutable_config *mutable,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0struct sk_buff *skb, unsigned int mtu, __be64 flow_key)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0struct sk_buff *skb, unsigned int mtu,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0struct ovs_key_ipv4_tunnel *tun_key)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int eth_hdr_len =3D ETH_HLEN;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int total_length =3D 0, header_le=
ngth =3D 0, payload_length;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ethhdr *eh, *old_eh =3D eth_hdr(skb=
);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sk_buff *nskb;
> + =C2=A0 =C2=A0 =C2=A0 struct ovs_key_ipv4_tunnel ntun_key;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Sanity check */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (skb->protocol =3D=3D htons(ETH_P_IP)) =
{
> @@ -705,8 +707,10 @@ bool ovs_tnl_frag_needed(struct vport *vport,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * any way of synthesizing packets.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((mutable->flags & (TNL_F_IN_KEY_MATCH =
| TNL_F_OUT_KEY_ACTION)) =3D=3D
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (TNL_F_IN_KEY_MATCH | TNL_F_OUT_=
KEY_ACTION))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 OVS_CB(nskb)->tun_=
id =3D flow_key;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (TNL_F_IN_KEY_MATCH | TNL_F_OUT_=
KEY_ACTION)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ntun_key =3D *tun_=
key;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 OVS_CB(nskb)->tun_=
key =3D &ntun_key;
> + =C2=A0 =C2=A0 =C2=A0 }

I guess this is probably where you were going to use the function to
reverse IP addresses.  The logic doesn't really work but it's moot
since this is going away anyways.

> @@ -799,10 +803,8 @@ static void create_tunnel_header(const struct vp=
ort *vport,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0iph->ihl =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D si=
zeof(struct iphdr) >> 2;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0iph->frag_off =C2=A0 =3D htons(IP_DF);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0iph->protocol =C2=A0 =3D tnl_vport->tnl_op=
s->ipproto;
> - =C2=A0 =C2=A0 =C2=A0 iph->tos =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D mutabl=
e->tos;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0iph->daddr =C2=A0 =C2=A0 =C2=A0=3D rt->rt_=
dst;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0iph->saddr =C2=A0 =C2=A0 =C2=A0=3D rt->rt_=
src;
> - =C2=A0 =C2=A0 =C2=A0 iph->ttl =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D mutabl=
e->ttl;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!iph->ttl)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0iph->ttl =3D i=
p4_dst_hoplimit(&rt_dst(rt));

I'm not sure that these changes quite belong in this patch (not that
it shouldn't be done but it seems like the supporting code isn't there
yet).

> diff --git a/datapath/vport-gre.c b/datapath/vport-gre.c
> index ab89c5b..fd2b038 100644
> --- a/datapath/vport-gre.c
> +++ b/datapath/vport-gre.c
> @@ -101,10 +101,6 @@ static struct sk_buff *gre_update_header(const s=
truct vport *vport,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__be32 *options =3D (__be32 *)(skb_network=
_header(skb) + mutable->tunnel_hlen
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 - GRE_HEADER_SECTION);
>
> - =C2=A0 =C2=A0 =C2=A0 /* Work backwards over the options so the chec=
ksum is last. */
> - =C2=A0 =C2=A0 =C2=A0 if (mutable->flags & TNL_F_OUT_KEY_ACTION)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *options =3D be64_=
get_low32(OVS_CB(skb)->tun_id);

Why does this go away?

> diff --git a/datapath/vport.c b/datapath/vport.c
> index 172261a..0c77a1b 100644
> --- a/datapath/vport.c
> +++ b/datapath/vport.c
> @@ -462,7 +462,7 @@ void ovs_vport_receive(struct vport *vport, struc=
t sk_buff *skb)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0OVS_CB(skb)->f=
low =3D NULL;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!(vport->ops->flags & VPORT_F_TUN_ID))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 OVS_CB(skb)->tun_i=
d =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 OVS_CB(skb)->tun_k=
ey =3D NULL;

We probably should rename this flag now.

> diff --git a/lib/odp-util.h b/lib/odp-util.h
> index d53f083..4e5a8a1 100644
> --- a/lib/odp-util.h
> +++ b/lib/odp-util.h
> @@ -72,6 +72,7 @@ int odp_actions_from_string(const char *, const str=
uct simap *port_names,
> =C2=A0* =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 ------ =C2=A0--- =C2=A0------ =C2=A0-----
> =C2=A0* =C2=A0OVS_KEY_ATTR_PRIORITY =C2=A0 =C2=A0 =C2=A04 =C2=A0 =C2=A0=
-- =C2=A0 =C2=A0 4 =C2=A0 =C2=A0 =C2=A08
> =C2=A0* =C2=A0OVS_KEY_ATTR_TUN_ID =C2=A0 =C2=A0 =C2=A0 =C2=A08 =C2=A0=
 =C2=A0-- =C2=A0 =C2=A0 4 =C2=A0 =C2=A0 12
> + * =C2=A0OVS_KEY_ATTR_IPV4_TUNNEL =C2=A018 =C2=A0 =C2=A0 2 =C2=A0 =C2=
=A0 4 =C2=A0 =C2=A0 24

Same thing about the size here as well.
