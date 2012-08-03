From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH v2] ipv4/ipv6: multicast api unappropriate errno fix.
Date: Fri, 3 Aug 2012 08:09:58 -0400
Message-ID: <OF074B1468.BAD353FE-ON85257A4F.0041C4E9-85257A4F.0042D425@us.ibm.com>
References: <1343977605-14446-1-git-send-email-lw@cn.fujitsu.com> <501B99E1.9090803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, Li Wei <lw@cn.fujitsu.com>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:59902 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753504Ab2HCMLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 08:11:22 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Fri, 3 Aug 2012 06:11:14 -0600
In-Reply-To: <501B99E1.9090803@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 08/03/2012 05:29:05 AM:

> @@ -1933,10 +1933,8 @@ int ip_mc_source(int add, int omode, struct 
> sock *sk, struct
>            (pmc->multi.imr_ifindex == imr.imr_ifindex))
>           break;
>     }
> -   if (!pmc) {      /* must have a prior join */
> -      err = -EINVAL;
> -      goto done;
> -   }
> +   if (!pmc)      /* must have a prior join */
> +      goto done;   /* err = -EADDRNOTAVAIL */

RFC3678, section 4.1.3:
        "When the option itself is not legal on the group (i.e., when 
trying a
   Source-Specific option on a group after doing IP_ADD_MEMBERSHIP, or
   when trying an Any-Source option without doing IP_ADD_MEMBERSHIP) the
   error generated is EINVAL."

>     }
> -   if (rv == 0)      /* address already there is an error */
> +   if (rv == 0) {      /* address already there is an error */
> +      err = -EADDRINUSE;
>        goto done;
> +   }

EADDRINUSE is not one of the API's listed error codes. Section 4.1.3
of RFC3678 specifies:
  "When the option would be legal on the group, but an address is
   invalid (e.g., when trying to block a source that is already blocked
   by the socket, or when trying to drop an unjoined group) the error
   generated is EADDRNOTAVAIL."

At least some of this patch directly differs with RFC3678.

                                                        +-DLS
