From: Ed Cashin <ecashin@coraid.com>
Subject: Re: [PATCH 01/14] aoe: for performance support larger packet
 payloads
Date: Thu, 23 Aug 2012 15:46:44 -0500
Message-ID: <A07E1015-B0AA-4FA5-B8B3-43F0A0771247@coraid.com>
References: <cover.1345743800.git.ecashin@coraid.com>
 <7c895879cfd1e15dd76c2469b417b48d0462d7df.1345743801.git.ecashin@coraid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ed Cashin <ecashin@coraid.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server505a.appriver.com ([98.129.35.4]:3996 "EHLO
	server505.appriver.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754673Ab2HWU4v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 16:56:51 -0400
Received: from [98.129.35.1] (HELO smtp.exg5.exghost.com)
  by server505.appriver.com (CommuniGate Pro SMTP 5.4.4)
  with ESMTPS id 314875883 for netdev@vger.kernel.org; Thu, 23 Aug 2012 15:46:47 -0500
In-Reply-To: <7c895879cfd1e15dd76c2469b417b48d0462d7df.1345743801.git.ecashin@coraid.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I should have Cc'ed netdev for this patch.  The series was only sent to linux-kernel, sorry.

On Aug 17, 2012, at 9:18 PM, Ed Cashin wrote:

> This patch adds the ability to work with large packets composed of a
> number of segments, using the scatter gather feature of the block
> layer (biovecs) and the network layer (skb frag array).  The
> motivation is the performance gained by using a packet data payload
> greater than a page size and by using the network card's scatter
> gather feature.
> 
> Users of the out-of-tree aoe driver already had these changes, but
> since early 2011, they have complained of increased memory utilization
> and higher CPU utilization during heavy writes.[1] The commit below
> appears related, as it disables scatter gather on non-IP protocols
> inside the harmonize_features function, even when the NIC supports sg.
> 
>  commit f01a5236bd4b140198fbcc550f085e8361fd73fa
>  Author: Jesse Gross <jesse@nicira.com>
>  Date:   Sun Jan 9 06:23:31 2011 +0000
> 
>      net offloading: Generalize netif_get_vlan_features().
> 
> With that regression in place, transmits always linearize sg AoE
> packets, but in-kernel users did not have this patch.  Before 2.6.38,
> though, these changes were working to allow sg to increase
> performance.
> 
> 1. http://www.spinics.net/lists/linux-mm/msg15184.html
> 
> Signed-off-by: Ed Cashin <ecashin@coraid.com>
> ---
> drivers/block/aoe/aoe.h    |    2 +
> drivers/block/aoe/aoeblk.c |    3 +
> drivers/block/aoe/aoecmd.c |  138 ++++++++++++++++++++++++++++++-------------
> drivers/block/aoe/aoedev.c |    1 +
> drivers/block/aoe/aoenet.c |   13 +++-
> 5 files changed, 111 insertions(+), 46 deletions(-)
> 
> diff --git a/drivers/block/aoe/aoe.h b/drivers/block/aoe/aoe.h
> index db195ab..8ca8c8a 100644
> --- a/drivers/block/aoe/aoe.h
> +++ b/drivers/block/aoe/aoe.h
> @@ -119,6 +119,8 @@ struct frame {
> 	ulong bcnt;
> 	sector_t lba;
> 	struct sk_buff *skb;
> +	struct bio_vec *bv;
> +	ulong bv_off;
> };
> 
> struct aoeif {
> diff --git a/drivers/block/aoe/aoeblk.c b/drivers/block/aoe/aoeblk.c
> index 321de7b..1471f81 100644
> --- a/drivers/block/aoe/aoeblk.c
> +++ b/drivers/block/aoe/aoeblk.c
> @@ -279,6 +279,9 @@ aoeblk_gdalloc(void *vp)
> 	if (bdi_init(&d->blkq->backing_dev_info))
> 		goto err_blkq;
> 	spin_lock_irqsave(&d->lock, flags);
> +	blk_queue_max_hw_sectors(d->blkq, BLK_DEF_MAX_SECTORS);
> +	d->blkq->backing_dev_info.ra_pages = BLK_DEF_MAX_SECTORS * 1024;
> +	d->blkq->backing_dev_info.ra_pages /= PAGE_CACHE_SIZE;
> 	gd->major = AOE_MAJOR;
> 	gd->first_minor = d->sysminor * AOE_PARTITIONS;
> 	gd->fops = &aoe_bdops;
> diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
> index de0435e..f10ab49 100644
> --- a/drivers/block/aoe/aoecmd.c
> +++ b/drivers/block/aoe/aoecmd.c
> @@ -164,7 +164,8 @@ freeframe(struct aoedev *d)
> 						rf = f;
> 					continue;
> 				}
> -gotone:				skb_shinfo(skb)->nr_frags = skb->data_len = 0;
> +gotone:				skb->truesize -= skb->data_len;
> +				skb_shinfo(skb)->nr_frags = skb->data_len = 0;
> 				skb_trim(skb, 0);
> 				d->tgt = t;
> 				ifrotate(*t);
> @@ -200,6 +201,24 @@ gotone:				skb_shinfo(skb)->nr_frags = skb->data_len = 0;
> 	return NULL;
> }
> 
> +static void
> +skb_fillup(struct sk_buff *skb, struct bio_vec *bv, ulong off, ulong cnt)
> +{
> +	int frag = 0;
> +	ulong fcnt;
> +loop:
> +	fcnt = bv->bv_len - (off - bv->bv_offset);
> +	if (fcnt > cnt)
> +		fcnt = cnt;
> +	skb_fill_page_desc(skb, frag++, bv->bv_page, off, fcnt);
> +	cnt -= fcnt;
> +	if (cnt <= 0)
> +		return;
> +	bv++;
> +	off = bv->bv_offset;
> +	goto loop;
> +}
> +
> static int
> aoecmd_ata_rw(struct aoedev *d)
> {
> @@ -210,7 +229,7 @@ aoecmd_ata_rw(struct aoedev *d)
> 	struct bio_vec *bv;
> 	struct aoetgt *t;
> 	struct sk_buff *skb;
> -	ulong bcnt;
> +	ulong bcnt, fbcnt;
> 	char writebit, extbit;
> 
> 	writebit = 0x10;
> @@ -225,8 +244,28 @@ aoecmd_ata_rw(struct aoedev *d)
> 	bcnt = t->ifp->maxbcnt;
> 	if (bcnt == 0)
> 		bcnt = DEFAULTBCNT;
> -	if (bcnt > buf->bv_resid)
> -		bcnt = buf->bv_resid;
> +	if (bcnt > buf->resid)
> +		bcnt = buf->resid;
> +	fbcnt = bcnt;
> +	f->bv = buf->bv;
> +	f->bv_off = f->bv->bv_offset + (f->bv->bv_len - buf->bv_resid);
> +	do {
> +		if (fbcnt < buf->bv_resid) {
> +			buf->bv_resid -= fbcnt;
> +			buf->resid -= fbcnt;
> +			break;
> +		}
> +		fbcnt -= buf->bv_resid;
> +		buf->resid -= buf->bv_resid;
> +		if (buf->resid == 0) {
> +			d->inprocess = NULL;
> +			break;
> +		}
> +		buf->bv++;
> +		buf->bv_resid = buf->bv->bv_len;
> +		WARN_ON(buf->bv_resid == 0);
> +	} while (fbcnt);
> +
> 	/* initialize the headers & frame */
> 	skb = f->skb;
> 	h = (struct aoe_hdr *) skb_mac_header(skb);
> @@ -237,7 +276,6 @@ aoecmd_ata_rw(struct aoedev *d)
> 	t->nout++;
> 	f->waited = 0;
> 	f->buf = buf;
> -	f->bufaddr = page_address(bv->bv_page) + buf->bv_off;
> 	f->bcnt = bcnt;
> 	f->lba = buf->sector;
> 
> @@ -252,10 +290,11 @@ aoecmd_ata_rw(struct aoedev *d)
> 		ah->lba3 |= 0xe0;	/* LBA bit + obsolete 0xa0 */
> 	}
> 	if (bio_data_dir(buf->bio) == WRITE) {
> -		skb_fill_page_desc(skb, 0, bv->bv_page, buf->bv_off, bcnt);
> +		skb_fillup(skb, f->bv, f->bv_off, bcnt);
> 		ah->aflags |= AOEAFL_WRITE;
> 		skb->len += bcnt;
> 		skb->data_len = bcnt;
> +		skb->truesize += bcnt;
> 		t->wpkts++;
> 	} else {
> 		t->rpkts++;
> @@ -266,18 +305,7 @@ aoecmd_ata_rw(struct aoedev *d)
> 
> 	/* mark all tracking fields and load out */
> 	buf->nframesout += 1;
> -	buf->bv_off += bcnt;
> -	buf->bv_resid -= bcnt;
> -	buf->resid -= bcnt;
> 	buf->sector += bcnt >> 9;
> -	if (buf->resid == 0) {
> -		d->inprocess = NULL;
> -	} else if (buf->bv_resid == 0) {
> -		buf->bv = ++bv;
> -		buf->bv_resid = bv->bv_len;
> -		WARN_ON(buf->bv_resid == 0);
> -		buf->bv_off = bv->bv_offset;
> -	}
> 
> 	skb->dev = t->ifp->nd;
> 	skb = skb_clone(skb, GFP_ATOMIC);
> @@ -364,14 +392,12 @@ resend(struct aoedev *d, struct aoetgt *t, struct frame *f)
> 		put_lba(ah, f->lba);
> 
> 		n = f->bcnt;
> -		if (n > DEFAULTBCNT)
> -			n = DEFAULTBCNT;
> 		ah->scnt = n >> 9;
> 		if (ah->aflags & AOEAFL_WRITE) {
> -			skb_fill_page_desc(skb, 0, virt_to_page(f->bufaddr),
> -				offset_in_page(f->bufaddr), n);
> +			skb_fillup(skb, f->bv, f->bv_off, n);
> 			skb->len = sizeof *h + sizeof *ah + n;
> 			skb->data_len = n;
> +			skb->truesize += n;
> 		}
> 	}
> 	skb->dev = t->ifp->nd;
> @@ -530,20 +556,6 @@ rexmit_timer(ulong vp)
> 				ejectif(t, ifp);
> 				ifp = NULL;
> 			}
> -
> -			if (ata_scnt(skb_mac_header(f->skb)) > DEFAULTBCNT / 512
> -			&& ifp && ++ifp->lostjumbo > (t->nframes << 1)
> -			&& ifp->maxbcnt != DEFAULTBCNT) {
> -				printk(KERN_INFO
> -					"aoe: e%ld.%d: "
> -					"too many lost jumbo on "
> -					"%s:%pm - "
> -					"falling back to %d frames.\n",
> -					d->aoemajor, d->aoeminor,
> -					ifp->nd->name, t->addr,
> -					DEFAULTBCNT);
> -				ifp->maxbcnt = 0;
> -			}
> 			resend(d, t, f);
> 		}
> 
> @@ -736,6 +748,45 @@ diskstats(struct gendisk *disk, struct bio *bio, ulong duration, sector_t sector
> 	part_stat_unlock();
> }
> 
> +static void
> +bvcpy(struct bio_vec *bv, ulong off, struct sk_buff *skb, ulong cnt)
> +{
> +	ulong fcnt;
> +	char *p;
> +	int soff = 0;
> +loop:
> +	fcnt = bv->bv_len - (off - bv->bv_offset);
> +	if (fcnt > cnt)
> +		fcnt = cnt;
> +	p = page_address(bv->bv_page) + off;
> +	skb_copy_bits(skb, soff, p, fcnt);
> +	soff += fcnt;
> +	cnt -= fcnt;
> +	if (cnt <= 0)
> +		return;
> +	bv++;
> +	off = bv->bv_offset;
> +	goto loop;
> +}
> +
> +static void
> +fadvance(struct frame *f, ulong cnt)
> +{
> +	ulong fcnt;
> +
> +	f->lba += cnt >> 9;
> +loop:
> +	fcnt = f->bv->bv_len - (f->bv_off - f->bv->bv_offset);
> +	if (fcnt > cnt) {
> +		f->bv_off += cnt;
> +		return;
> +	}
> +	cnt -= fcnt;
> +	f->bv++;
> +	f->bv_off = f->bv->bv_offset;
> +	goto loop;
> +}
> +
> void
> aoecmd_ata_rsp(struct sk_buff *skb)
> {
> @@ -753,6 +804,7 @@ aoecmd_ata_rsp(struct sk_buff *skb)
> 	u16 aoemajor;
> 
> 	hin = (struct aoe_hdr *) skb_mac_header(skb);
> +	skb_pull(skb, sizeof(*hin));
> 	aoemajor = get_unaligned_be16(&hin->major);
> 	d = aoedev_by_aoeaddr(aoemajor, hin->minor);
> 	if (d == NULL) {
> @@ -790,7 +842,8 @@ aoecmd_ata_rsp(struct sk_buff *skb)
> 
> 	calc_rttavg(d, tsince(f->tag));
> 
> -	ahin = (struct aoe_atahdr *) (hin+1);
> +	ahin = (struct aoe_atahdr *) skb->data;
> +	skb_pull(skb, sizeof(*ahin));
> 	hout = (struct aoe_hdr *) skb_mac_header(f->skb);
> 	ahout = (struct aoe_atahdr *) (hout+1);
> 	buf = f->buf;
> @@ -809,7 +862,7 @@ aoecmd_ata_rsp(struct sk_buff *skb)
> 		switch (ahout->cmdstat) {
> 		case ATA_CMD_PIO_READ:
> 		case ATA_CMD_PIO_READ_EXT:
> -			if (skb->len - sizeof *hin - sizeof *ahin < n) {
> +			if (skb->len < n) {
> 				printk(KERN_ERR
> 					"aoe: %s.  skb->len=%d need=%ld\n",
> 					"runt data size in read", skb->len, n);
> @@ -817,7 +870,7 @@ aoecmd_ata_rsp(struct sk_buff *skb)
> 				spin_unlock_irqrestore(&d->lock, flags);
> 				return;
> 			}
> -			memcpy(f->bufaddr, ahin+1, n);
> +			bvcpy(f->bv, f->bv_off, skb, n);
> 		case ATA_CMD_PIO_WRITE:
> 		case ATA_CMD_PIO_WRITE_EXT:
> 			ifp = getif(t, skb->dev);
> @@ -827,21 +880,22 @@ aoecmd_ata_rsp(struct sk_buff *skb)
> 					ifp->lostjumbo = 0;
> 			}
> 			if (f->bcnt -= n) {
> -				f->lba += n >> 9;
> -				f->bufaddr += n;
> +				fadvance(f, n);
> 				resend(d, t, f);
> 				goto xmit;
> 			}
> 			break;
> 		case ATA_CMD_ID_ATA:
> -			if (skb->len - sizeof *hin - sizeof *ahin < 512) {
> +			if (skb->len < 512) {
> 				printk(KERN_INFO
> 					"aoe: runt data size in ataid.  skb->len=%d\n",
> 					skb->len);
> 				spin_unlock_irqrestore(&d->lock, flags);
> 				return;
> 			}
> -			ataid_complete(d, t, (char *) (ahin+1));
> +			if (skb_linearize(skb))
> +				break;
> +			ataid_complete(d, t, skb->data);
> 			break;
> 		default:
> 			printk(KERN_INFO
> diff --git a/drivers/block/aoe/aoedev.c b/drivers/block/aoe/aoedev.c
> index 6b5110a..b2d1fd3 100644
> --- a/drivers/block/aoe/aoedev.c
> +++ b/drivers/block/aoe/aoedev.c
> @@ -182,6 +182,7 @@ skbfree(struct sk_buff *skb)
> 			"cannot free skb -- memory leaked.");
> 		return;
> 	}
> +	skb->truesize -= skb->data_len;
> 	skb_shinfo(skb)->nr_frags = skb->data_len = 0;
> 	skb_trim(skb, 0);
> 	dev_kfree_skb(skb);
> diff --git a/drivers/block/aoe/aoenet.c b/drivers/block/aoe/aoenet.c
> index 4d3bc0d..0787807 100644
> --- a/drivers/block/aoe/aoenet.c
> +++ b/drivers/block/aoe/aoenet.c
> @@ -102,7 +102,9 @@ static int
> aoenet_rcv(struct sk_buff *skb, struct net_device *ifp, struct packet_type *pt, struct net_device *orig_dev)
> {
> 	struct aoe_hdr *h;
> +	struct aoe_atahdr *ah;
> 	u32 n;
> +	int sn;
> 
> 	if (dev_net(ifp) != &init_net)
> 		goto exit;
> @@ -110,13 +112,16 @@ aoenet_rcv(struct sk_buff *skb, struct net_device *ifp, struct packet_type *pt,
> 	skb = skb_share_check(skb, GFP_ATOMIC);
> 	if (skb == NULL)
> 		return 0;
> -	if (skb_linearize(skb))
> -		goto exit;
> 	if (!is_aoe_netif(ifp))
> 		goto exit;
> 	skb_push(skb, ETH_HLEN);	/* (1) */
> -
> -	h = (struct aoe_hdr *) skb_mac_header(skb);
> +	sn = sizeof(*h) + sizeof(*ah);
> +	if (skb->len >= sn) {
> +		sn -= skb_headlen(skb);
> +		if (sn > 0 && !__pskb_pull_tail(skb, sn))
> +			goto exit;
> +	}
> +	h = (struct aoe_hdr *) skb->data;
> 	n = get_unaligned_be32(&h->tag);
> 	if ((h->verfl & AOEFL_RSP) == 0 || (n & 1<<31))
> 		goto exit;
> -- 
> 1.7.2.5
> 

-- 
  Ed Cashin
  ecashin@coraid.com
