From: Premkumar Jonnala <pjonnala@broadcom.com>
Subject: RE: [PATCH net-next 2/4] switchdev: skip over ports returning
 -EOPNOTSUPP when recursing ports
Date: Fri, 25 Sep 2015 04:33:06 +0000
Message-ID: <77EF4405DD4BB54AACCE7DB593DF6A9A9F22D9@SJEXCHMB14.corp.ad.broadcom.com>
References: <1443128370-27353-1-git-send-email-sfeldma@gmail.com>
 <1443128370-27353-3-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
	"siva.mannem.lnx@gmail.com" <siva.mannem.lnx@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"vivien.didelot@savoirfairelinux.com"
	<vivien.didelot@savoirfairelinux.com>
To: "sfeldma@gmail.com" <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:31408 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbbIYEdI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 00:33:08 -0400
In-Reply-To: <1443128370-27353-3-git-send-email-sfeldma@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Premkumar Jonnala

> -----Original Message-----
> From: sfeldma@gmail.com [mailto:sfeldma@gmail.com]
> Sent: Friday, September 25, 2015 2:29 AM
> To: netdev@vger.kernel.org
> Cc: jiri@resnulli.us; siva.mannem.lnx@gmail.com; Premkumar Jonnala;
> stephen@networkplumber.org; roopa@cumulusnetworks.com;
> andrew@lunn.ch; f.fainelli@gmail.com; vivien.didelot@savoirfairelinux.com
> Subject: [PATCH net-next 2/4] switchdev: skip over ports returning -
> EOPNOTSUPP when recursing ports
> 
> From: Scott Feldman <sfeldma@gmail.com>
> 
> This allows us to recurse over all the ports, skipping over unsupporting
> ports.  Without the change, the recursion would stop at first unsupported
> port.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---
>  include/net/switchdev.h   |    1 +
>  net/switchdev/switchdev.c |    9 ++++++++-
>  2 files changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index 54b2faa..22a6dbe 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -15,6 +15,7 @@
>  #include <linux/notifier.h>
> 
>  #define SWITCHDEV_F_NO_RECURSE		BIT(0)
> +#define SWITCHDEV_F_SKIP_EOPNOTSUPP	BIT(1)
> 
>  enum switchdev_trans {
>  	SWITCHDEV_TRANS_NONE,
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index fda38f8..5c30da0 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -73,7 +73,7 @@ static int __switchdev_port_attr_set(struct net_device
> *dev,
>  		return ops->switchdev_port_attr_set(dev, attr);
> 
>  	if (attr->flags & SWITCHDEV_F_NO_RECURSE)
> -		return err;
> +		goto done;
> 
>  	/* Switch device port(s) may be stacked under
>  	 * bond/team/vlan dev, so recurse down to set attr on
> @@ -82,10 +82,17 @@ static int __switchdev_port_attr_set(struct net_device
> *dev,
> 
>  	netdev_for_each_lower_dev(dev, lower_dev, iter) {
>  		err = __switchdev_port_attr_set(lower_dev, attr);
> +		if (err == -EOPNOTSUPP &&
> +		    attr->flags & SWITCHDEV_F_SKIP_EOPNOTSUPP)
> +			continue;
>  		if (err)
>  			break;
>  	}
> 
> +done:
> +	if (err == -EOPNOTSUPP && attr->flags &
> SWITCHDEV_F_SKIP_EOPNOTSUPP)
> +		err = 0;
> +
>  	return err;
>  }
> 
> --
> 1.7.10.4
