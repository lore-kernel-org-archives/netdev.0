From: Mike Manning <mmanning@brocade.com>
Subject: Re: [PATCH] net: ipv6: Fix warning of freeing alive inet6 address
Date: Wed, 3 May 2017 15:16:20 +0100
Message-ID: <1fb7b6de-ddb8-0207-0567-91d1ed0aad83@brocade.com>
References: <1493749857-18032-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Andrey Konovalov <andreyknvl@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:50840 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753133AbdECOQe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 10:16:34 -0400
In-Reply-To: <1493749857-18032-1-git-send-email-mmanning@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On reflection, please put this on hold subject to testing with syzkaller. I have not had a repro of the issue and so the fix even though harmless may not be effective.

Thanks
Mike

On 02/05/17 19:30, Mike Manning wrote:
> While this is not reproducible manually, Andrey's syzkaller program hit
> the warning "IPv6: Freeing alive inet6 address" with this part trace:
> 
> inet6_ifa_finish_destroy+0x12e/0x190 c:894
> in6_ifa_put ./include/net/addrconf.h:330
> addrconf_dad_work+0x4e9/0x1040 net/ipv6/addrconf.c:3963
> 
> The fix is to call in6_ifa_put() for the inet6_ifaddr before rather
> than after calling addrconf_ifdown(), as the latter may remove it from
> the address hash table.
> 
> Fixes: 85b51b12115c ("net: ipv6: Remove addresses for failures with strict DAD")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Mike Manning <mmanning@brocade.com>
> ---
>  net/ipv6/addrconf.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 80ce478..361993a 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3902,8 +3902,11 @@ static void addrconf_dad_work(struct work_struct *w)
>  	} else if (action == DAD_ABORT) {
>  		in6_ifa_hold(ifp);
>  		addrconf_dad_stop(ifp, 1);
> -		if (disable_ipv6)
> +		if (disable_ipv6) {
> +			in6_ifa_put(ifp);
>  			addrconf_ifdown(idev->dev, 0);
> +			goto unlock;
> +		}
>  		goto out;
>  	}
>  
> @@ -3950,6 +3953,7 @@ static void addrconf_dad_work(struct work_struct *w)
>  		      ifp->dad_nonce);
>  out:
>  	in6_ifa_put(ifp);
> +unlock:
>  	rtnl_unlock();
>  }
>  
> 
