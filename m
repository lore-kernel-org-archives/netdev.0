From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: question about map_read_chunks()
Date: Mon, 20 Feb 2012 12:50:19 +0300
Message-ID: <20120220095019.GA21338@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tom Tucker <tom-/Yg/VP3ZvrM@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I had a couple questions about some map_read_chunks().

net/sunrpc/xprtrdma/svc_rdma_recvfrom.c

   150          ch_bytes = ntohl(ch->rc_target.rs_length);
                ^^^^^^^^
It look like this is 32 bits from the network?

   151          head->arg.head[0] = rqstp->rq_arg.head[0];
   152          head->arg.tail[0] = rqstp->rq_arg.tail[0];
   153          head->arg.pages = &head->pages[head->count];
   154          head->hdr_count = head->count; /* save count of hdr pages */
   155          head->arg.page_base = 0;
   156          head->arg.page_len = ch_bytes;
   157          head->arg.len = rqstp->rq_arg.len + ch_bytes;
                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Can overflow.
   158          head->arg.buflen = rqstp->rq_arg.buflen + ch_bytes;
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Same.  I didn't follow it through to see if an overflow matters.  Does
it?

   159          head->count++;
   160          chl_map->ch[0].start = 0;
   161          while (byte_count) {
   162                  rpl_map->sge[sge_no].iov_base =
   163                          page_address(rqstp->rq_arg.pages[page_no]) + page_off;
   164                  sge_bytes = min_t(int, PAGE_SIZE-page_off, ch_bytes);
                                          ^^^
This is the wrong cast to use.  A large ch_bytes would be counted as a
negative value and get around the cap here.

   165                  rpl_map->sge[sge_no].iov_len = sge_bytes;

regards,
dan carpenter
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
