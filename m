From: Jesse Gross <jesse-P0zfqm4/dxOLnZed9OPc8Q@public.gmane.org>
Subject: Re: [PATCH 01/21] datapath: tunnelling: Replace tun_id
	with tun_key
Date: Sun, 3 Jun 2012 18:01:48 +0900
Message-ID: <32F7FF5E-DFFC-4B25-ADF3-675825803435@nicira.com>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
	<1337850554-10339-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: multipart/mixed; boundary="===============0045503581=="
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1337850554-10339-2-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============0045503581==
Content-Type: multipart/alternative; boundary="Apple-Mail=_6A5E42A2-FDD2-4BDA-82DD-1FD43E287819"


--Apple-Mail=_6A5E42A2-FDD2-4BDA-82DD-1FD43E287819
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On May 24, 2012, at 2:08 AM, Simon Horman wrote:

> this is a first pass at providing a tun_key which can be used
> as the basis for flow-based tunnelling. The tun_key includes and
> replaces the tun_id in both struct ovs_skb_cb and struct sw_tun_key.
>=20
> In ovs_skb_cb tun_key is a pointer as it is envisaged that it will =
grow
> when support for IPv6 to an extent that inlining the structure will =
result
> in ovs_skb_cb being larger than the 48 bytes available in skb->cb.
>=20
> As OVS does not support IPv6 as the outer transport protocol for =
tunnels
> the IPv6 portions of this change, which appeared in the previous =
revision,
> have been dropped in order to limit the scope and size of this patch.
>=20
> This patch does not make any effort to retain the existing tun_id =
behaviour
> nor does it fully implement flow-based tunnels. As such it it is =
incomplete
> and can't be used in its current form (other than to break OVS =
tunnelling).
>=20
> ** Please do not apply **
>=20
> Cc: Kyle Mestery <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

Thanks and sorry again about being so slow to look at this.

Overall, this looks pretty good to me.  The main difficulty that I had =
was in figuring out what should go with the old behavior and what should =
go with the new since it's at an intermediate point between the two but =
I understand that it's difficult to break it up in a way that both =
encapsulates a particular set of functionality and isn't too large.  =
Otherwise, I noticed a few specific things that I noted below.

> diff --git a/datapath/flow.c b/datapath/flow.c
> index d07337c..49c0dd8 100644
> --- a/datapath/flow.c
> +++ b/datapath/flow.c
> @@ -1162,14 +1166,15 @@ int ovs_flow_from_nlattrs(struct sw_flow_key =
*swkey, int *key_lenp,
>  * get the metadata, that is, the parts of the flow key that cannot be
>  * extracted from the packet itself.
>  */
> -int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port, =
__be64 *tun_id,
> +int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port,
> +				   struct ovs_key_ipv4_tunnel *tun_key,
> 				   const struct nlattr *attr)
> {
> 	const struct nlattr *nla;
> 	int rem;
>=20
> 	*in_port =3D DP_MAX_PORTS;
> -	*tun_id =3D 0;
> +	tun_key->tun_id =3D 0;

I think we probably want to memset the entire tun_key to zero to avoid =
having potentially uninitialized data in the flow.

>=20
> @@ -1204,15 +1210,21 @@ int ovs_flow_metadata_from_nlattrs(u32 =
*priority, u16 *in_port, __be64 *tun_id,
> int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct =
sk_buff *skb)
> {
> 	struct ovs_key_ethernet *eth_key;
> +	struct ovs_key_ipv4_tunnel *tun_key;
> 	struct nlattr *nla, *encap;
>=20
> 	if (swkey->phy.priority &&
> 	    nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, =
swkey->phy.priority))
> 		goto nla_put_failure;
>=20
> -	if (swkey->phy.tun_id !=3D cpu_to_be64(0) &&
> -	    nla_put_be64(skb, OVS_KEY_ATTR_TUN_ID, swkey->phy.tun_id))
> -		goto nla_put_failure;
> +	if (swkey->phy.tun_key.ipv4_dst) {

It's probably OK to use DIP equal to zero as a not present marker but we =
need to enforce that it's always true - for example we shouldn't allow =
somebody to setup a flow that way or receive packets with a zero =
address.  Alternately, we may be able to find a spare bit to indicate =
this, like is done with vlans.

In any case, I think we need to do some additional validation when =
setting up flows to check reserved space, for example, as otherwise that =
will never match.

> diff --git a/datapath/flow.h b/datapath/flow.h
> index 5be481e..bab5363 100644
> --- a/datapath/flow.h
> +++ b/datapath/flow.h
> @@ -42,7 +42,7 @@ struct sw_flow_actions {
>=20
> struct sw_flow_key {
> 	struct {
> -		__be64	tun_id;		/* Encapsulating tunnel ID. */
> +		struct ovs_key_ipv4_tunnel tun_key;  /* Encapsulating =
tunnel key. */

This is an optimization but as we get closer I'd like to put the tun_key =
at the end of struct sw_flow_key so that packets that didn't come from a =
tunnel don't have to pay the cost during the lookup (this is especially =
true as we add support for IPv6 tunnels).

In a similar vein, struct ovs_key_ipv4_tunnel contains some fields that =
I think can never apply for lookup such as the flags so it would be nice =
if we could remove that for lookup.

>=20
> @@ -150,6 +150,7 @@ u64 ovs_flow_used_time(unsigned long =
flow_jiffies);
>  *                         ------  ---  ------  -----
>  *  OVS_KEY_ATTR_PRIORITY      4    --     4      8
>  *  OVS_KEY_ATTR_TUN_ID        8    --     4     12
> + *  OVS_KEY_ATTR_IPV4_TUNNEL  18     2     4     24

If my math is correct, I think the size of the base struct =
ova_key_ipv4_tunnel is 24 bytes.

> +static inline void tun_key_swap_addr(struct ovs_key_ipv4_tunnel =
*tun_key)
> +{
> +	__be32 ndst =3D tun_key->ipv4_src;
> +	tun_key->ipv4_src =3D tun_key->ipv4_dst;
> +	tun_key->ipv4_dst =3D ndst;
> +}

I'm not quite sure when we would need to swap the addresses in a tunnel =
and I didn't see any uses of this function.

> +static inline void tun_key_init(struct ovs_key_ipv4_tunnel *tun_key,
> +				const struct iphdr *iph, __be64 tun_id)
> +{
> +	tun_key->tun_id =3D tun_id;
> +	tun_key->ipv4_src =3D iph->saddr;
> +	tun_key->ipv4_dst =3D iph->daddr;
> +	tun_key->ipv4_tos =3D iph->tos;
> +	tun_key->ipv4_ttl =3D iph->ttl;
> +}
>=20

Aren't there some fields that we need to zero out to avoid problems in =
the lookup?

> diff --git a/datapath/tunnel.c b/datapath/tunnel.c
> index d651c11..010e513 100644
> --- a/datapath/tunnel.c
> +++ b/datapath/tunnel.c
> @@ -367,9 +367,9 @@ struct vport *ovs_tnl_find_port(struct net *net, =
__be32 saddr, __be32 daddr,
> 	return NULL;
> }
>=20
> -static void ecn_decapsulate(struct sk_buff *skb, u8 tos)
> +static void ecn_decapsulate(struct sk_buff *skb)
> {
> -	if (unlikely(INET_ECN_is_ce(tos))) {
> +	if (unlikely(INET_ECN_is_ce(OVS_CB(skb)->tun_key->ipv4_tos))) {
> 		__be16 protocol =3D skb->protocol;

This might come in a later patch, although I didn't see it in a quick =
scan, but it should be possible to implement all the ECN encapsulation =
and decapsulation in userspace, just like we can do with the rest of the =
ToS and TTL.

>=20
> bool ovs_tnl_frag_needed(struct vport *vport,
> 			 const struct tnl_mutable_config *mutable,
> -			 struct sk_buff *skb, unsigned int mtu, __be64 =
flow_key)
> +			 struct sk_buff *skb, unsigned int mtu,
> +			 struct ovs_key_ipv4_tunnel *tun_key)
> {
> 	unsigned int eth_hdr_len =3D ETH_HLEN;
> 	unsigned int total_length =3D 0, header_length =3D 0, =
payload_length;
> 	struct ethhdr *eh, *old_eh =3D eth_hdr(skb);
> 	struct sk_buff *nskb;
> +	struct ovs_key_ipv4_tunnel ntun_key;
>=20
> 	/* Sanity check */
> 	if (skb->protocol =3D=3D htons(ETH_P_IP)) {
> @@ -705,8 +707,10 @@ bool ovs_tnl_frag_needed(struct vport *vport,
> 	 * any way of synthesizing packets.
> 	 */
> 	if ((mutable->flags & (TNL_F_IN_KEY_MATCH | =
TNL_F_OUT_KEY_ACTION)) =3D=3D
> -	    (TNL_F_IN_KEY_MATCH | TNL_F_OUT_KEY_ACTION))
> -		OVS_CB(nskb)->tun_id =3D flow_key;
> +	    (TNL_F_IN_KEY_MATCH | TNL_F_OUT_KEY_ACTION)) {
> +		ntun_key =3D *tun_key;
> +		OVS_CB(nskb)->tun_key =3D &ntun_key;
> +	}

I guess this is probably where you were going to use the function to =
reverse IP addresses.  The logic doesn't really work but it's moot since =
this is going away anyways.
>=20
> @@ -799,10 +803,8 @@ static void create_tunnel_header(const struct =
vport *vport,
> 	iph->ihl	=3D sizeof(struct iphdr) >> 2;
> 	iph->frag_off	=3D htons(IP_DF);
> 	iph->protocol	=3D tnl_vport->tnl_ops->ipproto;
> -	iph->tos	=3D mutable->tos;
> 	iph->daddr	=3D rt->rt_dst;
> 	iph->saddr	=3D rt->rt_src;
> -	iph->ttl	=3D mutable->ttl;
> 	if (!iph->ttl)
> 		iph->ttl =3D ip4_dst_hoplimit(&rt_dst(rt));
>=20

I'm not sure that these changes quite belong in this patch (not that it =
shouldn't be done but it seems like the supporting code isn't there =
yet).
>=20
> diff --git a/datapath/vport-gre.c b/datapath/vport-gre.c
> index ab89c5b..fd2b038 100644
> --- a/datapath/vport-gre.c
> +++ b/datapath/vport-gre.c
> @@ -101,10 +101,6 @@ static struct sk_buff *gre_update_header(const =
struct vport *vport,
> 	__be32 *options =3D (__be32 *)(skb_network_header(skb) + =
mutable->tunnel_hlen
> 					       - GRE_HEADER_SECTION);
>=20
> -	/* Work backwards over the options so the checksum is last. */
> -	if (mutable->flags & TNL_F_OUT_KEY_ACTION)
> -		*options =3D be64_get_low32(OVS_CB(skb)->tun_id);

Why does this go away?

> diff --git a/datapath/vport.c b/datapath/vport.c
> index 172261a..0c77a1b 100644
> --- a/datapath/vport.c
> +++ b/datapath/vport.c
> @@ -462,7 +462,7 @@ void ovs_vport_receive(struct vport *vport, struct =
sk_buff *skb)
> 		OVS_CB(skb)->flow =3D NULL;
>=20
> 	if (!(vport->ops->flags & VPORT_F_TUN_ID))
> -		OVS_CB(skb)->tun_id =3D 0;
> +		OVS_CB(skb)->tun_key =3D NULL;

We probably should rename this flag now.

> diff --git a/lib/odp-util.h b/lib/odp-util.h
> index d53f083..4e5a8a1 100644
> --- a/lib/odp-util.h
> +++ b/lib/odp-util.h
> @@ -72,6 +72,7 @@ int odp_actions_from_string(const char *, const =
struct simap *port_names,
>  *                         ------  ---  ------  -----
>  *  OVS_KEY_ATTR_PRIORITY      4    --     4      8
>  *  OVS_KEY_ATTR_TUN_ID        8    --     4     12
> + *  OVS_KEY_ATTR_IPV4_TUNNEL  18     2     4     24

Same thing about the size here as well.=

--Apple-Mail=_6A5E42A2-FDD2-4BDA-82DD-1FD43E287819
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=us-ascii

<html><head></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space; =
"><div><div>On May 24, 2012, at 2:08 AM, Simon Horman wrote:</div><br =
class=3D"Apple-interchange-newline"><blockquote type=3D"cite"><div>this =
is a first pass at providing a tun_key which can be used<br>as the basis =
for flow-based tunnelling. The tun_key includes and<br>replaces the =
tun_id in both struct ovs_skb_cb and struct sw_tun_key.<br><br>In =
ovs_skb_cb tun_key is a pointer as it is envisaged that it will =
grow<br>when support for IPv6 to an extent that inlining the structure =
will result<br>in ovs_skb_cb being larger than the 48 bytes available in =
skb-&gt;cb.<br><br>As OVS does not support IPv6 as the outer transport =
protocol for tunnels<br>the IPv6 portions of this change, which appeared =
in the previous revision,<br>have been dropped in order to limit the =
scope and size of this patch.<br><br>This patch does not make any effort =
to retain the existing tun_id behaviour<br>nor does it fully implement =
flow-based tunnels. As such it it is incomplete<br>and can't be used in =
its current form (other than to break OVS tunnelling).<br><br>** Please =
do not apply **<br><br>Cc: Kyle Mestery &lt;<a =
href=3D"mailto:kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org">kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org</a>&gt;<br>Signed-of=
f-by: Simon Horman &lt;<a =
href=3D"mailto:horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org">horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org</a>&gt;<br></div></b=
lockquote><div><br></div><div>Thanks and sorry again about being so slow =
to look at this.</div><div><br></div><div>Overall, this looks pretty =
good to me. &nbsp;The main difficulty that I had was in figuring out =
what should go with the old behavior and what should go with the new =
since it's at an intermediate point between the two but I understand =
that it's difficult to break it up in a way that both encapsulates a =
particular set of functionality and isn't too large. &nbsp;Otherwise, I =
noticed a few specific things that I noted =
below.</div><div><br></div><blockquote type=3D"cite"><div>diff --git =
a/datapath/flow.c b/datapath/flow.c<br>index d07337c..49c0dd8 =
100644<br>--- a/datapath/flow.c<br>+++ b/datapath/flow.c<br>@@ -1162,14 =
+1166,15 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int =
*key_lenp,<br> &nbsp;* get the metadata, that is, the parts of the flow =
key that cannot be<br> &nbsp;* extracted from the packet itself.<br> =
&nbsp;*/<br>-int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 =
*in_port, __be64 *tun_id,<br>+int ovs_flow_metadata_from_nlattrs(u32 =
*priority, u16 *in_port,<br>+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span> &nbsp;&nbsp;struct =
ovs_key_ipv4_tunnel *tun_key,<br> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span> &nbsp;&nbsp;const struct nlattr =
*attr)<br> {<br> <span class=3D"Apple-tab-span" style=3D"white-space:pre">=
	</span>const struct nlattr *nla;<br> <span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>int =
rem;<br><br> <span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>*in_port =3D DP_MAX_PORTS;<br>-<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>*tun_id =3D 0;<br>+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>tun_key-&gt;tun_id =3D =
0;<br></div></blockquote><div><br></div><div>I think we probably want to =
memset the entire tun_key to zero to avoid having potentially =
uninitialized data in the flow.</div><br><blockquote =
type=3D"cite"><div><font class=3D"Apple-style-span" =
color=3D"#000000"><br></font>@@ -1204,15 +1210,21 @@ int =
ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port, __be64 =
*tun_id,<br> int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, =
struct sk_buff *skb)<br> {<br> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>struct ovs_key_ethernet =
*eth_key;<br>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>struct ovs_key_ipv4_tunnel *tun_key;<br> <span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>struct =
nlattr *nla, *encap;<br><br> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>if (swkey-&gt;phy.priority =
&amp;&amp;<br> <span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span> &nbsp;&nbsp;&nbsp;nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, =
swkey-&gt;phy.priority))<br> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>goto =
nla_put_failure;<br><br>-<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>if (swkey-&gt;phy.tun_id !=3D =
cpu_to_be64(0) &amp;&amp;<br>-<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span> =
&nbsp;&nbsp;&nbsp;nla_put_be64(skb, OVS_KEY_ATTR_TUN_ID, =
swkey-&gt;phy.tun_id))<br>-<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>goto nla_put_failure;<br>+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>if =
(swkey-&gt;phy.tun_key.ipv4_dst) =
{<br></div></blockquote><div><br></div><div>It's probably OK to use DIP =
equal to zero as a not present marker but we need to enforce that it's =
always true - for example we shouldn't allow somebody to setup a flow =
that way or receive packets with a zero address. &nbsp;Alternately, we =
may be able to find a spare bit to indicate this, like is done with =
vlans.</div><div><br></div><div>In any case, I think we need to do some =
additional validation when setting up flows to check reserved space, for =
example, as otherwise that will never match.</div><br><blockquote =
type=3D"cite"><div>diff --git a/datapath/flow.h =
b/datapath/flow.h<br>index 5be481e..bab5363 100644<br>--- =
a/datapath/flow.h<br>+++ b/datapath/flow.h<br>@@ -42,7 +42,7 @@ struct =
sw_flow_actions {<br><br> struct sw_flow_key {<br> <span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>struct =
{<br>-<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>__be64<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>tun_id;<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>/* Encapsulating tunnel ID. */<br>+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>struct ovs_key_ipv4_tunnel =
tun_key; &nbsp;/* Encapsulating tunnel key. =
*/<br></div></blockquote><div><br></div><div>This is an optimization but =
as we get closer I'd like to put the tun_key at the end of struct =
sw_flow_key so that packets that didn't come from a tunnel don't have to =
pay the cost during the lookup (this is especially true as we add =
support for IPv6 tunnels).</div><div><br></div><div>In a similar vein, =
struct ovs_key_ipv4_tunnel contains some fields that I think can never =
apply for lookup such as the flags so it would be nice if we could =
remove that for lookup.</div><br><blockquote type=3D"cite"><div><font =
class=3D"Apple-style-span" color=3D"#000000"><br></font>@@ -150,6 +150,7 =
@@ u64 ovs_flow_used_time(unsigned long flow_jiffies);<br> &nbsp;* =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;----=
-- &nbsp;--- &nbsp;------ &nbsp;-----<br> &nbsp;* =
&nbsp;OVS_KEY_ATTR_PRIORITY &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4 =
&nbsp;&nbsp;&nbsp;-- &nbsp;&nbsp;&nbsp;&nbsp;4 =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;8<br> &nbsp;* &nbsp;OVS_KEY_ATTR_TUN_ID =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;8 &nbsp;&nbsp;&nbsp;-- =
&nbsp;&nbsp;&nbsp;&nbsp;4 &nbsp;&nbsp;&nbsp;&nbsp;12<br>+ * =
&nbsp;OVS_KEY_ATTR_IPV4_TUNNEL &nbsp;18 &nbsp;&nbsp;&nbsp;&nbsp;2 =
&nbsp;&nbsp;&nbsp;&nbsp;4 =
&nbsp;&nbsp;&nbsp;&nbsp;24<br></div></blockquote><div><br></div><div>If =
my math is correct, I think the size of the base struct =
ova_key_ipv4_tunnel is 24 bytes.</div><div><br></div><blockquote =
type=3D"cite"><div>+static inline void tun_key_swap_addr(struct =
ovs_key_ipv4_tunnel *tun_key)<br>+{<br>+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>__be32 ndst =3D =
tun_key-&gt;ipv4_src;<br>+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>tun_key-&gt;ipv4_src =3D =
tun_key-&gt;ipv4_dst;<br>+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>tun_key-&gt;ipv4_dst =3D =
ndst;<br>+}<br></div></blockquote><div><br></div><div>I'm not quite sure =
when we would need to swap the addresses in a tunnel and I didn't see =
any uses of this function.</div><br><blockquote type=3D"cite"><div>+static=
 inline void tun_key_init(struct ovs_key_ipv4_tunnel *tun_key,<br>+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>const =
struct iphdr *iph, __be64 tun_id)<br>+{<br>+<span class=3D"Apple-tab-span"=
 style=3D"white-space:pre">	</span>tun_key-&gt;tun_id =3D =
tun_id;<br>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>tun_key-&gt;ipv4_src =3D iph-&gt;saddr;<br>+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>tun_key-&gt;ipv4_dst =3D iph-&gt;daddr;<br>+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>tun_key-&gt;ipv4_tos =3D iph-&gt;tos;<br>+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>tun_key-&gt;ipv4_ttl =3D =
iph-&gt;ttl;<br>+}<br><br></div></blockquote><div><br></div><div>Aren't =
there some fields that we need to zero out to avoid problems in the =
lookup?</div><div><br></div><blockquote type=3D"cite"><div>diff --git =
a/datapath/tunnel.c b/datapath/tunnel.c<br>index d651c11..010e513 =
100644<br>--- a/datapath/tunnel.c<br>+++ b/datapath/tunnel.c<br>@@ =
-367,9 +367,9 @@ struct vport *ovs_tnl_find_port(struct net *net, __be32 =
saddr, __be32 daddr,<br> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>return NULL;<br> }<br><br>-static =
void ecn_decapsulate(struct sk_buff *skb, u8 tos)<br>+static void =
ecn_decapsulate(struct sk_buff *skb)<br> {<br>-<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>if =
(unlikely(INET_ECN_is_ce(tos))) {<br>+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>if =
(unlikely(INET_ECN_is_ce(OVS_CB(skb)-&gt;tun_key-&gt;ipv4_tos))) {<br> =
<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>__be16 protocol =3D =
skb-&gt;protocol;<br></div></blockquote><div><br></div><div>This might =
come in a later patch, although I didn't see it in a quick scan, but it =
should be possible to implement all the ECN encapsulation and =
decapsulation in userspace, just like we can do with the rest of the ToS =
and TTL.</div><br><blockquote type=3D"cite"><div><font =
class=3D"Apple-style-span" color=3D"#000000"><br></font> bool =
ovs_tnl_frag_needed(struct vport *vport,<br> <span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span> const =
struct tnl_mutable_config *mutable,<br>-<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span> struct sk_buff *skb, unsigned =
int mtu, __be64 flow_key)<br>+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span> struct sk_buff *skb, unsigned =
int mtu,<br>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span> struct ovs_key_ipv4_tunnel *tun_key)<br> {<br> <span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>unsigned =
int eth_hdr_len =3D ETH_HLEN;<br> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>unsigned int total_length =3D 0, =
header_length =3D 0, payload_length;<br> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>struct ethhdr *eh, *old_eh =3D =
eth_hdr(skb);<br> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>struct sk_buff *nskb;<br>+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>struct =
ovs_key_ipv4_tunnel ntun_key;<br><br> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>/* Sanity check */<br> <span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>if =
(skb-&gt;protocol =3D=3D htons(ETH_P_IP)) {<br>@@ -705,8 +707,10 @@ bool =
ovs_tnl_frag_needed(struct vport *vport,<br> <span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span> * any =
way of synthesizing packets.<br> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span> */<br> <span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>if =
((mutable-&gt;flags &amp; (TNL_F_IN_KEY_MATCH | TNL_F_OUT_KEY_ACTION)) =
=3D=3D<br>-<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span> &nbsp;&nbsp;&nbsp;(TNL_F_IN_KEY_MATCH | =
TNL_F_OUT_KEY_ACTION))<br>-<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>OVS_CB(nskb)-&gt;tun_id =3D =
flow_key;<br>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span> &nbsp;&nbsp;&nbsp;(TNL_F_IN_KEY_MATCH | TNL_F_OUT_KEY_ACTION)) =
{<br>+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>ntun_key =3D *tun_key;<br>+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>OVS_CB(nskb)-&gt;tun_key =3D =
&amp;ntun_key;<br>+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	=
</span>}<br></div></blockquote><div><br></div><div>I guess this is =
probably where you were going to use the function to reverse IP =
addresses. &nbsp;The logic doesn't really work but it's moot since this =
is going away anyways.</div><blockquote type=3D"cite"><div><font =
class=3D"Apple-style-span" color=3D"#000000"><br></font>@@ -799,10 =
+803,8 @@ static void create_tunnel_header(const struct vport =
*vport,<br> <span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>iph-&gt;ihl<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>=3D sizeof(struct iphdr) &gt;&gt; =
2;<br> <span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>iph-&gt;frag_off<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>=3D htons(IP_DF);<br> <span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>iph-&gt;protocol<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>=3D =
tnl_vport-&gt;tnl_ops-&gt;ipproto;<br>-<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>iph-&gt;tos<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>=3D =
mutable-&gt;tos;<br> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>iph-&gt;daddr<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>=3D =
rt-&gt;rt_dst;<br> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>iph-&gt;saddr<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>=3D =
rt-&gt;rt_src;<br>-<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>iph-&gt;ttl<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>=3D =
mutable-&gt;ttl;<br> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>if (!iph-&gt;ttl)<br> <span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>iph-&gt;ttl =3D =
ip4_dst_hoplimit(&amp;rt_dst(rt));<br><br></div></blockquote><div><br></di=
v><div>I'm not sure that these changes quite belong in this patch (not =
that it shouldn't be done but it seems like the supporting code isn't =
there yet).</div><blockquote type=3D"cite"><div><font =
class=3D"Apple-style-span" color=3D"#000000"><br></font>diff --git =
a/datapath/vport-gre.c b/datapath/vport-gre.c<br>index ab89c5b..fd2b038 =
100644<br>--- a/datapath/vport-gre.c<br>+++ b/datapath/vport-gre.c<br>@@ =
-101,10 +101,6 @@ static struct sk_buff *gre_update_header(const struct =
vport *vport,<br> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>__be32 *options =3D (__be32 =
*)(skb_network_header(skb) + mutable-&gt;tunnel_hlen<br> <span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span> =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- GRE_HEADER_SECTION);<br><br>-<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>/* Work =
backwards over the options so the checksum is last. */<br>-<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>if =
(mutable-&gt;flags &amp; TNL_F_OUT_KEY_ACTION)<br>-<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>*options =
=3D =
be64_get_low32(OVS_CB(skb)-&gt;tun_id);<br></div></blockquote><div><br></d=
iv><div>Why does this go away?</div><br><blockquote =
type=3D"cite"><div>diff --git a/datapath/vport.c =
b/datapath/vport.c<br>index 172261a..0c77a1b 100644<br>--- =
a/datapath/vport.c<br>+++ b/datapath/vport.c<br>@@ -462,7 +462,7 @@ void =
ovs_vport_receive(struct vport *vport, struct sk_buff *skb)<br> <span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>OVS_CB(skb)-&gt;flow =3D NULL;<br><br> <span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>if =
(!(vport-&gt;ops-&gt;flags &amp; VPORT_F_TUN_ID))<br>-<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>OVS_CB(skb)-&gt;tun_id =3D 0;<br>+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>OVS_CB(skb)-&gt;tun_key =3D =
NULL;</div></blockquote><div><br></div><div>We probably should rename =
this flag now.</div><br><blockquote type=3D"cite"><div>diff --git =
a/lib/odp-util.h b/lib/odp-util.h<br>index d53f083..4e5a8a1 =
100644<br>--- a/lib/odp-util.h<br>+++ b/lib/odp-util.h<br>@@ -72,6 +72,7 =
@@ int odp_actions_from_string(const char *, const struct simap =
*port_names,<br> &nbsp;* =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;----=
-- &nbsp;--- &nbsp;------ &nbsp;-----<br> &nbsp;* =
&nbsp;OVS_KEY_ATTR_PRIORITY &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4 =
&nbsp;&nbsp;&nbsp;-- &nbsp;&nbsp;&nbsp;&nbsp;4 =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;8<br> &nbsp;* &nbsp;OVS_KEY_ATTR_TUN_ID =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;8 &nbsp;&nbsp;&nbsp;-- =
&nbsp;&nbsp;&nbsp;&nbsp;4 &nbsp;&nbsp;&nbsp;&nbsp;12<br>+ * =
&nbsp;OVS_KEY_ATTR_IPV4_TUNNEL &nbsp;18 &nbsp;&nbsp;&nbsp;&nbsp;2 =
&nbsp;&nbsp;&nbsp;&nbsp;4 =
&nbsp;&nbsp;&nbsp;&nbsp;24<br></div></blockquote><div><br></div><div>Same =
thing about the size here as well.</div></div></body></html>=

--Apple-Mail=_6A5E42A2-FDD2-4BDA-82DD-1FD43E287819--

--===============0045503581==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0045503581==--
