From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v6 3/4] rocker: Handle protodown notifications.
Date: Tue, 14 Jul 2015 19:42:51 +0300
Message-ID: <55A53C0B.6010807@cogentembedded.com>
References: <1436887930-3067-4-git-send-email-anuradhak@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com
To: anuradhak@cumulusnetworks.com, davem@davemloft.net,
	sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:36511 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753096AbbGNQmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 12:42:55 -0400
Received: by lbbpo10 with SMTP id po10so9613021lbb.3
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 09:42:54 -0700 (PDT)
In-Reply-To: <1436887930-3067-4-git-send-email-anuradhak@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07/14/2015 06:32 PM, anuradhak@cumulusnetworks.com wrote:

> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

> protodown can be set by user space applications like MLAG on detecting
> errors on a switch port. This patch provides sample switch driver changes
> for handling protodown. Rocker PHYS disables the port in response to
> protodown.

> Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
> ---
>   drivers/net/ethernet/rocker/rocker.c |   19 ++++++++++++++++++-
>   1 file changed, 18 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index 2d8578cade..ec950d9 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -3983,7 +3983,8 @@ static int rocker_port_open(struct net_device *dev)
>
>   	napi_enable(&rocker_port->napi_tx);
>   	napi_enable(&rocker_port->napi_rx);
> -	rocker_port_set_enable(rocker_port, true);
> +	if (!(dev->proto_down))

    Inner parens not needed.

> +		rocker_port_set_enable(rocker_port, true);
>   	netif_start_queue(dev);
>   	return 0;
>
> @@ -4167,6 +4168,21 @@ static int rocker_port_get_phys_port_name(struct net_device *dev,
>   	return err ? -EOPNOTSUPP : 0;
>   }
>
> +static int rocker_port_change_proto_down(struct net_device *dev,
> +					 bool proto_down)
> +{
> +	struct rocker_port *rocker_port = netdev_priv(dev);
> +
> +	if (rocker_port->dev->flags & IFF_UP) {
> +		if (proto_down)
> +			rocker_port_set_enable(rocker_port, false);
> +		else
> +			rocker_port_set_enable(rocker_port, true);

    Why not:

		rocker_port_set_enable(rocker_port, !proto_down);

[...]

MBR, Sergei
