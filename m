From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [4.9.13] use after free in ipv4_mtu
Date: Tue, 7 Mar 2017 08:29:46 -0800
Message-ID: <20170307082946.72a7520a@xeon-e3>
References: <CAMVG2ssDe2NMOZzeTF77H1zEEh3dBuT75bS6f81Tqd+3v_4J+g@mail.gmail.com>
        <1488460104.9415.325.camel@edumazet-glaptop3.roam.corp.google.com>
        <1488461281.9415.327.camel@edumazet-glaptop3.roam.corp.google.com>
        <CAMVG2styKvhUkVnhkFJ-B427sgnbxsBN8rJfE=wFd3wtXYXvrg@mail.gmail.com>
        <1488807904.9415.375.camel@edumazet-glaptop3.roam.corp.google.com>
        <1488817203.9415.382.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel J Blueman <daniel@quora.org>,
        Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Stephen Hemminger <shemminger@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:32810 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755386AbdCGQaU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 11:30:20 -0500
Received: by mail-pf0-f170.google.com with SMTP id w189so2494555pfb.0
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 08:29:56 -0800 (PST)
In-Reply-To: <1488817203.9415.382.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 06 Mar 2017 08:20:03 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2017-03-06 at 05:45 -0800, Eric Dumazet wrote:
> > On Mon, 2017-03-06 at 14:33 +0800, Daniel J Blueman wrote:  
> 
> > > I do change the network queueing discipline and related at runtime [1]
> > > which may be triggering this, though I did think I saw the KASAN
> > > report only after resuming from suspend. rf(un)kill and other tweaking
> > > may have been involved too.
> > > 
> > > Thanks,
> > >   Dan
> > > 
> > > [1] /etc/sysctl.d/90-tcp.conf
> > > 
> > > net.core.default_qdisc = fq_codel
> > > net.ipv4.tcp_congestion_control = bbr
> > > net.ipv4.tcp_slow_start_after_idle = 0
> > > net.ipv4.tcp_ecn = 1  
> 
> BTW, fq_codel is not suitable for BBR.
> 
> Only fq contains the needed pacing for BBR.

What about something like this???

diff --git a/net/ipv4/tcp_bbr.c b/net/ipv4/tcp_bbr.c
index b89bce4c721e..647be997a9c5 100644
--- a/net/ipv4/tcp_bbr.c
+++ b/net/ipv4/tcp_bbr.c
@@ -801,6 +801,9 @@ static void bbr_init(struct sock *sk)
        struct bbr *bbr = inet_csk_ca(sk);
        u64 bw;
 
+       WARN_ONCE(strcmp(default_qdisc_ops->id, "fq"),
+                 "TCP BBR should only be used with FQ qdisc\n");
+
        bbr->prior_cwnd = 0;
        bbr->tso_segs_goal = 0;  /* default segs per skb until first ACK */
        bbr->rtt_cnt = 0;
