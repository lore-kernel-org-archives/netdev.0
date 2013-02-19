From: pravin <pravin.shelar@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] ip_gre: propogate target device GSO
 capability to the tunnel device
Date: Tue, 19 Feb 2013 14:51:18 -0800
Message-ID: <CANvJab0mmuap_ygd0BWwVr9LbP0gDnZ3B4TqCv+aeM6f0sbWag@mail.gmail.com>
References: <1361217053-16984-1-git-send-email-dmitry@broadcom.com>
	<1361217053-16984-2-git-send-email-dmitry@broadcom.com>
	<CANvJab2wKiQjZ=ZEuJO1A=jCnja==a0qL8XULSAU2dc6W-rh3A@mail.gmail.com>
	<504C9EFCA2D0054393414C9CB605C37F1C019A53@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:48969 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933694Ab3BSWvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 17:51:19 -0500
Received: by mail-wg0-f48.google.com with SMTP id 16so5832738wgi.3
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 14:51:18 -0800 (PST)
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F1C019A53@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 19, 2013 at 11:31 AM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
>> -----Original Message-----
>> From: pravin [mailto:pravin.shelar@gmail.com]
>> Sent: Tuesday, February 19, 2013 8:40 PM
>> To: Dmitry Kravkov
>> Cc: davem@davemloft.net; netdev@vger.kernel.org
>> Subject: Re: [PATCH net-next v2 2/2] ip_gre: propogate target device GSO
>> capability to the tunnel device
>>
>> On Mon, Feb 18, 2013 at 11:50 AM, Dmitry Kravkov <dmitry@broadcom.com>
>> wrote:
>> >
>> > Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
>> > ---
>> > Changes from v1: fixed email address
>> >
>> >
>> >  net/ipv4/ip_gre.c |   10 ++++++++--
>> >  1 files changed, 8 insertions(+), 2 deletions(-)
>> >
>> > diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
>> > index cdc31ac..31bc941 100644
>> > --- a/net/ipv4/ip_gre.c
>> > +++ b/net/ipv4/ip_gre.c
>> > @@ -1103,8 +1103,14 @@ static int ipgre_tunnel_bind_dev(struct net_device
>> *dev)
>> >         tunnel->hlen = addend;
>> >         /* TCP offload with GRE SEQ is not supported. */
>> >         if (!(tunnel->parms.o_flags & GRE_SEQ)) {
>> > -               dev->features           |= NETIF_F_GSO_SOFTWARE;
>> > -               dev->hw_features        |= NETIF_F_GSO_SOFTWARE;
>> > +               /* device supports enc gso offload*/
>> > +               if (tdev->hw_enc_features & NETIF_F_GRE_GSO) {
>> > +                       dev->features           |= NETIF_F_TSO;
>> > +                       dev->hw_features        |= NETIF_F_TSO;
>> > +               } else {
>> > +                       dev->features           |= NETIF_F_GSO_SOFTWARE;
>> > +                       dev->hw_features        |= NETIF_F_GSO_SOFTWARE;
>> > +               }
>> >         }
>>
>> I am not sure about this change, Are you trying to limit GRE TSO to
>> just IPV4  in case of GRE offload in hardware?
>>
> You're right,
> It probably should be fixed to:
>         if (tdev && tdev->hw_enc_features & NETIF_F_GRE_GSO) {
>                 dev->features           |= tdev-> hw_enc_features & NETIF_F_GSO_MASK;
>                 dev->hw_features        |= tdev-> hw_enc_features & NETIF_F_GSO_MASK;
>
>> >
>> >         return mtu;
>> > --
>> > 1.7.7.2
>> >

I think if device features are set right, dev_hard_start_xmit() should
do right thing without any of these changes. i.e. it will GSO ipv6
packets if hardware only supports GRE-ipv4 packets.
This patch changes that at encapsulated dev layer and disables rest of
GSO if one type of TSO available which is not optimal.

>> >
>> > --
>> > To unsubscribe from this list: send the line "unsubscribe netdev" in
>> > the body of a message to majordomo@vger.kernel.org
>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
