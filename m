From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] crash in 8139cp with 3.9.2 and KVM
Date: Thu, 16 May 2013 22:49:42 -0700
Message-ID: <1368769782.3301.83.camel@edumazet-glaptop>
References: <20130516214913.53ed65f9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, nic_swsd@realtek.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:64202 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753529Ab3EQFto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 01:49:44 -0400
Received: by mail-pd0-f181.google.com with SMTP id p11so3017245pdj.12
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 22:49:43 -0700 (PDT)
In-Reply-To: <20130516214913.53ed65f9@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-16 at 21:49 -0700, Stephen Hemminger wrote:
> Seeing the following panic when using emulated 8139cp with KVM and 3.9.2 kernel.
> 
> Looks like netdev_alloc_skb_ip_align() can return a fragmented skb sometimes
> and using skb_put() on a non-linear skb causes a panic.

It looks like that len is not always less or equal to buflen.

I would try this fix :

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 7d1fb9a..6488dec 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -494,7 +494,8 @@ rx_status_loop:
 		len = (status & 0x1fff) - 4;
 		mapping = le64_to_cpu(desc->addr);
 
-		if ((status & (FirstFrag | LastFrag)) != (FirstFrag | LastFrag)) {
+		if ((status & (FirstFrag | LastFrag)) != (FirstFrag | LastFrag) ||
+		    len > buflen) {
 			/* we don't support incoming fragmented frames.
 			 * instead, we attempt to ensure that the
 			 * pre-allocated RX skbs are properly sized such
