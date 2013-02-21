From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH net-next v2 2/2] ip_gre: propogate target device GSO
 capability to the tunnel device
Date: Fri, 22 Feb 2013 00:30:05 +0200
Message-ID: <1361485805.21950.6.camel@lb-tlvb-dmitry>
References: <1361217053-16984-1-git-send-email-dmitry@broadcom.com>
 <1361217053-16984-2-git-send-email-dmitry@broadcom.com>
 <CANvJab2wKiQjZ=ZEuJO1A=jCnja==a0qL8XULSAU2dc6W-rh3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: pravin <pravin.shelar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3448 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756142Ab3BUWaM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2013 17:30:12 -0500
In-Reply-To: <CANvJab2wKiQjZ=ZEuJO1A=jCnja==a0qL8XULSAU2dc6W-rh3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-19 at 10:39 -0800, pravin wrote:
> On Mon, Feb 18, 2013 at 11:50 AM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
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
> > @@ -1103,8 +1103,14 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev)
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


This mostly reverts previous patch, but also disables GSO when CSUM is
set.

---
 net/ipv4/ip_gre.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 0de54cd..aae2d4b 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1107,16 +1107,10 @@ static int ipgre_tunnel_bind_dev(struct
net_device *dev)
 		mtu = 68;
 
 	tunnel->hlen = addend;
-	/* TCP offload with GRE SEQ is not supported. */
-	if (!(tunnel->parms.o_flags & GRE_SEQ)) {
-		/* device supports enc gso offload*/
-		if (tdev->hw_enc_features & NETIF_F_GRE_GSO) {
-			dev->features		|= NETIF_F_TSO;
-			dev->hw_features	|= NETIF_F_TSO;
-		} else {
-			dev->features		|= NETIF_F_GSO_SOFTWARE;
-			dev->hw_features	|= NETIF_F_GSO_SOFTWARE;
-		}
+	/* TCP offload with GRE SEQ or CSUM is not supported. */
+	if (!(tunnel->parms.o_flags & (GRE_SEQ|GRE_CSUM))) {
+		dev->features		|= NETIF_F_GSO_SOFTWARE;
+		dev->hw_features	|= NETIF_F_GSO_SOFTWARE;
 	}
 
 	return mtu;
-- 
1.7.7.2


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
> 
