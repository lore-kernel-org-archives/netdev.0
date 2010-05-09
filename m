From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] fix multi-buffer logging with mergeable buffers
Date: Sun, 9 May 2010 14:10:16 +0300
Message-ID: <20100509111016.GA19453@redhat.com>
References: <1273263068.24088.1.camel@w-dls.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10180 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752782Ab0EILOS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 May 2010 07:14:18 -0400
Content-Disposition: inline
In-Reply-To: <1273263068.24088.1.camel@w-dls.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 07, 2010 at 01:11:08PM -0700, David L Stevens wrote:
> This patch fixes the multibuffer case of logging with
> mergeable buffers.
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

So, I folded this into your original patch submission,
this way we don't get broken logging followed
by a fix (better for bisect). Further, I think it's better to only use log_num
on success. After fixing whitespace (+ needs space around it:
didn't checkpatch complain?) I merged the below,
and rebased my tweaks patch on top.

The result can be found here:
git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-mrg-rxbuf

Compiles fine but I'm a bit busy with other things,
and didn't test at all yet, I'd appreciate testing and reports.

--

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 8ef5e3f..1964ab0 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -877,7 +877,7 @@ int vhost_get_desc_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
 	unsigned int out, in;
 	int seg = 0;
 	int headcount = 0;
-	int r;
+	int r, nlogs = 0;
 
 	while (datalen > 0) {
 		if (headcount >= VHOST_NET_MAX_SG) {
@@ -897,12 +897,18 @@ int vhost_get_desc_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
 			r = -EINVAL;
 			goto err;
 		}
+		if (unlikely(log)) {
+			nlogs += *log_num;
+			log += *log_num;
+		}
 		heads[headcount].len = iov_length(vq->iov + seg, in);
 		datalen -= heads[headcount].len;
 		++headcount;
 		seg += in;
 	}
 	*iovcount = seg;
+	if (unlikely(log))
+		*log_num = nlogs;
 	return headcount;
 err:
 	vhost_discard_desc(vq, headcount);
-- 
MST
