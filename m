From: Mahesh Kelkar <maheshkelkar@gmail.com>
Subject: Last Ipv6 address removal causes "addrconf_sysctl_unregister", which
	inihibits from changing disable_ipv6 setting
Date: Mon, 26 Jul 2010 10:03:13 -0400
Message-ID: <AANLkTimnBssEeO_faqcAAzHCy8KxQo9FVcn7vu5fru4j@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44631 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247Ab0GZODP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 10:03:15 -0400
Received: by wyf19 with SMTP id 19so2115421wyf.19
        for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 07:03:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Odd behavior associated with the patch:
**Last address removal causes "addrconf_sysctl_unregister", which
inihibits from changing disable_ipv6 setting
(connected issue: With disable_ipv6 set to 1 on an interface, ff00:/8
and fe80::/64 are still added on device UP)

Current sysctl config:
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

Steps:
- Remove last IPv6 address assigned to the "eth0" interface
- inet6_addr_del => addrconf_ifdown(idev->dev, 1) => does the device
sysctl unregister
******Not sure why the addrconf_sysctl_unregister is necessary on last
address removal*******
- Now, "sysctl -a" does not show "net.ipv6.conf.eth0.disable_ipv6"

Problem:
- If you WANT to assign IPv6 address to eth0,
-> Do it once, which fails due to "disable_ipv6" check in
addrconf_add_dev OR ipv6_add_addr
-> But, this process does "addrconf_sysctl_register" (addrconf_add_dev
=> ipv6_find_idev => ipv6_add_dev)
-> set net.ipv6.conf.eth0.disable_ipv6=0 and then successfully assign
ipv6-address to the eth0
(Another alternative is to change all or default to 1; but I wanted to
disable ipv6 by default)

===============
Probable Solution:
===============
@@ -1948,7 +1959,7 @@ static int inet6_addr_del(int ifindex, s
 			   disable IPv6 on this interface.
 			 */
 			if (idev->addr_list == NULL)
-				addrconf_ifdown(idev->dev, 1);
+				addrconf_ifdown(idev->dev, 0);
 			return 0;
 		}
 	}
I have tested the above solution and it seems to work fine - so far.
