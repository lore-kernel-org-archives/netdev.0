From: Robert Evans <robert.evans@nasdaqomx.com>
Subject: tcp_shift_skb_data uses wrong mss in non-gso case?
Date: Tue, 17 Aug 2010 18:35:45 -0400
Message-ID: <D3B72A8DFCA0A8418CB61D1E9E310A99E5F35219@US01XMB01.org.nasdaqomx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.nasdaqomx.com ([206.200.254.15]:20739 "EHLO
	mx1.nasdaqomx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648Ab0HQWpU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 18:45:20 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

In reading through the latest SACK code introduced by 832d11c, I have noticed
that for the in_sack case tcp_shift_skb will take mss = tcp_skb_seglen(skb).
This seems to be wrong since the queue might contain small packets (f.e.
TCP_NODELAY). If the collapse succeeds, the resulting skb will have an
arbitrarily small gso_size equal to the original skb length.

8ed88d4:net/ipv4/tcp_input.c
   1506         in_sack = !after(start_seq, TCP_SKB_CB(skb)->seq) &&
   1507                   !before(end_seq, TCP_SKB_CB(skb)->end_seq);
   1508 
   1509         if (in_sack) {
   1510                 len = skb->len;
   1511                 pcount = tcp_skb_pcount(skb);
   1512                 mss = tcp_skb_seglen(skb);     /* possibly wrong? */
   1513 
   1514                 /* TODO: Fix DSACKs to not fragment already SACKed and w
   1514 e can
   1515                  * drop this restriction as unnecessary
   1516                  */
   1517                 if (mss != tcp_skb_seglen(prev))
   1518                         goto fallback;
   1519         } else {

This ends up being troublesome if the segment is later retransmitted and the
device driver has trouble with very small gso_size (e1000e seems to be an
example).

Is the small gso_size the correct and/or desired behavior?  Or am I missing
something else that prevents this from being a problem?


-Bob Evans
