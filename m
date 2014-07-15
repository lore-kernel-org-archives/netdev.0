From: Karl Heiss <kheiss@gmail.com>
Subject: Re: IPSEC: tunnel breakage with out-of-order IPv4 fragments
Date: Tue, 15 Jul 2014 08:13:01 -0400
Message-ID: <CAGugRbXgAqO_qJRemfaYMM6+WE+nRnfU0LK3DkpBpSOwOkcD0Q@mail.gmail.com>
References: <CAGugRbVWyTM2J0Fyw1Cq1byqfjZBy_EFLSShqVdzxYZmmUWK_g@mail.gmail.com>
	<20140711110035.GB6633@secunet.com>
	<CAGugRbWPOyWLrdiTqtScWi2JTKeyEEjOLRvDUqx20SG7uXifLw@mail.gmail.com>
	<20140714093345.GC6633@secunet.com>
	<CAGugRbWL8Orkobwt4FENyswLsm1jWLBMdr-WJ6mCBhVn-xGwXw@mail.gmail.com>
	<20140715091613.GD6633@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:42582 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758321AbaGOMNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 08:13:01 -0400
Received: by mail-ig0-f170.google.com with SMTP id h3so2732198igd.3
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 05:13:01 -0700 (PDT)
In-Reply-To: <20140715091613.GD6633@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 5:16 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Mon, Jul 14, 2014 at 07:52:23AM -0400, Karl Heiss wrote:
>> On Mon, Jul 14, 2014 at 5:33 AM, Steffen Klassert
>> <steffen.klassert@secunet.com> wrote:
>> >
>> > Your tcpdump looks interesting. Is it possible that all your
>> > fragmented packets have the id field set to 'id 0'? This should
>> > be only the case if the DF flag is set on that packet, but this
>> > is apparently not the case here. If all the fragmented packets
>> > have id 0, it is not possible to determine the correct fragment
>> > chain. If only one fragment gets lost, all further packets might
>> > be reassembled wrong.
>> >
>>
>> Yes, all fragments have 'id 0'.
>>
>> > When looking at the code, is seems that sctp sets the DF flag
>> > on packets as the default. The IPsec encapsulation code copies
>> > the DF bit from the inner header and sets 'id 0' in this case.
>> > A first guess would be that someone removes the DF flag after
>> > the IPsec encapsulation.
>> >
>> > Is the DF flag set on your inner sctp packets?
>> >
>>
>> Yes, the inner packets have DF set, but the outer do not.
>
> So we need to find where the DF flag disappears.

I feel like we may be focusing on two different things.  I am more
interested in figuring out why the receive side does not handle these
packets gracefully.  I would assume that the missing/reordered
fragments may not get reassembled correctly and would be dropped,
which is OK.  However, it is when this event occurs and then every
subsequent, correctly ordered, fragmented packet is dropped that I am
concerned about.  While the sender may be in a broken state, the
receiver should be consistent with receive behavior, agreed?

>
> I tried to reproduce your issue with the current net tree,
> but I was not able to do so.
>
> With the plain net tree, all packets have the DF flag set
> (sctp and esp), no fragments.
>
> With the net tree and commit c08751c851b78514f6ec5 reverted,
> I have some packets with the DF flag and some without. The
> packets without the DF flag got fragmented after IPsec
> processing. But even in this case, the ESP packet has the
> DF flag set whenever the inner sctp packet has it set.
> And also, the DF flag is set whenever a packet has 'id 0'.
> The fragmented packets never have the 'id 0'.

Fragmented packets never having 'id 0' is probably fixed due to
703133de331a7a7df47f31f (ip: generate unique IP identificator if local
fragmentation is allowed).  Sounds like I need to come up with more
detail on the sending side for better recreation (see below).

>
> Can you describe your usecase more precisely? Do you use
> any additional tunnel like ipip/gre etc. or packet mangling?

I apologize, I did leave out one critical bit of information in that
the sender is based on a RHEL 6.5 kernel with a backported 3.4.75 SCTP
stack.  As for other mangling or anything else, the case is as
straightforward as originally described.  I will try and see if I can
find which combination of commits need to be removed to allow this
case on the sending side.  I didn't think to elaborate on the sending
side as I was solely concentrating on the receive aspect :(
