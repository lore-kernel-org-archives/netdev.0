From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Wed, 23 May 2012 19:24:26 +0200
Message-ID: <1337793866.3361.3090.camel@edumazet-glaptop>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
	 <1337099641.8512.1102.camel@edumazet-glaptop>
	 <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <1337101280.8512.1108.camel@edumazet-glaptop>
	 <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>
	 <1337272654.3403.20.camel@edumazet-glaptop>
	 <1337674831.1698.7.camel@kjm-desktop.uk.level5networks.com>
	 <1337678759.3361.147.camel@edumazet-glaptop>
	 <1337679045.3361.154.camel@edumazet-glaptop>
	 <1337699379.1698.30.camel@kjm-desktop.uk.level5networks.com>
	 <1337703170.3361.217.camel@edumazet-glaptop>
	 <1337704382.1698.53.camel@kjm-desktop.uk.level5networks.com>
	 <1337705135.3361.226.camel@edumazet-glaptop>
	 <1337720076.3361.667.camel@edumazet-glaptop>
	 <1337766246.3361.2447.camel@edumazet-glaptop>
	 <1337774978.3361.2744.camel@edumazet-glaptop> <4FBD0A85.4040407@intel.com>
	 <1337789530.3361.2992.camel@edumazet-glaptop> <4FBD1740.1020304@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kieran Mansley <kmansley@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:37683 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752747Ab2EWRYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 13:24:32 -0400
Received: by eeit10 with SMTP id t10so2189618eei.19
        for <netdev@vger.kernel.org>; Wed, 23 May 2012 10:24:30 -0700 (PDT)
In-Reply-To: <4FBD1740.1020304@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-23 at 09:58 -0700, Alexander Duyck wrote:

> Right, but the problem is that in order to make this work the we are
> dropping the padding for head and hoping to have room for shared info. 
> This is going to kill performance for things like routing workloads
> since the entire head is going to have to be copied over to make space
> for NET_SKB_PAD. 

Hey I said that one of the point I have to add to my patch. Please read
it again ;)

By the way, we can also add code doing the ksb->head upgrade to fragment
again in case we need to add a tunnel header, instead of full copy.

So maybe the NET_SKB_PAD is not really needed anymore.

Anyway, a router host could use a different allocation strategy (going
back to current one)

>  Also this assumes no RSC being enabled.  RSC is
> normally enabled by default.  If it is turned on we are going to start
> receiving full 2K buffers which will cause even more issues since there
> wouldn't be any room for shared info in the 2K frame.
> 

Hey his is one of the point I have to address, also mentioned.

Its almost trivial to check len (if we have room for shared info, take
it, if not allocate the head as before)


> The way the driver is currently written probably provides the optimal
> setup for truesize given the circumstances.

It unfortunate the hardware has 1KB granularity.


>   In order to support
> receiving at least 1 full 1500 byte frame per fragment, and supporting
> RSC I have to support receiving up to 2K of data.  If we try to make it
> all part of one paged receive we would then have to either reduce the
> receive buffer size to 1K in hardware and span multiple fragments for a
> 1.5K frame or allocate a 3K buffer so we would have room to add
> NET_SKB_PAD and the shared info on the end.  At which point we are back
> to the extra 1K again, only in that case we cannot trim it off later via
> skb_try_coalesce.  In the 3K buffer case we would be over a 1/2 page
> which means we can only get one buffer per page instead of 2 in which
> case we might as well just round it up to 4K and be honest.
> 
> The reason I am confused is that I thought the skb_try_coalesce function
> was supposed to be what addressed these types of issues.  If these
> packets go through that function they should be stripping the sk_buff
> and possibly even the skb->head if we used the fragment since the only
> thing that is going to end up in the head would be the TCP header which
> should have been pulled prior to trying to coalesce.
> 
> I will need to investigate this further to understand what is going on. 
> I realize that dealing with 3K of memory for buffer storage is not
> ideal, but all of the alternatives lean more toward 4K when fully
> implemented.  I'll try and see what alternative solutions we might have
> available.

Problem is skb_try_coalesce() is not used when we store packets in
socket backlog, and only used for TCP at this moment.
