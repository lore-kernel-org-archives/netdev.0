From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH v2] bnx2x: Alloc 4k fragment for each rx ring buffer
 element
Date: Thu, 30 Apr 2015 11:25:31 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63D383CB@avmb3.qlogic.org>
References: <1429908351-12262-1-git-send-email-krisman@linux.vnet.ibm.com>
	<553AD097.4020209@gmx.de> <87383jhxj9.fsf@dhcp-9-18-235-171.br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"cascardo@linux.vnet.ibm.com" <cascardo@linux.vnet.ibm.com>,
	"cascardo@cascardo.eti.br" <cascardo@cascardo.eti.br>,
	"brking@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>
To: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>,
	Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:13958 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750876AbbD3LZo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 07:25:44 -0400
In-Reply-To: <87383jhxj9.fsf@dhcp-9-18-235-171.br.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 The driver allocates one page for each buffer on the rx ring, which is too much
> on architectures like ppc64 and can cause unexpected allocation failures when
> the system is under stress.  Now, we keep a memory pool per queue, and if the
> architecture's PAGE_SIZE is greater than 4k, we fragment pages and assign each
> 4k segment to a ring element, which reduces the overall memory consumption
> on such architectures.  This helps avoiding errors like the example below:
> 
> [bnx2x_alloc_rx_sge:435(eth1)]Can't alloc sge [c00000037ffeb900]
> [d000000075eddeb4] .bnx2x_alloc_rx_sge+0x44/0x200 [bnx2x]
> [c00000037ffeb9b0] [d000000075ee0b34] .bnx2x_fill_frag_skb+0x1ac/0x460
> [bnx2x] [c00000037ffebac0] [d000000075ee11f0]
> .bnx2x_tpa_stop+0x160/0x2e8 [bnx2x] [c00000037ffebb90]
> [d000000075ee1560] .bnx2x_rx_int+0x1e8/0xc30 [bnx2x] [c00000037ffebcd0]
> [d000000075ee2084] .bnx2x_poll+0xdc/0x3d8 [bnx2x] (unreliable)
> 
> Signed-off-by: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     | 19 ++++++--
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 61 +++++++++++++++++-
> -------  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h | 33 +++++++++++--
>  3 files changed, 89 insertions(+), 24 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> index 4085c4b..d0c8ed0 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> @@ -356,6 +356,8 @@ struct sw_tx_bd {
> 
 ...
> +struct bnx2x_alloc_pool {
> +	struct page	*page;
> +	dma_addr_t	dma;
> +	int		len;

Isn't len always set to PAGE_SIZE? If so it can be dropped

> +	int		offset;
> +	int		last_offset;

Looks like you last_offset is used only for comparisons with offset;
Can we make it into a counter of possible allocations instead?

I.e., set it to (PAGE_SIZE / SGE_PAGE_SIZE - 1) during allocation
And decrement it each time an SGE_PAGE_SIZE chunk is taken.
That would turn (pool-> offset > pool->last_offset) into (!remain).
	
