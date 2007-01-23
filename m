From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Tue, 23 Jan 2007 09:18:20 +0900 (JST)
Message-ID: <20070123.091820.104515696.yoshfuji@linux-ipv6.org>
References: <20070119212314.GA10748@hmsreliant.homelinux.net>
	<20070120.080507.25118874.yoshfuji@linux-ipv6.org>
	<20070122181528.GD21059@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@coreworks.de, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:46461 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932523AbXAWARN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 19:17:13 -0500
To: nhorman@tuxdriver.com
In-Reply-To: <20070122181528.GD21059@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <20070122181528.GD21059@hmsreliant.homelinux.net> (at Mon, 22 Jan 2007 13:15:28 -0500), Neil Horman <nhorman@tuxdriver.com> says:

> Reposted patch, with your suggestions/corrections incorporated.  The only thing
> I left alone was your last comment regarding the checking of saddr for being a
> unicast address.  According to the RFC as I read it, its possible to receive
> valid neighbor soliciations with a source address that is the unspecified
> address, which I didn't think ipv6_addr_type flagged as being unicast.  Now it
> may be that such NS messages are discarded before arriving at that recieve
> routine, but I was figuring better safe than sorry.  If you're sufficiently
> confident that we won't see non-unicast saddrs there, let me know and I'll
> happily remove that as well.

Okay, right, we can see unspecified source address.
However, we have "dad" variable.

More comments.

> +++ b/include/linux/ipv6.h
> @@ -176,6 +176,7 @@ struct ipv6_devconf {
>  	__s32		accept_ra_rt_info_max_plen;
>  #endif
>  #endif
> +	__s32		use_optimistic_dad;
>  	__s32		proxy_ndp;
>  	void		*sysctl;
>  };

Please do not insert between variables but add to the right before the
"sysctl" member.

> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index 81480e6..972a33a 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -570,6 +570,7 @@ enum {
>  	NET_IPV6_RTR_PROBE_INTERVAL=21,
>  	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN=22,
>  	NET_IPV6_PROXY_NDP=23,
> +	NET_IPV6_OPTIMISTIC_DAD=24,
>  	__NET_IPV6_MAX
>  };
>  
:
> @@ -3918,6 +3948,15 @@ static struct addrconf_sysctl_table
>  			.proc_handler	=	&proc_dointvec,
>  		},
>  		{
> +			.ctl_name	=	NET_IPV6_OPTIMISTIC_DAD,
> +			.procname       =       "use_optimistic_dad",
> +			.data           =       &ipv6_devconf.use_optimistic_dad,
> +			.maxlen         =       sizeof(int),
> +			.mode           =       0644,
> +			.proc_handler   =       &proc_dointvec,
> +
> +		},
> +		{
>  			.ctl_name	=	0,	/* sentinel */
>  		}
>  	},

Please use similar names (sysctl enum, member name and sysctl name(s)); e.g.
NET_IPV6_OPTIMISTIC_DAD, optimistic_dad, "optimistic_dad".

You forgot adding DEVCONF_OPTIMISTIC_DAD in include/linux/ipv6.h
and net/ipv6/addrconf.c:ipv6_store_devconf().

:
> @@ -746,6 +772,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  	int dad = ipv6_addr_any(saddr);
>  	int inc;
>  	int is_router;
> +	int type;
>  
>  	if (ipv6_addr_is_multicast(&msg->target)) {
>  		ND_PRINTK2(KERN_WARNING 

Here, "dad" is true if the source is unspecified address.  So,

> @@ -816,8 +845,20 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>  					goto out;
>  				}
>  			}
> -			addrconf_dad_failure(ifp); 
> -			return;
> +
> +			/* The one exception to the above rule about 
> +			   optimistic addresses is that we need to always 
> +			   respond to an NS from a unicast address if we are
> +			   optimistic. RFC 4429 Sec 3.3.  If (unicast
> +			   and optimistic) are false then we can just fail
> +			   dad now.
> +			*/
> +			type = ipv6_addr_type(saddr);			
> +			if (!((ifp->flags & IFA_F_OPTIMISTIC) && 
> +			    (type & IPV6_ADDR_UNICAST))) {
> +				addrconf_dad_failure(ifp); 
> +				return;
> +			}
>  		}
>  
>  		idev = ifp->idev;

You can say,
			if (dad || !(ifp->flags & IFA_F_OPTIMISTIC)) {
				addrconf_dad_failure(ifp);
				return;
			}

Regards,

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
