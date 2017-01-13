From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: resend: tcp: performance issue with fastopen connections (mss >
 window)
Date: Fri, 13 Jan 2017 18:01:19 +0300
Message-ID: <30f38b3c-8c5c-7fab-e424-985e63ad900a@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vasily Isaenko <vasily.isaenko@oracle.com>
To: David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20819 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751739AbdAMPBv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 10:01:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Got the issue when running LTP/netstress test on localhost with mss
greater than the send window advertised by client (right after 3WHS).
Here is the testscenario that can reproduce this:

TCP client is sending 32 bytes request, TCP server replies with 65KB answer.
net.ipv4.tcp_fastopen set to 3. Also notethat first TCP Fastopen connection
processed without delay as tcp_send_mss()setshalf of the window size
to the'size_goal' inside tcp_sendmsg().

Though on the 2nd and subsequent connections:

    < S  seq 0:0 win 43690 options [mss 65495 wscale 7
         tfo cookie ac6246a51d5422fc] length 32
    > S.seq 0:0ack 1win 43690 options [mss 65495wscale 7] length 0
    <.  ack 1 win 342 length 0

Inside tcp_sendmsg(), tcp_send_mss() returns 65483 in 'mss_now',as well as
in 'size_goal'. This results the segment not queued for transmition
until all
data copied from userbuffer. Then, inside  __tcp_push_pending_frames() it
breaks on send window test,continue with the check probe timer, thus
introducing 200ms delay here.

Fragmentationoccurs in tcp_write_wakeup()...

+0.2> P. seq 1:43777 ack 1 win 342 length 43776
     <  . ack 43777, win 1365 length 0
     > P. seq 43777:65001 ack 1 win 342 optionslength 21224
     ...


Not sure what is the right fix for this, I guess we could limit size_goal
to the current window or mss, what is currently less, e.g:

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4a04496..3d3bd97 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -860,7 +860,12 @@ static unsigned int tcp_xmit_size_goal(struct sock
*sk, u32 mss_now,
                size_goal = tp->gso_segs * mss_now;
        }

-       return max(size_goal, mss_now);
+       size_goal = max(size_goal, mss_now);
+
+       if (tp->snd_wnd > TCP_MSS_DEFAULT)
+               return min(tp->snd_wnd, size_goal);
+
+       return size_goal;
 }

 static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1d5331a..0ac133f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2445,7 +2445,7 @@ void tcp_push_one(struct sock *sk, unsigned int
mss_now)
 {
        struct sk_buff *skb = tcp_send_head(sk);

-       BUG_ON(!skb || skb->len < mss_now);
+       BUG_ON(!skb);

        tcp_write_xmit(sk, mss_now, TCP_NAGLE_PUSH, 1, sk->sk_allocation);
 }


Any ideas?

Best regards,
Alexey
