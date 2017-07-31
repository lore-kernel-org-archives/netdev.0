From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Performance regression with virtio_net
Date: Mon, 31 Jul 2017 16:26:08 +0300
Message-ID: <20170731161903-mutt-send-email-mst@kernel.org>
References: <20170730222552.4fxxnx3jxg4yv65g@multivac.euank.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: seth.forshee@canonical.com, netdev@vger.kernel.org
To: Euan Kemp <euan.kemp@coreos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41234 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751827AbdGaN0K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 09:26:10 -0400
Content-Disposition: inline
In-Reply-To: <20170730222552.4fxxnx3jxg4yv65g@multivac.euank.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 30, 2017 at 03:25:52PM -0700, Euan Kemp wrote:
> I've also observed this performance regression.
> 
> The minimal fix for me is removing the two
> > if (unlikely(len > (unsigned long)ctx))
> checks added in 680557c.
> 
> After digging a little more, the reason that check can fail appears to
> be that add_recvbuf_mergeable sometimes includes a hole at the end,
> which is included in len but not ctx.
> 
> I'd send a patch removing those conditions, but I'm not certain
> whether "truesize" in receive_mergeable should also be changed back to
> be the max of len/ctx, or should remain as-is.
> 
> - Euan

Thanks a lot for looking into it!

I kept this around unchanged from
ab7db91705e95ed1bba1304388936fccfa58c992.  That commit had an internal
reason not to account for that space: not enough bits to do it.  No
longer true so let's account for length exactly.  I'll send a proper
patch after a bit of testing, would appreciate reports reports of
whether this helps very much.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>


diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f41ab0e..782c33f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -889,7 +889,6 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi,
 
 	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
 	buf += headroom; /* advance address leaving hole at front of pkt */
-	ctx = (void *)(unsigned long)len;
 	get_page(alloc_frag->page);
 	alloc_frag->offset += len + headroom;
 	hole = alloc_frag->size - alloc_frag->offset;
@@ -904,6 +903,7 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi,
 	}
 
 	sg_init_one(rq->sg, buf, len);
+	ctx = (void *)(unsigned long)len;
 	err = virtqueue_add_inbuf_ctx(rq->vq, rq->sg, 1, buf, ctx, gfp);
 	if (err < 0)
 		put_page(virt_to_head_page(buf));
-- 
MST
