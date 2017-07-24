From: Neal Cardwell <ncardwell@google.com>
Subject: Re: A buggy behavior for Linux TCP Reno and HTCP
Date: Mon, 24 Jul 2017 14:29:12 -0400
Message-ID: <CADVnQymwOwWVr_Ln5+04pyiGWChf-K0XcXYP5s-+db+q1zGB9w@mail.gmail.com>
References: <CANdGJ5Qp1MoGfeSyAnEqYeSeEyoiH8e1j_Ut3F4PnLRBnqNNZg@mail.gmail.com>
 <CAK6E8=eP3jwTD5t7Cj3h_m4JTJ61p=roqsr02WiSHUANse1ynw@mail.gmail.com>
 <CANdGJ5SOUV1OoonC-3i=5MLUWvoHPBZgp19c3mJTTYbNr2yLeQ@mail.gmail.com>
 <CAK6E8=eWYybZZxkjjVXC_K7DfYayEg7gx0bPqKpwi6iuE+bh8Q@mail.gmail.com>
 <dc5db0ec-0746-d42e-5418-f621e1840bc0@unl.edu> <CADVnQynG0MZcuAPpZ+hiK-9Ounx8JKPWxvb1n3t-OyyC7=es_Q@mail.gmail.com>
 <CAK6E8=d+-kA_PyVgAoe0dtGg--ek0CurehQZ7JXo=32em2Gv+Q@mail.gmail.com>
 <CADVnQy=-m37Uxfg1=nJpkuy2CKTtW1fp2jG53Q+MNF7ifGvoHw@mail.gmail.com>
 <CADVnQym0TdX=NgdP2YeF-OAMmLXZrmxt7HaitqxxCcDCMpWJmg@mail.gmail.com> <CAK6E8=etPfZMy2ZiPJPFXF5wf9a2foU-Wummq3kLn_koL8wO+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Lisong Xu <xu@unl.edu>, Wei Sun <unlcsewsun@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:33679 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753515AbdGXS3o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 14:29:44 -0400
Received: by mail-oi0-f44.google.com with SMTP id a9so32160469oih.0
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 11:29:43 -0700 (PDT)
In-Reply-To: <CAK6E8=etPfZMy2ZiPJPFXF5wf9a2foU-Wummq3kLn_koL8wO+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 2:17 PM, Yuchung Cheng <ycheng@google.com> wrote:
> On Sun, Jul 23, 2017 at 7:37 PM, Neal Cardwell <ncardwell@google.com> wrote:
>> On Sun, Jul 23, 2017 at 10:36 PM, Neal Cardwell <ncardwell@google.com> wrote:
...
>>> What if we call the field tp->prior_cwnd? Then at least we'd have some
>>> nice symmetry:
>>>
>>> - tp->snd_cwnd,  which is saved in tp->prior_cwnd  (and restored upon undo)
>>> - tp->snd_ssthresh,  which is saved in tp-> prior_ssthresh  (and
>>> restored upon undo)
>>>
>>> That sounds appealing to me. WDYT?
>>
>> And, I should add, if we go with the tp->prior_cwnd approach, then we
>> can have a single "default"/CUBIC-style undo function, instead of 15
>> separate but identical implementations...
> you mean all CC modules share one ca_ops->undo_cwnd function? sounds a
> nice consolidation work.

Yes, exactly.

Right now we have 9 modules that have identical tcp_foo_cwnd_undo functions:

tcp_bic.c:188:  return max(tp->snd_cwnd, ca->loss_cwnd);
tcp_cubic.c:378:        return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
tcp_dctcp.c:318:        return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
tcp_highspeed.c:165:    return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
tcp_illinois.c:309:     return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
tcp_nv.c:190:   return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
tcp_scalable.c:50:      return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
tcp_veno.c:210: return max(tcp_sk(sk)->snd_cwnd, veno->loss_cwnd);
tcp_yeah.c:232: return max(tcp_sk(sk)->snd_cwnd, yeah->loss_cwnd);

And if we fix this bug in tcp_reno_undo_cwnd() by referring to
ca->loss_cwnd then we will add another 6 like this.

So my proposal would be

- tp->snd_cwnd,  which is saved in tp->prior_cwnd  (and restored upon undo)
- tp->snd_ssthresh,  which is saved in tp-> prior_ssthresh  (and
   restored upon undo)

Actually, now that I re-read the code, we already do have a
prior_cwnd, which is used for the PRR code, and already set upon
entering CA_Recovery. So if we set prior_cwnd for CA_Loss, perhaps we
can do something like:

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index fde983f6376b..c2b174469645 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -456,7 +456,7 @@ u32 tcp_reno_undo_cwnd(struct sock *sk)
 {
        const struct tcp_sock *tp = tcp_sk(sk);

-       return max(tp->snd_cwnd, tp->snd_ssthresh << 1);
+       return max(tp->snd_cwnd, tp->prior_cwnd);
 }
 EXPORT_SYMBOL_GPL(tcp_reno_undo_cwnd);

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2920e0cb09f8..ae790a84302d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1951,6 +1951,7 @@ void tcp_enter_loss(struct sock *sk)
            !after(tp->high_seq, tp->snd_una) ||
            (icsk->icsk_ca_state == TCP_CA_Loss && !icsk->icsk_retransmits)) {
                tp->prior_ssthresh = tcp_current_ssthresh(sk);
+               tp->prior_cwnd = tp->snd_cwnd;
                tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
                tcp_ca_event(sk, CA_EVENT_LOSS);
                tcp_init_undo(tp);

And then change all the CC modules but BBR to use the
tcp_reno_undo_cwnd() instead of their own custom undo code.

WDYT?

neal
