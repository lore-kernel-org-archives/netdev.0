From: Jeremiah Mahler <jmmahler@gmail.com>
Subject: Re: [PATCH net-next] net: ipv6: Fix refcnt on host routes
Date: Wed, 2 Mar 2016 17:23:40 -0800
Message-ID: <20160303012340.GA1894@hudson.localdomain>
References: <1456947007-32444-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrey Wagin <avagin@gmail.com>,
	Ying Huang <ying.huang@linux.intel.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:32773 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754518AbcCCBXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 20:23:43 -0500
Received: by mail-pa0-f48.google.com with SMTP id fl4so4418730pad.0
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 17:23:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1456947007-32444-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Mar 02, 2016 at 11:30:07AM -0800, David Ahern wrote:
> Andrew and Ying Huang's test robot both reported usage count problems that
> trace back to the 'keep address on ifdown' patch.
> 
> From Andrew:
> We execute CRIU test on linux-next. On the current linux-next kernel
> they hangs on creating a network namespace.
> 
> The kernel log contains many massages like this:
> [ 1036.122108] unregister_netdevice: waiting for lo to become free.
> Usage count = 2
> [ 1046.165156] unregister_netdevice: waiting for lo to become free.
> Usage count = 2
> [ 1056.210287] unregister_netdevice: waiting for lo to become free.
> Usage count = 2
> 
> I tried to revert this patch and the bug disappeared.
> 
> Here is a set of commands to reproduce this bug:
> 
> [root@linux-next-test linux-next]# uname -a
> Linux linux-next-test 4.5.0-rc6-next-20160301+ #3 SMP Wed Mar 2
> 17:32:18 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
> 
> [root@linux-next-test ~]# unshare -n
> [root@linux-next-test ~]# ip link set up dev lo
> [root@linux-next-test ~]# ip a
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
> group default qlen 1
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>     inet 127.0.0.1/8 scope host lo
>        valid_lft forever preferred_lft forever
>     inet6 ::1/128 scope host
>        valid_lft forever preferred_lft forever
> [root@linux-next-test ~]# logout
> [root@linux-next-test ~]# unshare -n
> 
>  -----
> 
> The problem is a change made to RTM_DELADDR case in __ipv6_ifa_notify that
> was added in an early version of the offending patch and is no longer
> needed.
> 
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Cc: Andrey Wagin <avagin@gmail.com>
> Cc: Ying Huang <ying.huang@linux.intel.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/ipv6/addrconf.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index b1169d511ab4..8c0dab2de5c9 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -5319,12 +5319,10 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
>  			if (rt)
>  				ip6_del_rt(rt);
>  		}
> -		if (ifp->rt) {
> -			dst_hold(&ifp->rt->dst);
> +		dst_hold(&ifp->rt->dst);
> +
> +		ip6_del_rt(ifp->rt);
>  
> -			ip6_del_rt(ifp->rt);
> -			ifp->rt = NULL;
> -		}
>  		rt_genid_bump_ipv6(net);
>  		break;
>  	}
> -- 
> 2.1.4
> 

Tested-by: Jeremiah Mahler <jmmahler@gmail.com>

-- 
- Jeremiah Mahler
