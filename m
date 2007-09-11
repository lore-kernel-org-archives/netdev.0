From: Pierre-Yves Ritschard <pyritschard@echo.fr>
Subject: Re: [PATCH] sky2.c: length mismatch errors with vlan frames
Date: Tue, 11 Sep 2007 11:46:44 +0200
Message-ID: <20070911114644.00e2eeee@gamma.echo-net.net>
References: <20070910163538.3b23e842@gamma.echo-net.net>
 <20070911101048.02509747@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout01s1.x-echo.com ([193.252.149.37]:52507 "EHLO
	smtpout01s1.x-echo.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754912AbXIKJqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 05:46:46 -0400
In-Reply-To: <20070911101048.02509747@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> My bad, I hadn't tested VLAN acceleration code in a while so must
> have broken it when more error checking was added.
> 
I did check without vlans and the messages don't appear so it seems
to be working correctly. When vlans are enabled I do receive a few
frames that have the length difference but not the GMR_FS_VLAN bit
set, since there's high traffic on the interfaces it might be a
firmware bug that is triggered sometimes (running with my patch the
occurences are about 10/hour).

> Your fix looks right. Could you format properly for kernel patch
> inclusion. Also, instead of hard coding 4, please use VLAN_HLEN.

Since the snippet became a patch, here goes:

Signed-off-by: Pierre-Yves Ritschard <pyr@spootnik.org>

--- linux-2.6.22.6/drivers/net/sky2.c.orig	2007-09-10
15:34:15.000000000 +0200 +++ linux-2.6.22.6/drivers/net/sky2.c
2007-09-11 11:38:54.000000000 +0200 @@ -2059,6 +2059,9 @@ static struct
sk_buff *sky2_receive(stru sky2->rx_next = (sky2->rx_next + 1) %
sky2->rx_pending; prefetch(sky2->rx_ring + sky2->rx_next);
 
+	if (status & GMR_FS_VLAN)
+		length += VLAN_HLEN;
+
 	if (status & GMR_FS_ANY_ERR)
 		goto error;
 
@@ -2081,6 +2084,8 @@ len_mismatch:
 	/* Truncation of overlength packets
 	   causes PHY length to not match MAC length */
 	++sky2->net_stats.rx_length_errors;
+	printk(KERN_INFO PFX "%s: rx length mismatch: length %d !=
%d\n",
+	       dev->name, length, status >> 16);
 
 error:
 	++sky2->net_stats.rx_errors;
