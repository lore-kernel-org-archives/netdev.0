From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [REGRESSION] Warning in tcp_fastretrans_alert() of net/ipv4/tcp_input.c
Date: Sun, 10 Sep 2017 19:59:02 -0400
Message-ID: <CADVnQy=dzjROPgrOw3vAZvtb9ETRJgTPVGtau8Q3ChteDKnYow@mail.gmail.com>
References: <10035198.1vE6NFrMDO@natalenko.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Oleksandr Natalenko <oleksandr@natalenko.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:36544 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751994AbdIJX7e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2017 19:59:34 -0400
Received: by mail-wr0-f172.google.com with SMTP id o42so11495591wrb.3
        for <netdev@vger.kernel.org>; Sun, 10 Sep 2017 16:59:34 -0700 (PDT)
In-Reply-To: <10035198.1vE6NFrMDO@natalenko.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 10, 2017 at 4:53 PM, Oleksandr Natalenko
<oleksandr@natalenko.name> wrote:
> Hello.
>
> Since, IIRC, v4.11, there is some regression in TCP stack resulting in the
> warning shown below. Most of the time it is harmless, but rarely it just
> causes either freeze or (I believe, this is related too) panic in
> tcp_sacktag_walk() (because sk_buff passed to this function is NULL).
> Unfortunately, I still do not have proper stacktrace from panic, but will try
> to capture it if possible.
...
> [14407.060066] ------------[ cut here ]------------
> [14407.060353] WARNING: CPU: 0 PID: 719 at net/ipv4/tcp_input.c:2826
> tcp_fastretrans_alert+0x7c8/0x990
...
> 2823     /* D. Check state exit conditions. State can be terminated
> 2824      *    when high_seq is ACKed. */
> 2825     if (icsk->icsk_ca_state == TCP_CA_Open) {
> 2826         WARN_ON(tp->retrans_out != 0); // here
> 2827         tp->retrans_stamp = 0;

Thanks for the detailed report!

I suspect this is due to the following commit, which happened between
4.10 and 4.11:

  89fe18e44f7e tcp: extend F-RTO to catch more spurious timeouts
  https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=89fe18e44f7e

This commit expanded the set of scenarios where we would undo a
CA_Loss cwnd reduction and return to TCP_CA_Open, but did not include
a check to see if there were any in-flight retransmissions. I think we
need a fix like the following:

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 659d1baefb2b..730a2de9d2b0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2439,7 +2439,7 @@ static bool tcp_try_undo_loss(struct sock *sk,
bool frto_undo)
 {
        struct tcp_sock *tp = tcp_sk(sk);

-       if (frto_undo || tcp_may_undo(tp)) {
+       if ((frto_undo || tcp_may_undo(tp)) && !tp->retrans_out) {
                tcp_undo_cwnd_reduction(sk, true);

                DBGUNDO(sk, "partial loss");

I will try a packetdrill test to see if I can reproduce this issue and
verify the fix.

thanks,
neal
