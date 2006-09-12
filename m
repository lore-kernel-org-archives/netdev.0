From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: TCP Pacing
Date: Tue, 12 Sep 2006 15:21:56 -0300
Message-ID: <39e6f6c70609121121o6b1468fcv994b2365dfe3b0d4@mail.gmail.com>
References: <200609121958.22820.root@danielinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@osdl.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Carlo Caini" <ccaini@deis.unibo.it>,
	"Rosario Firrincieli" <rfirrincieli@arces.unibo.it>,
	"Giovanni Pau" <gpau@cs.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:58134 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1030318AbWILSWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 14:22:00 -0400
Received: by wr-out-0506.google.com with SMTP id i32so572562wra
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2006 11:21:59 -0700 (PDT)
To: root@danielinux.net
In-Reply-To: <200609121958.22820.root@danielinux.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/12/06, Daniele Lacamera <root@danielinux.net> wrote:
> Hello,
>
> Please let me insist once again on the importance of adding a TCP Pacing
> mechanism in our TCP, as many people are including this algorithm in
> their congestion control proposals. Recent researches have found out
> that it really can help improving performance in different scenarios,
> like satellites and long-delay high-speed channels (>100ms RTT, Gbit).
> Hybla module itself is cripple without this feature in its natural
> scenario.
>
> The following patch is totally non-invasive: it has a config option and
> a sysctl switch, both turned off by default. When the config option is
> enabled, it adds only 6B to the tcp_sock.
>
> Signed-off by: Daniele Lacamera <root@danielinux.net>
> ---
>
diff -ruN linux-2.6.18-rc6/net/ipv4/tcp_input.c
linux-pacing/net/ipv4/tcp_input.c
--- linux-2.6.18-rc6/net/ipv4/tcp_input.c	2006-09-04 04:19:48.000000000 +0200
+++ linux-pacing/net/ipv4/tcp_input.c	2006-09-12 17:11:38.000000000 +0200
@@ -2569,6 +2569,11 @@
 			tcp_cong_avoid(sk, ack, seq_rtt, prior_in_flight, 1);
 	}

Without getting into the merits of the pacing technique:

+#ifdef CONFIG_TCP_PACING
+	if(sysctl_tcp_pacing)
+		tcp_pacing_recalc_delta(sk);
+#endif

Please rewrite the patch so as to avoid adding that many #ifdefs to
the common code, replacing above code with:

tcp_pacing_recalc_delta(sk);

That is defined in a header (net/tcp.h) as:

#ifdef CONFIG_TCP_PACING
extern void __tcp_pacing_recalc_delta(struct sock *sk);
extern int sysctl_tcp_pacing;

static inline void tcp_pacing_recalc_delta(struct sock *sk)
{
        if (sysctl_tcp_pacing) /* notice the space after ( */
               __tcp_pacing_recalc_delta(sk);
}
#else
static inline void tcp_pacing_recalc_delta(struct sock *sk) {};
#endif

Thanks,

- Arnaldo
