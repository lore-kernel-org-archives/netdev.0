From: Neal Cardwell <ncardwell@google.com>
Subject: Re: TCP NewReno and single retransmit
Date: Wed, 29 Oct 2014 22:03:08 -0400
Message-ID: <CADVnQynu7+wgkNTkdY=XDBeyWjFxpYYBjx=n98g1_awdG2OpnA@mail.gmail.com>
References: <544E93BD.50202@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:33063 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756754AbaJ3CDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 22:03:09 -0400
Received: by mail-qc0-f180.google.com with SMTP id o8so3524098qcw.11
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 19:03:08 -0700 (PDT)
In-Reply-To: <544E93BD.50202@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 27, 2014 at 2:49 PM, Marcelo Ricardo Leitner
<mleitner@redhat.com> wrote:
> Hi,
>
> We have a report from a customer saying that on a very calm connection, like
> having only a single data packet within some minutes, if this packet gets to
> be re-transmitted, retrans_stamp is only cleared when the next acked packet
> is received. But this may make we abort the connection too soon if this next
> packet also gets lost, because the reference for the initial loss is still
> for a big while ago..
...
> @@ -2382,31 +2382,32 @@ static inline bool tcp_may_undo(const struct
> tcp_sock *tp)
>  static bool tcp_try_undo_recovery(struct sock *sk)
...
>         if (tp->snd_una == tp->high_seq && tcp_is_reno(tp)) {
>                 /* Hold old state until something *above* high_seq
>                  * is ACKed. For Reno it is MUST to prevent false
>                  * fast retransmits (RFC2582). SACK TCP is safe. */
>                 tcp_moderate_cwnd(tp);
> +               tp->retrans_stamp = 0;
>                 return true;
>         }
>         tcp_set_ca_state(sk, TCP_CA_Open);
>         return false;
>  }
>
> We would still hold state, at least part of it.. WDYT?

This approach sounds OK to me as long as we include a check of
tcp_any_retrans_done(), as we do in the similar code paths (for
motivation, see the comment above tcp_any_retrans_done()).

So it sounds fine to me if you change that one new line to the following 2:

+  if (!tcp_any_retrans_done(sk))
+    tp->retrans_stamp = 0;

Nice catch!

neal
