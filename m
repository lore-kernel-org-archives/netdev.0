From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 5/5] net: Use netlink_ns_capable to verify the permisions of netlink messages
Date: Fri, 23 May 2014 16:25:09 -0700
Message-ID: <87ioow6pt6.fsf@x220.int.ebiederm.org>
References: <87d2g7d9ag.fsf_-_@x220.int.ebiederm.org>
	<536AB151.2070804@dti2.net>
	<CALCETrXL6eui802diSCrzNEtVcA5f3W58kFj6h4DYobm3YR_JQ@mail.gmail.com>
	<20140507.185256.496391962242529591.davem@davemloft.net>
	<CALCETrVo7ducU3S25Z_4NDB1p72pSLU0oLQh-ppxEWMgqYyjqQ@mail.gmail.com>
	<CA+55aFzZg3LfpPpx3+83sB0npd9863NTMqvsCArMDjg-9J151A@mail.gmail.com>
	<CALCETrVWkW16Y7hOq-mA1auJjRXmwiAUfAGurK0-2bOdbZu_dA@mail.gmail.com>
	<20140522170505.64ef87a2@griffin>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andy Lutomirski <luto@amacapital.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	"Jorge Boncompte \[DTI2\]" <jorge@dti2.net>,
	Vivek Goyal <vgoyal@redhat.com>,
	Simo Sorce <ssorce@redhat.com>,
	"security\@kernel.org" <security@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:36241 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbaEWX0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 19:26:04 -0400
In-Reply-To: <20140522170505.64ef87a2@griffin> (Jiri Benc's message of "Thu,
	22 May 2014 17:05:05 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Benc <jbenc@redhat.com> writes:

> On Wed, 7 May 2014 16:45:10 -0700, Andy Lutomirski wrote:
>> It looks like Zebra is mucking with its effective set.  It creates the
>> socket w/o effective caps, raises them to bind (no clue why), lowers
>> them post-bind, then raises them again to sendto.  Presumably the new
>> checks cause the sendto to fail b/c the socket()-time credentials were
>> insufficient.
>> 
>> I don't see why it bound w/ elevated permissions, since I don't think
>> this is important.  And it never connected at all.
>> 
>> Hence my suggestion that we check permissions at connect time instead
>> of socket() time and that we just check send-time permissions on an
>> unconnected socket.  Yes, this is awful.
>
> AFAIK this is still unresolved and this seems to be the only solution
> proposed so far that fixes the security problem and does not break
> zebra. Or have I missed something and the conclusion is zebra needs to
> be modified to comply with the changed semantics?

I have not seen consensus that what Zebra is doing makes sense to
support.

What Zebra is doing (opening a socket without privilege and then sending
privileged messages over that socket) smells.  This is effecting
performing trusted operations over an untrusted channel.

I can not see why that would ever be a desirable application
architecture.

There is also historical precedent for what the kernel is doing as it is
effectively checking SO_PEERCRED.

Furthermore I have not seen even a bad implementation of a way to
remember who called connect, and the possibility of needing different
permission checks for send vs sendto makes any implementation I can
think of nasty and ugly.  Which generally translates into complicated
and not secure.

So short of someone having a better idea it looks like Zebra is broken
until it is patched to open sockets with privilege when Zerbra is going
to send privileged messages over those sockets.

Eric
