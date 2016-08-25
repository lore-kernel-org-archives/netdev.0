From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 1/3] tcp: randomize tcp timestamp offsets for each
 connection
Date: Thu, 25 Aug 2016 14:06:54 -0700
Message-ID: <1472159214.14381.161.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471524527-10029-1-git-send-email-fw@strlen.de>
         <1471524527-10029-2-git-send-email-fw@strlen.de>
         <1472153655.14381.152.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160825203125.GA10987@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36063 "EHLO
        mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756158AbcHYVHT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 17:07:19 -0400
Received: by mail-pa0-f44.google.com with SMTP id di2so20117533pad.3
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 14:06:56 -0700 (PDT)
In-Reply-To: <20160825203125.GA10987@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-25 at 22:31 +0200, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2016-08-18 at 14:48 +0200, Florian Westphal wrote:
> > It seems tcp_v4_reqsk_send_ack() and tcp_v6_reqsk_send_ack() were not
> > taken into account.
> > 
> > See commit 20a2b49fc5385 changelog
> > packetdrill test showing the possible issue if the TS sent on an ACK in
> > SYN_RECV state is wrong.
> 
> Thanks a lot Eric, I'll fix this.

I would try :

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 47683c798f57..c2bf284239f6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -826,7 +826,7 @@ static void tcp_v4_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
 
        tcp_v4_send_ack(sock_net(sk), skb, seq,
                        tcp_rsk(req)->rcv_nxt, req->rsk_rcv_wnd,
-                       tcp_time_stamp,
+                       tcp_time_stamp + tcp_rsk(req)->ts_off,
                        req->ts_recent,
                        0,
                        tcp_md5_do_lookup(sk, (union tcp_md5_addr *)&ip_hdr(skb)->daddr,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ce029c090f94..6411aa378b1b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -955,7 +955,8 @@ static void tcp_v6_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
        tcp_v6_send_ack(sk, skb, (sk->sk_state == TCP_LISTEN) ?
                        tcp_rsk(req)->snt_isn + 1 : tcp_sk(sk)->snd_nxt,
                        tcp_rsk(req)->rcv_nxt, req->rsk_rcv_wnd,
-                       tcp_time_stamp, req->ts_recent, sk->sk_bound_dev_if,
+                       tcp_time_stamp + tcp_rsk(req)->ts_off,
+                       req->ts_recent, sk->sk_bound_dev_if,
                        tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr),
                        0, 0);
 }
