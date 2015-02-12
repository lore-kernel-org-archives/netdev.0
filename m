From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] tun: change speed from 10M to dynamically configured
Date: Thu, 12 Feb 2015 16:52:49 +0300
Message-ID: <54DCB031.4020200@cogentembedded.com>
References: <1423719323-4667-1-git-send-email-Yanjun.Zhu@windriver.com> <1423719323-4667-2-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Zhu Yanjun <Yanjun.Zhu@windriver.com>, netdev@vger.kernel.org,
	mst@redhat.com, jasowang@redhat.com, viro@zeniv.linux.org.uk,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:53729 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766AbbBLNwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 08:52:51 -0500
Received: by mail-lb0-f172.google.com with SMTP id p9so8784054lbv.3
        for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 05:52:50 -0800 (PST)
In-Reply-To: <1423719323-4667-2-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/12/2015 8:35 AM, Zhu Yanjun wrote:

> From: Zhu Yanjun <yanjun.zhu@windriver.com>

> The default speed of normal nic is 1000M while the default speed
> of tun is 10M. Now the default speed of tun is changed to 1000M.
> And there are 3 options: 10M, 100M and 1000M to the speed of tun.
> The command "ethtool -s tun0 speed 10/100/1000" can configure the
> speed of tun dynamically.

> CC: Michael S. Tsirkin <mst@redhat.com>
> CC: Jason Wang <jasowang@redhat.com>
> CC: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
> ---
>   drivers/net/tun.c           | 36 +++++++++++++++++++++++++++++++++++-
>   include/uapi/linux/if_tun.h |  5 +++++
>   2 files changed, 40 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 8c8dc16..64f4dcc 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
[...]
> @@ -2257,9 +2260,18 @@ static struct miscdevice tun_miscdev = {
>
>   static int tun_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>   {
> +	struct tun_struct *tun = netdev_priv(dev);
> +
> +	/*Get the speed of tun*/

    Please add spaces after /* and before */.

[...]
> @@ -2287,6 +2299,27 @@ static void tun_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info
>   	}
>   }
>
> +static int tun_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
> +{
> +	struct tun_struct *tun = netdev_priv(dev);
> +	u32 speed = ethtool_cmd_speed(cmd);
> +
> +	if (10 == speed) {
> +		tun->flags &= ~TUN_CTRL_SPD_100;
> +		tun->flags &= ~TUN_CTRL_SPD_1000;

   Can't you clear both bits at once?

> +		tun->flags |= TUN_CTRL_SPD_10;
> +	} else if (100 == speed) {
> +		tun->flags &= ~TUN_CTRL_SPD_10;
> +		tun->flags &= ~TUN_CTRL_SPD_1000;
> +		tun->flags |= TUN_CTRL_SPD_100;
> +	} else {
> +		tun->flags &= ~TUN_CTRL_SPD_10;
> +		tun->flags &= ~TUN_CTRL_SPD_100;
> +		tun->flags |= TUN_CTRL_SPD_1000;
> +	}

    This is asking to be a *switch* statement.

[...]
> diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
> index 50ae243..78a09a7 100644
> --- a/include/uapi/linux/if_tun.h
> +++ b/include/uapi/linux/if_tun.h
> @@ -66,6 +66,11 @@
>   #define IFF_PERSIST	0x0800
>   #define IFF_NOFILTER	0x1000
>
> +/*add speed control, default 1000M*/

    Same remark about the comment style as above.

[...]

WBR, Sergei
