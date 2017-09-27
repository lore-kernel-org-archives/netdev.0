From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/6] net: dsa: {e}dsa: set offload_fwd_mark on
 received packets
Date: Wed, 27 Sep 2017 22:11:20 +0200
Message-ID: <20170927201120.GG12394@lunn.ch>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
 <1506464764-12699-3-git-send-email-andrew@lunn.ch>
 <1c4ba973-91c0-ae81-1c4b-d0281f5c7517@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:58557 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751136AbdI0ULY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 16:11:24 -0400
Content-Disposition: inline
In-Reply-To: <1c4ba973-91c0-ae81-1c4b-d0281f5c7517@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 27, 2017 at 12:46:35PM -0700, Florian Fainelli wrote:
> On 09/26/2017 03:25 PM, Andrew Lunn wrote:
> > The software bridge needs to know if a packet has already been bridged
> > by hardware offload to ports in the same hardware offload, in order
> > that it does not re-flood them, causing duplicates. This is
> > particularly true for broadcast and multicast traffic which the host
> > has requested.
> > 
> > By setting offload_fwd_mark in the skb the bridge will only flood to
> > ports in other offloads and other netifs. Set this flag in the DSA and
> > EDSA tag driver.
> 
> Is not there some kind of forwarding code/reason code being provided in
> the EDSA/DSA tag that tell you why this packet was sent to the CPU in
> the first place?

Hi Florian

There are some codes, but nothing specific to broadcast, or ATU
misses. I'm also trying to keep the code generic so it could be a
template for other drivers. Many of the tagging schemes don't provide
a reason code. So i want that any frame that comes from the switch has
no need to go back to the switch. KISS.
 
> What is the impact on non-broadcast traffic, e.g: multicast and unicast?

The bridge uses this flag when flooding. unicast traffic from the
switch should not need flooding. Either it is known in the switch and
hence won't be forwarded to the host, or it is unknown in the switch,
so it probably is on some other interface.

My testing with multicast has not shown issues. The switch pushes down
mdb entries, which causes frames to be replicated out ports. So again,
there should not be a need to pass the frame back to the switch. But
it is possible i missed a corner case or two...
 
> Nit: I don't really have a solution on how to order patches, but until
> the next 4 patches get in, I suppose we temporarily have broadcast
> flooding by the bridge "broken"? Ordering in the opposite way would
> probably result in an equally bad situation so...

Yes, it is an issue. I could put this patch last. We then get
duplication of broadcast...

Which is the lesser of two evils?

      Andrew
