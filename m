From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: fixes for DSACK-based undo of cwnd reduction during
 fast recovery
Date: Tue, 15 Nov 2011 00:00:45 -0500
Message-ID: <CADVnQykYW1kBopj2qpy8gt4gWejn+2k2YJg-UDHZ8uUxBXw5Zw@mail.gmail.com>
References: <1320775631-16341-1-git-send-email-ncardwell@google.com>
	<20111114.152359.1131974895743731960.davem@davemloft.net>
	<CADVnQyn7czRocYV3-goTtwqCDg9MBv+bTHeZ-A8R4n45LH8L=g@mail.gmail.com>
	<alpine.DEB.2.00.1111150333360.24223@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, nanditad@google.com,
	ycheng@google.com, therbert@google.com
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:42072 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667Ab1KOFAr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 00:00:47 -0500
Received: by vws1 with SMTP id 1so5889352vws.19
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 21:00:46 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1111150333360.24223@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2011 at 9:05 PM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
> On Mon, 14 Nov 2011, Neal Cardwell wrote:
>
>> On Mon, Nov 14, 2011 at 3:23 PM, David Miller <davem@davemloft.net> =
wrote:
>> > From: Neal Cardwell <ncardwell@google.com>
>> > Date: Tue, =A08 Nov 2011 13:07:11 -0500
>> >
>> >> (2)
>
> When you need to say "fixes 1), 2), and 3)", please stop for a moment
> thinking if the fixes really need to be sent as one fix or 3 fixes (a
> series PATCH x/3, see netdev for examples). It would make review much
> simpler if unrelated fixes are not put together even if all of them
> would be needed to get DSACK working as intented.

I'm happy to split this patch into a few smaller patches. I was on the
fence about how fine-grained to make them; I'll make them smaller.

>> >> =A0When the ACK field is below snd_una (the "old_ack" goto label)=
,
>> >> process any DSACKs and try to send out more packets based on
>> >> newly-SACKed packets.
>> >
>> > This seems dubious.
>
> Indeed. However, there's nothing wrong in the processing of DSACKs no=
r
> SACKs in the given case but we lack call to tcp_fastretrans_alert. Bu=
t the
> commit message does not say that, in fact, I failed to understand wha=
t 2)
> tried to say as I knew that DSACK and SACK processing itself is ok an=
d
> done (it also mixes "DSACKs"/"SACKed" illogically). This commit messa=
ge
> must be fixed so that guys who read it later won't get confused too. =
BUT
> I'd on the same time split the whole fix to 3 different patches unles=
s
> there's some very good reason why the changes are interlocked so that=
 the
> splitting is not possible.

I will attempt to make the commit messages more clear as I split up
the patch into smaller patches.

>> > An older ACK should not have more uptodate SACK information than a=
 newer
>> > ACK.
>
> This is not true with DSACK that are not cumulative. And also the
> reported SACK state is cumulative up to a limit.
>
>> I grant that it is a rare corner case, but it is possible if there i=
s
>> reordering and packet loss in both directions.
>>
>> In fact, AFAICT the code path to handle this corner case is already
>> there: AFAICT we call tcp_sacktag_write_queue() in the old_ack code
>> path exactly because it is possible for old ACKs to carry SACK range=
s
>> that we haven't seen yet.
>
> I agree. ...And also DSACKs that can only be seen in that particular =
ACK.
>
>> Let me try to lay out a specific example:
>>
>> Suppose a sender sends packets 1-12, and there is lots of loss and
>> reordering in both directions.
>>
>> Suppose the receiver sends the following ACKs with SACK blocks, in t=
he
>> following order (using packet numbers rather than sequence numbers):
>>
>> (1) ack 1, sack <3-4>
>> (2) ack 1, sack <3-4 6>
>> (3) ack 1, sack <3-4 6 8>
>> (4) ack 1, sack <3-4 6 8 10>
>> (5) ack 1, sack <6 8 10 12>
>> (6) ack 2, sack <6 8 10 12>
>>
>> Note that starting at ACK (5) the receiver is limited by the fact th=
at
>> TCP options can only hold 4 SACK ranges, so the SACK for 3-4 "falls
>> off" the SACK block set.
>>
>> Now suppose the ACKs are reordered, and some are dropped, so that th=
e
>> sender receives the ACKs in this order:
>>
>> (6) ack 2, sack <6 8 10 12>
>> (1) ack 1, sack <3-4>
>>
>> The arrival of (6) advances snd_una to 2. Now the question is what t=
o
>> do when (1), with an ACK field below snd_una, arrives at the
>> sender. The existing code tags packets 3-4 as SACKed, but does not u=
se
>> this newly SACK-tagged data to send out new data. This commit propos=
es
>> to use the newly SACK-tagged 3-4 to send out new data.
>
> Contrary to your commit message, new data sending is already done out=
side
> of tcp_ack() in tcp_data_snd_check?

If my commit message seemed to be talking about sending new data, then
it was only because of a lack of clarity. Where the commit message
referred to "more packets" I meant either new/untransmitted data or
retransmitted data. I will try to make this more clear.

> ...It's tcp_fastretrans_alert call
> that is lacking so no rexmits could be done currently?

Yes, in terms of missing some opportunities for SACKs to trigger
sends, the tcp_fastretrans_alert call is basically all that's lacking.

> In addition, this given scenarios was not DSACK related!?! I think yo=
ur
> commit message is just bogus discussing (only) DSACK processing for t=
his
> case.

Case 2)/(2) in the commit message does mention both DSACK and SACK
processing for this case. Or maybe you are referring to one of the
other cases? I don' think SACK processing applies to the other cases.

In any case, I'm hoping this will all be more clear once I split up
the patch into smaller pieces, and do a little wordsmithing on the
commit messages. I'll be sending this out soon.

Thanks to both of you for taking a look at this.

neal
