From: Joseph Gasparakis <jgaspara@intel.com>
Subject: Re: [net-next] vxlan: Advertise SCTP checksum offloads
Date: Tue, 29 Apr 2014 10:34:04 -0700 (PDT)
Message-ID: <alpine.LFD.2.11.1404291028470.14497@fvl-a0.jf.intel.com>
References: <1398714735-23920-1-git-send-email-jeffrey.t.kirsher@intel.com> <1398775161.3881.9.camel@deadeye.wl.decadent.org.uk> <C5551D9AAB213A418B7FD5E4A6F30A0784A4DA91@ORSMSX108.amr.corp.intel.com> <535FDCE0.80803@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Gasparakis, Joseph" <joseph.gasparakis@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:3846 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932759AbaD2Rcj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 13:32:39 -0400
In-Reply-To: <535FDCE0.80803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 29 Apr 2014, Vlad Yasevich wrote:

> On 04/29/2014 12:10 PM, Rose, Gregory V wrote:
> >=20
> >> -----Original Message-----
> >> From: Ben Hutchings [mailto:ben@decadent.org.uk]
> >> Sent: Tuesday, April 29, 2014 5:39 AM
> >> To: Kirsher, Jeffrey T
> >> Cc: davem@davemloft.net; Rose, Gregory V; netdev@vger.kernel.org;
> >> gospo@redhat.com; sassmann@redhat.com
> >> Subject: Re: [net-next] vxlan: Advertise SCTP checksum offloads
> >>
> >> On Mon, 2014-04-28 at 12:52 -0700, Jeff Kirsher wrote:
> >>> From: Greg Rose <gregory.v.rose@intel.com>
> >>>
> >>> Some HW can offload encapsulated SCTP checksums.  Advertise the
> >>> capability for such cases.
> >>
> >> Don't we need a software fallback on the output path before doing =
this?
> >=20
> > I believe that the vxlan driver will compare offload features with =
the lower device hw_enc_feature flags and if the HW doesn't have the of=
fload then it won't be advertised to the sctp driver.  In that case the=
 sctp driver will do its own checksumming.  At least that is the behavi=
or I saw.
> >=20
>=20
> I've been looking at this and can't see vxlan doing any feature
> comparisons/disabling...
>=20
> At the time SCTP tries to do checksum, it will see hw offload
> support and set checksum as partial.  That will be propagated
> all the way to vxlan which will set encapsulation and pass it on.
> At next dev_hard_start_xmit(), we'll look at hw_enc_features,
> but it won't matter since SCTP packets are never GSO.
>=20
> So, we'll use the non-gso code path and still send with partial
> checksum set.  Now, if the driver supports encapsulated SCTP,
> then it will work.  If it doesn't, the udp checksum will be computed,
> but not the sctp one.
>=20
> -vlad

That is exactly the way it works, dev_hard_start_xmit() is where=20
the (inner) unchecksummed packets will get checksummed if the Tx'ing=20
interface does not support inner SCTP checksumming.

In effect by "falsely" advertising vxlan being capable to "offload" a=20
protocol, we just postpone the software csum calculation until the last=
=20
minute, which is dev_hard_start_xmit().

Joseph

>=20
> > I'm adding Joseph Gasparakis.  He might have a better answer.
> >=20
> > - Greg
> >=20
> >>
> >> Ben.
> >>
> >>> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> >>> Acked-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> >>> Acked-by: Shannon Nelson <shannon.nelson@intel.com>
> >>> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> >>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >>> ---
> >>>  drivers/net/vxlan.c | 1 +
> >>>  1 file changed, 1 insertion(+)
> >>>
> >>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c index
> >>> 1dfee9a..988208f 100644
> >>> --- a/drivers/net/vxlan.c
> >>> +++ b/drivers/net/vxlan.c
> >>> @@ -2293,6 +2293,7 @@ static void vxlan_setup(struct net_device *=
dev)
> >>>  	dev->features	|=3D NETIF_F_SG | NETIF_F_HW_CSUM;
> >>>  	dev->features   |=3D NETIF_F_RXCSUM;
> >>>  	dev->features   |=3D NETIF_F_GSO_SOFTWARE;
> >>> +	dev->features   |=3D NETIF_F_SCTP_CSUM;
> >>>
> >>>  	dev->vlan_features =3D dev->features;
> >>>  	dev->features |=3D NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_ST=
AG_TX;
> >>
> >> --
> >> Ben Hutchings
> >> Q.  Which is the greater problem in the world today, ignorance or =
apathy?
> >> A.  I don't know and I couldn't care less.
> > N???????????????r??????y?????????b???X??????=C7=A7v???^???)=DE=BA{.=
n???+?????????z???^???)?????????w*=1Fjg?????????=1E???????????????=DD=A2=
j/?????????z???=DE=96??????2???=DE=99?????????&???)=DF=A1???a??????=7F?=
?????=1E???G?????????h???=0F???j:+v?????????w???=D9=A5
> >=20
>=20
>=20
