From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] rtnetlink & address family problem
Date: Mon, 6 Dec 2004 15:02:14 +0100
Message-ID: <20041206140214.GA749@postel.suug.ch>
References: <41B0A5B4.6060108@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com, Jan Kara <jack@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Ludvig <mludvig@suse.cz>
Content-Disposition: inline
In-Reply-To: <41B0A5B4.6060108@suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Michal Ludvig <41B0A5B4.6060108@suse.cz> 2004-12-03 18:43
> running 'ip -6 addr flush dev eth0' on a kernel without IPv6 support
> flushes *all* addresses from the interface, even those IPv4 ones,
> because the unsupported protocol is substituted by PF_UNSPEC.
> IMHO it should better return with an error EAFNOSUPPORT.
> 
> diff -Nru a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> --- a/net/core/rtnetlink.c	2004-12-03 18:30:33 +01:00
> +++ b/net/core/rtnetlink.c	2004-12-03 18:30:33 +01:00
> @@ -477,8 +477,10 @@
>  	}
>  
>  	link_tab = rtnetlink_links[family];
> -	if (link_tab == NULL)
> -		link_tab = rtnetlink_links[PF_UNSPEC];
> +	if (link_tab == NULL) {
> +		*errp = -EAFNOSUPPORT;
> +		return -1;
> +	}
>  	link = &link_tab[type];
>  
>  	sz_idx = type>>2;

Your patch would fix this issue but might break various things. The
actual problem is that iproute2 doesn't check the family in its filter.
It blindly assumes that the kernel only returns addresses of the kind it
has requested. I can understand if you think the current behaviour
is wrong but we shouldn't change it in the middle of a stable tree.

--- iproute2-2.6.9.orig/ip/ipaddress.c	2004-10-19 22:49:02.000000000 +0200
+++ iproute2-2.6.9/ip/ipaddress.c	2004-12-06 14:55:58.000000000 +0100
@@ -330,6 +330,8 @@
 				return 0;
 		}
 	}
+	if (filter.family && filter.family != ifa->ifa_family)
+		return 0;
 
 	if (filter.flushb) {
 		struct nlmsghdr *fn;
