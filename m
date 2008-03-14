From: Patrick McHardy <kaber@trash.net>
Subject: [TCP]: Fix shrinking windows with window scaling
Date: Fri, 14 Mar 2008 18:42:38 +0100
Message-ID: <47DAB90E.40806@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010505000607060106080605"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	=?ISO-8859-15?Q?Ilpo_J=E4r?= =?ISO-8859-15?Q?vinen?=
	<ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep31-int.chello.at ([62.179.121.49]:57252 "EHLO
	viefep31-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663AbYCNRvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2008 13:51:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010505000607060106080605
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Please review carefully since I'm not too familiar with the
TCP code.


--------------010505000607060106080605
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit adced31497ffbb3fe6ffef2d05f2b8fc74f1f138
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Mar 14 17:15:20 2008 +0100

    [TCP]: Fix shrinking windows with window scaling

    When selecting a new window, tcp_select_window() tries not to shrink
    the offered window by using the maximum of the remaining offered window
    size and the newly calculated window size. The newly calculated window
    size is always a multiple of the window scaling factor, the remaining
    window size however might not be since it depends on rcv_wup/rcv_nxt.
    This means we're effectively shrinking the window when scaling it down.


    The dump below shows the problem (scaling factor 2^7):

    - Window size of 557 (71296) is advertised, up to 3111907257:

    IP 172.2.2.3.33000 > 172.2.2.2.33000: . ack 3111835961 win 557 <...>

    - New window size of 514 (65792) is advertised, up to 3111907217, 40 bytes
      below the last end:

    IP 172.2.2.3.33000 > 172.2.2.2.33000: . 3113575668:3113577116(1448) ack 3111841425 win 514 <...>

    The number 40 results from downscaling the remaining window:

    3111907257 - 3111841425 = 65832
    65832 / 2^7 = 514
    65832 % 2^7 = 40

    If the sender uses up the entire window before it is shrunk, this can have
    chaotic effects on the connection. When sending ACKs, tcp_acceptable_seq()
    will notice that the window has been shrunk since tcp_wnd_end() is before
    tp->snd_nxt, which makes it choose tcp_wnd_end() as sequence number.
    This will fail the receivers checks in tcp_sequence() however since it
    is before it's tp->rcv_wup, making it respond with a dupack.

    If both sides are in this condition, this leads to a constant flood of
    ACKs until the connection times out.


    Make sure the window is never shrunk by aligning the remaining window to
    the window scaling factor.

    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 01578f5..72b9350 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -255,7 +255,7 @@ static u16 tcp_select_window(struct sock *sk)
 		 *
 		 * Relax Will Robinson.
 		 */
-		new_win = cur_win;
+		new_win = ALIGN(cur_win, 1 << tp->rx_opt.rcv_wscale);
 	}
 	tp->rcv_wnd = new_win;
 	tp->rcv_wup = tp->rcv_nxt;

--------------010505000607060106080605--
