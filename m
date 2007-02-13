From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Prevent pseudo garbage in SYN's advertized window
Date: Tue, 13 Feb 2007 15:08:34 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0702131432350.25858@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-609776933-1171372114=:25858"
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34789 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbXBMNNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 08:13:47 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-609776933-1171372114=:25858
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

TCP may advertize up to 16-bits window in SYN packets (no window
scaling allowed). At the same time, TCP may have rcv_wnd
(32-bits) that does not fit to 16-bits without window scaling
resulting in pseudo garbage into advertized window from the
low-order bits of rcv_wnd. This can happen at least when
mss <= (1<<wscale) (see tcp_select_initial_window). This patch
fixes the handling of SYN advertized windows (compile tested
only).

In worst case (which is unlikely to occur though), the receiver
advertized window could be just couple of bytes. I'm not sure
that such situation would be handled very well at all by the
receiver!? Fortunately, the situation normalizes after the
first non-SYN ACK is received because it has the correct,
scaled window.

Alternatively, tcp_select_initial_window could be changed to
prevent too large rcv_wnd in the first place.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cebe9aa..1b2897b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -481,7 +481,7 @@ #endif
 		/* RFC1323: The window in SYN & SYN/ACK segments
 		 * is never scaled.
 		 */
-		th->window	= htons(tp->rcv_wnd);
+		th->window	= htons(min(tp->rcv_wnd, 65535U));
 	} else {
 		th->window	= htons(tcp_select_window(sk));
 	}
-- 
1.4.2

---696243703-609776933-1171372114=:25858--
