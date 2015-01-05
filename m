From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/3] enic: make vnic_wq_buf doubly linked
Date: Mon, 5 Jan 2015 17:30:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAC0D9E@AcuExch.aculab.com>
References: <1419416978-1008-1-git-send-email-_govind@gmx.com>
 <1419416978-1008-2-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "ssujith@cisco.com" <ssujith@cisco.com>,
	"benve@cisco.com" <benve@cisco.com>
To: 'Govindarajulu Varadarajan' <_govind@gmx.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sassmann@redhat.com" <sassmann@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:53016 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbbAERbv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 12:31:51 -0500
In-Reply-To: <1419416978-1008-2-git-send-email-_govind@gmx.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This patch makes vnic_wq_buf doubly liked list. This is needed for dma_mapping
> error check, in case some frag's dma map fails, we need to move back and remove
> previously queued buffers.

I can't see any code that keeps the back-pointers valid when items are removed.
Maybe they aren't needed, but I'd like to be convinced.

If errors are really unlikely, and the list likely to be short,
then just traverse the entire list forwards in the error path.

	David

> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
>  drivers/net/ethernet/cisco/enic/vnic_wq.c | 3 +++
>  drivers/net/ethernet/cisco/enic/vnic_wq.h | 1 +
>  2 files changed, 4 insertions(+)
> 
> diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.c b/drivers/net/ethernet/cisco/enic/vnic_wq.c
> index 3e6b8d5..b5a1c93 100644
> --- a/drivers/net/ethernet/cisco/enic/vnic_wq.c
> +++ b/drivers/net/ethernet/cisco/enic/vnic_wq.c
> @@ -47,11 +47,14 @@ static int vnic_wq_alloc_bufs(struct vnic_wq *wq)
>  				wq->ring.desc_size * buf->index;
>  			if (buf->index + 1 == count) {
>  				buf->next = wq->bufs[0];
> +				buf->next->prev = buf;
>  				break;
>  			} else if (j + 1 == VNIC_WQ_BUF_BLK_ENTRIES(count)) {
>  				buf->next = wq->bufs[i + 1];
> +				buf->next->prev = buf;
>  			} else {
>  				buf->next = buf + 1;
> +				buf->next->prev = buf;
>  				buf++;
>  			}
>  		}
> diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.h b/drivers/net/ethernet/cisco/enic/vnic_wq.h
> index 816f1ad..2961543 100644
> --- a/drivers/net/ethernet/cisco/enic/vnic_wq.h
> +++ b/drivers/net/ethernet/cisco/enic/vnic_wq.h
> @@ -62,6 +62,7 @@ struct vnic_wq_buf {
>  	uint8_t cq_entry; /* Gets completion event from hw */
>  	uint8_t desc_skip_cnt; /* Num descs to occupy */
>  	uint8_t compressed_send; /* Both hdr and payload in one desc */
> +	struct vnic_wq_buf *prev;
>  };
> 
>  /* Break the vnic_wq_buf allocations into blocks of 32/64 entries */
> --
> 2.2.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
