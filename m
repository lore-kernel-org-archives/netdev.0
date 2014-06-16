From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: tcp: multiple ssthresh reductions before all packets are
 retransmitted
Date: Mon, 16 Jun 2014 20:48:23 +0200
Message-ID: <20140616184823.GA20932@unicorn.suse.cz>
References: <20140616153515.GA4907@unicorn.suse.cz>
 <CAK6E8=cFnDut3xYhNqHkhV9FNXkuTtrT=iB19Way80A43LAXwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36611 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932566AbaFPSsZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2014 14:48:25 -0400
Content-Disposition: inline
In-Reply-To: <CAK6E8=cFnDut3xYhNqHkhV9FNXkuTtrT=iB19Way80A43LAXwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2014 at 10:02:08AM -0700, Yuchung Cheng wrote:
> On Mon, Jun 16, 2014 at 8:35 AM, Michal Kubecek <mkubecek@suse.cz> wrote:
> >
> > RFC 5681 says that ssthresh reduction in response to RTO should be done
> > only once and should not be repeated until all packets from the first
> > loss are retransmitted. RFC 6582 (as well as its predecessor RFC 3782)
> > is even more specific and says that when loss is detected, one should
> > mark current SND.NXT and ssthresh shouldn't be reduced again due to
> > a loss until SND.UNA reaches this remembered value.
> >
> > Linux implementation does exactly that but in TCP_CA_Loss state,
> > tcp_enter_loss() also takes icsk_retransmits into account:
> >
> >         /* Reduce ssthresh if it has not yet been made inside this window. */
> >         if (icsk->icsk_ca_state <= TCP_CA_Disorder ||
> >             !after(tp->high_seq, tp->snd_una) ||
> >             (icsk->icsk_ca_state == TCP_CA_Loss && !icsk->icsk_retransmits)) {
> >                 new_recovery = true;
> >                 tp->prior_ssthresh = tcp_current_ssthresh(sk);
> >                 tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
> >                 tcp_ca_event(sk, CA_EVENT_LOSS);
> >         }
> >
> > This seems correct as icsk_retransmits is supposed to mean "we still
> > have packets to retransmit". But icsk_retransmits is reset in
> > tcp_process_loss() if one of two conditions is satisfied:
> 
> icsk_retransmits indicates the number of recurring timeouts (of the
> same sequence). so it is reset when the recovery is done or SND_UNA is
> advanced. the variable name however is confusing.

In that case, I suppose the problem would be this part

    (icsk->icsk_ca_state == TCP_CA_Loss && !icsk->icsk_retransmits)

of the condition above (in tcp_enter_loss()). As that would mean we
would allow further ssthresh reduction as soon as SND.UNA moves forward
(not when it reaches high_seq).

> does your suggested change fix the problem you are observing?

It does, with it ssthresh isn't lowered again until all lost packets are
retransmitted (at which time, cwnd is already reasonably high). But
I wasn't sure it wouldn't break something else.

                                                          Michal Kubecek
