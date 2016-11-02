From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next v2] ipv4: fib: Replay events when registering
 FIB notifier
Date: Wed, 2 Nov 2016 15:44:53 +0200
Message-ID: <20161102134453.ij5d4fdcmmlvnkzy@splinter>
References: <1477948427-9189-1-git-send-email-idosch@idosch.org>
 <1477949046.7065.320.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161031225737.7nfoy4ka3ydzhptq@splinter>
 <1478009999.7065.334.camel@edumazet-glaptop3.roam.corp.google.com>
 <5818B146.20209@cumulusnetworks.com>
 <20161101170345.pq2ewecw35mrurkp@splinter>
 <58194BD6.5040406@cumulusnetworks.com>
 <20161102072032.GA1713@nanopsycho.orion>
 <CAJieiUjGHX0C7mG3Y8m2VZHPPq=Rz-2D8e_L9ZASi-bCs8nJJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>, mlxsw <mlxsw@mellanox.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        alexander.h.duyck@intel.com,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Ido Schimmel <idosch@mellanox.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:48821 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751795AbcKBNo4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 09:44:56 -0400
Content-Disposition: inline
In-Reply-To: <CAJieiUjGHX0C7mG3Y8m2VZHPPq=Rz-2D8e_L9ZASi-bCs8nJJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 02, 2016 at 06:29:40AM -0700, Roopa Prabhu wrote:
> On Wed, Nov 2, 2016 at 12:20 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> > Wed, Nov 02, 2016 at 03:13:42AM CET, roopa@cumulusnetworks.com wrote:
> >>
> [snip]
> 
> >>I understand..but, if you are adding some core infrastructure for switchdev ..it cannot be
> >>based on the number of simple use-cases or data you have today.
> >>
> >>I won't be surprised if tomorrow other switch drivers have a case where they need to
> >>reset the hw routing table state and reprogram all routes again. Re-registering the notifier to just
> >>get the routing state of the kernel will not scale. For the long term, since the driver does not maintain a cache,
> >
> > Driver (mlxsw, rocker) maintain a cache. So I'm not sure why you say
> > otherwise.
> >
> >
> >>a pull api with efficient use of rtnl will be useful for other such cases as well.
> >
> > How do you imagine this "pull API" should look like?
> 
> 
> Just like you already have added fib notifiers to parallel fib netlink
> notifications, the pull API is  a parallel to 'netlink dump'.
> Is my imagination too wild  ? :)

The question is more about the mechanics of this pull API, because it's
not very clear to me how that should look like. You want consumers to
dump the tables in batches, so that rtnl is held only during the batch
but not in between them? How are the routes passed down? Does the fib
code fill up some struct or does it use the fib chain?

> >>If you don't want to get to the complexity of a new api right away because of the
> >>simple case of management interface routes you have, Can your driver register the notifier early  ?
> >>(I am sure you have probably already thought about this)
> >
> > Register early? What it would resolve? I must be missing something. We
> > register as early as possible. But the thing is, we cannot register
> > in a past. And that is what this patch resolves.
> 
> sure, you must be having a valid problem then. I was just curious why
> your driver is not up and initialized before any of the addresses or
> routes get configured in the system (even on a management port). Ours
> does. But i agree there can be races and you cannot always guarantee
> (I was just responding to ido's comment about adding complexity for a
> small problem he has to solve for management routes). Our driver does
> a pull before it starts. This helps when we want to reset the hardware
> routing table state too.

One can modprobe the module after routes are already present on other
netdevs. That's actually how I tested the patch.
