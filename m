From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when losing link
Date: Mon, 25 Oct 2010 19:08:27 -0700
Message-ID: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:16387 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757861Ab0JZCIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 22:08:49 -0400
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o9Q28nvt015318
	for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 19:08:49 -0700
Received: from gxk8 (gxk8.prod.google.com [10.202.11.8])
	by wpaz5.hot.corp.google.com with ESMTP id o9Q28m9u031209
	for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 19:08:48 -0700
Received: by gxk8 with SMTP id 8so2485682gxk.11
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 19:08:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When roaming between different networks (e.g., changing wireless
SSIDs, or plugging in to different wired networks), IPv6 addresses and
routes are not cleared. If the two networks have different IPv6
subnets assigned, the host maintains both the old and new IPv6
addresses and gateways, but only the new ones works. If the host
chooses the wrong source address or gateway, or if the new network
does not have IPv6 but the old one did, IPv6 connections time out,
leading to long delays when trying to connect to IPv6 hosts.

Fix this by ensuring that autoconfigured IPv6 addresses and routes are
purged when link is lost, not only when the interface goes down.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

--- a/net/ipv6/addrconf.c	2010-10-20 13:30:22.000000000 -0700
+++ b/net/ipv6/addrconf.c	2010-10-25 13:55:15.000000000 -0700
@@ -2524,6 +2524,14 @@
 		} else {
 			if (!addrconf_qdisc_ok(dev)) {
 				/* device is still not ready. */
+				if (idev && (idev->if_flags & IF_READY)) {
+					/* Link lost. Clear addresses and
+					   routes, the device might come back
+					   on a link where they are no longer
+					   valid. */
+					addrconf_ifdown(dev, 0);
+					idev->if_flags &= ~IF_READY;
+				}
 				break;
 			}
