From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH v3 1/7] Only parse time stamp TCP option in time wait
 sock
Date: Wed, 28 Oct 2009 12:14:43 +0200
Message-ID: <4AE81993.5090706@codefidence.com>
References: <1256544393-12450-1-git-send-email-gilad@codefidence.com> <1256544393-12450-2-git-send-email-gilad@codefidence.com> <4AE5D4AE.2080108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ori@comsleep.com,
	Yony Amit <yony@comsleep.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:37319 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbZJ1KOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 06:14:47 -0400
In-Reply-To: <4AE5D4AE.2080108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi William,


William Allen Simpson wrote:

> Gilad Ben-Yossef wrote:
>> Since we only use tcp_parse_options here to check for the exietence
>> of TCP timestamp option in the header, it is better to call with
>> the "established" flag on.
>>
> Please explain how this patch is required for the other patches?
Gladly (and suggestions to do it differently are welcome) :

For the purpose of the patch tcp_parse_options was changed to consult 
dst_entry options when parsing non established packets.

This means that for any place that we call tcp_parse_options with the 
established parameter set to false, we need to supply it with a dst_entry.

In all other locations in kernel code when tcp_parse_options is called 
such a dst_entry is easily available already.

The time wait mini socket exists so that we would not waste resource 
keeping around the full socket state of a "real socket". As such, it 
does not cache the dst_entry. Adding it to the TIME_WAIT mini sockets 
jsut for this purpose defeats the purpose of having a mini socket in the 
first place.

One other possible way to go about it is to re-compute the dst_entry at 
this location, but this seemed an expensive operation to perform for 
what should be a light weight operation. I asked myself if there might 
be another way?

So I took a good look at the code and discovered that there is no need 
to call tcp_parse_options there in "non established" mode at all.
>
> And more importantly, why it is better to call with established on?
Sure. This is kind of long written down, although it's really simple. I 
will try to describe it as best I can.

Take a look at what tcp_parse_options() does as a function -

It has only one output: changing the fields of the tcp_options_received 
struct  which it gets a pointer to as a parameter. It also has a single 
side effect: it updates the  SKB TCP control block sacked field, if a 
SACK option is detected in the packet header.

Its behavior is dictated by the established parameter. If false, it will 
try to parse all supported TCP options, if found in the packet header. 
If true it will only try to parse the time stamp and SACK options.

Now take a look what happens at tcp_timewait_state_process() when we 
call tcp_parse_options() -

We allocate (on stack) a temporary tcp_options_received struct, and if 
our TIME_WAIT mini socket had recent timestamp data 
(tcptw->tw_ts_recent_stamp), we call tcp_parse_options() with our 
temporay tcp_options_received struct.

Here is the important bit:  we never ever look at anything in the 
tcp_options_received struct after the call returns, except for the time 
stamp data if it is available!

So, passing established as false here makes us try to parse, if found in 
the packet, a bunch of options that we never ever look at the result of. 
(The fact that time wait minisocket  code also zeros the saw_tstamp 
before the call to tcp_parse_options although the same field is being 
zeroed again inside the function is just icing on the cake...)

I have one more issue to explain, and this is regarding the single side 
effect tcp_parse_option has - if the SACK option is found, 
tcp_parse_options updates the skb control block sacked field. However, 
not that it does this regardless of whether established is true or 
false, so it doesn't matter which we pass. (I will leave out the fact 
that whether or not the SACK option is parsed depends on a non 
initialized field of the tcp_options_received struct now as an obscure 
detail... nothing obviously looks at that later).

So bottom line: passing a true value in established does the exact same 
thing, result wise, as current code, except it does so in fewer cycles.

I do confess to having goofed here in one regard: the patch I posted did 
not set the tstamp_ok field of the tcp_options_received struct, which 
can lead to randomly not parsing the time stamp option even when you 
need to.

Perhaps this is what masks my intent. This is a bug of course and I'm 
grateful for you for helping me catch it :-)

I will send an updated patch set with this fixed ASAP.

> And most importantly, what end cases you considered, and how this
> interacts with the proposed rfc1323bis changes, especially on reset?
>
My whole point was that this "change" does not change the behavior of 
the code in any way. In fact, it is no different then a compile time 
optimization (don't execute code paths nothing later uses the result 
thereof) and if the compiler was smart enough, it would have done the 
same. So corner cases and RFC compliance stay exactly as before.

I hope I managed to explain myself better this time around and thanks 
again for taking the time to review this. ;-)

Gilad

-- 
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
Fax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxology.net

	"The biggest risk you can take it is to take no risk."
		-- Mark Zuckerberg and probably others

