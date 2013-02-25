From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 2/2] ip_gre: propogate target device GSO
 capability to the tunnel device
Date: Sun, 24 Feb 2013 22:07:45 -0800
Message-ID: <CALnjE+pijatQgSLTkveWBJjDkWt5SQqcxP0d-fTe1SyC1UwDhQ@mail.gmail.com>
References: <1361217053-16984-1-git-send-email-dmitry@broadcom.com>
	<1361217053-16984-2-git-send-email-dmitry@broadcom.com>
	<CANvJab2wKiQjZ=ZEuJO1A=jCnja==a0qL8XULSAU2dc6W-rh3A@mail.gmail.com>
	<1361485805.21950.6.camel@lb-tlvb-dmitry>
	<CANvJab3zfR2r_hV=UHWWb5qjx-eyT38F1ZWZWmjRya9eUz5XjA@mail.gmail.com>
	<1361724339.20403.2.camel@lb-tlvb-dmitry.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pravin <pravin.shelar@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:44398 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754563Ab3BYGHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 01:07:46 -0500
Received: by mail-qe0-f71.google.com with SMTP id 3so4858241qea.2
        for <netdev@vger.kernel.org>; Sun, 24 Feb 2013 22:07:45 -0800 (PST)
In-Reply-To: <1361724339.20403.2.camel@lb-tlvb-dmitry.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 24, 2013 at 8:45 AM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
> On Thu, 2013-02-21 at 15:53 -0800, pravin wrote:
>> On Thu, Feb 21, 2013 at 2:30 PM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
>> > On Tue, 2013-02-19 at 10:39 -0800, pravin wrote:
>> >> On Mon, Feb 18, 2013 at 11:50 AM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
>> >> >
>> >> > Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
>> >> > ---
>> >> > Changes from v1: fixed email address
>> >> >
>> >> >
>> >> >  net/ipv4/ip_gre.c |   10 ++++++++--
>> >> >  1 files changed, 8 insertions(+), 2 deletions(-)
>> >> >
>> >> > diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
>> >> > index cdc31ac..31bc941 100644
>> >> > --- a/net/ipv4/ip_gre.c
>> >> > +++ b/net/ipv4/ip_gre.c
>> >> > @@ -1103,8 +1103,14 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev)
>> >> >         tunnel->hlen = addend;
>> >> >         /* TCP offload with GRE SEQ is not supported. */
>> >> >         if (!(tunnel->parms.o_flags & GRE_SEQ)) {
>> >> > -               dev->features           |= NETIF_F_GSO_SOFTWARE;
>> >> > -               dev->hw_features        |= NETIF_F_GSO_SOFTWARE;
>> >> > +               /* device supports enc gso offload*/
>> >> > +               if (tdev->hw_enc_features & NETIF_F_GRE_GSO) {
>> >> > +                       dev->features           |= NETIF_F_TSO;
>> >> > +                       dev->hw_features        |= NETIF_F_TSO;
>> >> > +               } else {
>> >> > +                       dev->features           |= NETIF_F_GSO_SOFTWARE;
>> >> > +                       dev->hw_features        |= NETIF_F_GSO_SOFTWARE;
>> >> > +               }
>> >> >         }
>> >>
>> >> I am not sure about this change, Are you trying to limit GRE TSO to
>> >> just IPV4  in case of GRE offload in hardware?
>> >
>> >
>> > This mostly reverts previous patch, but also disables GSO when CSUM is
>> > set.
>> >
>> > ---
>> >  net/ipv4/ip_gre.c |   14 ++++----------
>> >  1 files changed, 4 insertions(+), 10 deletions(-)
>> >
>> > diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
>> > index 0de54cd..aae2d4b 100644
>> > --- a/net/ipv4/ip_gre.c
>> > +++ b/net/ipv4/ip_gre.c
>> > @@ -1107,16 +1107,10 @@ static int ipgre_tunnel_bind_dev(struct
>> > net_device *dev)
>> >                 mtu = 68;
>> >
>> >         tunnel->hlen = addend;
>> > -       /* TCP offload with GRE SEQ is not supported. */
>> > -       if (!(tunnel->parms.o_flags & GRE_SEQ)) {
>> > -               /* device supports enc gso offload*/
>> > -               if (tdev->hw_enc_features & NETIF_F_GRE_GSO) {
>> > -                       dev->features           |= NETIF_F_TSO;
>> > -                       dev->hw_features        |= NETIF_F_TSO;
>> > -               } else {
>> > -                       dev->features           |= NETIF_F_GSO_SOFTWARE;
>> > -                       dev->hw_features        |= NETIF_F_GSO_SOFTWARE;
>> > -               }
>> > +       /* TCP offload with GRE SEQ or CSUM is not supported. */
>> > +       if (!(tunnel->parms.o_flags & (GRE_SEQ|GRE_CSUM))) {
>> > +               dev->features           |= NETIF_F_GSO_SOFTWARE;
>> > +               dev->hw_features        |= NETIF_F_GSO_SOFTWARE;
>> >         }
>> >
>> >         return mtu;
>>
>> This narrows down definition of NETIF_F_GRE_GSO. Is it required for
>> hardware offload?
>
> This is required to prevent dev_hard_xmit() to perform soft GSO.
> W/o it device receives divided packets.
>
If NIC features are set correctly dev_hard_xmit() will not perform GSO.

>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
