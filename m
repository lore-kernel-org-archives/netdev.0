From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 0/2] handle_ing update
Date: Sun, 10 May 2015 10:55:23 -0700
Message-ID: <554F9B8B.30306@plumgrid.com>
References: <cover.1431203900.git.daniel@iogearbox.net> <20150510170550.GA4442@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jhs@mojatatu.com, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:35300 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbbEJRz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 13:55:26 -0400
Received: by ieczm2 with SMTP id zm2so93952450iec.2
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 10:55:26 -0700 (PDT)
In-Reply-To: <20150510170550.GA4442@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/10/15 10:05 AM, Pablo Neira Ayuso wrote:
> On Sat, May 09, 2015 at 10:51:30PM +0200, Daniel Borkmann wrote:
>> These are a couple of cleanups to make ingress a bit more lightweight.
>
> This is plain wrong at many levels.
>
> You're persisting on embedding the ingress code into the core, and you
> have to remember that most users don't need this. Modules allows
> people to get the code that they need into the core, with this
> approach, they have no other choice other than disable from .config
> this if they don't need it.

I think you're misreading the patch set. Where do you see that this is
pushed on all users?
if (static_key_false(&ingress_needed))
still protects all of these bits.
When ingress qdisc is added, the key gets enabled and it only needs
one deref to not go any further. Much faster than it is today.

> This has to be done the other way around. I just sent a patchset to
> clean up this that in exactly the other direction, as a result,
> performance is improved for users that don't need this.

you're doing exactly the same in your patch set, but with added extra
overhead for netfilter hook.

> We should do things to make users aware that when they request
> features, they have to pay a performance cost, and that happens by
> when you invoke:
>
>          tc qdisc add dev eth0 handle ffff: ingress
>
> David already stated before that ingress path is performance critical,
> but you insist on trying to get qdisc ingress faster *at any cost*.

Nope. We're cleaning up ingress qdisc path _without_ affecting anything
else, whereas your netfilter hook creates binary choice for users
whether they want nft or tc.
Please just add your own netfilter hook to netif_receive_skb and
let's be done with this back and forth arguments.
