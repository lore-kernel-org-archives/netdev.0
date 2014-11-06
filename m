From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH net 3/5] fm10k: Implement ndo_gso_check()
Date: Thu, 6 Nov 2014 10:41:15 -0800
Message-ID: <20141106184115.GB18339@gmail.com>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com>
 <1415138202-1197-4-git-send-email-joestringer@nicira.com>
 <545AE2C8.3070705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	jeffrey.t.kirsher@intel.com, linux.nics@intel.com,
	amirv@mellanox.com, shahed.shaikh@qlogic.com,
	Dept-GELinuxNICDev@qlogic.com, therbert@google.com,
	linux-kernel@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:47638 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751305AbaKFSqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 13:46:54 -0500
Received: by mail-pd0-f178.google.com with SMTP id fp1so1633584pdb.23
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 10:46:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <545AE2C8.3070705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 05, 2014 at 06:54:00PM -0800, Alexander Duyck wrote:
> On 11/04/2014 01:56 PM, Joe Stringer wrote:
> > ndo_gso_check() was recently introduced to allow NICs to report the
> > offloading support that they have on a per-skb basis. Add an
> > implementation for this driver which checks for something that look=
s
> > like VXLAN.
> >
> > Implementation shamelessly stolen from Tom Herbert:
> > http://thread.gmane.org/gmane.linux.network/332428/focus=3D333111
> >
> > Signed-off-by: Joe Stringer <joestringer@nicira.com>
> > ---
> > Should this driver report support for GSO on packets with tunnel he=
aders
> > up to 64B like the i40e driver does?
> > ---
> >  drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |   12 +++++++++++=
+
> >  1 file changed, 12 insertions(+)
> >
> > diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/driv=
ers/net/ethernet/intel/fm10k/fm10k_netdev.c
> > index 8811364..b9ef622 100644
> > --- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
> > +++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
> > @@ -1350,6 +1350,17 @@ static void fm10k_dfwd_del_station(struct ne=
t_device *dev, void *priv)
> >  	}
> >  }
> > =20
> > +static bool fm10k_gso_check(struct sk_buff *skb, struct net_device=
 *dev)
> > +{
> > +	if ((skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) &&
> > +	    (skb->inner_protocol_type !=3D ENCAP_TYPE_ETHER ||
> > +	     skb->inner_protocol !=3D htons(ETH_P_TEB) ||
> > +	     skb_inner_mac_header(skb) - skb_transport_header(skb) !=3D 1=
6))
> > +		return false;
> > +
> > +	return true;
> > +}
> > +
> >  static const struct net_device_ops fm10k_netdev_ops =3D {
> >  	.ndo_open		=3D fm10k_open,
> >  	.ndo_stop		=3D fm10k_close,
> > @@ -1372,6 +1383,7 @@ static const struct net_device_ops fm10k_netd=
ev_ops =3D {
> >  	.ndo_do_ioctl		=3D fm10k_ioctl,
> >  	.ndo_dfwd_add_station	=3D fm10k_dfwd_add_station,
> >  	.ndo_dfwd_del_station	=3D fm10k_dfwd_del_station,
> > +	.ndo_gso_check		=3D fm10k_gso_check,
> >  };
> > =20
> >  #define DEFAULT_DEBUG_LEVEL_SHIFT 3
>=20
> I'm thinking this check is far too simplistic.  If you look the fm10k
> driver already has fm10k_tx_encap_offload() in the TSO function for
> verifying if it can support offloading tunnels or not.  I would
> recommend starting there or possibly even just adapting that function=
 to
> suit your purpose.
>=20
> Thanks,
>=20
> Alex

Would it be enough to just call fm10k_tx_encap_offload() in a way that =
echoes fm10k_tso()?

+static bool fm10k_gso_check(struct sk_buff *skb, struct net_device *de=
v)
+{
+ =A0 =A0 =A0 if (skb->encapsulation && !fm10k_tx_encap_offload(skb))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
+
+ =A0 =A0 =A0 return true;
+}

Thanks,
Joe
