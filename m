From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Add TCP_NO_DELAYED_ACK socket option
Date: Wed, 26 Oct 2011 13:06:15 -0700
Message-ID: <4EA86837.60003@hp.com>
References: <fc8b00b9978b4f956fa705badfaa138854abf919.1319595687.git.luto@amacapital.net> <4EA849E7.5030503@hp.com> <CALCETrVcG=F6FrcQ3PhGz27t9+6jGh0TGACfVQ6CeUX=EjNsAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:6948 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511Ab1JZUGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 16:06:17 -0400
In-Reply-To: <CALCETrVcG=F6FrcQ3PhGz27t9+6jGh0TGACfVQ6CeUX=EjNsAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> If the networks where this happens are indeed truly private, can they run a
>> private kernel?  Or use an LD_PRELOAD hack to wedge-in a
>> setsockopt(TCP_NODELAY) call into the application?  Or set something like
>> tcp_naglim_def on the application system(s)?  Or have the server application
>> make a setsockopt(TCP_MAXSEG) call before listen() to a value one byte below
>> that of what the application is sending?
>
> We control our server.  We don't control the server at the other end.
> We've tried to get them to do any of the above, but they seem
> unwilling or unable to do it.  I suspect that they're using various
> pieces from various third-party vendors that just don't care.

Making the setsockopt(TCP_MAXSEG) would be at your end :)  Presumably 
based on the minimum message size.  That would cause the connection to 
have an MSS == the request size so every request send should take the 
"is this send plus any queued unsent data >= MSS" path.

Another "at your end" possibility would be setting a rather small 
SO_RCVBUF size at your end before calling listen(), in hopes of 
triggering the window update.

>> Is the application actually "virtuous" in sending logically associated data
>> in one "send" call, and simply running afoul of Nagle+DelayedACK in having
>> multiple distinct requests outstanding at once, or is it actually quite evil
>> in that it is sending logically associated data in separate send calls?
>>
>
> The remote application generates messages meant for us, and they
> appear to send each message in its own segment.  I don't have the
> source, so I don't know whether they're really using one send call per
> message or whether they're using MSG_MORE, TCP_CORK, so some other
> mechanism.  Each message is time-sensitive and should be received as
> soon as possible afterq its sent (i.e. one-half rtt).  Unfortunately,
> when they send two messages and we don't ack the first one, the second
> gets delayed.  Turning off delayed acks helps but does not completely
> solve the problem.

If it is write,write,read  (multiple sends per logical message) in a 
packet trace you should see a partial request in the first segment, 
followed by the rest of the request  (and perhaps the second through 
Nth) in the second segment.  Or, I suppose your server application would 
have a receive complete with the first part of the first request, 
getting the second part of the request in a subsequent receive call.

If it is multiple requests at a time each sent in one send call, you 
should see a first segment arriving with a complete request within it, 
followed by a second segment with the next request(s).

rick jones
