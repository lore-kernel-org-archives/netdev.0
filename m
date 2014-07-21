From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC Patch V1 15/30] mm,
 igb: Use cpu_to_mem()/numa_mem_id() to support memoryless node
Date: Mon, 21 Jul 2014 10:42:18 -0700
Message-ID: <20140721174218.GD4156@linux.vnet.ibm.com>
References: <1405064267-11678-1-git-send-email-jiang.liu@linux.intel.com>
	<1405064267-11678-16-git-send-email-jiang.liu@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>, linux-hotplug@vger.kernel.org,
	linux-mm@kvack.org, Mike Galbraith <umgwanakikbuti@gmail.com>,
	e1000-devel@lists.sourceforge.net,
	"Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>,
	Linux NICS <linux.nics@intel.com>,
	Tony Luck <tony.luck@intel.com>, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>, linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1405064267-11678-16-git-send-email-jiang.liu@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 11.07.2014 [15:37:32 +0800], Jiang Liu wrote:
> When CONFIG_HAVE_MEMORYLESS_NODES is enabled, cpu_to_node()/numa_node_id()
> may return a node without memory, and later cause system failure/panic
> when calling kmalloc_node() and friends with returned node id.
> So use cpu_to_mem()/numa_mem_id() instead to get the nearest node with
> memory for the/current cpu.
> 
> If CONFIG_HAVE_MEMORYLESS_NODES is disabled, cpu_to_mem()/numa_mem_id()
> is the same as cpu_to_node()/numa_node_id().
> 
> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index f145adbb55ac..2b74bffa5648 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -6518,7 +6518,7 @@ static bool igb_can_reuse_rx_page(struct igb_rx_buffer *rx_buffer,
>  				  unsigned int truesize)
>  {
>  	/* avoid re-using remote pages */
> -	if (unlikely(page_to_nid(page) != numa_node_id()))
> +	if (unlikely(page_to_nid(page) != numa_mem_id()))
>  		return false;
> 
>  #if (PAGE_SIZE < 8192)
> @@ -6588,7 +6588,7 @@ static bool igb_add_rx_frag(struct igb_ring *rx_ring,
>  		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
> 
>  		/* we can reuse buffer as-is, just make sure it is local */
> -		if (likely(page_to_nid(page) == numa_node_id()))
> +		if (likely(page_to_nid(page) == numa_mem_id()))
>  			return true;
> 
>  		/* this page cannot be reused so discard it */

This doesn't seem to have anything to do with crashes or errors?

The original code is checking if the NUMA node of a page is remote to
the NUMA node current is running on. Your change makes it check if the
NUMA node of a page is not equal to the nearest NUMA node with memory.
That's not necessarily local, though, which seems like that is the whole
point. In this case, perhaps the driver author doesn't want to reuse the
memory at all for performance reasons? In any case, I don't think this
patch has appropriate justification.

Thanks,
Nish


------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
