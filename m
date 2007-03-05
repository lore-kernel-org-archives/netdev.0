From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: [PATCH] Ensure IF_READY is unset when link is not ready
Date: Mon, 5 Mar 2007 17:59:24 +0900
Message-ID: <20070305175924.2f46446c.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:39489 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721AbXCEI7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 03:59:52 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l258xpva020982
	for <netdev@vger.kernel.org>; Mon, 5 Mar 2007 03:59:51 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l258xpgx503476
	for <netdev@vger.kernel.org>; Mon, 5 Mar 2007 01:59:51 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l258xpfr022083
	for <netdev@vger.kernel.org>; Mon, 5 Mar 2007 01:59:51 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,

On linux-2.6.21-rc2 or later, IPv6 link-local address is not assigned to
some kind of interfaces during system start-up. (I found this issue
occures with e100, e1000 and tg3.)

This issue comes from the change that inet6_dev is allocated when
NETDEV_REGISTER event occurs. The allocation code is at ipv6_add_dev()
in net/ipv6/addrinfo.c. At the code, IF_READY bit would be set when the
link is ready. The link readyness is verified by netif_caeeir_ok().
However as the drivers don't call netif_carrier_off() prior to calling
register_netdev(), netif_caeeir_ok() returns true in spite of the
actual link state.

Here's a work around patch. This make IF_READY unset when NETDEV_UP
event occurs and the link is not ready. This patch may not be an
fundamental fix. But I don't have any other idea now.

Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
---
 net/ipv6/addrconf.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e16f1bb..1593cd1 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2196,6 +2196,7 @@ static int addrconf_notify(struct notifi
 					"ADDRCONF(NETDEV_UP): %s: "
 					"link is not ready\n",
 					dev->name);
+				idev->if_flags &= ~IF_READY;
 				break;
 			}
 
-- 
1.4.3.4

