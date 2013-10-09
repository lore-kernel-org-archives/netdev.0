From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH net-next v2 5/5] xen-netback: enable IPv6
 TCP GSO to the guest
Date: Wed, 9 Oct 2013 10:26:56 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD012FE96@AMSPEX01CL01.citrite.net>
References: <1381229896-18657-1-git-send-email-paul.durrant@citrix.com>
 <1381229896-18657-6-git-send-email-paul.durrant@citrix.com>
 <5254DE88.90808@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: annie li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:36427 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757097Ab3JIK1t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 06:27:49 -0400
In-Reply-To: <5254DE88.90808@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: annie li [mailto:annie.li@oracle.com]
> Sent: 09 October 2013 05:42
> To: Paul Durrant
> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Wei Liu; David Vrabel;
> Ian Campbell
> Subject: Re: [Xen-devel] [PATCH net-next v2 5/5] xen-netback: enable IPv6
> TCP GSO to the guest
> 
> 
> On 2013-10-8 18:58, Paul Durrant wrote:
> > This patch adds code to handle SKB_GSO_TCPV6 skbs and construct
> appropriate
> > extra or prefix segments to pass the large packet to the frontend. New
> > xenstore flags, feature-gso-tcpv6 and feature-gso-tcpv6-prefix, are
> sampled
> > to determine if the frontend is capable of handling such packets.
> >
> > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> > Cc: Wei Liu <wei.liu2@citrix.com>
> > Cc: David Vrabel <david.vrabel@citrix.com>
> > Cc: Ian Campbell <ian.campbell@citrix.com>
> > ---
> >   drivers/net/xen-netback/common.h    |    6 +++--
> >   drivers/net/xen-netback/interface.c |    8 ++++--
> >   drivers/net/xen-netback/netback.c   |   47
> +++++++++++++++++++++++++++--------
> >   drivers/net/xen-netback/xenbus.c    |   29 +++++++++++++++++++--
> >   4 files changed, 74 insertions(+), 16 deletions(-)
> >
> > diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-
> netback/common.h
> > index b4a9a3c..720b1ca 100644
> > --- a/drivers/net/xen-netback/common.h
> > +++ b/drivers/net/xen-netback/common.h
> > @@ -87,6 +87,7 @@ struct pending_tx_info {
> >   struct xenvif_rx_meta {
> >   	int id;
> >   	int size;
> > +	int gso_type;
> >   	int gso_size;
> >   };
> >
> > @@ -150,9 +151,10 @@ struct xenvif {
> >   	u8               fe_dev_addr[6];
> >
> >   	/* Frontend feature information. */
> > +	int gso_mask;
> > +	int gso_prefix_mask;
> I assume it is a flag instead of mask here, right? If it is mask, then 1
> means disabling the gso.

I don't understand what you're saying here. I'm just swapping from bit flags to a couple of masks. Masks without either of the requisite bits for v4 or v6 gso mean it is disabled.

> > +
> >   	u8 can_sg:1;
> > -	u8 gso:1;
> > -	u8 gso_prefix:1;
> >   	u8 ip_csum:1;
> >   	u8 ipv6_csum:1;
> >
> > diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-
> netback/interface.c
> > index cb0d8ea..3d11387 100644
> > --- a/drivers/net/xen-netback/interface.c
> > +++ b/drivers/net/xen-netback/interface.c
> > @@ -214,8 +214,12 @@ static netdev_features_t
> xenvif_fix_features(struct net_device *dev,
> >
> >   	if (!vif->can_sg)
> >   		features &= ~NETIF_F_SG;
> > -	if (!vif->gso && !vif->gso_prefix)
> > +	if (~(vif->gso_mask | vif->gso_prefix_mask) &
> > +	    (1 << XEN_NETIF_GSO_TYPE_TCPV4))
> 
> Is it better to use XEN_NETIF_GSO_TYPE_TCPV4 directly and setting
> gso_mask(gso_prefix_mask) with "|= XEN_NETIF_GSO_TYPE_TCPV4" or "|=
> XEN_NETIF_GSO_TYPE_TCPV6" instead of "1 <<"?
> 

I thought about it but decided it was best to leave XEN_NETIF_GSO_TYPE_xxx as a list of types rather than bits in a mask as there's no intrinsic reason why you'd ever want to OR them together (unlike the tx or rx flags). That fact I use them as bit shifts in netback is purely for convenience of coding - I guess I could define macros to make it a little tidier though.

  Paul
