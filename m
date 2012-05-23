From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Wed, 23 May 2012 10:57:49 -0700
Message-ID: <4FBD251D.8090807@intel.com>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>  <1337099641.8512.1102.camel@edumazet-glaptop>  <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>  <1337101280.8512.1108.camel@edumazet-glaptop>  <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>  <1337272654.3403.20.camel@edumazet-glaptop>  <1337674831.1698.7.camel@kjm-desktop.uk.level5networks.com>  <1337678759.3361.147.camel@edumazet-glaptop>  <1337679045.3361.154.camel@edumazet-glaptop>  <1337699379.1698.30.camel@kjm-desktop.uk.level5networks.com>  <1337703170.3361.217.camel@edumazet-glaptop>  <1337704382.1698.53.camel@kjm-desktop.uk.level5networks.com>  <1337705135.3361.226.camel@edumazet-glaptop>  <1337720076.3361.667.camel@edumazet-glaptop>  <1337766246.3361.2447.camel@edumazet-glaptop>  <1
 337774978.3361.2744.camel@edumazet-glaptop> <4FBD0A85.4040407@intel.com>  <1337789530.3361.2992.camel@edumazet-glaptop> <4FBD1740.1020304@intel.com> <1337793866.3361.3090.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Kieran Mansley <kmansley@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32224 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760679Ab2EWR5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2012 13:57:50 -0400
In-Reply-To: <1337793866.3361.3090.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2012 10:24 AM, Eric Dumazet wrote:
> On Wed, 2012-05-23 at 09:58 -0700, Alexander Duyck wrote:
>
>> Right, but the problem is that in order to make this work the we are
>> dropping the padding for head and hoping to have room for shared info. 
>> This is going to kill performance for things like routing workloads
>> since the entire head is going to have to be copied over to make space
>> for NET_SKB_PAD. 
> Hey I said that one of the point I have to add to my patch. Please read
> it again ;)
I'm aware of that, but still it seems like we are getting ahead of
ourselves.  This fix is so specific to just the socket backlog case that
I think we are missing the fact that it is going to have huge
performance repercussions elsewhere.

> By the way, we can also add code doing the ksb->head upgrade to fragment
> again in case we need to add a tunnel header, instead of full copy.
>
> So maybe the NET_SKB_PAD is not really needed anymore.
>
> Anyway, a router host could use a different allocation strategy (going
> back to current one)
The thing I don't like is that we are adding extra memcpy calls to all
of these paths.  We cannot change the head without having to copy the
shared info and there is going to be a cost for that.  I would prefer to
only generate the shared info once and not have to relocate it every
time I want to run a router or tunnel.

>>  Also this assumes no RSC being enabled.  RSC is
>> normally enabled by default.  If it is turned on we are going to start
>> receiving full 2K buffers which will cause even more issues since there
>> wouldn't be any room for shared info in the 2K frame.
>>
> Hey his is one of the point I have to address, also mentioned.
>
> Its almost trivial to check len (if we have room for shared info, take
> it, if not allocate the head as before)
I know you mentioned this as well.  The thing is I would prefer not to
add code where we are branching in so many different directions on what
the header actually looks like.  It tends to open a lot of opportunities
for bugs when someone makes a change and doesn't take one of the
possible head and fragment combinations into account.

>> The way the driver is currently written probably provides the optimal
>> setup for truesize given the circumstances.
> It unfortunate the hardware has 1KB granularity.
Agreed, I would have preferred 512B granularity, but we are locked in at
1K for now..  :-/

> Problem is skb_try_coalesce() is not used when we store packets in
> socket backlog, and only used for TCP at this moment.
One piece of low hanging fruit that is available to help with some of
this is to drop the Rx header size for ixgbe to 256.  That should at
least cut the total truesize for the buffer and sk_buff to 960 or so
which is at least a step in the right direction.

Thanks,

Alex
