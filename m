From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC] defer skb allocation in virtio_net -- mergable buff part
Date: Sun, 16 Aug 2009 16:47:42 +0300
Message-ID: <4A880DFE.2040507@redhat.com>
References: <1250145231.6653.29.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751928AbZHPNrz@vger.kernel.org>
In-Reply-To: <1250145231.6653.29.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/13/2009 09:33 AM, Shirley Ma wrote:
> Guest virtio_net receives packets from its pre-allocated vring
> buffers, then it delivers these packets to upper layer protocols
> as skb buffs. So it's not necessary to pre-allocate skb for each
> mergable buffer, then frees it when it's useless.
>
> This patch has deferred skb allocation to when receiving packets,
> it reduces skb pre-allocations and skb_frees. And it induces two
> page list: freed_pages and used_page list, used_pages is used to
> track pages pre-allocated, it is only useful when removing virtio_net.
>
> This patch has tested and measured against 2.6.31-rc4 git,
> I thought this patch will improve large packet performance, but I saw
> netperf TCP_STREAM performance improved for small packet for both
> local guest to host and host to local guest cases. It also reduces
> UDP packets drop rate from host to local guest. I am not fully understand
> why.
>
> The netperf results from my laptop are:
>
> mtu=1500
> netperf -H xxx -l 120
>
> 		w/o patch	w/i patch (two runs)	
> guest to host:  3336.84Mb/s   3730.14Mb/s ~ 3582.88Mb/s
>
> host to guest:  3165.10Mb/s   3370.39Mb/s ~ 3407.96Mb/s
>
> Here is the patch for your review. The same approach can apply to non-mergable
> buffs too, so we can use code in common. If there is no objection, I will
> submit the non-mergable buffs patch later.
>
>
> Signed-off-by: Shirley Ma<xma@us.ibm.com>
> ---
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 2a6e81d..e31ebc9 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -17,6 +17,7 @@
>    * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
>    */
>   //#define DEBUG
> +#include<linux/list.h>
>   #include<linux/netdevice.h>
>   #include<linux/etherdevice.h>
>   #include<linux/ethtool.h>
> @@ -39,6 +40,12 @@ module_param(gso, bool, 0444);
>
>   #define VIRTNET_SEND_COMMAND_SG_MAX    2
>
> +struct page_list
> +{
> +	struct page *page;
> +	struct list_head list;
> +};
>    

This is an inefficient way to store a list of pages.  Each page requires 
an allocation and a cache line.

Alternatives include:
- store the link in the page itself
- have an array of pages per list element instead of just one pointer
- combine the two, store an array of page pointers in one of the free pages
- use the struct page::lru member

The last is the most traditional and easiest so I'd recommend it (though 
it still takes the cacheline hit).

> +static struct page_list *get_a_free_page(struct virtnet_info *vi, gfp_t gfp_mask)
> +{
> +	struct page_list *plist;
> +
> +	if (list_empty(&vi->freed_pages)) {
> +		plist = kmalloc(sizeof(struct page_list), gfp_mask);
> +		if (!plist)
> +			return NULL;
> +		list_add_tail(&plist->list,&vi->freed_pages);
> +		plist->page = alloc_page(gfp_mask);
>    

What if the allocation fails here?

-- 
error compiling committee.c: too many arguments to function
