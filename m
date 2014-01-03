From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: allow > 0 order atomic page alloc in
	skb_page_frag_refill
Date: Thu, 02 Jan 2014 16:56:31 -0800
Message-ID: <1388710591.12212.110.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	<20131224.174647.2276571374631580479.davem@davemloft.net>
	<CAATkVExsrzKyx3da=sApxdR5DJRTWBw1MOcLE9WiWQN56WfcdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Banerjee, Debabrata" <dbanerje@akamai.com>, mwdalton@google.com,
	mst@redhat.com, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jbaron@akamai.com, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, Joshua Hunt <johunt@akamai.com>,
	David Miller <davem@davemloft.net>
To: Debabrata Banerjee <dbavatar@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAATkVExsrzKyx3da=sApxdR5DJRTWBw1MOcLE9WiWQN56WfcdA@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-01-02 at 19:42 -0500, Debabrata Banerjee wrote:
> Currently because of how mm behaves (3.10.y) the code even before the
> patch is a problem. I believe what may fix it is if instead of just
> removing the conditional on __GFP_WAIT, the initial order > 0
> allocation should be made GFP_ATOMIC, then fallback to the original
> gfp mask for the order-0 allocations.
> 
> On systems that have highly fragmented main memory with pressure,
> skb_page_frag_refill() causes problems. mm enters significant
> compaction cycles on all cpu's which in itself is bad (add
> considerable spinlock contention in isolate_migratepages_range() for
> several seconds in kernel at 100% cpu), however even without this
> happening basically we have large memory reclaimation when only
> allocations from order-3 were necessary. For example, I might see half
> the existing page cache on a system (2GB out of 8GB) reclaimed in a
> burst, which effectively means the application has to wait even longer
> after this compact/reclaim cycle for those pages to be read back from
> disk. This is a significant reduction in useful memory from before
> skb_page_frag_refill() existed, as one of our systems could run in
> steady state will little free memory and 100% fragmentation. Now I see
> 10-30x more memory free (read: not utilized). Order > 0 allocations
> were happening rarely before, now it happens consistently from this
> function.
> 
> My suggestion above would avoid mm going through
> __alloc_pages_direct_compact() and triggering the bad events above. It
> will take me several days to try this experiment.

My suggestion is to use a recent kernel, and/or eventually backport the
mm fixes if any.

order-3 allocations should not reclaim 2GB out of 8GB.

There is a reason PAGE_ALLOC_COSTLY_ORDER exists and is 3
