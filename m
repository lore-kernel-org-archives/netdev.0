From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Fix slow_start_after_idle
Date: Mon, 09 Apr 2007 13:35:20 -0700 (PDT)
Message-ID: <20070409.133520.59467340.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50869
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965030AbXDIUfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 16:35:20 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 4CAC3AB4158
	for <netdev@vger.kernel.org>; Mon,  9 Apr 2007 13:35:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When a user sets tcp_slow_start_after_idle to zero they want the
congestion window to not time out, that's why we added the sysctl in
the first place.

But in the cases where this matters, the user can still get screwed
over by congestion window validation, so we should apply the
slow_start_after_idle test there too.

I just checked this into net-2.6 and will push to -stable
as well after Linus takes this.

commit 15d33c070ddde99f7368e6b17b71d22c866f97d9
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Mon Apr 9 13:23:14 2007 -0700

    [TCP]: slow_start_after_idle should influence cwnd validation too
    
    For the cases that slow_start_after_idle are meant to deal
    with, it is almost a certainty that the congestion window
    tests will think the connection is application limited and
    we'll thus decrease the cwnd there too.  This defeats the
    whole point of setting slow_start_after_idle to zero.
    
    So test it there too.
    
    We do not cancel out the entire tcp_cwnd_validate() function
    so that if the sysctl is changed we still have the validation
    state maintained.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 688b955..3c24881 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -943,7 +943,8 @@ static void tcp_cwnd_validate(struct sock *sk, struct tcp_sock *tp)
 		if (tp->packets_out > tp->snd_cwnd_used)
 			tp->snd_cwnd_used = tp->packets_out;
 
-		if ((s32)(tcp_time_stamp - tp->snd_cwnd_stamp) >= inet_csk(sk)->icsk_rto)
+		if (sysctl_tcp_slow_start_after_idle &&
+		    (s32)(tcp_time_stamp - tp->snd_cwnd_stamp) >= inet_csk(sk)->icsk_rto)
 			tcp_cwnd_application_limited(sk);
 	}
 }
