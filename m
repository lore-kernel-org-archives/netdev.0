From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH v2] sky2: Fix transmit dma mapping handling
Date: Mon, 01 Feb 2010 12:52:12 -0500
Message-ID: <4B6714CC.8020607@majjas.com>
References: <20100128225621.GD3109@del.dom.local> <4B6216B9.1010802@majjas.com>
 <20100128153643.0fca3c51@nehalam> <4B645EF4.4050701@majjas.com>
 <20100131003449.GA11935@del.dom.local> <4B650D53.2010607@majjas.com>
 <4B65D0F9.2020602@majjas.com> <4B65FD12.7090101@majjas.com>
 <20100131221835.GA3317@del.dom.local> <4B661E22.8090907@majjas.com>
 <20100201091718.GA9849@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20100201091718.GA9849@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/1/2010 4:17 AM, Jarek Poplawski wrote:
> On Sun, Jan 31, 2010 at 07:19:46PM -0500, Michael Breuer wrote:
>    
>> On 1/31/2010 5:18 PM, Jarek Poplawski wrote:
>>      
>>> On Sun, Jan 31, 2010 at 04:58:42PM -0500, Michael Breuer wrote:
>>>
>>>        
>>>> On 1/31/2010 1:50 PM, Michael Breuer wrote:
>>>>          
>>>>> I put a printk as a third else case in sky2_tx_unmap. Looks like
>>>>> the issue is that a large number (perhaps all) calls to
>>>>> sky2_tx_unmap have re->flags set to neither TX_MAP_SINGLE or
>>>>> TX_MAP_PAGE. Thus the elements are never being unmapped.
>>>>>
>>>>> I suspect that the system collapses when using DMAR sooner than if
>>>>> not using DMAR. Probably some hardware limitation on the number of
>>>>> mapped elements that is less than the software limitation. I don't
>>>>> see at present how a ring element can ever get to this code
>>>>> without re->flags being set to one or the other.
>>>>>
>>>>>
>>>>>
>>>>>            
>>>> Put some more debugging code in... re->flags is always NULL upon
>>>> entry to sky2_tx_unmap.
>>>>
>>>>
>>>>          
>>> Yes, good point! Could you try if this patch can fix it. (not compiled)
>>>        
> ...
>    
>> Ok- solves the dma-debug issue - i.e., elements are now being unmapped.
>>
>> Will leave up and hit with traffic unless a crash occurs. If I hit
>> something unrelated I'll backport to 2.6.32.7 and try that for a while.
>> I do think it's plausible that the dma errors after (during) load were
>> due to hardware limitations on the number of mapped entries (haven't
>> researched what that limit was). I would also assume that the sw map
>> would also have failed eventually.
>>
>> I'd suggest that regardless of whether this patch solves my crash that
>> it ought to be backported as it seems unlikely that any machine would be
>> able to survive for long without the tx entries being unmapped.
>>      
> Here is a bit improved version (re->flags = 0 in sky2_tx_unmap()) for
> merging, or additional testing if David wishes.
>
> Thanks,
> Jarek P.
> --------------->
> Michael Breuer reported that dma-debug entries added by sky2 driver
> weren't unmapped, and found out "re->flags is always NULL upon entry
> to sky2_tx_unmap". It is overwritten by get_tx_le() after changes
> introduced by commit 6b84dacadbdc3dab6a5b313d20d5a93b0d998641.
>
> This patch reorders initializations in get_tx_le() and tx_init(), and
> additionally does re->flags zeroing in sky2_tx_unmap() to prevent
> possible double unmapping.
>
> With debugging by: Michael Breuer<mbreuer@majjas.com>
>
> Reported-by: Michael Breuer<mbreuer@majjas.com>
> Tested-by: Michael Breuer<mbreuer@majjas.com>
> Signed-off-by: Jarek Poplawski<jarkao2@gmail.com>
> ---
>
>   drivers/net/sky2.c |   20 +++++++++++++-------
>   1 files changed, 13 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index d760650..21bb00a 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -1025,9 +1025,10 @@ static void sky2_prefetch_init(struct sky2_hw *hw, u32 qaddr,
>   static inline struct sky2_tx_le *get_tx_le(struct sky2_port *sky2, u16 *slot)
>   {
>   	struct sky2_tx_le *le = sky2->tx_le + *slot;
> -	struct tx_ring_info *re = sky2->tx_ring + *slot;
> +	struct tx_ring_info *re;
>
>   	*slot = RING_NEXT(*slot, sky2->tx_ring_size);
> +	re = sky2->tx_ring + *slot;
>   	re->flags = 0;
>   	re->skb = NULL;
>   	le->ctrl = 0;
> @@ -1036,13 +1037,16 @@ static inline struct sky2_tx_le *get_tx_le(struct sky2_port *sky2, u16 *slot)
>
>   static void tx_init(struct sky2_port *sky2)
>   {
> -	struct sky2_tx_le *le;
> +	struct sky2_tx_le *le = sky2->tx_le;
> +	struct tx_ring_info *re = sky2->tx_ring;
>
>   	sky2->tx_prod = sky2->tx_cons = 0;
>   	sky2->tx_tcpsum = 0;
>   	sky2->tx_last_mss = 0;
>
> -	le = get_tx_le(sky2,&sky2->tx_prod);
> +	re->flags = 0;
> +	re->skb = NULL;
> +	le->ctrl = 0;
>   	le->addr = 0;
>   	le->opcode = OP_ADDR64 | HW_OWNER;
>   	sky2->tx_last_upper = 0;
> @@ -1622,17 +1626,19 @@ static unsigned tx_le_req(const struct sk_buff *skb)
>   	return count;
>   }
>
> -static void sky2_tx_unmap(struct pci_dev *pdev,
> -			  const struct tx_ring_info *re)
> +static void sky2_tx_unmap(struct pci_dev *pdev, struct tx_ring_info *re)
>   {
> -	if (re->flags&  TX_MAP_SINGLE)
> +	if (re->flags&  TX_MAP_SINGLE) {
>   		pci_unmap_single(pdev, pci_unmap_addr(re, mapaddr),
>   				 pci_unmap_len(re, maplen),
>   				 PCI_DMA_TODEVICE);
> -	else if (re->flags&  TX_MAP_PAGE)
> +		re->flags = 0;
> +	} else if (re->flags&  TX_MAP_PAGE) {
>   		pci_unmap_page(pdev, pci_unmap_addr(re, mapaddr),
>   			       pci_unmap_len(re, maplen),
>   			       PCI_DMA_TODEVICE);
> +		re->flags = 0;
> +	}
>   }
>
>   /*
>    
Running with v2 now. v1 patch significantly improved things. I cannot 
state for certain that the original issue is resolved (crash under 
load), however so far it appears so. Additionally, some performance 
issues (raid rebuild times, etc.) seem drastically improved. I'm 
guessing that this might have to do with the excess mapped sky2 tx buffers.
