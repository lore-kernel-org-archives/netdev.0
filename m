From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next v3 3/4] rocker: Handle IFF_PROTODOWN by doing
 a PHYS-DOWN on the switch port.
Date: Mon, 27 Apr 2015 22:51:06 -0700
Message-ID: <CAE4R7bDF4C_WpueoiRkXDyHk=TfQJG99GB8jEFtOL-yN6Sa2xQ@mail.gmail.com>
References: <1430156304-13187-4-git-send-email-anuradhak@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: anuradhak@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:33563 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbbD1FvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 01:51:07 -0400
Received: by qcrf4 with SMTP id f4so65617344qcr.0
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 22:51:06 -0700 (PDT)
In-Reply-To: <1430156304-13187-4-git-send-email-anuradhak@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 27, 2015 at 10:38 AM,  <anuradhak@cumulusnetworks.com> wrote:
> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>
> IFF_PROTODOWN can be set by user space applications like MLAG on detecting
> errors on a switch port. This patch provides sample switch driver changes
> for handling IFF_PROTODOWN. Rocker PHYS disables the port in response to
> protodown.
>
> Note: I understand Scott has some rocker changes on hold. I will re-spin
> this patch once his changes are in.
>
> Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
> ---
>  drivers/net/ethernet/rocker/rocker.c |   16 +++++++++++++++-
>  1 file changed, 15 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index a87b177..e3084e3 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -3838,7 +3838,8 @@ static int rocker_port_open(struct net_device *dev)
>
>         napi_enable(&rocker_port->napi_tx);
>         napi_enable(&rocker_port->napi_rx);
> -       rocker_port_set_enable(rocker_port, true);
> +       if (!(dev->flags & IFF_PROTO_DOWN))
> +               rocker_port_set_enable(rocker_port, true);
>         netif_start_queue(dev);
>         return 0;
>
> @@ -4238,6 +4239,18 @@ static int rocker_port_swdev_port_stp_update(struct net_device *dev, u8 state)
>         return rocker_port_stp_update(rocker_port, state);
>  }
>
> +static int rocker_port_swdev_port_phy_state_set(struct net_device *dev,
> +                                               bool enable)
> +{
> +       struct rocker_port *rocker_port = netdev_priv(dev);
> +
> +       if (enable && (dev->flags & IFF_UP) && !(dev->flags & IFF_PROTO_DOWN))
> +               rocker_port_set_enable(rocker_port, true);
> +       else
> +               rocker_port_set_enable(rocker_port, false);

This isn't working like your expecting.  PHY link is still up on the
rocker port, so the other end of the wire still sees link UP even when
IFF_PROTO_DOWN is set locally.
