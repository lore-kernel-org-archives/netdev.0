From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Subject: Re: [PATCH net-next 17/27] OVS: remove assumptions about
 VLAN_TAG_PRESENT bit
Date: Tue, 13 Dec 2016 16:14:07 +0100
Message-ID: <20161213151406.pfu23jqmj3ftluqm@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
	<e44219bc56d3e44aa0711c83c626adabf4c4ecd8.1481586602.git.mirq-linux@rere.qmqm.pl>
	<20161213114010.0fa2ddb6@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable
Cc: "open list:OPENVSWITCH" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161213114010.0fa2ddb6@griffin>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 13, 2016 at 11:40:10AM +0100, Jiri Benc wrote:
> On Tue, 13 Dec 2016 01:12:38 +0100 (CET), Micha=B3 Miros=B3aw wrote:
> > @@ -850,20 +848,11 @@ static int validate_vlan_from_nlattrs(const struc=
t sw_flow_match *match,
> >  		return -EINVAL;
> >  	}
> >  =

> > -	if (a[OVS_KEY_ATTR_VLAN])
> > -		tci =3D nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
> > -
> > -	if (!(tci & htons(VLAN_TAG_PRESENT))) {
> > -		if (tci) {
> > -			OVS_NLERR(log, "%s TCI does not have VLAN_TAG_PRESENT bit set.",
> > -				  (inner) ? "C-VLAN" : "VLAN");
> > -			return -EINVAL;
> > -		} else if (nla_len(a[OVS_KEY_ATTR_ENCAP])) {
> > -			/* Corner case for truncated VLAN header. */
> > -			OVS_NLERR(log, "Truncated %s header has non-zero encap attribute.",
> > -				  (inner) ? "C-VLAN" : "VLAN");
> > -			return -EINVAL;
> > -		}
> > +	if (!a[OVS_KEY_ATTR_VLAN] && nla_len(a[OVS_KEY_ATTR_ENCAP])) {
> > +		/* Corner case for truncated VLAN header. */
> > +		OVS_NLERR(log, "Truncated %s header has non-zero encap attribute.",
> > +			(inner) ? "C-VLAN" : "VLAN");
> > +		return -EINVAL;
> =

> This looks wrong. The zero value of nla_get_be16(a[OVS_KEY_ATTR_VLAN])
> together with empty a[OVS_KEY_ATTR_ENCAP] means truncated VLAN header
> and this needs to be preserved.
> =

> In other words, you need to check also !nla_get_be16(a[OVS_KEY_ATTR_VLAN])
> here.
> =

> =

> Overall, this whole patch looks very suspicious from the very
> beginning. The xors used are strong indication that something is not
> right.
> =

> And indeed, you're breaking uAPI compatibility. Previously, the
> VLAG_TAG_PRESENT bit set in OVS_KEY_ATTR_VLAN caused the flow to match
> on packets with VLAN tag present. After this patch, it causes the flow
> to match only on those packets that have a certain value of
> VLAN_CFI_MASK in their VLAN tag (I haven't bother deciphering what
> value is checked after all these xors, it's as well possible that it
> will also match on packets _without_ any VLAN header).
> =

> You have to preserve the old meaning of VLAN_TAG_PRESENT in
> OVS_KEY_ATTR_VLAN. When doing flow lookups, VLAN_TAG_PRESENT must match
> on and only on packets that have VLAN tag present, irrespective of their
> VLAN_CFI_MASK.
> =

> If you want to introduce support for lookups on VLAN_CFI_MASK, you'll
> have to do that by introducing a new netlink attribute.

Hmm. In that case I'll just mask the CFI bit on entry to OVS.
Otherwise it's for me like to stab in a dark at a large beast
I know nothing about.

Best Regards,
Micha=B3=A0Miros=B3aw
