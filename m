From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net] tcp: avoid multiple ssthresh reductions in on
 retransmit window
Date: Mon, 16 Jun 2014 15:39:28 -0700
Message-ID: <CAK6E8=dxszKmHssR7ib7Fxfm6hQRdbwBG1ygRvOXoSAXddBSPA@mail.gmail.com>
References: <CAK6E8=dwh1btNzX80YNre9u7rS+SgochXxHxDhQYQZCvY8yVMQ@mail.gmail.com>
 <20140616211954.6E12BA3A89@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Neal Cardwell <ncardwell@google.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:56619 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932538AbaFPWkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 18:40:10 -0400
Received: by mail-ie0-f181.google.com with SMTP id y20so5422561ier.26
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 15:40:10 -0700 (PDT)
In-Reply-To: <20140616211954.6E12BA3A89@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2014 at 2:19 PM, Michal Kubecek <mkubecek@suse.cz> wrote:
> RFC 5681 says that ssthresh reduction in response to RTO should
> be done only once and should not be repeated until all packets
> from the first loss are retransmitted. RFC 6582 (as well as its
> predecessor RFC 3782) is even more specific and says that when
> loss is detected, one should mark current SND.NXT and ssthresh
> shouldn't be reduced again due to a loss until SND.UNA reaches
> this remembered value.
>
> In Linux implementation, this is done in tcp_enter_loss() but an
> additional condition
>
>   (icsk->icsk_ca_state == TCP_CA_Loss && !icsk->icsk_retransmits)
>
> allows to further reduce ssthresh before snd_una reaches the
> high_seq (the snd_nxt value at the previous loss) as
> icsk_retransmits is reset as soon as snd_una moves forward. As a
> result, if a retransmit timeout ouccurs early in the retransmit
> phase, we can adjust snd_ssthresh based on very low value of
> cwnd. This can be especially harmful for reno congestion control
> with slow linear cwnd growth in congestion avoidance phase.
>
> The patch removes the condition above so that snd_ssthresh is
> not reduced again until snd_una reaches high_seq as described in
> RFC 5681 and 6582.
>
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Acked-by: Yuchung Cheng <ycheng@google.com>

> ---
>  net/ipv4/tcp_input.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 40661fc..768ba88 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1917,8 +1917,7 @@ void tcp_enter_loss(struct sock *sk, int how)
>
>         /* Reduce ssthresh if it has not yet been made inside this window. */
>         if (icsk->icsk_ca_state <= TCP_CA_Disorder ||
> -           !after(tp->high_seq, tp->snd_una) ||
> -           (icsk->icsk_ca_state == TCP_CA_Loss && !icsk->icsk_retransmits)) {
> +           !after(tp->high_seq, tp->snd_una)) {
>                 new_recovery = true;
>                 tp->prior_ssthresh = tcp_current_ssthresh(sk);
>                 tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
> --
> 1.8.4.5
>
