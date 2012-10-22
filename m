From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: listen(2) backlog changes in or around Linux 3.1?
Date: Mon, 22 Oct 2012 13:00:01 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1210221251520.1684@cleese>
References: <CAJgzZorigejCuFweNrvmkEJts3Um7exh1fYTH=4KrEcB=v=2SA@mail.gmail.com> <507C4401.7050500@oracle.com> <CAJgzZoqhw6HJxa6uRbekLMaVTDVOo92YDtzqHnZoRiQ8tq6G2g@mail.gmail.com> <CAJgzZoq9+KZpQ1tVQJUK++VVk4JfY9u8timaJ5q6wSYoF+_tog@mail.gmail.com>
 <5080279F.80008@oracle.com> <5080340F.3050207@oracle.com> <CAJgzZooJM7aj=K-idvdbwUOOmtDM6u-=gsVOs2OFZjiZwQP0zw@mail.gmail.com> <CAGK4HS-tOE1uZR2PE+_DShEb3y5ZAn=dtECY1AmmyO2AmTVzTA@mail.gmail.com> <1350629413.2293.157.camel@edumazet-glaptop>
 <1350634013.2293.262.camel@edumazet-glaptop> <CAGK4HS_9mLzL9ESm=n5hvO0cw1hkHFMCSmBiYTBnqEMqQOvPvQ@mail.gmail.com> <1350642562.2293.411.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	enh <enh@google.com>,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:57786 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798Ab2JVTmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 15:42:47 -0400
Received: by mail-da0-f46.google.com with SMTP id n41so1533803dak.19
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 12:42:47 -0700 (PDT)
In-Reply-To: <1350642562.2293.411.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>
> If we send a SYNACK, then receive the ACK from client, and the acceptq
> is full, we should reset the connexion. Right now we have kind of stupid
> situation, were we drop the ACK, and leave the REQ in the SYN_RECV
> state, so we retransmit SYNACKS.
>


It seems the third ack is remembered in inet_rsk(req)->acked in
tcp_check_req(). However, because of the order in which the tests are performed, 
server stills retransmits the synack needlessly. Following patch 
(for review) prevents this synack retransmission if third ack has been 
received.

The request_sock will expire in around 30 seconds and will be dropped if it does
not move into accept_queue by then.  Maybe we should also call 
req->rsk_ops->send_reset(sk,skb); 
when the request_sock expires and is dropped?


net/ipv4/inet_connection_sock.c |    5 ++---
  1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index d34ce29..4e8e52e 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -598,9 +598,8 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
                                                &expire, &resend);
                                 req->rsk_ops->syn_ack_timeout(parent, req);
                                 if (!expire &&
-                                   (!resend ||
-                                    !req->rsk_ops->rtx_syn_ack(parent, req, NULL) ||
-                                    inet_rsk(req)->acked)) {
+                                   (!resend || inet_rsk(req)->acked ||
+                                    !req->rsk_ops->rtx_syn_ack(parent, req, NULL))) {
                                         unsigned long timeo;

                                         if (req->retrans++ == 0)

Thanks,
Vijay
