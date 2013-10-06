From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net] net/mlx4_en: Fix pages never dma unmapped on rx
Date: Sun, 6 Oct 2013 18:05:47 +0300
Message-ID: <52517C4B.3070503@mellanox.com>
References: <1381064240-12902-1-git-send-email-amirv@mellanox.com> <1381069372.3564.68.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>,
	"Eugenia Emantayev" <eugenia@mellanox.com>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:52186 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753358Ab3JFPG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Oct 2013 11:06:57 -0400
In-Reply-To: <1381069372.3564.68.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/2013 17:22, Eric Dumazet wrote:
> On Sun, 2013-10-06 at 14:57 +0200, Amir Vadai wrote:
>> This patch fixes a bug introduced by commit 51151a16 (mlx4: allow
>> order-0 memory allocations in RX path).
>>
>> dma_unmap_page never reached because condition to detect last fragment
>> in page is wrong. offset+frag_stride can't be greater than size, need to
>> make sure no additional frag will fit in page => compare offset +
>> frag_stride + next_frag_size instead.
>> next_frag_size could be next frag in the same skb, or the first frag in
>> the next.
>>
>> CC: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlx4/en_rx.c | 5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> index dec455c..44d8865 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> @@ -131,8 +131,11 @@ static void mlx4_en_free_frag(struct mlx4_en_priv *priv,
>>  			      int i)
>>  {
>>  	const struct mlx4_en_frag_info *frag_info = &priv->frag_info[i];
>> +	u16 next_frag_end = frags[i].offset + frag_info->frag_stride;
>>  
> 
> Hmm, could you make this an u32 ?
> 
> frags[i].offset and frags[i].size are u32
> 
> Maybe some folks want to use PAGE_SIZE=65536 or whatever high order
> allocs
> 
> 
>> -	if (frags[i].offset + frag_info->frag_stride > frags[i].size)
>> +	next_frag_end += frags[(i + 1) % priv->num_frags].size;
>> +
>> +	if (next_frag_end > frags[i].size)
>>  		dma_unmap_page(priv->ddev, frags[i].dma, frags[i].size,
>>  					 PCI_DMA_FROMDEVICE);
>>  
> 
> Not sure I understand how this can work. How was this tested ?
> 
> frags[i + 1].size is the size of the page containing next fragment,
> so now test should _always_ trigger.
> 
> (We could rename @size to @page_size to avoid confusion)
> 
> I think you meant to add the size of the next fragment ?
> 
> What about following instead (I also removed the divide operation)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index dec455c..22444de 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -131,10 +131,17 @@ static void mlx4_en_free_frag(struct mlx4_en_priv *priv,
>  			      int i)
>  {
>  	const struct mlx4_en_frag_info *frag_info = &priv->frag_info[i];
> +	u32 next_frag_end = frags[i].offset + frag_info->frag_stride;
>  
> -	if (frags[i].offset + frag_info->frag_stride > frags[i].size)
> +	frag_info++;
> +	if (i + 1 == priv->num_frags)
> +		frag_info = &priv->frag_info[0];
> +
> +	next_frag_end += frag_info->frag_stride;
> +
> +	if (next_frag_end > frags[i].size)
>  		dma_unmap_page(priv->ddev, frags[i].dma, frags[i].size,
> -					 PCI_DMA_FROMDEVICE);
> +			       PCI_DMA_FROMDEVICE);
>  
>  	if (frags[i].page)
>  		put_page(frags[i].page);
> 
> 

It looks good.

Will also change it into a small patchset with a new patch to rename
@size to @page_size and @offset to @page_offset.

I Will send it after I finish testing.
(Previously I had the typo added just after I removed the prints I used
while testing).

Thanks,
Amir
