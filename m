From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: use new rhlist interface on sctp transport
 rhashtable
Date: Wed, 16 Nov 2016 14:09:31 -0500
Message-ID: <20161116190931.GA31421@hmsreliant.think-freely.org>
References: <0a89ef8506db3bba6a37010bd5622cd145183ab4.1479223391.git.lucien.xin@gmail.com>
 <20161115180427.GC11283@hmsreliant.think-freely.org>
 <CADvbK_eOu5oZJ67r8WJ-Vc0O8fLj5X4y-ROeE2aX-12Xd2jzDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Phil Sutter <phil@nwl.cc>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56719 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933142AbcKPTJv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 14:09:51 -0500
Content-Disposition: inline
In-Reply-To: <CADvbK_eOu5oZJ67r8WJ-Vc0O8fLj5X4y-ROeE2aX-12Xd2jzDw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2016 at 09:34:52PM +0800, Xin Long wrote:
> On Wed, Nov 16, 2016 at 2:04 AM, Neil Horman <nhorman@tuxdriver.com> wrote:
> > On Tue, Nov 15, 2016 at 11:23:11PM +0800, Xin Long wrote:
> >> Now sctp transport rhashtable uses hash(lport, dport, daddr) as the key
> >> to hash a node to one chain. If in one host thousands of assocs connect
> >> to one server with the same lport and different laddrs (although it's
> >> not a normal case), all the transports would be hashed into the same
> >> chain.
> >>
> >> It may cause to keep returning -EBUSY when inserting a new node, as the
> >> chain is too long and sctp inserts a transport node in a loop, which
> >> could even lead to system hangs there.
> >>
> >> The new rhlist interface works for this case that there are many nodes
> >> with the same key in one chain. It puts them into a list then makes this
> >> list be as a node of the chain.
> >>
> >> This patch is to replace rhashtable_ interface with rhltable_ interface.
> >> Since a chain would not be too long and it would not return -EBUSY with
> >> this fix when inserting a node, the reinsert loop is also removed here.
> >>
> >> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> >
> > Does this really buy us anything in this case though?  If the use case is that a
> > majority of the associations map to the same key, then you might avoid EBUSY for
> > the individual associaion that doesn't map there, but you still have to cope
> > with a huge linear search for the majority of the keys.
> >
> 
> This patch is NOT for improving performance, it is to reorganize
> transports in rhashtable in another way to avoid EBUSY, rhlist is born
> for this.
> 
Never said it was a performance issue, just suggested that avoiding EBUSY
returns on inserts might be handled in other ways.

> Before this patch, the transport insert codes are pretty bad, if it returns
> EBUSY, it would retry in a loop. now this patch avoid this and even
> removed that loop, it's a fix for this issue.
> 
> > Might be more reasonable to mix saddr into the hash function so that your use
> > case gets spread through the hash table more evenly.
> 
> we can not do this:
> 1. it will increase rhashtable's size when using multihome, if a host has
>     N addrs, the size for one assoc will be N times bigger than now.
> 2. the hash node is inside transport, if we mix saddrs, when using multihome
>     one transport would be hashed many times with different saddrs, we
>     would have to define new structure to link transport.
> we do not need to do this:
> 1. as the changelog said, "it's not a normal case", in one host (client), it
> shouldn't connect to the same server with different saddrs.
> 2. now as long as paddr+dport+lport are different, rhashtable can hash
> it evenly.

Its the 'not a normal case' thats getting me.  Making a non-trivial change like
this for a corner use case typically makes me suspcious, but your points
regarding multiple hash entries being needed when saddr is used in a multihome
scenario make sense to me.  And looking at the rhltable code more closely, I
think this makes more sense

Acked-by: Neil Horman <nhorman@tuxdriver.com>

> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
