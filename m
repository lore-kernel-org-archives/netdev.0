From: Simon Horman <horms@verge.net.au>
Subject: Re: [ovs-dev] [PATCH 01/21] datapath: tunnelling: Replace tun_id
 with tun_key
Date: Tue, 5 Jun 2012 17:12:35 +0900
Message-ID: <20120605081234.GB12720@verge.net.au>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
 <1337850554-10339-2-git-send-email-horms@verge.net.au>
 <CAEP_g=9hkP-7fuFK3zSJcR=2BTK0feq7qUa8LHs3dbGQBy+suw@mail.gmail.com>
 <20120604223413.GF28747@verge.net.au>
 <CAEP_g=8ahniEzTQQ8a8Kfu2cudxyM_+DA5YLyxM0EdY43NkpBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:56335 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754657Ab2FEIMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 04:12:40 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=8ahniEzTQQ8a8Kfu2cudxyM_+DA5YLyxM0EdY43NkpBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 05, 2012 at 12:33:11PM +0900, Jesse Gross wrote:
> On Tue, Jun 5, 2012 at 7:34 AM, Simon Horman <horms@verge.net.au> wro=
te:
> > On Sun, Jun 03, 2012 at 06:15:04PM +0900, Jesse Gross wrote:
> >> On Thu, May 24, 2012 at 6:08 PM, Simon Horman <horms@verge.net.au>=
 wrote:
> >> > @@ -1204,15 +1210,21 @@ int ovs_flow_metadata_from_nlattrs(u32 *=
priority, u16 *in_port, __be64 *tun_id,
> >> > =C2=A0int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, s=
truct sk_buff *skb)
> >> > =C2=A0{
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ovs_key_ethernet *eth_key;
> >> > + =C2=A0 =C2=A0 =C2=A0 struct ovs_key_ipv4_tunnel *tun_key;
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct nlattr *nla, *encap;
> >> >
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (swkey->phy.priority &&
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nla_put_u32(skb, OVS_KE=
Y_ATTR_PRIORITY, swkey->phy.priority))
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto nla_=
put_failure;
> >> >
> >> > - =C2=A0 =C2=A0 =C2=A0 if (swkey->phy.tun_id !=3D cpu_to_be64(0)=
 &&
> >> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nla_put_be64(skb, OVS_KEY_A=
TTR_TUN_ID, swkey->phy.tun_id))
> >> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto nla_put_=
failure;
> >> > + =C2=A0 =C2=A0 =C2=A0 if (swkey->phy.tun_key.ipv4_dst) {
> >>
> >> It's probably OK to use DIP equal to zero as a not present marker =
but
> >> we need to enforce that it's always true - for example we shouldn'=
t
> >> allow somebody to setup a flow that way or receive packets with a =
zero
> >> address. =C2=A0Alternately, we may be able to find a spare bit to =
indicate
> >> this, like is done with vlans.
> >
> > When I originally wrote this there didn't seem to be any obvious
> > place in ovs_key_ipv4_tunnel to have an active/inactive bit, which
> > is in part why the code relies on checking DIP.
> >
> > However, more recent versions of ovs_key_ipv4_tunnel have a flags f=
ield of
> > which only one bit is currently used. We could use one of the unuse=
d flag
> > bits.
>=20
> I guess it depends on what we end up doing with the lookup struct.  I=
f
> it stays as it is today, there's plenty of space if you include those
> padding bytes.  If we shrink it down and there isn't a place then I d=
o
> think it is fine to use DIP (since this is traversing an IP stack and
> DIP =3D 0 is an invalid value it's not like an L2 switch not allowing
> invalid IP packet).  In that case, we just need to do more validation
> in other places to make sure that this is the only situation that the
> condition can arise.

Ok, my suspicion is that there will be space.

> >> In any case, I think we need to do some additional validation when
> >> setting up flows to check reserved space, for example, as otherwis=
e
> >> that will never match.
> >
> > Sure. My testing seems to indicate that matching does occur,
> > though I am quite happy to tighten things up.
>=20
> I don't think it causes a problem as long as userspace is well
> behaved, I was think it's best to detect problems early.

Ok, good point. I'll make sure the data is clean.
>=20
> >> In a similar vein, struct ovs_key_ipv4_tunnel contains some fields
> >> that I think can never apply for lookup such as the flags so it wo=
uld
> >> be nice if we could remove that for lookup.
> >
> > I think they need to be there to be passed around, so I'm not
> > sure if they can easily be removed from ovs_key_ipv4_tunnel if that
> > is what you are asking.
>=20
> My guess is that we'll probably want to separate out the struct that
> is used for lookup from the one that is used for communication with
> userspace, which is what we do for most things so that we have more
> freedom to optimize in the kernel.

Understood, I'll look into doing that.

> >> > =C2=A0bool ovs_tnl_frag_needed(struct vport *vport,
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 const struct tnl_mutable_config *mutable,
> >> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0struct sk_buff *skb, unsigned int mtu, __be64 flow=
_key)
> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0struct sk_buff *skb, unsigned int mtu,
> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0struct ovs_key_ipv4_tunnel *tun_key)
> >> > =C2=A0{
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int eth_hdr_len =3D ETH_HLEN=
;
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int total_length =3D 0, head=
er_length =3D 0, payload_length;
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ethhdr *eh, *old_eh =3D eth_hd=
r(skb);
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sk_buff *nskb;
> >> > + =C2=A0 =C2=A0 =C2=A0 struct ovs_key_ipv4_tunnel ntun_key;
> >> >
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Sanity check */
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (skb->protocol =3D=3D htons(ETH_P_=
IP)) {
> >> > @@ -705,8 +707,10 @@ bool ovs_tnl_frag_needed(struct vport *vpor=
t,
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 * any way of synthesizing packets.
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((mutable->flags & (TNL_F_IN_KEY_M=
ATCH | TNL_F_OUT_KEY_ACTION)) =3D=3D
> >> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (TNL_F_IN_KEY_MATCH | TNL_F=
_OUT_KEY_ACTION))
> >> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 OVS_CB(nskb)-=
>tun_id =3D flow_key;
> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (TNL_F_IN_KEY_MATCH | TNL_F=
_OUT_KEY_ACTION)) {
> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ntun_key =3D =
*tun_key;
> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 OVS_CB(nskb)-=
>tun_key =3D &ntun_key;
> >> > + =C2=A0 =C2=A0 =C2=A0 }
> >>
> >> I guess this is probably where you were going to use the function =
to
> >> reverse IP addresses. =C2=A0The logic doesn't really work but it's=
 moot
> >> since this is going away anyways.
> >
> > My latest series includes a clean up to ovs_tnl_frag_needed() to al=
low
> > it to work in some circumstances - i.e. those found in my test envi=
ronment.
> > That series removes knowledge of tun_key from ovs_tnl_frag_needed()=
=2E
> >
> > I am however happy to remove ovs_tnl_frag_needed() completely if yo=
u think
> > that is appropriate.
>=20
> I think, in retrospect, that the path MTU discovery that I implemente=
d
> here was probably not the right choice and MSS clamping is the correc=
t
> way to do things.  It was better when it wasn't possible to do any
> kind of flow-based manipulation of tunnels but the model is breaking
> down more and more over time.  Given that I would be hesitant to
> submit it upstream and since that's the goal of this work, removing i=
t
> completely is probably the right thing to do.

Sure. My latest series also includes an implementation of MSS clamping,
so assuming it isn't doomed in some way we should be safe to remove
MTU discovery. I'll see about doing that for my next post.
