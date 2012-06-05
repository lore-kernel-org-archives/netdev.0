From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH 01/21] datapath: tunnelling: Replace tun_id with tun_key
Date: Tue, 5 Jun 2012 12:33:11 +0900
Message-ID: <CAEP_g=8ahniEzTQQ8a8Kfu2cudxyM_+DA5YLyxM0EdY43NkpBg@mail.gmail.com>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
 <1337850554-10339-2-git-send-email-horms@verge.net.au> <CAEP_g=9hkP-7fuFK3zSJcR=2BTK0feq7qUa8LHs3dbGQBy+suw@mail.gmail.com>
 <20120604223413.GF28747@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:40327 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755811Ab2FEDdd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 23:33:33 -0400
Received: by ggnm2 with SMTP id m2so3868458ggn.41
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 20:33:31 -0700 (PDT)
In-Reply-To: <20120604223413.GF28747@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 5, 2012 at 7:34 AM, Simon Horman <horms@verge.net.au> wrote=
:
> On Sun, Jun 03, 2012 at 06:15:04PM +0900, Jesse Gross wrote:
>> On Thu, May 24, 2012 at 6:08 PM, Simon Horman <horms@verge.net.au> w=
rote:
>> > @@ -1204,15 +1210,21 @@ int ovs_flow_metadata_from_nlattrs(u32 *pr=
iority, u16 *in_port, __be64 *tun_id,
>> > =C2=A0int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, str=
uct sk_buff *skb)
>> > =C2=A0{
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ovs_key_ethernet *eth_key;
>> > + =C2=A0 =C2=A0 =C2=A0 struct ovs_key_ipv4_tunnel *tun_key;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct nlattr *nla, *encap;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (swkey->phy.priority &&
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nla_put_u32(skb, OVS_KEY_=
ATTR_PRIORITY, swkey->phy.priority))
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto nla_pu=
t_failure;
>> >
>> > - =C2=A0 =C2=A0 =C2=A0 if (swkey->phy.tun_id !=3D cpu_to_be64(0) &=
&
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nla_put_be64(skb, OVS_KEY_ATT=
R_TUN_ID, swkey->phy.tun_id))
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto nla_put_fa=
ilure;
>> > + =C2=A0 =C2=A0 =C2=A0 if (swkey->phy.tun_key.ipv4_dst) {
>>
>> It's probably OK to use DIP equal to zero as a not present marker bu=
t
>> we need to enforce that it's always true - for example we shouldn't
>> allow somebody to setup a flow that way or receive packets with a ze=
ro
>> address. =C2=A0Alternately, we may be able to find a spare bit to in=
dicate
>> this, like is done with vlans.
>
> When I originally wrote this there didn't seem to be any obvious
> place in ovs_key_ipv4_tunnel to have an active/inactive bit, which
> is in part why the code relies on checking DIP.
>
> However, more recent versions of ovs_key_ipv4_tunnel have a flags fie=
ld of
> which only one bit is currently used. We could use one of the unused =
flag
> bits.

I guess it depends on what we end up doing with the lookup struct.  If
it stays as it is today, there's plenty of space if you include those
padding bytes.  If we shrink it down and there isn't a place then I do
think it is fine to use DIP (since this is traversing an IP stack and
DIP =3D 0 is an invalid value it's not like an L2 switch not allowing
invalid IP packet).  In that case, we just need to do more validation
in other places to make sure that this is the only situation that the
condition can arise.

>> In any case, I think we need to do some additional validation when
>> setting up flows to check reserved space, for example, as otherwise
>> that will never match.
>
> Sure. My testing seems to indicate that matching does occur,
> though I am quite happy to tighten things up.

I don't think it causes a problem as long as userspace is well
behaved, I was think it's best to detect problems early.

>> In a similar vein, struct ovs_key_ipv4_tunnel contains some fields
>> that I think can never apply for lookup such as the flags so it woul=
d
>> be nice if we could remove that for lookup.
>
> I think they need to be there to be passed around, so I'm not
> sure if they can easily be removed from ovs_key_ipv4_tunnel if that
> is what you are asking.

My guess is that we'll probably want to separate out the struct that
is used for lookup from the one that is used for communication with
userspace, which is what we do for most things so that we have more
freedom to optimize in the kernel.

>> > =C2=A0bool ovs_tnl_frag_needed(struct vport *vport,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 const struct tnl_mutable_config *mutable,
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0struct sk_buff *skb, unsigned int mtu, __be64 flow_key=
)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0struct sk_buff *skb, unsigned int mtu,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0struct ovs_key_ipv4_tunnel *tun_key)
>> > =C2=A0{
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int eth_hdr_len =3D ETH_HLEN;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int total_length =3D 0, header=
_length =3D 0, payload_length;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct ethhdr *eh, *old_eh =3D eth_hdr(=
skb);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sk_buff *nskb;
>> > + =C2=A0 =C2=A0 =C2=A0 struct ovs_key_ipv4_tunnel ntun_key;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Sanity check */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (skb->protocol =3D=3D htons(ETH_P_IP=
)) {
>> > @@ -705,8 +707,10 @@ bool ovs_tnl_frag_needed(struct vport *vport,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 * any way of synthesizing packets.
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((mutable->flags & (TNL_F_IN_KEY_MAT=
CH | TNL_F_OUT_KEY_ACTION)) =3D=3D
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (TNL_F_IN_KEY_MATCH | TNL_F_O=
UT_KEY_ACTION))
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 OVS_CB(nskb)->t=
un_id =3D flow_key;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (TNL_F_IN_KEY_MATCH | TNL_F_O=
UT_KEY_ACTION)) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ntun_key =3D *t=
un_key;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 OVS_CB(nskb)->t=
un_key =3D &ntun_key;
>> > + =C2=A0 =C2=A0 =C2=A0 }
>>
>> I guess this is probably where you were going to use the function to
>> reverse IP addresses. =C2=A0The logic doesn't really work but it's m=
oot
>> since this is going away anyways.
>
> My latest series includes a clean up to ovs_tnl_frag_needed() to allo=
w
> it to work in some circumstances - i.e. those found in my test enviro=
nment.
> That series removes knowledge of tun_key from ovs_tnl_frag_needed().
>
> I am however happy to remove ovs_tnl_frag_needed() completely if you =
think
> that is appropriate.

I think, in retrospect, that the path MTU discovery that I implemented
here was probably not the right choice and MSS clamping is the correct
way to do things.  It was better when it wasn't possible to do any
kind of flow-based manipulation of tunnels but the model is breaking
down more and more over time.  Given that I would be hesitant to
submit it upstream and since that's the goal of this work, removing it
completely is probably the right thing to do.
