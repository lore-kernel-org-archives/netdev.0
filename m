From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 4/5] net: tcp: more detailed ACK events, and events for
 CE marked packets
Date: Tue, 13 May 2014 12:26:24 +0200
Message-ID: <20140513102624.GC13945@breakpoint.cc>
References: <1399928384-24143-1-git-send-email-fw@strlen.de>
 <1399928384-24143-5-git-send-email-fw@strlen.de>
 <CAK6E8=d4i+NR7_gE7HDYQWhgNSYPchZ7kKqoRH93M-ZhrXs86g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Glenn Judd <glenn.judd@morganstanley.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:58071 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760703AbaEMK00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 06:26:26 -0400
Content-Disposition: inline
In-Reply-To: <CAK6E8=d4i+NR7_gE7HDYQWhgNSYPchZ7kKqoRH93M-ZhrXs86g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yuchung Cheng <ycheng@google.com> wrote:
> On Mon, May 12, 2014 at 1:59 PM, Florian Westphal <fw@strlen.de> wrote:
> >
> > DataCenter TCP (DCTCP) determines cwnd growth based on ECN information
> > and ACK properties, e.g. ACK that updates window is treated differently
> > than DUPACK.
> >
> > Also DCTCP needs information whether ACK was delayed ACK. Furthermore,
> > DCTCP also implements a CE state machine that keeps track of CE markings
> > of incoming packets.
> >
> > Therefore, extend the congestion control framework to provide these
> > event types, so that DCTCP can be properly implemented as a normal
> > congestion algorithm module outside the core stack.
> >
> > Joint work with Daniel Borkmann and Glenn Judd.
> >
> > Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> > Signed-off-by: Glenn Judd <glenn.judd@morganstanley.com>
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > ---
> >  include/net/tcp.h     |  9 ++++++++-
> >  net/ipv4/tcp_input.c  | 22 ++++++++++++++++++----
> >  net/ipv4/tcp_output.c |  4 ++++
> >  3 files changed, 30 insertions(+), 5 deletions(-)
> >
> > diff --git a/include/net/tcp.h b/include/net/tcp.h
> > index 0d767d2..56bf383 100644
> > --- a/include/net/tcp.h
> > +++ b/include/net/tcp.h
> > @@ -754,10 +754,17 @@ enum tcp_ca_event {
> >         CA_EVENT_CWND_RESTART,  /* congestion window restart */
> >         CA_EVENT_COMPLETE_CWR,  /* end of congestion recovery */
> >         CA_EVENT_LOSS,          /* loss timeout */
> > +       CA_EVENT_ECN_NO_CE,     /* ECT set, but not CE marked */
> > +       CA_EVENT_ECN_IS_CE,     /* received CE marked IP packet */
> > +       CA_EVENT_DELAYED_ACK,   /* Delayed ack is sent */
> > +       CA_EVENT_NON_DELAYED_ACK,
> do we need NON_DELAYED_ACK event? is there a third kind?

Could you elaborate? I am not sure what you mean.

> > @@ -3421,10 +3428,12 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
> >                 tp->snd_una = ack;
> >                 flag |= FLAG_WIN_UPDATE;
> >
> > -               tcp_in_ack_event(sk, 0);
> > +               tcp_in_ack_event(sk, CA_ACK_WIN_UPDATE);
> These CA_ACK_xxx are identical to the ACK flag so might as well just
> pass the flag to the event handler?

We felt that exposing all the FLAG_xxx values (which are private to
tcp_input.c) to congestion modules would be overkill, especially
since we would fail to notify the cong_ops module(s) about all of these.

I think if we were to expose all of them we'd also have to call
rename tcp_in_ack_event() (since most of the flags are not ack related)
and then consistently call that for all the flag changes (which is just
needless overhead since no cong_ops module would react to these).

We can update the tcp_ca_ack_event_flags to include
all FLAG_xxx values and then convert tcp_input.c  to use them, but it
would mean that cong_ops modules could only rely on a selected few of
these flags to actually be set/propagated consistently.
