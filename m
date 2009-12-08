From: Jiri Bohac <jbohac@suse.cz>
Subject: ipv6: why disable ipv6 on last address removal?
Date: Tue, 8 Dec 2009 20:20:46 +0100
Message-ID: <20091208192046.GA5649@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:48828 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965820AbZLHTUo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 14:20:44 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I came across a strange behaviour:

When the last IPv6 address of an interface is removed (using e.g.
"ip -6 addr flush ethX"), inet6_addr_del() calls addrconf_ifdown(... , how=1).

This completely removes IPv6 from the interface. (The same thing
is done e.g. on NETDEV_UNREGISTER). An ugly side effect of this
is that it is no longer possible to set the interface IPv6
settings using sysctl. The only way to make the sysctl settings
accessible again seems to be taking the interface down and up.

This is a nightmare for management scripts.

Most other actions, such as NETDEV_DOWN, call
addrconf_ifdown(..., how=0), which keeps the sysctl settings
available.

Is there any reason why inet6_addr_del needs to sets how=1 and
disable IPv6 even more than "ifconfig down" does?


I quickly tested this patch and it did not seem to break
anything:

--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2185,7 +2185,7 @@ static int inet6_addr_del(struct net *net, int ifindex, struct in6_addr *pfx,
 			   disable IPv6 on this interface.
 			 */
 			if (idev->addr_list == NULL)
-				addrconf_ifdown(idev->dev, 1);
+				addrconf_ifdown(idev->dev, 0);
 			return 0;
 		}
 	}

Thanks,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

