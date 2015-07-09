From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 4/5] rocker: add offload_fwd_mark support
Date: Thu, 9 Jul 2015 13:26:09 +0900
Message-ID: <20150709042606.GA16603@vergenet.net>
References: <1436397403-62412-1-git-send-email-sfeldma@gmail.com>
 <1436397403-62412-5-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@resnulli.us, roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34754 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbbGIE0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 00:26:19 -0400
Received: by pdbep18 with SMTP id ep18so157433570pdb.1
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 21:26:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1436397403-62412-5-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Scott,

On Wed, Jul 08, 2015 at 04:16:42PM -0700, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> If device flags ingress packet as "fwd offload", mark the
> skb->offlaod_fwd_mark using the ingress port's dev->offlaod_fwd_mark.  This
> will be the hint to the kernel that this packet has already been forwarded
> by device to egress ports matching skb->offlaod_fwd_mark.
> 
> For rocker, derive port dev->offlaod_fwd_mark based on device switch ID and
> port ifindex.  If port is bridged, use the bridge ifindex rather than the
> port ifindex.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

[snip]

> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index c005167..a4ced91 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c

[snip] 

> @@ -4938,11 +4944,13 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
>  	}
>  	rocker->ports[port_number] = rocker_port;
>  
> +	switchdev_port_fwd_mark_set(rocker_port->dev, NULL, false);
> +
>  	rocker_port_set_learning(rocker_port, SWITCHDEV_TRANS_NONE);
>  
>  	err = rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE, 0);
>  	if (err) {
> -		dev_err(&pdev->dev, "install ig port table failed\n");
> +		netdev_err(rocker_port->dev, "install ig port table failed\n");
>  		goto err_port_ig_tbl;
>  	}

It is unclear to me how the above *_err change and...

>  
> @@ -4962,6 +4970,7 @@ err_untagged_vlan:
>  	rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE,
>  			   ROCKER_OP_FLAG_REMOVE);
>  err_port_ig_tbl:
> +	rocker->ports[port_number] = NULL;
>  	unregister_netdev(dev);
>  err_register_netdev:
>  	free_netdev(dev);

... the above ports[] change relate to the rest of this patch.

[snip]
