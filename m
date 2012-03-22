From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: Piggyback the final ACK of the three way TCP connection
 establishment with the data
Date: Thu, 22 Mar 2012 16:02:41 -0700
Message-ID: <CAK3+h2ydKQ15U1_2dqWsHAL_LKYm-1xbJvUbeaMJShoOCU_TsA@mail.gmail.com>
References: <CAK3+h2zYLsWw44cAqJN_7vE1bqbEEsDK5oqKLpej0RLuKhk3qQ@mail.gmail.com>
	<1332374452.9433.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:37816 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756364Ab2CVXCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 19:02:42 -0400
Received: by wejx9 with SMTP id x9so2245609wej.19
        for <netdev@vger.kernel.org>; Thu, 22 Mar 2012 16:02:41 -0700 (PDT)
In-Reply-To: <1332374452.9433.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> No kernel patch is needed, you already can do this on linux.
>
> Check file net/ipv4/tcp_input.c lines around 5722
>
>

is this code snippet in tcp_rcv_synsent_state_process that you refer to?

5676                 if (sk->sk_write_pending ||
5677                     icsk->icsk_accept_queue.rskq_defer_accept ||
5678                     icsk->icsk_ack.pingpong) {
5679                         /* Save one ACK. Data will be ready after
5680                          * several ticks, if write_pending is set.
5681                          *
5682                          * It may be deleted, but with this
feature tcpdumps
5683                          * look so _wonderfully_ clever, that I
was not able
5684                          * to stand against the temptation 8)     --ANK
5685                          */
5686                         inet_csk_schedule_ack(sk);
5687                         icsk->icsk_ack.lrcvtime = tcp_time_stamp;
5688                         icsk->icsk_ack.ato       = TCP_ATO_MIN;
5689                         tcp_incr_quickack(sk);
5690                         tcp_enter_quickack_mode(sk);
5691                         inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
5692                                                   TCP_DELACK_MAX,
TCP_RTO_MAX);
5693
5694 discard:
5695                         __kfree_skb(skb);
5696                         return 0;
5697                 } else {
5698                         tcp_send_ack(sk);
5699                 }

if I understand it correct on linux, the application code need to set
socket option with TCP_DEFER_ACCEPT or TCP_QUICKACK in order to
trigger it, correct?

We have user running wu-ftpd on HP Unix with tcp tunable
tcp_delay_final_twh_ack on. so in active FTP situation, when wu-ftpd
open up data connection to client, it sends SYN, client SYN/ACK, then
ACK/PUSH with data. so on HU UNIX, it appears just turn on tcp tunable
tcp_delay_final_twh_ack would make it happen.

but on Linux, do I need to change wu-ftpd code and modify the socket
option with TCP_DEFER_ACCEPT or TCP_QUICKACK in order to trigger the
code snippet in tcp_rcv_synsent_state_process?

Thanks

Vincent
