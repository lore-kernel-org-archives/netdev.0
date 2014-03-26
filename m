From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return -EINTR
Date: Wed, 26 Mar 2014 13:57:46 +0000
Message-ID: <87ha6l83l1.fsf@sable.mobileactivedefense.com>
References: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
	<8761n19k0w.fsf@sable.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:46483 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753716AbaCZN56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 09:57:58 -0400
In-Reply-To: <8761n19k0w.fsf@sable.mobileactivedefense.com> (Rainer Weikusat's
	message of "Wed, 26 Mar 2014 13:17:18 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rainer Weikusat <rw@sable> writes:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Some applications didn't expect recvmsg() on a non blocking socket
>> could return -EINTR. This possibility was added as a side effect
>> of commit b3ca9b02b00704 ("net: fix multithreaded signal handling in
>> unix recv routines").
>>
>> To hit this bug, you need to be a bit unlucky, as the u->readlock
>> mutex is usually held for very small periods.

[...]

> the function was interrupted before any data was available and it
> is unknown if the condition supposed to be signalled by EAGAIN had
> otherwise occurred.

Further explanation of the difference:

do
	rc = recv(...);
while (rc == -1 && errno == EINTR);

is 'usually sensible code' while

do
	rc = recv(...);
while (rc == -1 && errno == EAGAIN);

usually isn't: One is a one-off event not expected to occur again
'soon', the other implies that "do something else for a while" would be
advisable. In particular, EAGAIN usually shouldn't happen after 'data is
available now' was signalled by select/ poll/ $you_name_it and while it
would be prudent to handle it nevertheless (especially considering that
Linux doesn't necessarily behave in this way), there are doubtlessly
applications 'unprepared' for that, too.
