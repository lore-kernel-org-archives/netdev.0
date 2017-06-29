From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 0/2] kproxy: Kernel Proxy
Date: Thu, 29 Jun 2017 16:43:28 -0700
Message-ID: <CALx6S36rQAe=yWAd_K4fnNGNgZ-gQbQ6K_p8RDmN+5CsKGogsQ@mail.gmail.com>
References: <1498760825-8516-1-git-send-email-tom@herbertland.com>
 <20170629195402.GA10048@1wt.eu> <CALx6S369XPs_6Ap9H8yZCW+XL1pAbJx9XhNdpZ36hpQCEvs-3w@mail.gmail.com>
 <20170629205806.GA10285@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33126 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751333AbdF2Xna (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 19:43:30 -0400
Received: by mail-wr0-f196.google.com with SMTP id x23so37966067wrb.0
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 16:43:29 -0700 (PDT)
In-Reply-To: <20170629205806.GA10285@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 29, 2017 at 1:58 PM, Willy Tarreau <w@1wt.eu> wrote:
> On Thu, Jun 29, 2017 at 01:40:26PM -0700, Tom Herbert wrote:
>> > In fact that's not much what I observe in field. In practice, large
>> > data streams are cheaply relayed using splice(), I could achieve
>> > 60 Gbps of HTTP forwarding via HAProxy on a 4-core xeon 2 years ago.
>> > And when you use SSL, the cost of the copy to/from kernel is small
>> > compared to all the crypto operations surrounding this.
>> >
>> Right, getting rid of the extra crypto operations and so called "SSL
>> inspection" is the ultimate goal this is going towards.
>
> Yep but in order to take decisions at L7 you need to decapsulate SSL.
>
Decapsulate or decrypt? There's a big difference... :-) I'm am aiming
to just have to decapsulate.

>> HTTP is only one use case. The are other interesting use cases such as
>> those in container security where the application protocol might be
>> something like simple RPC.
>
> OK that indeed makes sense in such environments.
>
>> Performance is relevant because we
>> potentially want security applied to every message in every
>> communication in a containerized data center. Putting the userspace
>> hop in the datapath of every packet is know to be problematic, not
>> just for the performance hit  also because it increases the attack
>> surface on users' privacy.
>
> While I totally agree on the performance hit when inspecting each packet,
> I fail to see the relation with users' privacy. In fact under some
> circumstances it can even be the opposite. For example, using something
> like kTLS for a TCP/HTTP proxy can result in cleartext being observable
> in strace while it's not visible when TLS is terminated in userland because
> all you see are openssl's read()/write() operations. Maybe you have specific
> attacks in mind ?
>
No, just the normal problem of making yet one more tool systematically
have access to user data.

>> > Regarding kernel-side protocol parsing, there's an unfortunate trend
>> > at moving more and more protocols to userland due to these protocols
>> > evolving very quickly. At least you'll want to find a way to provide
>> > these parsers from userspace, which will inevitably come with its set
>> > of problems or limitations :-/
>> >
>> That's why everything is going BPF now ;-)
>
> Yes, I knew you were going to suggest this :-)  I'm still prudent on it
> to be honnest. I don't think it would be that easy to implement an HPACK
> encoder/decoder using BPF. And even regarding just plain HTTP parsing,
> certain very small operations in haproxy's parser can quickly result in
> a 10% performance degradation when improperly optimized (ie: changing a
> "likely", altering branch prediction, or cache walk patterns when using
> arrays to evaluate character classes faster). But for general usage I
> indeed think it should be OK.
>
HTTP might qualify as a special case, and I believe there's already
been some work to put http in kernel by Alexander Krizhanovsky and
others. In this case maybe http parse could be front end before BPF.
Although, pretty clear we'll need regex in BPF if we want use it with
http.

Tom
