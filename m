From: Christian Seiler <christian@iwakd.de>
Subject: Re: [PATCH] net: add =?UTF-8?Q?SO=5FMAX=5FDGRAM=5FQLEN=20for=20AF?=
 =?UTF-8?Q?=5FUNIX=20SOCK=5FDGRAM=20sockets?=
Date: Tue, 03 Mar 2015 10:04:10 +0100
Message-ID: <0b5908020d83bcbaa7f4938e5cb433ea@iwakd.de>
References: <1425342774-32667-1-git-send-email-christian@iwakd.de>
 <20150302.213807.367185406305242762.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <dan@mindstab.net>,
	<edumazet@google.com>, <hannes@stressinduktion.org>,
	<linux-api@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arafel.iwakd.de ([78.46.72.57]:50259 "EHLO arafel.iwakd.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753375AbbCCJEN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 04:04:13 -0500
In-Reply-To: <20150302.213807.367185406305242762.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 2015-03-03 03:38, schrieb David Miller:
>> Rationale: applications may want to control how many datagrams the
>> kernel buffers before senders are blocked. A prominent example would 
>> be
>> to create a socket for syslog early at boot but only consume 
>> messages
>> once enough of the system has been set up. The default queue length 
>> of
>> 11 messages (= 10 + 1) is too low for this kind of application.
>
> I never like arguments that talk about forcing the kernel to do
> excessive buffering for an application.
>
> Queue this stuff in the userspace side, then you can have as many
> messages backlogged as you like _without_ consuming unswappable 
> kernel
> memory.
>
> I'm tossing this, you're going to have to do a much better job
> explaining to me why userspace cannot take upon itself the burdon of
> queueing data until it can be sent.

There are certain things that can't be done in userspace:

  - If SO_PASSCRED is active, a userspace process relaying the messages
    can't fake the PID of the original process unless that one is still
    around (sendmsg will return -ESRCH). Also, one needs CAP_SYS_ADMIN
    to do this (and CAP_SETUID/CAP_SETGID to fake uid/gid as well).

  - More importantly, timestamps of messages can't be faked at all. So
    in the example of a socket used for syslog purposes, all the
    timestamps on the messages queued would be wrong.

Also note that if I have a stream socket, by default I can buffer up to
256 kiB of data in the kernel. I did some test measurements on x86_64
and including overhead of internal bookkeeping structures, I can fit up
to 555 datagrams in there if each is at most 192 bytes long, at least
333 datagrams if each is at most 704 bytes long and at least 185
datagrams if each is at most 1728 bytes long. If I compare these
numbers to 11, that's an order of magnitude in difference.

I'm not asking to be able to use a lot of memory, I'm just asking to be
able to raise an artificial limit that doesn't apply to other types of
sockets.

Finally, increasing the queue length is not the only use case, some
applications might want to decrease it. For example, if the value is
set to zero, only a single datagram can be queued at a time (and all
else blocks or fails with -EAGAIN), which might be interesting if the
application processing the datagrams takes a long time to do so for
each one of them.

Christian
