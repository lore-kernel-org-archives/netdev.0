From: Greg KH <gregkh@suse.de>
Subject: [patch 06/20] sky2: check drop truncated packets
Date: Mon, 20 Aug 2007 23:54:21 -0700
Message-ID: <20070821065421.GG5275@kroah.com>
References: <20070821064251.972690753@blue.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([209.217.80.40]:44165 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756450AbXHUGwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 02:52:55 -0400
Content-Disposition: inline; filename="sky2-stable-trunc.patch"
In-Reply-To: <20070821065210.GA5275@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Stephen Hemminger <shemminger@linux-foundation.org>

Backport of commit 71749531f2d1954137a1a77422ef4ff29eb102dd

If packet larger than MTU is received, the driver uses hardware to
truncate the packet. Use the status registers to catch/drop them.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/sky2.c |    8 ++++++++
 1 file changed, 8 insertions(+)

--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2065,6 +2065,9 @@ static struct sk_buff *sky2_receive(stru
 	if (!(status & GMR_FS_RX_OK))
 		goto resubmit;
 
+	if (status >> 16 != length)
+		goto len_mismatch;
+
 	if (length < copybreak)
 		skb = receive_copy(sky2, re, length);
 	else
@@ -2074,6 +2077,11 @@ resubmit:
 
 	return skb;
 
+len_mismatch:
+	/* Truncation of overlength packets
+	   causes PHY length to not match MAC length */
+	++sky2->net_stats.rx_length_errors;
+
 error:
 	++sky2->net_stats.rx_errors;
 	if (status & GMR_FS_RX_FF_OV) {

-- 
