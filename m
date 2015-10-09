From: Premkumar Jonnala <pjonnala@broadcom.com>
Subject: RE: [PATCH net-next v3 3/4] bridge: push bridge setting ageing_time
 down to switchdev
Date: Fri, 9 Oct 2015 04:38:10 +0000
Message-ID: <77EF4405DD4BB54AACCE7DB593DF6A9A9F6596@SJEXCHMB14.corp.ad.broadcom.com>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
 <1444357400-37078-4-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
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
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:40997 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932418AbbJIEiR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 00:38:17 -0400
In-Reply-To: <1444357400-37078-4-git-send-email-sfeldma@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: sfeldma@gmail.com [mailto:sfeldma@gmail.com]
> Sent: Friday, October 09, 2015 7:53 AM
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net; jiri@resnulli.us; siva.mannem.lnx@gmail.com;
> Premkumar Jonnala; stephen@networkplumber.org;
> roopa@cumulusnetworks.com; andrew@lunn.ch; f.fainelli@gmail.com;
> vivien.didelot@savoirfairelinux.com
> Subject: [PATCH net-next v3 3/4] bridge: push bridge setting ageing_time down
> to switchdev
> 
> From: Scott Feldman <sfeldma@gmail.com>
> 
> Use SWITCHDEV_F_SKIP_EOPNOTSUPP to skip over ports in bridge that don't
> support setting ageing_time (or setting bridge attrs in general).
> 
> If push fails, don't update ageing_time in bridge and return err to user.
> 
> If push succeeds, update ageing_time in bridge and run gc_timer now to
> recalabrate when to run gc_timer next, based on new ageing_time.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/bridge/br_ioctl.c    |    3 +--
>  net/bridge/br_netlink.c  |    6 +++---
>  net/bridge/br_private.h  |    1 +
>  net/bridge/br_stp.c      |   23 +++++++++++++++++++++++
>  net/bridge/br_sysfs_br.c |    3 +--
>  5 files changed, 29 insertions(+), 7 deletions(-)
> 
> diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
> index 8d423bc..263b4de 100644
> --- a/net/bridge/br_ioctl.c
> +++ b/net/bridge/br_ioctl.c
> @@ -200,8 +200,7 @@ static int old_dev_ioctl(struct net_device *dev, struct
> ifreq *rq, int cmd)
>  		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
>  			return -EPERM;
> 
> -		br->ageing_time = clock_t_to_jiffies(args[1]);
> -		return 0;
> +		return br_set_ageing_time(br, args[1]);
> 
>  	case BRCTL_GET_PORT_INFO:
>  	{
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index d78b442..544ab96 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -870,9 +870,9 @@ static int br_changelink(struct net_device *brdev, struct
> nlattr *tb[],
>  	}
> 
>  	if (data[IFLA_BR_AGEING_TIME]) {
> -		u32 ageing_time = nla_get_u32(data[IFLA_BR_AGEING_TIME]);
> -
> -		br->ageing_time = clock_t_to_jiffies(ageing_time);
> +		err = br_set_ageing_time(br,
> nla_get_u32(data[IFLA_BR_AGEING_TIME]));
> +		if (err)
> +			return err;
>  	}
> 
>  	if (data[IFLA_BR_STP_STATE]) {
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 09d3ecb..ba0c67b 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -882,6 +882,7 @@ void __br_set_forward_delay(struct net_bridge *br,
> unsigned long t);
>  int br_set_forward_delay(struct net_bridge *br, unsigned long x);
>  int br_set_hello_time(struct net_bridge *br, unsigned long x);
>  int br_set_max_age(struct net_bridge *br, unsigned long x);
> +int br_set_ageing_time(struct net_bridge *br, u32 ageing_time);
> 
> 
>  /* br_stp_if.c */
> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
> index 3a982c0..db6d243de 100644
> --- a/net/bridge/br_stp.c
> +++ b/net/bridge/br_stp.c
> @@ -566,6 +566,29 @@ int br_set_max_age(struct net_bridge *br, unsigned
> long val)
> 
>  }
> 
> +int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
> +{
> +	struct switchdev_attr attr = {
> +		.id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
> +		.flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
> +		.u.ageing_time = ageing_time,
> +	};
> +	unsigned long t = clock_t_to_jiffies(ageing_time);
> +	int err;
> +
> +	if (t < BR_MIN_AGEING_TIME || t > BR_MAX_AGEING_TIME)
> +		return -ERANGE;
> +
> +	err = switchdev_port_attr_set(br->dev, &attr);

A thought - given that the ageing time is not a per-bridge-port attr, why are we using a "port based api"
to pass the attribute down?  May be I'm missing something here?

-Prem


> +	if (err)
> +		return err;
> +
> +	br->ageing_time = t;
> +	mod_timer(&br->gc_timer, jiffies);
> +
> +	return 0;
> +}
> +
>  void __br_set_forward_delay(struct net_bridge *br, unsigned long t)
>  {
>  	br->bridge_forward_delay = t;
> diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
> index 4c97fc5..04ef192 100644
> --- a/net/bridge/br_sysfs_br.c
> +++ b/net/bridge/br_sysfs_br.c
> @@ -102,8 +102,7 @@ static ssize_t ageing_time_show(struct device *d,
> 
>  static int set_ageing_time(struct net_bridge *br, unsigned long val)
>  {
> -	br->ageing_time = clock_t_to_jiffies(val);
> -	return 0;
> +	return br_set_ageing_time(br, val);
>  }
> 
>  static ssize_t ageing_time_store(struct device *d,
> --
> 1.7.10.4
