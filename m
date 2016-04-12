From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH] sctp: add support for RPS and RFS
Date: Tue, 12 Apr 2016 18:57:28 -0300
Message-ID: <20160412215728.GI15005@localhost.localdomain>
References: <d0b676c036479fe304218a05e1b03a7ba274426c.1460495323.git.marcelo.leitner@gmail.com>
 <CALx6S35by22eLr-FOFj_RQvOLZm+=cyKYn1MeeD3QQqEEcsRAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57413 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965132AbcDLV5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2016 17:57:31 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S35by22eLr-FOFj_RQvOLZm+=cyKYn1MeeD3QQqEEcsRAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 12, 2016 at 02:50:45PM -0700, Tom Herbert wrote:
> On Tue, Apr 12, 2016 at 2:11 PM, Marcelo Ricardo Leitner
> <marcelo.leitner@gmail.com> wrote:
> > This patch adds what's missing to properly support RPS and RFS on SCTP,
> > as some of it is already implemented in common calls.
> >
> > Having support for RPS and RFS allows better scaling specially because
> > not all NICs support hashing SCTP headers.
> >
> > Save the hash right when we dequeue a skb from inqueue so we do it only
> > once per skb instead of per chunk. New sockets will then inherit the
> > hash through sctp_copy_sock().
> >
> > Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> > ---
> >  net/sctp/inqueue.c | 3 +++
> >  net/sctp/socket.c  | 3 +++
> >  2 files changed, 6 insertions(+)
> >
> > diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
> > index 7e8a16c77039e1b70ef89f3e862dbb332bcc614f..b335ffcef0b901b0e71bf0843057dbf5877da31b 100644
> > --- a/net/sctp/inqueue.c
> > +++ b/net/sctp/inqueue.c
> > @@ -163,6 +163,9 @@ struct sctp_chunk *sctp_inq_pop(struct sctp_inq *queue)
> >                 chunk->singleton = 1;
> >                 ch = (sctp_chunkhdr_t *) chunk->skb->data;
> >                 chunk->data_accepted = 0;
> > +
> > +               if (chunk->asoc)
> > +                       sock_rps_save_rxhash(chunk->asoc->base.sk, chunk->skb);
> >         }
> >
> >         chunk->chunk_hdr = ch;
> > diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> > index 878d28eda1a68dc639d7b9f3f663d7518f21bb32..36697f85ce48be39f41ddedd9f53369c7f9e28d8 100644
> > --- a/net/sctp/socket.c
> > +++ b/net/sctp/socket.c
> > @@ -6430,6 +6430,8 @@ unsigned int sctp_poll(struct file *file, struct socket *sock, poll_table *wait)
> >
> >         poll_wait(file, sk_sleep(sk), wait);
> >
> > +       sock_rps_record_flow(sk);
> > +
> >         /* A TCP-style listening socket becomes readable when the accept queue
> >          * is not empty.
> >          */
> > @@ -7186,6 +7188,7 @@ void sctp_copy_sock(struct sock *newsk, struct sock *sk,
> >         newsk->sk_lingertime = sk->sk_lingertime;
> >         newsk->sk_rcvtimeo = sk->sk_rcvtimeo;
> >         newsk->sk_sndtimeo = sk->sk_sndtimeo;
> > +       newsk->sk_rxhash = sk->sk_rxhash;
> >
> >         newinet = inet_sk(newsk);
> >
> HI Marcelo,
> 
> sock_rps_record_flow should probably be in sctp_poll also (like it is
> in tcp_poll).
> 
> Thanks,
> Tom

Hi Tom,

Yes, that's the middle chunk on this patch, no?

Note that for udp it's done after the actual poll, while for tcp it's
being saved before it. I went more udp-style on this one.

Thanks,
Marcelo
