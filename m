From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2] pedit action: add mask for changing bits.
Date: Tue, 28 Feb 2012 08:05:08 -0500
Message-ID: <1330434308.2369.11.camel@mojatatu>
References: <CAEzD07+0EA12igqAcwbM8VGKLR9Hp0GjJ7t_Jve=JXOrEKvu9w@mail.gmail.com>
	 <1330351135.2384.1039.camel@mojatatu>
	 <CAEzD07KenHteg0S8-OfAwqTNTSQdvPOJsA-m_+8CW-8c_HCgnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:41933 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756897Ab2B1NFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 08:05:14 -0500
Received: by ggnh1 with SMTP id h1so2495169ggn.19
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2012 05:05:14 -0800 (PST)
In-Reply-To: <CAEzD07KenHteg0S8-OfAwqTNTSQdvPOJsA-m_+8CW-8c_HCgnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Anton,

Thinking about this some more:
Did you try the "retain" option? it is the xor mask to set operation.

Examples:
----
#At offset 3 retain the first nibble but set the second to 0xA
action pedit munge offset 3 u8 set 0xA0 retain 0xF
#At offset 9, retain the second nibble but set the first to 0xA
action pedit munge offset 9 u8 set 0x0A retain 0xF0
---

So if you were to point to the nibble holding the cos field
in your match, then you can set it to a new value while retaining
bitfields you dont want to change...

I was going to ask you to test the retain in addition to the
extra mask you are adding on different sets - but i am beginning 
to think the mask you are adding is not needed at all.

Here is an example of other tests i was going to ask you to 
run (this time with 16bit field):

#At offset 0, invert/clear/preserve the first 16 bits
action pedit munge offset 0 u16 invert

original data:
45000054 00004000 40013ca7 7f000001
modified data (invert):
baff0054 00004000 40013ca7 7f000001
modified data (clear):
00000054 00004000 40013ca7 7f000001
retain
45000054 00004000 40013ca7 7f000001
set 0x1234
12340054 00004000 40013ca7 7f000001

You can pipe to a mirror action to send to dummy0 and then run tcpdump
on dummy to watch the edited fields. I can describe a simple setup
i use if this still doesnt make sense.

As a side note: I think we need an action to work on VLANs since
they are such an important field. The action would push/pop and edit
VLAN fields. If you are interested in this, I can help provide guidance
(It is one of those things on my todo longtimenow but i cant seem to get
around to it).

cheers,
jamal


cheers,
jamal

On Mon, 2012-02-27 at 17:15 +0300, Anton 'EvilMan' Danilov wrote:
> Hi, Jamal.
> 
> 2012/2/27 jamal <hadi@cyberus.ca>:
> >
> > Looks like a reasonable feature to have - but it has to continue working
> > as before for things that dont need the mask.
> >
> >>
> >> diff --git a/tc/m_pedit.c b/tc/m_pedit.c
> >> index 7499846..f081eff 100644
> >> --- a/tc/m_pedit.c
> >> +++ b/tc/m_pedit.c
> >
> >>
> >>       tkey->val = htonl(tkey->val & retain);
> >> -     tkey->mask = htonl(tkey->mask | ~retain);
> >> +     tkey->mask = htonl(~tkey->mask | ~retain);
> >
> > A change like the above worries me that this may work for your use case
> > but will break other things that used to work. I'd like to run some
> > tests but dont have the cycles for the next few days. Alternatively, I
> > could explain some tests to you and you could validate and fix whatever
> > breaks.
> > Let me know what is best for you.
> >
> 
> Can You explain tests to me? I'll check behavior with my changes and fix breaks
> 
> 
