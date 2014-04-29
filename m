From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: [net-next] vxlan: Advertise SCTP checksum offloads
Date: Tue, 29 Apr 2014 13:59:34 -0700 (PDT)
Message-ID: <alpine.LFD.2.03.1404291357500.27339@intel.com>
References: <1398714735-23920-1-git-send-email-jeffrey.t.kirsher@intel.com> <1398775161.3881.9.camel@deadeye.wl.decadent.org.uk> <C5551D9AAB213A418B7FD5E4A6F30A0784A4DA91@ORSMSX108.amr.corp.intel.com> <535FDCE0.80803@gmail.com>
 <alpine.LFD.2.11.1404291028470.14497@fvl-a0.jf.intel.com> <535FE8D5.90600@gmail.com> <alpine.LFD.2.03.1404291210400.19571@intel.com> <535FFCA5.2080707@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51664 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933267AbaD2Uil (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 16:38:41 -0400
In-Reply-To: <535FFCA5.2080707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 29 Apr 2014, Vlad Yasevich wrote:

> On 04/29/2014 03:25 PM, Joseph Gasparakis wrote:
> >=20
> >=20
> > On Tue, 29 Apr 2014, Vlad Yasevich wrote:
> >=20
> >> On 04/29/2014 01:34 PM, Joseph Gasparakis wrote:
> >>>
> >>>
> >>> On Tue, 29 Apr 2014, Vlad Yasevich wrote:
> >>>
> >>>> On 04/29/2014 12:10 PM, Rose, Gregory V wrote:
> >>>>>
> >>>>>> -----Original Message-----
> >>>>>> From: Ben Hutchings [mailto:ben@decadent.org.uk]
> >>>>>> Sent: Tuesday, April 29, 2014 5:39 AM
> >>>>>> To: Kirsher, Jeffrey T
> >>>>>> Cc: davem@davemloft.net; Rose, Gregory V; netdev@vger.kernel.o=
rg;
> >>>>>> gospo@redhat.com; sassmann@redhat.com
> >>>>>> Subject: Re: [net-next] vxlan: Advertise SCTP checksum offload=
s
> >>>>>>
> >>>>>> On Mon, 2014-04-28 at 12:52 -0700, Jeff Kirsher wrote:
> >>>>>>> From: Greg Rose <gregory.v.rose@intel.com>
> >>>>>>>
> >>>>>>> Some HW can offload encapsulated SCTP checksums.  Advertise t=
he
> >>>>>>> capability for such cases.
> >>>>>>
> >>>>>> Don't we need a software fallback on the output path before do=
ing this?
> >>>>>
> >>>>> I believe that the vxlan driver will compare offload features w=
ith the lower device hw_enc_feature flags and if the HW doesn't have th=
e offload then it won't be advertised to the sctp driver.  In that case=
 the sctp driver will do its own checksumming.  At least that is the be=
havior I saw.
> >>>>>
> >>>>
> >>>> I've been looking at this and can't see vxlan doing any feature
> >>>> comparisons/disabling...
> >>>>
> >>>> At the time SCTP tries to do checksum, it will see hw offload
> >>>> support and set checksum as partial.  That will be propagated
> >>>> all the way to vxlan which will set encapsulation and pass it on=
=2E
> >>>> At next dev_hard_start_xmit(), we'll look at hw_enc_features,
> >>>> but it won't matter since SCTP packets are never GSO.
> >>>>
> >>>> So, we'll use the non-gso code path and still send with partial
> >>>> checksum set.  Now, if the driver supports encapsulated SCTP,
> >>>> then it will work.  If it doesn't, the udp checksum will be comp=
uted,
> >>>> but not the sctp one.
> >>>>
> >>>> -vlad
> >>>
> >>> That is exactly the way it works, dev_hard_start_xmit() is where=20
> >>> the (inner) unchecksummed packets will get checksummed if the Tx'=
ing=20
> >>> interface does not support inner SCTP checksumming.
> >>
> >> No, it will not.  dev_hard_start_xmit() calls skb_checksum_help()
> >> which only knows how to calculate TCP/UDP checksums.  It doesn't k=
now
> >> how to compute CRC32c for SCTP protocol.
> >>
> >> -vlad
> >>
> >=20
> > Interesting, thanks for the clarification! Then how do things work =
with=20
> > non-encapsulated SCTP traffic? Where is the csumming for SCTP take =
place=20
> > if the NIC cannot offload the protocol?
>=20
> In SCTP itself.  Look at sctp_packet_transmit().   There are also
> fix-ups in netfilter to correct the checksum if the packet has
> to be rerouted somewhere else.
>=20
> We've tossed around the idea of making skb_checksum have pluggable
> components.  Daniel started us down that path by adding checksum ops.
> We just need registration and proper lookup support.
>=20
> -vlad
>=20

I now totaly see your point. It seems like registering customized=20
csumming/CRCing in skb_checksum is the right way to go. Thanks!

Joseph
> >=20
> >>>
> >>> In effect by "falsely" advertising vxlan being capable to "offloa=
d" a=20
> >>> protocol, we just postpone the software csum calculation until th=
e last=20
> >>> minute, which is dev_hard_start_xmit().
> >>>
> >>> Joseph
> >>>
> >>>>
> >>>>> I'm adding Joseph Gasparakis.  He might have a better answer.
> >>>>>
> >>>>> - Greg
> >>>>>
> >>>>>>
> >>>>>> Ben.
> >>>>>>
> >>>>>>> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> >>>>>>> Acked-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> >>>>>>> Acked-by: Shannon Nelson <shannon.nelson@intel.com>
> >>>>>>> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> >>>>>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >>>>>>> ---
> >>>>>>>  drivers/net/vxlan.c | 1 +
> >>>>>>>  1 file changed, 1 insertion(+)
> >>>>>>>
> >>>>>>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c index
> >>>>>>> 1dfee9a..988208f 100644
> >>>>>>> --- a/drivers/net/vxlan.c
> >>>>>>> +++ b/drivers/net/vxlan.c
> >>>>>>> @@ -2293,6 +2293,7 @@ static void vxlan_setup(struct net_devi=
ce *dev)
> >>>>>>>  	dev->features	|=3D NETIF_F_SG | NETIF_F_HW_CSUM;
> >>>>>>>  	dev->features   |=3D NETIF_F_RXCSUM;
> >>>>>>>  	dev->features   |=3D NETIF_F_GSO_SOFTWARE;
> >>>>>>> +	dev->features   |=3D NETIF_F_SCTP_CSUM;
> >>>>>>>
> >>>>>>>  	dev->vlan_features =3D dev->features;
> >>>>>>>  	dev->features |=3D NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLA=
N_STAG_TX;
> >>>>>>
> >>>>>> --
> >>>>>> Ben Hutchings
> >>>>>> Q.  Which is the greater problem in the world today, ignorance=
 or apathy?
> >>>>>> A.  I don't know and I couldn't care less.
> >>>>> N???????????????r??????y?????????b???X??????=C7=A7v???^???)=DE=BA=
{.n???+?????????z???^???)?????????w*=1Fjg?????????=1E???????????????=DD=
=A2j/?????????z???=DE=96??????2???=DE=99?????????&???)=DF=A1???a??????=7F=
??????=1E???G?????????h???=0F???j:+v?????????w???=D9=A5
> >>>>>
> >>>>
> >>>>
> >>
> >>
>=20
>=20
