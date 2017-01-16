From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 3/3] net: ipv6: Add option to dump multipath
 routes via RTA_MULTIPATH attribute
Date: Mon, 16 Jan 2017 10:40:31 -0700
Message-ID: <657faf8a-88ca-da82-c83a-d111400984da@cumulusnetworks.com>
References: <1484510826-2723-1-git-send-email-dsa@cumulusnetworks.com>
 <1484510826-2723-4-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ddutt@cumulusnetworks.com, roopa <roopa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34983 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750777AbdAPRkd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 12:40:33 -0500
Received: by mail-pg0-f41.google.com with SMTP id 194so17125023pgd.2
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 09:40:33 -0800 (PST)
In-Reply-To: <1484510826-2723-4-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

upon further review ...

On 1/15/17 1:07 PM, David Ahern wrote:
> To maintain backwards compatibility, a user has to request the change
> in behavior. Unfortunately, adding a flag to the header similar to a
> previous patch does not work here as the netlink header for route dumps
> can be either rtgenmsg or ifinfomsg. sysctl is the other commonly used
> option for backwards compatibility but it is overly abused and is not
> really appropriate for this situation since each request should be able
> to specify the preference for the RTA_MULTIPATH attribute (e.g, one
> command may understand RTA_MULTIPATH for IPv6 while another may not).

The ancillary header is supposed to be struct rtmsg, so the change in behavior can be done by requiring the rtmsg struct and then passing the RTM_F_ALL_NEXTHOPS flag in rtm_flags. This makes the user api for delete requests and dumps consistent.

...

> @@ -422,9 +436,22 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
>  		cb->args[2] = (long)w;
>  	}
>  
> +	hdrlen = nlmsg_len(cb->nlh) < sizeof(struct ifinfomsg) ?
> +		 sizeof(struct rtgenmsg) : sizeof(struct ifinfomsg);
> +
> +	if (nlmsg_parse(cb->nlh, hdrlen, nlattr, RTA_MAX, NULL) >= 0) {
> +		/* existence of RTA_MULTIPATH attribute in dump
> +		 * request means user wants multipath routes
> +		 * returned using RTA_MULTIPATH attribute
> +		 */
> +		if (nlattr[RTA_MULTIPATH])
> +			flags |= RTM_F_ALL_NEXTHOPS;
> +	}
> +

And the above becomes:

+       /* sadly, the size of the ancillary header can vary: the correct
+        * header is struct rtmsg as passed by libnl. iproute2 sends
+        * ifinfomsg [+ filter]. Technically, passing only rtgenmsg is
+        * sufficient since the header has not been parsed before. Luckily,
+        * the struct sizes sufficiently vary to detect the permutations.
+        * For the dump request to contain flags require rtmsg header.
+        */
+       if (nlmsg_len(cb->nlh) == sizeof(struct rtmsg)) {
+               struct rtmsg *rtm = nlmsg_data(cb->nlh);
+
+               flags = rtm->rtm_flags;
+       }
