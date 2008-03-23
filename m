From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [IPV6]: Event type in addrconf_ifdown is mis-used.
Date: Sat, 22 Mar 2008 17:38:43 -0700 (PDT)
Message-ID: <20080322.173843.71057686.davem@davemloft.net>
References: <1205850761.9163.21.camel@iris.sw.ru>
	<1205850925-11736-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, kaber@trash.net,
	containers@lists.osdl.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43142
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754246AbYCWAi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 20:38:27 -0400
In-Reply-To: <1205850925-11736-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Tue, 18 Mar 2008 17:35:23 +0300

> addrconf_ifdown is broken in respect to the usage of how parameter. This
> function is called with (event != NETDEV_DOWN) and (2) on the IPv6 stop.
> It the latter case inet6_dev from loopback device should be destroyed.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

The code purposefully treats "2" specially because when IPV6 routes
are destroyed they are changed to point to the loopback device's
inet6_dev object.

This allows statistic bumping code to not have to check if it has a
NULL inet6_dev pointer or not, because that's now impossible.

Since ipv6 is not unloadable, addrconf_cleanup(), and thus the
"how == 2" case can only occur when ipv6 fails to load properly.
The only real consequence of this bug is that if ipv6 fails
to load properly, a subsequent successfull load of ipv6 will
leak the loopback device's inet6_dev object, which isn't that
much of a big deal.

I understand that for namespaces you have to deal with multiple
loopback devices, but you'll need to solve that problem while
still handling the wish of the ipv6 stack for inet6_dev objects
of loopback devices to be permanent and guarenteed to always
be around for the sake of statistics bumping.

I thus can't apply any of these patches until those issues are
resolved.
