From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: possible race between tcp_done() and tcp_poll()
Date: Wed, 29 Mar 2017 20:18:03 -0700
Message-ID: <1490843883.24891.61.camel@edumazet-glaptop3.roam.corp.google.com>
References: <34d952a3-77cd-ea53-c3e3-ccde91d5cf63@jp.fujitsu.com>
         <75d1b617-b143-3061-fcc7-4cca26ffc9fe@jp.fujitsu.com>
         <1490841090.24891.58.camel@edumazet-glaptop3.roam.corp.google.com>
         <3c8a7438-9ce4-593a-d492-ec8117d71af4@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34496 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753959AbdC3DSG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 23:18:06 -0400
Received: by mail-pg0-f65.google.com with SMTP id o123so6565188pga.1
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 20:18:05 -0700 (PDT)
In-Reply-To: <3c8a7438-9ce4-593a-d492-ec8117d71af4@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-30 at 11:55 +0900, Seiichi Ikarashi wrote:

> I got a report that receiving a RST packet but poll() got only POLLERR, no POLLIN|POLLRDHUP .
> It was an old x86_64 kernel which does not include sk_state_{load,store} functions.
> I suspected some race might have occur above.

It looks that a one-liner patch would be enough in tcp_done()

No need adding extra barriers

Untested patch :

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1e319a525d51b0b603a5ccc5143381c752b9f2c7..4107d3fc00a53f768cdb885971a1067c810f5c9f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3285,12 +3285,12 @@ void tcp_done(struct sock *sk)
 	if (sk->sk_state == TCP_SYN_SENT || sk->sk_state == TCP_SYN_RECV)
 		TCP_INC_STATS(sock_net(sk), TCP_MIB_ATTEMPTFAILS);
 
+	sk->sk_shutdown = SHUTDOWN_MASK;
 	tcp_set_state(sk, TCP_CLOSE);
 	tcp_clear_xmit_timers(sk);
 	if (req)
 		reqsk_fastopen_remove(sk, req, false);
 
-	sk->sk_shutdown = SHUTDOWN_MASK;
 
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_state_change(sk);
