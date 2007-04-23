From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Suspicious fackets_out handling
Date: Mon, 23 Apr 2007 14:28:21 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704231218440.28337@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57503 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161441AbXDWL2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 07:28:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,


While looking through the users of fackets_out, i found this from 
tcp_fragment(...):

	/* If this packet has been sent out already, we must
         * adjust the various packet counters.
         */
        if (!before(tp->snd_nxt, TCP_SKB_CB(buff)->end_seq)) {
		int diff = old_factor - tcp_skb_pcount(skb) -
                        tcp_skb_pcount(buff);

		[...snip...]

		if (diff > 0) {
                        /* Adjust Reno SACK estimate. */
                        if (!tp->rx_opt.sack_ok) {
                                tp->sacked_out -= diff;
                                if ((int)tp->sacked_out < 0)
                                        tp->sacked_out = 0;
                                tcp_sync_left_out(tp);
                        }

                        tp->fackets_out -= diff;
                        if ((int)tp->fackets_out < 0)
                                tp->fackets_out = 0;
                }
	}
	[...]

There are IMHO two problems in it. First of all, nothing ensures that the 
skb TCP is fragmenting is actually below the forwardmost sack block (and 
thus is included to the fackets_out)... What I'm not sure of though, is 
how to fix this in net-2.6(.22), it is due to the fact that there is no 
pointer/seq which can be used in testing for it like in tcp-2.6 which has 
the highest_sack. Second problem is even more obvious: if adjustment here 
is being done and the sacktag code then uses fastpath at the arrival of 
the next ACK, the sacktag code will use a stale value from 
fastpath_cnt_hint and fails to notice all that math TCP did here unless we 
start clearing fastpath_skb_hint.


-- 
 i.
