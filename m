From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 5/5] net: Use netlink_ns_capable to verify the permisions
 of netlink messages
Date: Thu, 8 May 2014 14:49:11 -0700
Message-ID: <CALCETrWP_u+9Aw1Hf-7JWECP5mX55rUAp4bKRJf16jjo=0-+0w@mail.gmail.com>
References: <87d2g7d9ag.fsf_-_@x220.int.ebiederm.org> <536AB151.2070804@dti2.net>
 <CALCETrXL6eui802diSCrzNEtVcA5f3W58kFj6h4DYobm3YR_JQ@mail.gmail.com>
 <20140507.185256.496391962242529591.davem@davemloft.net> <CALCETrVo7ducU3S25Z_4NDB1p72pSLU0oLQh-ppxEWMgqYyjqQ@mail.gmail.com>
 <CA+55aFzZg3LfpPpx3+83sB0npd9863NTMqvsCArMDjg-9J151A@mail.gmail.com>
 <20140508142939.201b3e07@nehalam.linuxnetplumber.net> <CA+55aFzOHZcw2o6Cq6rSddSBDZvhgzYToBruak9SLCHxx-fA3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"security@kernel.org" <security@kernel.org>,
	Vivek Goyal <vgoyal@redhat.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Simo Sorce <ssorce@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Network Development <netdev@vger.kernel.org>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	David Miller <davem@davemloft.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f169.google.com ([209.85.220.169]:32962 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755461AbaEHVtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 17:49:32 -0400
Received: by mail-vc0-f169.google.com with SMTP id ij19so4111088vcb.14
        for <netdev@vger.kernel.org>; Thu, 08 May 2014 14:49:31 -0700 (PDT)
In-Reply-To: <CA+55aFzOHZcw2o6Cq6rSddSBDZvhgzYToBruak9SLCHxx-fA3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 8, 2014 at 2:41 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On May 8, 2014 2:29 PM, "Stephen Hemminger" <stephen@networkplumber.org>
> wrote:
>>
>> Ideally it should be able to not have to raise/lower on each send/recvmsg
>> call.
>
> Well, that's actually what the *new* semantics are: only raise them for the
> socket open, then the reads and writes well be done with the elevated
> privileges.
>
> Sadly, the thing apparently does exactly the reverse, which is wasteful
> _and_ now breaks with the fixed semantics.
>
> Annoying. We may have to revert the changes because of the regression, even
> though it sounds like the new semantics would actually be preferred for the
> very application that regresses...
>

The current code checks capabilities on socket *and* send{msg,to,}.  I
think is this because we were worried that dropping privilege might
stop working.

TBH, I'm starting to think that the real solution is to add a new syscall:

sys_net_ctl(int nl_proto, const void *intput, size_t inlen, void
*output, size_t outlen)

This sends a netlink message to the kernel and returns the response,
if any.  We could eventually deprecate the use of netlink sockets for
anything other than receiving notifications from the kernel and
dealing with netfilter logs, queues, and such.

Heck, the kernel tinification people might love this.

--Andy
