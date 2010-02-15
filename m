From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v4 4/7] tcp: input header length, prediction, and timestamp
 bugs
Date: Mon, 15 Feb 2010 14:03:34 -0500
Message-ID: <4B799A86.8040303@gmail.com>
References: <4B793CAA.2030902@gmail.com> <4B793E8F.30208@gmail.com> <20100215151055.GG21783@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f185.google.com ([209.85.223.185]:38936 "EHLO
	mail-iw0-f185.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755867Ab0BOTDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 14:03:39 -0500
In-Reply-To: <20100215151055.GG21783@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> On Mon, Feb 15, 2010 at 07:31:11AM -0500, William Allen Simpson wrote:
>> Don't use output calculated tp->tcp_header_len for input decisions.
>> While the output header is usually the same as the input (same options
>> in both directions), that's a poor assumption. In particular, Sack will
>> be different. Newer options are not guaranteed.
> 
> Is this a bug fix? 
> 
Yes.  One of many, all inter-related.

I don't know how much description folks want in the patch "summary", so
simply used declarative statements that are one-to-one with the order of
the patch, but it took me a bit to grok this problem!

1) unknown options can be stripped out of the header in middleware, see
RFC 1122 section 4.2.2.5.

2) new options Cookie Pair and 64-bit Timestamps (defined in patch 7).

3) stripping them leaves a Sack covering 1 segment, which has the exact
same word count as 32-bit Timestamps.  Boom!  All the silly checks
against the size of the options field (instead of the proper saw_tstamp)
start setting fields based on completely useless data!

4) and of course, using the size of the previous output to predict the
expected input header size is a poor assumption (to be generous).

There are 29+ options these days, not 4 or 5.  There are options that
are only sent one way.  There are options that have different data in
different directions.

Yes, it was originally for TCPCT, but fixes a broad spectrum of bugs.


>> Stand-alone patch, originally developed for TCPCT.
> 
> Normally it would be better to split this into smaller patches
> that do one thing at a time (typically this requires getting
> used to patch stack tools like "quilt")
> 
> But it's not too bad here.
> 
There are small efficiency patches included, but it would be likely
impossible to split them from the bug fixes without re-writing the same
code over and over again.  And I'm doing these patch splits by hand....

I did recently learn how to maintain branches that are branches on top of
each other, so I've got tcpct1, tcpct2, and tcpct3 for the 3 parts.  But
it's a pain to keep updated with git fetch, and checkout, and rebase,
for each branch.

At first, I was keeping a master patch set, and trying to maintain it
over .31, .32, and net-next, and now .33 -- but I gave up.


>>  static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)
>>  {
>> -	tp->pred_flags = htonl((tp->tcp_header_len << 26) |
>> +	tp->pred_flags = htonl((__tcp_fast_path_header_length(tp) << (28 - 2)) |
> 
> It would be better to use defines or sizeof for the magic numbers.
> 
I agree!  I was just following the existing coding style, trying to
improve understanding by splitting it into 28 (matches the shift
documented in the header file), and 2 (the doff field is actually the
number of 32-bit words).

These are field offsets in a 32-bit word, sizeof() wouldn't work.

It might be even better to have pred_flags be a union, but I didn't do
the original design for this code....

I'll add a nice block comment explaining the shift value here.


>> -	tp->rx_opt.saw_tstamp = 0;
>> -
>> -	/*	pred_flags is 0xS?10 << 16 + snd_wnd
>> -	 *	if header_prediction is to be made
>> -	 *	'S' will always be tp->tcp_header_len >> 2
>> -	 *	'?' will be 0 for the fast path, otherwise pred_flags is 0 to
>> -	 *  turn it off	(when there are holes in the receive
>> -	 *	 space for instance)
>> -	 *	PSH flag is ignored.
>> -	 */
> 
> I liked the comment at this place.
> 
The existing comment here didn't match the comment in the header file,
and both comments had errors.  Here, the 'S' is wrong.  Instead, it was
only '5' in the header file, among other errors.

It's easier to avoid bit-rot by defining in only one place, but I will
add a comment here saying "See linux/tcp.h for pred_flags details."


> 
> I did a quick review of the rest and it seems ok to me.
> 
> -Andi
> 
Thank you again.  As the fixes requested are merely adding comments,
I'll quickly re-spin this patch without reposting the entire patch set.
