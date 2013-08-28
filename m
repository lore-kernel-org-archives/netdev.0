From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH] tipc: set sk_err correctly when connection fails
Date: Wed, 28 Aug 2013 09:32:05 +0800
Message-ID: <521D5315.9060608@windriver.com>
References: <1377266200-26691-1-git-send-email-erik.hugne@ericsson.com> <521CA797.2010109@windriver.com> <20130827151841.GE1939@eerihug-hybrid.rnd.ki.sw.ericsson.se> <521CEBF7.4040103@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<jon.maloy@ericsson.com>, <tipc-discussion@lists.sourceforge.net>,
	<nhan.tt.vo@dektech.com.au>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:52356 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884Ab3H1Bc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 21:32:27 -0400
In-Reply-To: <521CEBF7.4040103@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/2013 02:12 AM, Paul Gortmaker wrote:
> On 13-08-27 11:18 AM, Erik Hugne wrote:
>> On Tue, Aug 27, 2013 at 09:20:23AM -0400, Paul Gortmaker wrote:
>>> What was the high level user visible symptom in this case?
>>> Stalled connections or ... ?
>>
>> Should the connect fail, if the publication/server is unavailable or some other
>> error. The connect() call returns the error code directly (as a positive value).
> 
> Please send a v2 with the end-user visible symptom clearly described;
> as this information is what people use in order to triage whether
> commits belong in stable, or net vs. net-next etc.   For example:
> 
>   Should the connect fail, say if the publication/server is unavailable or
>   some other error, then the code returns a positive return value.  Since
>   most code only checks for a negative return on connect(), it tries to
>   continue, but will ultimately fail on the 1st sendto() as the strace
>   snippet below shows.
> 
> I've said "most code" since I simply don't know what it was that you were
> tracing below.  It would help if we knew if this part of a common application
> or similar.
> 

Firstly it's absolutely wrong that connect() returns a positive error
code - 111(i.e, ECONNREFUSED) if connect() is failed, that is, it
violates POSIX standard.

As the patch's changelog describes, sk_err is incorrectly set to a
negative value instead of positive value in filter_connect(). In
connect(), it will set its return value with sock_error(sk) if it fails.
As the return value of sock_error(sk) almost can be deemed as -sk_err,
this is why we see a positive error code of connect() in below strace log.

But, the patch is absolutely able to fix the issue.

Regards,
Ying

> Thanks,
> Paul.
> --
> 
>>
>> [...]
>> socket(0x1e /* PF_??? */, SOCK_SEQPACKET, 0) = 3
>> setsockopt(3, 0x10f /* SOL_?? */, 129, [0], 4) = 0
>> setsockopt(3, 0x10f /* SOL_?? */, 127, [0], 4) = 0
>> connect(3, {sa_family=0x1e /* AF_??? */, sa_data="\2\1\322\4\0\0\322\4\0\0\0\0\0\0"}, 16) = 111
>> sendto(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 66000, 0, NULL, 0) = -1 EPIPE (Broken pipe)
>>
>> In the strace above, error checking was done as:
>> if (connect(fd,.....) < 0)
>>     perror("connect");
>>
>> //E
>>
> 
> 
