From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: avoid possible arithmetic overflows
Date: Sat, 20 Sep 2014 12:55:56 -0700
Message-ID: <1411242956.26859.81.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411233550.26859.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411236071.8612.6.camel@joe-AO725>
	 <CAK6E8=etvB4MUBu96ck+7yucbFLgbxvEPJ3TM8X5qBsZLTnhDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:49549 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754758AbaITTz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 15:55:58 -0400
Received: by mail-pa0-f52.google.com with SMTP id hz1so2102714pad.25
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 12:55:57 -0700 (PDT)
In-Reply-To: <CAK6E8=etvB4MUBu96ck+7yucbFLgbxvEPJ3TM8X5qBsZLTnhDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-09-20 at 12:46 -0700, Yuchung Cheng wrote:
> On Sat, Sep 20, 2014 at 11:01 AM, Joe Perches <joe@perches.com> wrote:
> > On Sat, 2014-09-20 at 10:19 -0700, Eric Dumazet wrote:
> >> From: Eric Dumazet <edumazet@google.com>
> >>
> >> icsk_rto is an 32bit field, and icsk_backoff can reach 15 by default,
> >> or more if some sysctl (eg tcp_retries2) are changed.
> >>
> >> Better use 64bit to perform icsk_rto << icsk_backoff operations
> >
> > Maybe better to use a helper function for this?
> >
> > something like:
> >
> > static inline u64 icsk_rto_backoff(const struct inet_connection_sock *icsk)
> > {
> >         u64 when = (u64)icsk->icsk_rto;
> >
> >         return when << icsk->icsk_backoff;
> > }
> Thanks for the fix Eric. I second Joe's idea to use a helper function.
> 

Yep.

Given the timeout functions in the kernel use 'unsigned long', I prefer
to keep the u64 magic private to this helper.

I will probably use 

static inline unsigned long icsk_rto_backoff(const struct inet_connection_sock *icsk)
{
	u64 when = (u64)icsk->icsk_rto << icsk->icsk_backoff;

	return min_t(u64, when, ~0UL);
}

On 64bit arches, the min_t() should be a nop.
