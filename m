From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Tue, 22 May 2012 18:12:50 +0200
Message-ID: <1337703170.3361.217.camel@edumazet-glaptop>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
	 <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
	 <1337099641.8512.1102.camel@edumazet-glaptop>
	 <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <1337101280.8512.1108.camel@edumazet-glaptop>
	 <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>
	 <1337272654.3403.20.camel@edumazet-glaptop>
	 <1337674831.1698.7.camel@kjm-desktop.uk.level5networks.com>
	 <1337678759.3361.147.camel@edumazet-glaptop>
	 <1337679045.3361.154.camel@edumazet-glaptop>
	 <1337699379.1698.30.camel@kjm-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:58554 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575Ab2EVQMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 12:12:55 -0400
Received: by eeit10 with SMTP id t10so1773669eei.19
        for <netdev@vger.kernel.org>; Tue, 22 May 2012 09:12:54 -0700 (PDT)
In-Reply-To: <1337699379.1698.30.camel@kjm-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-22 at 16:09 +0100, Kieran Mansley wrote:
> On Tue, 2012-05-22 at 11:30 +0200, Eric Dumazet wrote:
> > Also can you post a pcap capture of problematic flow ?
> 
> I'll email this to you directly. The capture is generated with netserver
> on the system under test, and NetPerf sending from a similar server.
> I've only included the first 1000 frames to keep the capture size down.
> There are 7 retransmissions in that capture, and the TCPBacklogDrops
> counter incremented by 7 during the test, so I'm happy to say they are
> the cause of the drops.
> 
> The system under test was running net-next.
> 
> I've not tried with another NIC (e.g. tg3) but will see if I can find
> one to test.

Or you could change sfc to allow its frames being coalesced.

> 
> I've got a feeling that the drops might be easier to reproduce if I
> taskset the netserver process to a different package than the one that
> is handling the network interrupt for that NIC.  This fits with my
> earlier theory in that it is likely to increase the overhead of waking
> the user-level process to satisfy the read and so increase the time
> during which received packets could overflow the backlog.  Having a
> relatively aggressive sending TCP also helps, e.g. one that is
> configured to open its congestion window quickly, as this will produce
> more intensive bursts.

__tcp_select_window() ( more precisely tcp_space() takes into account
memory used in receive/ofo queue, but not frames in backlog queue)

So if you send bursts, it might explain TCP stack continues to advertise
a too big window, instead of anticipate the problem.

Please try the following patch :

diff --git a/include/net/tcp.h b/include/net/tcp.h
index e79aa48..82382cb 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1042,8 +1042,9 @@ static inline int tcp_win_from_space(int space)
 /* Note: caller must be prepared to deal with negative returns */ 
 static inline int tcp_space(const struct sock *sk)
 {
-	return tcp_win_from_space(sk->sk_rcvbuf -
-				  atomic_read(&sk->sk_rmem_alloc));
+	int used = atomic_read(&sk->sk_rmem_alloc) + sk->sk_backlog.len;
+
+	return tcp_win_from_space(sk->sk_rcvbuf - used);
 } 
 
 static inline int tcp_full_space(const struct sock *sk)
