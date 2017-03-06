From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [4.9.13] use after free in ipv4_mtu
Date: Mon, 06 Mar 2017 05:45:04 -0800
Message-ID: <1488807904.9415.375.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAMVG2ssDe2NMOZzeTF77H1zEEh3dBuT75bS6f81Tqd+3v_4J+g@mail.gmail.com>
         <1488460104.9415.325.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488461281.9415.327.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAMVG2styKvhUkVnhkFJ-B427sgnbxsBN8rJfE=wFd3wtXYXvrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Stephen Hemminger <shemminger@linux-foundation.org>
To: Daniel J Blueman <daniel@quora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34076 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753162AbdCFNpN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 08:45:13 -0500
Received: by mail-pg0-f67.google.com with SMTP id b5so2996051pgg.1
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 05:45:12 -0800 (PST)
In-Reply-To: <CAMVG2styKvhUkVnhkFJ-B427sgnbxsBN8rJfE=wFd3wtXYXvrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-03-06 at 14:33 +0800, Daniel J Blueman wrote:
> On 2 March 2017 at 21:28, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2017-03-02 at 05:08 -0800, Eric Dumazet wrote:
> >
> >> Thanks for the report !
> >>
> >> This patch should solve this precise issue, but we need more work.
> >>
> >> We need to audit all __sk_dst_get() and make sure they are inside an
> >> rcu_read_lock()/rcu_read_unlock() section.
> >>
> >> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> >> index 22548b5f05cbe5a655e0c53df2d31c5cc2e8a702..517963e1cb6eb9d70fcd71f44262813c3378759f 100644
> >> --- a/net/ipv4/tcp_output.c
> >> +++ b/net/ipv4/tcp_output.c
> >> @@ -1459,7 +1459,7 @@ EXPORT_SYMBOL(tcp_sync_mss);
> >>  unsigned int tcp_current_mss(struct sock *sk)
> >>  {
> >>       const struct tcp_sock *tp = tcp_sk(sk);
> >> -     const struct dst_entry *dst = __sk_dst_get(sk);
> >> +     const struct dst_entry *dst;
> >>       u32 mss_now;
> >>       unsigned int header_len;
> >>       struct tcp_out_options opts;
> >> @@ -1467,11 +1467,14 @@ unsigned int tcp_current_mss(struct sock *sk)
> >>
> >>       mss_now = tp->mss_cache;
> >>
> >> +     rcu_read_lock();
> >> +     dst = __sk_dst_get(sk);
> >>       if (dst) {
> >>               u32 mtu = dst_mtu(dst);
> >>               if (mtu != inet_csk(sk)->icsk_pmtu_cookie)
> >>                       mss_now = tcp_sync_mss(sk, mtu);
> >>       }
> >> +     rcu_read_unlock();
> >>
> >>       header_len = tcp_established_options(sk, NULL, &opts, &md5) +
> >>                    sizeof(struct tcphdr);
> >
> > Normally TCP sockets sk_dst_cache can only be changed if the thread
> > doing the change owns the socket.
> >
> > I have not yet understood which point was breaking the rule yet.
> 
> Great work Eric! I have been unable to reproduce the KASAN warning
> with this patch.
> 
> Reported-by: Daniel J Blueman <daniel@quora.org>
> Tested-by: Daniel J Blueman <daniel@quora.org>
> 
> I do change the network queueing discipline and related at runtime [1]
> which may be triggering this, though I did think I saw the KASAN
> report only after resuming from suspend. rf(un)kill and other tweaking
> may have been involved too.
> 
> Thanks,
>   Dan
> 
> [1] /etc/sysctl.d/90-tcp.conf
> 
> net.core.default_qdisc = fq_codel
> net.ipv4.tcp_congestion_control = bbr
> net.ipv4.tcp_slow_start_after_idle = 0
> net.ipv4.tcp_ecn = 1

Thanks Daniel, but this bandaid patch should not be needed.

Somehow another point in the stack is at fault and needs to be
identified.

Otherwise we'll keep adding works around.

Since net-next is soon to be re-opened, I will submit patches adding
more lockdep assisted checks.
