From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: PATCH: ipv6: avoid wraparound for expired lifetimes
Date: Thu, 25 Jun 2009 11:40:19 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0906251135410.917@melkinkari.cs.Helsinki.FI>
References: <20090625073943.GO21357@jayr.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Jens Rosenboom <me@jayr.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58333 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbZFYIkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 04:40:18 -0400
In-Reply-To: <20090625073943.GO21357@jayr.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Jun 2009, Jens Rosenboom wrote:

> If the valid or preferred lifetime for an address expires, the kernel
> shows huge values for these due to a counter wrap,

I suspect we have plenty of potentially counter-wrapped printouts all 
around the kernel. So you're fixing just a tip of the iceberg.

> the following patch
> should fix this, at least it did in the test I ran.

You must be kidding...

> --- linux-2.6.30.orig/net/ipv6/addrconf.c	2009-06-10 05:05:27.000000000 +0200
> +++ linux-2.6.30/net/ipv6/addrconf.c	2009-06-25 09:33:38.000000000 +0200
> @@ -3361,9 +3361,17 @@
>  		valid = ifa->valid_lft;
>  		if (preferred != INFINITY_LIFE_TIME) {
>  			long tval = (jiffies - ifa->tstamp)/HZ;
> -			preferred -= tval;
> -			if (valid != INFINITY_LIFE_TIME)
> -				valid -= tval;
> +			if (preferred > tval) {
> +				preferred -= tval;
> +			} else {
> +				preferred = 0;
> +			}
> +			if (valid != INFINITY_LIFE_TIME) {
> +				if (valid > tval) {
> +					valid -= tval;
> +				} else {
> +					valid = 0;
> +				}
>  		}

...because of the brace that is missing here, I get:

ijjarvin@pointhope:~/linux/mainline$ make net/ipv6/addrconf.o
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  SYMLINK include/asm -> include/asm-x86
  CALL    scripts/checksyscalls.sh
  CC      net/ipv6/addrconf.o
net/ipv6/addrconf.c: In function inet6_fill_ifaddr:
net/ipv6/addrconf.c:3393: error: invalid storage class for function 
inet6_fill_ifmcaddr
net/ipv6/addrconf.c:3391: warning: ISO C90 forbids mixed declarations and 
code
net/ipv6/addrconf.c:3418: error: invalid storage class for function 
inet6_fill_ifacaddr
net/ipv6/addrconf.c:3450: error: invalid storage class for function 
inet6_dump_addr
net/ipv6/addrconf.c:3531: error: invalid storage class for function 
inet6_dump_ifaddr
net/ipv6/addrconf.c:3538: error: invalid storage class for function 
inet6_dump_ifmcaddr
net/ipv6/addrconf.c:3546: error: invalid storage class for function 
inet6_dump_ifacaddr
net/ipv6/addrconf.c:3554: error: invalid storage class for function 
inet6_rtm_getaddr
net/ipv6/addrconf.c:3604: error: invalid storage class for function 
inet6_ifa_notify
net/ipv6/addrconf.c:3629: error: invalid storage class for function 
ipv6_store_devconf
net/ipv6/addrconf.c:3674: error: invalid storage class for function 
inet6_if_nlmsg_size
net/ipv6/addrconf.c:3691: error: invalid storage class for function 
__snmp6_fill_stats
net/ipv6/addrconf.c:3706: error: invalid storage class for function 
snmp6_fill_stats
net/ipv6/addrconf.c:3719: error: invalid storage class for function 
inet6_fill_ifinfo
net/ipv6/addrconf.c:3787: error: invalid storage class for function 
inet6_dump_ifinfo
net/ipv6/addrconf.c:3840: error: invalid storage class for function 
inet6_prefix_nlmsg_size
net/ipv6/addrconf.c:3849: error: invalid storage class for function 
inet6_fill_prefix
net/ipv6/addrconf.c:3887: error: invalid storage class for function 
inet6_prefix_notify
net/ipv6/addrconf.c:3911: error: invalid storage class for function 
__ipv6_ifa_notify
net/ipv6/addrconf.c:3939: error: invalid storage class for function 
ipv6_ifa_notify
net/ipv6/addrconf.c:3951: error: invalid storage class for function 
addrconf_sysctl_forward
net/ipv6/addrconf.c:3967: error: invalid storage class for function 
addrconf_sysctl_forward_strategy
net/ipv6/addrconf.c:3999: error: invalid storage class for function 
dev_disable_change
net/ipv6/addrconf.c:4010: error: invalid storage class for function 
addrconf_disable_change
net/ipv6/addrconf.c:4030: error: invalid storage class for function 
addrconf_disable_ipv6
net/ipv6/addrconf.c:4055: error: invalid storage class for function 
addrconf_sysctl_disable
net/ipv6/addrconf.c:4081: error: initializer element is not constant
net/ipv6/addrconf.c:4081: error: (near initialization for 
addrconf_sysctl.addrconf_vars[0].proc_handler)
net/ipv6/addrconf.c:4082: error: initializer element is not constant
net/ipv6/addrconf.c:4082: error: (near initialization for 
addrconf_sysctl.addrconf_vars[0].strategy)
net/ipv6/addrconf.c:4304: error: initializer element is not constant
net/ipv6/addrconf.c:4304: error: (near initialization for 
addrconf_sysctl.addrconf_vars[26].proc_handler)
net/ipv6/addrconf.c:4323: error: invalid storage class for function 
__addrconf_sysctl_register
net/ipv6/addrconf.c:4377: error: invalid storage class for function 
__addrconf_sysctl_unregister
net/ipv6/addrconf.c:4391: error: invalid storage class for function 
addrconf_sysctl_register
net/ipv6/addrconf.c:4401: error: invalid storage class for function 
addrconf_sysctl_unregister
net/ipv6/addrconf.c:4410: error: invalid storage class for function 
addrconf_init_net
net/ipv6/addrconf.c:4461: error: invalid storage class for function 
addrconf_exit_net
net/ipv6/addrconf.c:4473: error: initializer element is not constant
net/ipv6/addrconf.c:4473: error: (near initialization for 
addrconf_ops.init)
net/ipv6/addrconf.c:4474: error: initializer element is not constant
net/ipv6/addrconf.c:4474: error: (near initialization for 
addrconf_ops.exit)
net/ipv6/addrconf.c:4486: error: non-static declaration of 
register_inet6addr_notifier follows static declaration
net/ipv6/addrconf.c:4482: error: previous definition of 
register_inet6addr_notifier was here
net/ipv6/addrconf.c:4493: error: non-static declaration of 
unregister_inet6addr_notifier follows static declaration
net/ipv6/addrconf.c:4489: error: previous definition of 
unregister_inet6addr_notifier was here
net/ipv6/addrconf.c:4601: error: expected declaration or statement at end 
of input
make[1]: *** [net/ipv6/addrconf.o] Error 1
make: *** [net/ipv6/addrconf.o] Error 2
ijjarvin@pointhope:~/linux/mainline$ 


-- 
 i.
