From: =?UTF-8?B?UmljaGFyZCBSw7ZqZm9ycw==?= <richard.rojfors@endian.se>
Subject: [PATCH] macb: avoid lockup when TGO during underrun
Date: Thu, 15 Jan 2009 19:30:16 +0100
Message-ID: <496F80B8.6020408@endian.se>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050200080904070303030702"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy2.bredband.net ([195.54.101.72]:43075 "EHLO
	proxy2.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbZAOSaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 13:30:19 -0500
Received: from ironport.bredband.com (195.54.101.120) by proxy2.bredband.net (7.3.127)
        id 494BF3020075D9AA for netdev@vger.kernel.org; Thu, 15 Jan 2009 19:30:17 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050200080904070303030702
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

This patch against linux-2.6.28 solves an issue where macb might run out of TX buffers.

In rare cases when an underrun occur, all macb buffers where consumed and the netif_queue was stopped infinitely. This
happens then the TGO (transfer ongoing) bit in the TSR is set (and UND). It seems like clening up after the underrun
makes the driver and the macb hardware end up in an inconsistent state. The result of this is that in the following
calls to macb_tx no TX buffers are released -> the netif_queue was stopped, and never woken up again.

The solution is to disable the transmitter, if TGO is set, before clening up after the underrun, and re-enable the
transmitter when the cleaning up is done.


A patch to avoid lockup in the macb driver in some rare underrun cases.
Signed-off-by: Richard Röjfors <richard.rojfors@endian.se>

---

diff -urpN linux-2.6.28/drivers/net/macb.c linux-2.6.28-macb/drivers/net/macb.c
--- linux-2.6.28/drivers/net/macb.c	2008-12-25 00:26:37.000000000 +0100
+++ linux-2.6.28-macb/drivers/net/macb.c	2009-01-15 19:06:04.000000000 +0100
@@ -321,6 +321,10 @@ static void macb_tx(struct macb *bp)
 		printk(KERN_ERR "%s: TX underrun, resetting buffers\n",
 			bp->dev->name);

+		/* Transfer ongoing, disable transmitter, to avoid confusion */
+		if (status & MACB_BIT(TGO))
+			macb_writel(bp, NCR, macb_readl(bp, NCR) & ~MACB_BIT(TE));
+
 		head = bp->tx_head;

 		/*Mark all the buffer as used to avoid sending a lost buffer*/
@@ -343,6 +347,10 @@ static void macb_tx(struct macb *bp)
 		}

 		bp->tx_head = bp->tx_tail = 0;
+
+		/* Enable the transmitter again */
+		if (status & MACB_BIT(TGO))
+			macb_writel(bp, NCR, macb_readl(bp, NCR) | MACB_BIT(TE));
 	}

 	if (!(status & MACB_BIT(COMP)))

--Richard

--------------050200080904070303030702
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="macb-und-tgo.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="macb-und-tgo.patch"

QSBwYXRjaCB0byBhdm9pZCBsb2NrdXAgaW4gdGhlIG1hY2IgZHJpdmVyIGluIHNvbWUgcmFy
ZSB1bmRlcnJ1biBjYXNlcy4KU2lnbmVkLW9mZi1ieTogUmljaGFyZCBSw7ZqZm9ycyA8cmlj
aGFyZC5yb2pmb3JzQGVuZGlhbi5zZT4KCi0tLQoKZGlmZiAtdXJwTiBsaW51eC0yLjYuMjgv
ZHJpdmVycy9uZXQvbWFjYi5jIGxpbnV4LTIuNi4yOC1tYWNiL2RyaXZlcnMvbmV0L21hY2Iu
YwotLS0gbGludXgtMi42LjI4L2RyaXZlcnMvbmV0L21hY2IuYwkyMDA4LTEyLTI1IDAwOjI2
OjM3LjAwMDAwMDAwMCArMDEwMAorKysgbGludXgtMi42LjI4LW1hY2IvZHJpdmVycy9uZXQv
bWFjYi5jCTIwMDktMDEtMTUgMTk6MDY6MDQuMDAwMDAwMDAwICswMTAwCkBAIC0zMjEsNiAr
MzIxLDEwIEBAIHN0YXRpYyB2b2lkIG1hY2JfdHgoc3RydWN0IG1hY2IgKmJwKQogCQlwcmlu
dGsoS0VSTl9FUlIgIiVzOiBUWCB1bmRlcnJ1biwgcmVzZXR0aW5nIGJ1ZmZlcnNcbiIsCiAJ
CQlicC0+ZGV2LT5uYW1lKTsKIAorCQkvKiBUcmFuc2ZlciBvbmdvaW5nLCBkaXNhYmxlIHRy
YW5zbWl0dGVyLCB0byBhdm9pZCBjb25mdXNpb24gKi8KKwkJaWYgKHN0YXR1cyAmIE1BQ0Jf
QklUKFRHTykpCisJCQltYWNiX3dyaXRlbChicCwgTkNSLCBtYWNiX3JlYWRsKGJwLCBOQ1Ip
ICYgfk1BQ0JfQklUKFRFKSk7CisKIAkJaGVhZCA9IGJwLT50eF9oZWFkOwogCiAJCS8qTWFy
ayBhbGwgdGhlIGJ1ZmZlciBhcyB1c2VkIHRvIGF2b2lkIHNlbmRpbmcgYSBsb3N0IGJ1ZmZl
ciovCkBAIC0zNDMsNiArMzQ3LDEwIEBAIHN0YXRpYyB2b2lkIG1hY2JfdHgoc3RydWN0IG1h
Y2IgKmJwKQogCQl9CiAKIAkJYnAtPnR4X2hlYWQgPSBicC0+dHhfdGFpbCA9IDA7CisKKwkJ
LyogRW5hYmxlIHRoZSB0cmFuc21pdHRlciBhZ2FpbiAqLworCQlpZiAoc3RhdHVzICYgTUFD
Ql9CSVQoVEdPKSkKKwkJCW1hY2Jfd3JpdGVsKGJwLCBOQ1IsIG1hY2JfcmVhZGwoYnAsIE5D
UikgfCBNQUNCX0JJVChURSkpOwogCX0KIAogCWlmICghKHN0YXR1cyAmIE1BQ0JfQklUKENP
TVApKSkK
--------------050200080904070303030702--
