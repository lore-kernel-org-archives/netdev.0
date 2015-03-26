From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net] ipvlan: fix addr hash list corruption
Date: Wed, 25 Mar 2015 19:15:55 -0700
Message-ID: <CAF2d9jj2cbDKXPnFUyVOJUVzrvb4CbK5ktbeW32N31xG0Hz63g@mail.gmail.com>
References: <20150324180628.278017fb@griffin> <CAF2d9jh+VozezamrEK_6vfTvY8LZSzw9n-bJjSX3G11RXmfz3w@mail.gmail.com>
 <20150325095851.1d8d1622@griffin> <20150325.114622.1915164845375005128.davem@davemloft.net>
 <CAF2d9jh5WaNYsMxp29GY3LqM08jjVPwLd1BQ1HLFKMsKFda6zQ@mail.gmail.com> <20150326002154.3e179fec@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>, dcbw@redhat.com
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:36619 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbbCZCQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 22:16:16 -0400
Received: by oicf142 with SMTP id f142so28870350oic.3
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 19:16:16 -0700 (PDT)
In-Reply-To: <20150326002154.3e179fec@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2015 at 4:21 PM, Jiri Benc <jbenc@redhat.com> wrote:
>
> On Wed, 25 Mar 2015 11:11:47 -0700, Mahesh Bandewar wrote:
> > On Wed, Mar 25, 2015 at 8:46 AM, David Miller <davem@davemloft.net> wrote:
> > > From: Jiri Benc <jbenc@redhat.com>
> > >> However, I'm wondering that when there's apparently no problem with the
> > >> addresses being on the hash list when interface is down, what's the
> > >> point in clearing the hash list in the ndo_stop handler and
> > >> repopulating it in ndo_open?
> > >>
> > >> The following patch fixes the problem, too, and as a bonus removes code:
> > >
> > > I'll let Mahesh reply to this.
> >
> > Yes functionally you will get the same result. However during the RX
> > processing, that code helps ipvlan-demux machine along with
> > packet-dispatcher to determine it early to drop the packet rather than
> > later.
>
> When the interface is down, this doesn't matter, does it? You don't
> send/receive anything when the interface is down. But this is actually
> not so important for the discussion, see below.
>
When the interface is down, you wont send but you might receive.

> > Also note that addition / deletion of address entries in
> > hash-table is done in control-path while the demux / dispatcher
> > operate in data-path. So for this reason I would prefer to leave the
> > hash-table entries addition / deletion as it is.
>
> I don't understand how the context in which the addresses are added is
> relevant to the problem at hand. The addresses are still added and
> removed in the control path whichever patch is applied.
>
I think you missed the point. Addition / deletion of addresses into
the hash-table (always) happens in the control path while the cost of
those decisions will be paid per packet in data-path; was the point I
was trying to make.

> Basically, there are two (and only two) possible cases: 1. the
> addresses should not be on the hash list when the interface is down,
> and 2. there's no problem with the addresses being on the hash list
> when the interface is down.
>
As I mentioned earlier in my previous reply; it does work and
functionally same. However the decision to drop the packet will happen
later in RX path when the interface is down.

> If 1. is true, than my first patch does exactly that. It ensures that
> the addresses are on the hash list if and only if the interface is up.
>
> If 2. is true, than my second patch does that. Addresses are added to
> the hash list on their addition to the interface and removed on their
> removal.
>
> The patch you sent (and the boolean flag David suggested) is actually
> kind of strange hybrid: when the interface is down, sometimes the
> addresses are on the hash list and sometimes not, depending on the
> order in which the user added them and brought the interface up/down.
>
The root cause of the issue is addition / deletion of duplicate
entries into the hash-table and I think fixing it is better thing
which is exactly what the fix I proposed do. Your first patch though
fixes the symptoms, I believe it's not the correct fix while your
second patch does fix it but eliminates this optimization that is in
place. Hence I suggested that  "though correct, I would not *prefer*
it" for the said reasons. If the order in which user pushes config
alters the hash-table entries, then that's unintended and need to be
fixed.

> Maybe I'm just missing some important piece of information, though, in
> which case it would help me if you could explain why these two
> operations are fundamentally different (assuming ipvlan0 is up at the
> beginning of each):
>
> ip a a 1.2.3.4/24 dev ipvlan0
> ip l s ipvlan0 down
> -> at this point, 1.2.3.4 is *not* on the hash list
>
Intended behavior.

> and
>
> ip l s ipvlan0 down
> ip a a 1.2.3.4/24 dev ipvlan0
> -> at this point, 1.2.3.4 is on the hash list
>
unintended behavior and need to be fixed.

> Please note that my first patch turns both consistently to the first
> result, my second patch turns both consistently to the second result.
>
Well, no one can force you to choose which patch to use to fix the
problem you are facing. I'm merely suggesting which fix is a better
fix with reasons (of course in my opinion). I don't see a point in
this proof / debate.

> Thanks,
>
>  Jiri
>
> --
> Jiri Benc
