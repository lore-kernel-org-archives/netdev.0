From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net] tun: fix recovery from gup errors
Date: Sun, 23 Jun 2013 17:19:03 +0300
Message-ID: <20130623141903.GA21029@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	Brad Hubbard <bhubbard@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751509Ab3FWOSX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jun 2013 10:18:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

get user pages might fail partially in tun zero copy
mode. To recover we need to put all pages that we got,
but code used a wrong index resulting in double-free
errors.

Reported-by: Brad Hubbard <bhubbard@redhat.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

I haven't figured out why do we get failures,
but recovery is clearly wrong.

This is also -stable material.

 drivers/net/tun.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index bfa9bb4..c098b1e 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1010,8 +1010,9 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 			return -EMSGSIZE;
 		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
 		if (num_pages != size) {
-			for (i = 0; i < num_pages; i++)
-				put_page(page[i]);
+			int j;
+			for (j = 0; j < num_pages; j++)
+				put_page(page[i + j]);
 			return -EFAULT;
 		}
 		truesize = size * PAGE_SIZE;
-- 
MST
