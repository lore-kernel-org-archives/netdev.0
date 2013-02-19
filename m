From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH net-next v2 2/2] ip_gre: propogate target device GSO
 capability to the tunnel device
Date: Tue, 19 Feb 2013 19:31:06 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F1C019A53@SJEXCHMB06.corp.ad.broadcom.com>
References: <1361217053-16984-1-git-send-email-dmitry@broadcom.com>
 <1361217053-16984-2-git-send-email-dmitry@broadcom.com>
 <CANvJab2wKiQjZ=ZEuJO1A=jCnja==a0qL8XULSAU2dc6W-rh3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: pravin <pravin.shelar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2161 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933343Ab3BSTbT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 14:31:19 -0500
In-Reply-To: <CANvJab2wKiQjZ=ZEuJO1A=jCnja==a0qL8XULSAU2dc6W-rh3A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: pravin [mailto:pravin.shelar@gmail.com]
> Sent: Tuesday, February 19, 2013 8:40 PM
> To: Dmitry Kravkov
> Cc: davem@davemloft.net; netdev@vger.kernel.org
> Subject: Re: [PATCH net-next v2 2/2] ip_gre: propogate target device GSO
> capability to the tunnel device
> 
> On Mon, Feb 18, 2013 at 11:50 AM, Dmitry Kravkov <dmitry@broadcom.com>
> wrote:
> >
> > Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> > ---
> > Changes from v1: fixed email address
> >
> >
> >  net/ipv4/ip_gre.c |   10 ++++++++--
> >  1 files changed, 8 insertions(+), 2 deletions(-)
> >
> > diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> > index cdc31ac..31bc941 100644
> > --- a/net/ipv4/ip_gre.c
> > +++ b/net/ipv4/ip_gre.c
> > @@ -1103,8 +1103,14 @@ static int ipgre_tunnel_bind_dev(struct net_device
> *dev)
> >         tunnel->hlen = addend;
> >         /* TCP offload with GRE SEQ is not supported. */
> >         if (!(tunnel->parms.o_flags & GRE_SEQ)) {
> > -               dev->features           |= NETIF_F_GSO_SOFTWARE;
> > -               dev->hw_features        |= NETIF_F_GSO_SOFTWARE;
> > +               /* device supports enc gso offload*/
> > +               if (tdev->hw_enc_features & NETIF_F_GRE_GSO) {
> > +                       dev->features           |= NETIF_F_TSO;
> > +                       dev->hw_features        |= NETIF_F_TSO;
> > +               } else {
> > +                       dev->features           |= NETIF_F_GSO_SOFTWARE;
> > +                       dev->hw_features        |= NETIF_F_GSO_SOFTWARE;
> > +               }
> >         }
> 
> I am not sure about this change, Are you trying to limit GRE TSO to
> just IPV4  in case of GRE offload in hardware?
> 
You're right,
It probably should be fixed to:
	if (tdev && tdev->hw_enc_features & NETIF_F_GRE_GSO) {
		dev->features           |= tdev-> hw_enc_features & NETIF_F_GSO_MASK;
		dev->hw_features        |= tdev-> hw_enc_features & NETIF_F_GSO_MASK;

> >
> >         return mtu;
> > --
> > 1.7.7.2
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
