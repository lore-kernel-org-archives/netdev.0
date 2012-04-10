From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 05/10] net: move destructor_arg to the front of sk_buff.
Date: Tue, 10 Apr 2012 12:15:51 -0700
Message-ID: <4F8486E7.5050604@intel.com>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>  <1334067984-7706-5-git-send-email-ian.campbell@citrix.com>  <4F847CF9.3090701@intel.com> <1334083265.5300.288.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59901 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755268Ab2DJTPw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 15:15:52 -0400
In-Reply-To: <1334083265.5300.288.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2012 11:41 AM, Eric Dumazet wrote:
> On Tue, 2012-04-10 at 11:33 -0700, Alexander Duyck wrote:
>
>> Have you checked this for 32 bit as well as 64?  Based on my math your
>> next patch will still mess up the memset on 32 bit with the structure
>> being split somewhere just in front of hwtstamps.
>>
>> Why not just take frags and move it to the start of the structure?  It
>> is already an unknown value because it can be either 16 or 17 depending
>> on the value of PAGE_SIZE, and since you are making changes to frags the
>> changes wouldn't impact the alignment of the other values later on since
>> you are aligning the end of the structure.  That way you would be
>> guaranteed that all of the fields that will be memset would be in the
>> last 64 bytes.
>>
> Now when a fragmented packet is copied in pskb_expand_head(), you access
> two separate zones of memory to copy the shinfo. But its supposed to be
> slow path.
>
> Problem with this is that the offsets of often used fields will be big
> (instead of being < 127) and code will be bigger on x86.

Actually now that I think about it my concerns go much further than the
memset.  I'm convinced that this is going to cause a pretty significant
performance regression on multiple drivers, especially on non x86_64
architecture.  What we have right now on most platforms is a
skb_shared_info structure in which everything up to and including frag 0
is all in one cache line.  This gives us pretty good performance for igb
and ixgbe since that is our common case when jumbo frames are not
enabled is to split the head and place the data in a page.

However the change being recommend here only resolves the issue for one
specific architecture, and that is what I don't agree with.  What we
need is a solution that also works for 64K pages or 32 bit pointers and
I am fairly certain this current solution does not.

Thanks,

Alex
