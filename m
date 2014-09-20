From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] tcp: avoid possible arithmetic overflows
Date: Sat, 20 Sep 2014 13:19:52 -0700
Message-ID: <1411244392.10610.4.camel@joe-AO725>
References: <1411233550.26859.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411236071.8612.6.camel@joe-AO725>
	 <CAK6E8=etvB4MUBu96ck+7yucbFLgbxvEPJ3TM8X5qBsZLTnhDg@mail.gmail.com>
	 <1411242956.26859.81.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0150.hostedemail.com ([216.40.44.150]:39959 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757886AbaITUTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 16:19:55 -0400
In-Reply-To: <1411242956.26859.81.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-09-20 at 12:55 -0700, Eric Dumazet wrote:
> On Sat, 2014-09-20 at 12:46 -0700, Yuchung Cheng wrote:
> > On Sat, Sep 20, 2014 at 11:01 AM, Joe Perches <joe@perches.com> wrote:
> > > On Sat, 2014-09-20 at 10:19 -0700, Eric Dumazet wrote:
> > >> From: Eric Dumazet <edumazet@google.com>
> > >>
> > >> icsk_rto is an 32bit field, and icsk_backoff can reach 15 by default,
> > >> or more if some sysctl (eg tcp_retries2) are changed.
> > >>
> > >> Better use 64bit to perform icsk_rto << icsk_backoff operations
> > >
> > > Maybe better to use a helper function for this?
> > >
> > > something like:
> > >
> > > static inline u64 icsk_rto_backoff(const struct inet_connection_sock *icsk)
> > > {
> > >         u64 when = (u64)icsk->icsk_rto;
> > >
> > >         return when << icsk->icsk_backoff;
> > > }
> > Thanks for the fix Eric. I second Joe's idea to use a helper function.
> > 
> 
> Yep.
> 
> Given the timeout functions in the kernel use 'unsigned long', I prefer
> to keep the u64 magic private to this helper.
> 
> I will probably use 
> 
> static inline unsigned long icsk_rto_backoff(const struct inet_connection_sock *icsk)
> {
> 	u64 when = (u64)icsk->icsk_rto << icsk->icsk_backoff;
> 
> 	return min_t(u64, when, ~0UL);

OK.

I think an explicit cast to unsigned long after the min_t
to avoid the implicit downcast would be better

	return (unsigned long)min_t(etc...)

so that no warning is produced if someone does make W=3
