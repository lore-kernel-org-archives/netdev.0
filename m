From: dean gaudet <dean@arctic.org>
Subject: TCP_DEFER_ACCEPT brokenness?
Date: Sat, 30 Dec 2006 18:50:43 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0612301758160.27326@twinlark.arctic.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: mtk-manpages@gmx.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from twinlark.arctic.org ([207.29.250.54]:34952 "EHLO
	twinlark.arctic.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932085AbWLaCuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Dec 2006 21:50:44 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi... i'm having troubles matching up the tcp(7) man page description of 
TCP_DEFER_ACCEPT versus some comments in the kernel (2.6.20-rc2) versus 
how the kernel actually acts.

the man page says this:

   TCP_DEFER_ACCEPT
        Allows a listener to be awakened only when data arrives on
        the socket.  Takes an integer value (seconds), this can bound
        the maximum number of attempts TCP will make to complete the
        connection.  This option should not be used in code intended to
        be portable.

which is a bit confusing because it talks both about seconds and
"attempts".  (and doesn't mention what happens when the timeout finishes
-- i could see dropping the socket or passing it to userland anyhow as
possibilities... but in fact the socket is dropped).

the setsockopt code in tcp.c does this:

        case TCP_DEFER_ACCEPT:
                icsk->icsk_accept_queue.rskq_defer_accept = 0;
                if (val > 0) {
                        /* Translate value in seconds to number of
                         * retransmits */
                        while (icsk->icsk_accept_queue.rskq_defer_accept < 32 &&
                               val > ((TCP_TIMEOUT_INIT / HZ) <<
                                       icsk->icsk_accept_queue.rskq_defer_accept))
                                icsk->icsk_accept_queue.rskq_defer_accept++;
                        icsk->icsk_accept_queue.rskq_defer_accept++;
                }
                break;

so at least the comment agrees with the man page -- however the code
doesn't... the code finds the least n such that val < (3<<n)...  but these
are timeouts and they're cumulative -- it would be more appropriate to
search for least n such that

        val < (3<<0) + (3<<1) + (3<<2) + ... + (3<<n)

but that's not all that's wrong... i'm not sure why, for val == 1 it
computes n=0 correctly (verified with getsockopt) but then it defers
way more timeouts than 2.  here's a tcpdump example where the timeout
was set to 1:

1167532741.446027 IP 127.0.0.1.56733 > 127.0.0.1.53846: S 1792609127:1792609127(0) win 32792 <mss 16396,sackOK,timestamp 249615 0,nop,wscale 5>
1167532741.446899 IP 127.0.0.1.53846 > 127.0.0.1.56733: S 1785169552:1785169552(0) ack 1792609128 win 32768 <mss 16396,sackOK,timestamp 249616 249615,nop,wscale 5>
1167532741.446122 IP 127.0.0.1.56733 > 127.0.0.1.53846: . ack 1 win 1025 <nop,nop,timestamp 249616 249616>
1167532745.249902 IP 127.0.0.1.53846 > 127.0.0.1.56733: S 1785169552:1785169552(0) ack 1792609128 win 32768 <mss 16396,sackOK,timestamp 250566 249616,nop,wscale 5>
1167532745.249912 IP 127.0.0.1.56733 > 127.0.0.1.53846: . ack 1 win 1025 <nop,nop,timestamp 250566 250566,nop,nop,sack 1 {0:1}>
1167532751.648046 IP 127.0.0.1.53846 > 127.0.0.1.56733: S 1785169552:1785169552(0) ack 1792609128 win 32768 <mss 16396,sackOK,timestamp 252166 250566,nop,wscale 5>
1167532751.648058 IP 127.0.0.1.56733 > 127.0.0.1.53846: . ack 1 win 1025 <nop,nop,timestamp 252166 252166,nop,nop,sack 1 {0:1}>
1167532764.448456 IP 127.0.0.1.53846 > 127.0.0.1.56733: S 1785169552:1785169552(0) ack 1792609128 win 32768 <mss 16396,sackOK,timestamp 255366 252166,nop,wscale 5>
1167532764.448473 IP 127.0.0.1.56733 > 127.0.0.1.53846: . ack 1 win 1025 <nop,nop,timestamp 255366 255366,nop,nop,sack 1 {0:1}>
1167532788.452409 IP 127.0.0.1.53846 > 127.0.0.1.56733: S 1785169552:1785169552(0) ack 1792609128 win 32768 <mss 16396,sackOK,timestamp 261366 255366,nop,wscale 5>
1167532788.452430 IP 127.0.0.1.56733 > 127.0.0.1.53846: . ack 1 win 1025 <nop,nop,timestamp 261366 261366,nop,nop,sack 1 {0:1}>
1167532836.453520 IP 127.0.0.1.53846 > 127.0.0.1.56733: S 1785169552:1785169552(0) ack 1792609128 win 32768 <mss 16396,sackOK,timestamp 273366 261366,nop,wscale 5>
1167532836.453539 IP 127.0.0.1.56733 > 127.0.0.1.53846: . ack 1 win 1025 <nop,nop,timestamp 273366 273366,nop,nop,sack 1 {0:1}>


now honestly i don't mind if 1s works correctly (because
apache 2.2.x is broken and sets TCP_DEFER_ACCEPT to 1 ... see
<http://issues.apache.org/bugzilla/show_bug.cgi?id=41270>).

but even if i use more reasonable timeouts like 30s it doesn't
behave as expected based on the docs.

not sure which way this should be resolved -- or how long the code has 
been like this...  perhaps the current behaviour should just become the 
documented behaviour (whatever the current behaviour is :).

-dean
