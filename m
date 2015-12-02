From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next v2 01/28] net: dev: Check CHANGEUPPER notifier
 return value
Date: Wed, 02 Dec 2015 15:20:50 -0800
Message-ID: <565F7CD2.2080207@gmail.com>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us> <1449086871-19911-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34815 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757809AbbLBXVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 18:21:13 -0500
Received: by padhx2 with SMTP id hx2so53768905pad.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 15:21:12 -0800 (PST)
In-Reply-To: <1449086871-19911-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-12-02 12:07 PM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> switchdev drivers reflect the newly requested topology to hardware when
> CHANGEUPPER is received, after software links were already formed.
> However, the operation can fail and user will not be notified, as the
> return value of the notifier is not checked.
> 
> Add this check and rollback software links if necessary.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
> -new patch
> ---
>  net/core/dev.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 5df6cbc..df33f82 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5490,8 +5490,11 @@ static int __netdev_upper_dev_link(struct net_device *dev,
>  			goto rollback_lower_mesh;
>  	}
>  
> -	call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
> -				      &changeupper_info.info);
> +	ret = call_netdevice_notifiers_info(NETDEV_CHANGEUPPER, dev,
> +					    &changeupper_info.info);
> +	if (ret)
> +		goto rollback_lower_mesh;
> +

hmm small nit (take it or leave it) but I think it would be more
correct if this was

	if (ret == NOTIFY_BAD)
		goto rollback_lower_mesh;

It seems that NOTIFY_DONE, NOTIFY_OK and NOTIFY_STOP_MASK would be
valid return codes that don't indicate an error. However seeing I
couldn't find any cases of NOTIFY_OK/NOTIFY_STOP_MASK from the
CHANGEUPPER event it doesn't matter in practice.

Thanks,
John

>  	return 0;
>  
>  rollback_lower_mesh:
> 
