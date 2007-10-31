From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH]: Fix myri10ge NAPI oops & warnings
Date: Wed, 31 Oct 2007 17:40:06 -0400
Message-ID: <4728F636.9080505@myri.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000803050101060006040301"
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1904 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754914AbXJaVkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 17:40:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000803050101060006040301
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


When testing the myri10ge driver with 2.6.24-rc1, I found
that the machine crashed under heavy load:

Unable to handle kernel paging request at 0000000000100108 RIP:
  [<ffffffff803cc8dd>] net_rx_action+0x11b/0x184

The address corresponds to the list_move_tail() in
netif_rx_complete():
                     if (unlikely(work == weight))
                             list_move_tail(&n->poll_list, list);

Eventually, I traced the crashes to calling netif_rx_complete() with
work_done == budget.  From looking at other drivers, it appears that
one should only call netif_rx_complete() when work_done < budget.

To fix it, I changed the test in myri10ge_poll() so that it refers
to to work_done rather than looking at the rx ring status.  If
work_done is < budget, then that implies we have no more packets to
process. Any races will be resolved by the NIC when the write to
irq_claim is made.

In myri10ge_clean_rx_done(), if we ever exceeded our budget, it would
report a work_done one larger than was acutally done.  This is because
the increment was done in the conditional, so work_done would be
incremented regardless of whether or not the test passed or failed.
This would lead to the WARN_ON_ONCE(work > weight); warning in
net_rx_action triggering.  I've moved the increment of work_done
inside the loop.  Note that this would only be a problem when we had
exceeded our budget.

Signed off by: Andrew Gallatin <gallatin@myri.com>

Andrew Gallatin Myricom Inc



--------------000803050101060006040301
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="myri10ge-napi-oops.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="myri10ge-napi-oops.diff"

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 366e62a..0f306dd 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1151,7 +1151,7 @@ static inline int myri10ge_clean_rx_done
 	u16 length;
 	__wsum checksum;
 
-	while (rx_done->entry[idx].length != 0 && work_done++ < budget) {
+	while (rx_done->entry[idx].length != 0 && work_done < budget) {
 		length = ntohs(rx_done->entry[idx].length);
 		rx_done->entry[idx].length = 0;
 		checksum = csum_unfold(rx_done->entry[idx].checksum);
@@ -1167,6 +1167,7 @@ static inline int myri10ge_clean_rx_done
 		rx_bytes += rx_ok * (unsigned long)length;
 		cnt++;
 		idx = cnt & (myri10ge_max_intr_slots - 1);
+		work_done++;
 	}
 	rx_done->idx = idx;
 	rx_done->cnt = cnt;
@@ -1233,13 +1234,12 @@ static int myri10ge_poll(struct napi_str
 	struct myri10ge_priv *mgp =
 	    container_of(napi, struct myri10ge_priv, napi);
 	struct net_device *netdev = mgp->dev;
-	struct myri10ge_rx_done *rx_done = &mgp->rx_done;
 	int work_done;
 
 	/* process as many rx events as NAPI will allow */
 	work_done = myri10ge_clean_rx_done(mgp, budget);
 
-	if (rx_done->entry[rx_done->idx].length == 0 || !netif_running(netdev)) {
+	if (work_done < budget || !netif_running(netdev)) {
 		netif_rx_complete(netdev, napi);
 		put_be32(htonl(3), mgp->irq_claim);
 	}

--------------000803050101060006040301--
