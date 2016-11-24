From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net-next v2 09/11] ipv4: fib: Add an API to request a FIB
 dump
Date: Thu, 24 Nov 2016 10:47:58 +0200
Message-ID: <20161124084758.q5uh7lr55pwwhxoh@splinter>
References: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
 <1479911670-4525-10-git-send-email-jiri@resnulli.us>
 <fa5e105b-9109-1c30-c07c-5a2b0720ffec@stressinduktion.org>
 <20161123195328.aqzbhf263z2pq2e7@splinter>
 <6d57dab8-2c83-501e-f3ee-0bad0b72efbb@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kaber@trash.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:58235 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755878AbcKXIs0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 03:48:26 -0500
Content-Disposition: inline
In-Reply-To: <6d57dab8-2c83-501e-f3ee-0bad0b72efbb@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2016 at 12:04:57AM +0100, Hannes Frederic Sowa wrote:
> On 23.11.2016 20:53, Ido Schimmel wrote:
> > On Wed, Nov 23, 2016 at 06:47:03PM +0100, Hannes Frederic Sowa wrote:
> >> Hmm, I think you need to read the sequence counter under rtnl_lock to
> >> have an ordering with the rest of the updates to the RCU trie. Otherwise
> >> you don't know if the fib trie has the correct view regarding to the
> >> incoming notifications as a whole. This is also necessary during restarts.
> >
> > I spent quite a lot of time thinking about this specific issue, but I
> > couldn't convince myself that the read should be done under RTNL and I'm
> > not sure I understand your reasoning. Can you please elaborate?
> >
> > If, before each notification sent, we call atomic_inc() and then call
> > atomic_read() at the end, then how can we be tricked?
> 
> The race I am suspecting to happen is:
> 
> <CPU0> fib_register()
> 
> <CPU1> delete route by notifier
> <CPU1> enqueue delete cmd into ordered queue
> 
> <CPU0> starts dump
> <CPU0> sees deleted route by CPU1 because route not yet removed from RCU
> <CPU0> enqueues route for addition

Yea, I missed this trivial case... My mind was fixed on problems that
could happen after the dump already started. :(

Regarding your suggestion, I think the API will be more useful if we
don't bundle fib_register() and fib_dump() together. We can do the
following instead:

1) Sum 'fib_seq' (doesn't need to be atomic_t anymore) from all net
namespaces under RTNL
2) Dump FIB tables under RCU
3) Do 1) again
4) Compare results from 1) and 3) and retry (according to sysctl limit)
if results differ. Before each retry the module's callback (if passed)
will be invoked.

Sounds OK?
