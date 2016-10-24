From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: send/sendmsg ENOMEM errors WAS(Re: [PATCH net 6/6] sctp: not
 return ENOMEM err back in sctp_packet_transmit
Date: Mon, 24 Oct 2016 09:48:23 -0200
Message-ID: <20161024114823.GE2958@localhost.localdomain>
References: <c15cc225-608d-5268-d179-6a997c3cad62@mojatatu.com>
 <daecd6b5-47cf-c5de-90f5-445e0038dfce@mojatatu.com>
 <CADvbK_ci-aaX6-mgXTgR0mJm9ww7+48DmXH+m5R+-0PyMDH16g@mail.gmail.com>
 <2fa21505-59c2-fb8b-6e89-11fccc953d25@mojatatu.com>
 <CADvbK_cvYhCfzuJCcoUC3+Ghv+VYLoyRGo0mt9UccjYpSBYD0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Vlad Yasevich <vyasevic@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Michael Tuexen <Michael.Tuexen@lurchi.franken.de>,
        Eric Dumazet <edumazet@google.com>,
        Brenda Butler <bjb@mojatatu.com>, gabor@mojatatu.com
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36750 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756858AbcJXLs3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 07:48:29 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_cvYhCfzuJCcoUC3+Ghv+VYLoyRGo0mt9UccjYpSBYD0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 24, 2016 at 02:30:07PM +0800, Xin Long wrote:
> [1]
> >> This patch doesn't ignore all the ENOMEN cases, only after msg is
> >> enqueued in out queue/send queue, in the lower layer, when alloc
> >> new skb and copy data from old skb, if it fails to alloc new skb, sctp
> >> will ignore this ENOMEM, as this msg will be taken care by retransmit
> >> mechanism, it's reasonable and also safe, user can't feel that.
> >>
> >
> > Yes, that part i got.
> >
> 
> [2]
> >> But for the cases before enqueue, like in sctp_sendmsg,
> >> sctp_datamsg_from_user may return ENOMEM, this err will return
> >> back to user, and can't be ignored.
> >>
> >
> > The hard part is distinguishing between the above case and real
> > failure.
> > I am assuming in the case above user is _not_ required to send
> > again. But in the general case they are required to send again.
> > Correct?
> in case [1], user can't see the ENOMEM, ENOMEM is more like
> a internal err.
> 
> in case [2], user will got the ENOMEM, they should resend this msg,
> It's the the general case mentioned-above
> 
> >
> >> So I don't really think we should change something in manpage, what
> >> do you think ? maybe a little explanation there is also nice, :)
> >
> >
> > Yes, that would help. In particular it should be clear what user space
> > is expected to do. While this is about sctp - I am assuming equivalent
> > behavior for all callers of sendxxx() regardless of protocol.
> here sctp's behavior is actually same with tcp's, in tcp, tcp_transmit_skb
> also may fail to alloc skb, but it doesn't return any err to user, just like
> sctp_packet_transmit. That's why I don't think we should change something
> in manpage, as here sctp is consistent with tcp now.
> 
> make sense ?

I may be saying what is already understood, but just to be clear,
without this patch, there is no consistent way to known if you hit [1]
or [2]. Recovering from it then depends on how the protocol above SCTP
will handle it, if it can handle duplicate messages or not.
