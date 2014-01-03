From: Debabrata Banerjee <dbavatar@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: allow > 0 order atomic page alloc in skb_page_frag_refill
Date: Thu, 2 Jan 2014 19:42:00 -0500
Message-ID: <CAATkVExsrzKyx3da=sApxdR5DJRTWBw1MOcLE9WiWQN56WfcdA@mail.gmail.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	<20131224.174647.2276571374631580479.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	rusty@rustcorp.com.au, mst@redhat.com, jasowang@redhat.com,
	virtualization@lists.linux-foundation.org,
	"Banerjee, Debabrata" <dbanerje@akamai.com>, jbaron@akamai.com,
	Joshua Hunt <johunt@akamai.com>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, mwdalton@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:63404 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbaACAmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 19:42:00 -0500
Received: by mail-oa0-f54.google.com with SMTP id h16so15536607oag.41
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 16:42:00 -0800 (PST)
In-Reply-To: <20131224.174647.2276571374631580479.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently because of how mm behaves (3.10.y) the code even before the
patch is a problem. I believe what may fix it is if instead of just
removing the conditional on __GFP_WAIT, the initial order > 0
allocation should be made GFP_ATOMIC, then fallback to the original
gfp mask for the order-0 allocations.

On systems that have highly fragmented main memory with pressure,
skb_page_frag_refill() causes problems. mm enters significant
compaction cycles on all cpu's which in itself is bad (add
considerable spinlock contention in isolate_migratepages_range() for
several seconds in kernel at 100% cpu), however even without this
happening basically we have large memory reclaimation when only
allocations from order-3 were necessary. For example, I might see half
the existing page cache on a system (2GB out of 8GB) reclaimed in a
burst, which effectively means the application has to wait even longer
after this compact/reclaim cycle for those pages to be read back from
disk. This is a significant reduction in useful memory from before
skb_page_frag_refill() existed, as one of our systems could run in
steady state will little free memory and 100% fragmentation. Now I see
10-30x more memory free (read: not utilized). Order > 0 allocations
were happening rarely before, now it happens consistently from this
function.

My suggestion above would avoid mm going through
__alloc_pages_direct_compact() and triggering the bad events above. It
will take me several days to try this experiment.

-Debabrata

On Tue, Dec 24, 2013 at 5:46 PM, David Miller <davem@davemloft.net> wrote:
>
> There is still feedback and/or minor adjustments being asked for wrt.
> this series.   These changes have been sitting for more than a week
> which is a bit rediculous.
>
> Please resubmit these changes once everything is resolved to
> everyone's satisfaction, thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
