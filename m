From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH 1/2] e1000: Fix DMA mapping error handling
	on TX
Date: Tue, 26 Jan 2010 16:59:32 +0100
Message-ID: <4B5F1164.8030102@gmail.com>
References: <20100121114244.GC32259@kryten>	
	<9929d2391001221940r4482dde4k8e5409bc7933bc21@mail.gmail.com>	
	<20100124004753.GB2996@kryten>
	<9929d2391001231958n3f8d5165yaeed9ec1e0d7121a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Yi Zou <yi.zou@intel.com>, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Anton Blanchard <anton@samba.org>, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <9929d2391001231958n3f8d5165yaeed9ec1e0d7121a@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


>>> This patch does not apply to the current e1000 driver in net-2.6, much
>>> of this patch has already been corrected (applied) by Roel Kluin
>>> recent patch.
>>
>> Sorry I was basing off net-next. I just compared it to my fix and looks like
>> the patch in net-2.6 has an off by one error doesn't it?
> 
> This was discussed during our code review of Roel's patch, and it was
> found that there was not an issue.  But I will review the code again
> to ensure that there is not "an off by one error".  Thanks for looking
> at this.

He is right, as also reported by Juha Leppanen:

> Before your patch I suppose the logic disregarding the signed/unsigned error was :
> 1) if count==0, no unmapping/freeing inside while loop
> 2) if count>0, do 'count' loops unmapping/freeing
> 
> After your patch the logic is :
> 1) if count==0, no unmapping/freeing inside while loop
> 1) if count==1, no unmapping/freeing inside while loop
> 2) if count>1, do 'count-1' loops unmapping/freeing

> Can tx_ring->count be zero? I hope not.

His suggested fix works:

> dma_error:
> 	dev_err(&pdev->dev, "TX DMA map failed\n");
> 	buffer_info->dma = 0;
> -	if (count)
> -		count--;
> 
> 	while (count--) {
> 		if (i==0)
> -			i += tx_ring->count;
> +			i = tx_ring->count;
> 		i--;
> 		buffer_info = &tx_ring->buffer_info[i];
> 		e1000_unmap_and_free_tx_resource(adapter, buffer_info);
> 	}
> 
> 	return 0;
> }

This affects the patches:
[PATCH] e1000: Fix tests of unsigned in e1000_tx_map()
and the other patch in the same thread.

Do you want me to send a delta patch?

Roel

------------------------------------------------------------------------------
The Planet: dedicated and managed hosting, cloud storage, colocation
Stay online with enterprise data centers and the best network in the business
Choose flexible plans and management services without long-term contracts
Personal 24x7 support from experience hosting pros just a phone call away.
http://p.sf.net/sfu/theplanet-com
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
