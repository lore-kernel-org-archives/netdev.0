From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid possible arithmetic overflows
Date: Mon, 22 Sep 2014 05:42:19 -0700
Message-ID: <1411389739.26859.113.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411233550.26859.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411236071.8612.6.camel@joe-AO725>
	 <CAK6E8=etvB4MUBu96ck+7yucbFLgbxvEPJ3TM8X5qBsZLTnhDg@mail.gmail.com>
	 <1411242956.26859.81.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411244392.10610.4.camel@joe-AO725>
	 <1411259357.26859.89.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAK6E8=d9y8D5we_fibzxstaXBMnQcOG3DsOAL0jhzDGK1H62cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:58380 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804AbaIVMmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 08:42:20 -0400
Received: by mail-pa0-f51.google.com with SMTP id eu11so2760620pac.38
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 05:42:20 -0700 (PDT)
In-Reply-To: <CAK6E8=d9y8D5we_fibzxstaXBMnQcOG3DsOAL0jhzDGK1H62cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-09-21 at 10:46 -0700, Yuchung Cheng wrote:
> On Sat, Sep 20, 2014 at 5:29 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > icsk_rto is a 32bit field, and icsk_backoff can reach 15 by default,
> > or more if some sysctl (eg tcp_retries2) are changed.
> >
> > Better use 64bit to perform icsk_rto << icsk_backoff operations
> >
> > As Joe Perches suggested, add a helper for this.
> >
> > From: Eric Dumazet <edumazet@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>
> 
> Maybe also use the new helper for the backoff in tcp_v4_err()?

You mean the following bit ? If yes, I'll incorporate it in v3

Thanks

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 006b045716d8..3b2e49cb2b61 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -430,9 +430,9 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 			break;
 
 		icsk->icsk_backoff--;
-		inet_csk(sk)->icsk_rto = (tp->srtt_us ? __tcp_set_rto(tp) :
-			TCP_TIMEOUT_INIT) << icsk->icsk_backoff;
-		tcp_bound_rto(sk);
+		icsk->icsk_rto = tp->srtt_us ? __tcp_set_rto(tp) :
+					       TCP_TIMEOUT_INIT;
+		icsk->icsk_rto = inet_csk_rto_backoff(icsk, TCP_RTO_MAX);
 
 		skb = tcp_write_queue_head(sk);
 		BUG_ON(!skb);
