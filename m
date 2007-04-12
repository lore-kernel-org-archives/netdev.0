From: Patrick McHardy <kaber@trash.net>
Subject: Re: kernel BUG at net/core/skbuff.c in linux-2.6.21-rc6
Date: Thu, 12 Apr 2007 07:43:39 +0200
Message-ID: <461DC70B.4000500@trash.net>
References: <19061b0b0704071111m65c70d1ei736de86ad2f09a82@mail.gmail.com>	 <20070407.234708.93384523.davem@davemloft.net>	 <19061b0b0704081315g3593d652s70e9b5b0dcfcf966@mail.gmail.com>	 <19061b0b0704100219w4749e5fby9b400edca9bf334d@mail.gmail.com>	 <9a8748490704100425t34ebafcdq866a923df80b9aca@mail.gmail.com> <19061b0b0704112218j13688c16xc755d66147f8fe6a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040504000905010000070902"
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Bartek <poemann@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37076 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161560AbXDLFoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 01:44:06 -0400
In-Reply-To: <19061b0b0704112218j13688c16xc755d66147f8fe6a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040504000905010000070902
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Bartek wrote:
> Hopefully, this time it my bug report should be ok :):
> 
> Apr 11 23:53:38 localhost pppd[31289]: rcvd [proto=0x7689] e1 cd 33 f6
> fd f7 52 e6 58 c9 73 98 bc ff ad d5 b5 a3 e5 d9 1e 77 76 0a 1c 87 59
> bf 44 cc ac 3b ...
> Apr 11 23:53:38 localhost pppd[31289]: Unsupported protocol 0x7689 received
> Apr 11 23:53:38 localhost pppd[31289]: sent [LCP ProtRej id=0x9 76 89
> e1 cd 33 f6 fd f7 52 e6 58 c9 73 98 bc ff ad d5 b5 a3 e5 d9 1e 77 76
> 0a 1c 87 59 bf 44 cc ...]
> Apr 11 23:53:38 localhost pppd[31289]: rcvd [proto=0xda7d] 15 19 45 3c
> e0 ac 44 92 3b c4 8e 75 6b b8 4a 9f 4a 3a 22 63 d3 a1 56 98 47 62 bc
> cd a6 8e d5 77 ...
> Apr 11 23:53:38 localhost pppd[31289]: Unsupported protocol 0xda7d received
> Apr 11 23:53:38 localhost pppd[31289]: sent [LCP ProtRej id=0xa da 7d
> 15 19 45 3c e0 ac 44 92 3b c4 8e 75 6b b8 4a 9f 4a 3a 22 63 d3 a1 56
> 98 47 62 bc cd a6 8e ...]
> Apr 11 23:53:40 localhost kernel: skb_under_panic: text:f8c62c0e
> len:291 put:1 head:ddc94800 data:ddc947ff tail:ddc94922 end:ddc94e00
> dev:<NULL>


It seems we fail to reserve enough headroom for the case
buf[0] == PPP_ALLSTATIONS and buf[1] != PPP_UI.

Can you try this patch please?


--------------040504000905010000070902
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/drivers/net/ppp_async.c b/drivers/net/ppp_async.c
index 933e2f3..c68e37f 100644
--- a/drivers/net/ppp_async.c
+++ b/drivers/net/ppp_async.c
@@ -890,6 +890,8 @@ ppp_async_input(struct asyncppp *ap, const unsigned char *buf,
  				ap->rpkt = skb;
  			}
  			if (skb->len == 0) {
+				int headroom = 0;
+
  				/* Try to get the payload 4-byte aligned.
  				 * This should match the
  				 * PPP_ALLSTATIONS/PPP_UI/compressed tests in
@@ -897,7 +899,10 @@ ppp_async_input(struct asyncppp *ap, const unsigned char *buf,
  				 * enough chars here to test buf[1] and buf[2].
  				 */
 				if (buf[0] != PPP_ALLSTATIONS)
-					skb_reserve(skb, 2 + (buf[0] & 1));
+					headroom += 2;
+				if (buf[0] & 1)
+					headroom += 1;
+				skb_reserve(skb, headroom);
 			}
 			if (n > skb_tailroom(skb)) {
 				/* packet overflowed MRU */

--------------040504000905010000070902--
