From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv2 net-next] sctp: sctp should change socket state when
 shutdown is received
Date: Tue, 7 Jun 2016 09:08:45 -0300
Message-ID: <20160607120845.GG22680@localhost.localdomain>
References: <67353a74d044f1f643cdfe1442136b44d7188ea9.1464964965.git.lucien.xin@gmail.com>
 <20160603174918.GX22680@localhost.localdomain>
 <CADvbK_eCQiw4hhs84t2tj+6zSd7M8_ECNV+W+sviiGEG2WUX_g@mail.gmail.com>
 <72299bbd-475b-b39d-0f5f-6f1916cbe706@gmail.com>
 <CADvbK_eK0XUGr3+Nmnwy_sC9NHdWj-+k1BtnzNsjE516XBKcWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34993 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752889AbcFGMIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 08:08:49 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_eK0XUGr3+Nmnwy_sC9NHdWj-+k1BtnzNsjE516XBKcWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 07:03:55PM +0800, Xin Long wrote:
> On Sat, Jun 4, 2016 at 8:22 PM, Marcelo Ricardo Leitner
> <marcelo.leitner@gmail.com> wrote:
> >
> > Return error? Please don't. Adam Endrodi asked in May (linux-sctp@) a way to
> > return the addresses used on such attempts and currently this address
> > returned by accept() is the only one we can get.
> [1] I've checked Adam's email, what he asked  was different case,  in
> his case, the assoc
> closed *after* sctp_accept, that's why he can catch the SCTP_COMM_UP event on
> accept_sk but asoc is freed already.

It doesn't have to be after sctp_accept because we will queue
SCTP_COMM_UP as reactions to COOKIE_ECHO and COOKIE_ACK, and then such
event will be moved to the new socket upon sctp_accept() call (which
calls sctp_sock_migrate()).

> 
> [2] if assoc close *before* sctp_accept return, I mean asoc close
> during sctp_accept schedule out.
> listen sk will be the assoc's parent sk, in sctp_cmd_delete_tcb
> (SCTP_CMD_DELETE_TCB):
> 
>         if (sctp_style(sk, TCP) && sctp_sstate(sk, LISTENING) &&
>             (!asoc->temp) && (sk->sk_shutdown != SHUTDOWN_MASK))
>                 return;
> 
> assoc can't be freed. and the event skb will be appended to
> listen_sk->sk_receive_queue
> when sctp_accept schedule back, it will transfer to
> accept_sk->sk_receive_queue. we can
> still get the closed assoc information. until we call sctp_close:
>                         if (sctp_state(asoc, CLOSED)) {
>                                 sctp_association_free(asoc);
>                                 continue;
>                         }
> 
> and your suggestion to improve for his case [1] is to not schedule
> SCTP_CMD_DELETE_TCB
> (only for tcp style). right ?

Yes

> 
> if so, in the case [2] that assoc close *before* sctp_accept return,
> we should also update
> the newsk->sk_state, like:
> 
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -7565,10 +7565,12 @@ static void sctp_sock_migrate(struct sock
> *oldsk, struct sock *newsk,
>         /* If the association on the newsk is already closed before accept()
>          * is called, set RCV_SHUTDOWN flag.
>          */
> -       if (sctp_state(assoc, CLOSED) && sctp_style(newsk, TCP))
> +       if (sctp_state(assoc, CLOSED) && sctp_style(newsk, TCP)) {
> +               newsk->sk_state = SCTP_SS_CLOSING;
>                 newsk->sk_shutdown |= RCV_SHUTDOWN;
> +       } else
> +               newsk->sk_state = SCTP_SS_ESTABLISHED;
> 
> -       newsk->sk_state = SCTP_SS_ESTABLISHED;
> 
> so that this two cases have the similar process, and wait for
> sctp_close to clean assoc.
> what do you think ?

I don't agree with before/after thing, but I agree with the solution. :)

  Marcelo
