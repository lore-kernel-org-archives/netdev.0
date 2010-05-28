From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Choppy TCP send performance
Date: Fri, 28 May 2010 15:57:02 -0700
Message-ID: <4C004A3E.3010500@hp.com>
References: <AANLkTilSrX5PifVHlxMjTK-wo_viD8IS_1m1k-vPOlE3@mail.gmail.com>	<1275081377.2472.13.camel@edumazet-laptop>	<AANLkTilZxoSEGOhmWdk2RbIGMmCMi2yNJm9rUwIzDIoL@mail.gmail.com>	<4C003EE5.6070602@hp.com> <AANLkTilBPOQIb7ua7hl89_EqH9nZdL0XA9Y9bN7fjEfh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Tim Heath <theath@greenplum.com>
To: Ivan Novick <novickivan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:27994 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817Ab0E1W5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 18:57:06 -0400
In-Reply-To: <AANLkTilBPOQIb7ua7hl89_EqH9nZdL0XA9Y9bN7fjEfh@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan Novick wrote:
> On Fri, May 28, 2010 at 3:08 PM, Rick Jones <rick.jones2@hp.com> wrote:
>>Histogram of time spent in send() call.
>>UNIT_USEC     :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
>>TEN_USEC      :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
>>HUNDRED_USEC  :    0:    2:    0:    0:    0:    7: 2672: 1831:   19:    1
>>UNIT_MSEC     :    0: 21811:    6:    0:    4:    0:    0:    0:    0:    0
>>TEN_MSEC      :    0:    1:    0:    0:    0:    0:    0:    0:    0:    0
>>HUNDRED_MSEC  :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
>>UNIT_SEC      :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
>>TEN_SEC       :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
>>
>>>100_SECS: 0
>>
>>HIST_TOTAL:      26354
>>
> 
> 
> I am not sure i understand your historgram output. 

For example, 21811 of the send() calls were 1 <= time < 2 milliseconds.  2672 of 
the send calls were 6 <= time < 7 hundred microseconds.  Etc etc.

> But what i am
> getting from your message is that my buffer may be too big.  If i
> reduce the buffer like you are saying down to 256K send buffer than
> the code that checks if select or send should block:
> 
>  if ((atomic_read(&sk->sk_wmem_alloc) << 1) <=
> sk->sk_sndbuf
> 
> Would only block waiting for space of 128 KB free as compared to 1 Meg
> free in my example.
> 
> Therefore reducing the max time for send calls (in theory).
> 
> Is this what you are getting at?

Yes.

As for the select/poll stuff, if you have a thread that wants to get to 
something else, I would suggest marking the socket non-blocking, trying the 
send(), if it completes cool, if not, remember what didn't get sent, do the 
other thing(s) and come back.  If you find you have time to sit and wait, go 
ahead and call select/poll/epoll/whatever.

Or, if you want to make sure you wait in poll/select/whatnot no more than N 
units of time, and that length of time is within the abilities of the call, use 
the timeout parameter present in those.

rick jones
