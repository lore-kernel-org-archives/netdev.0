From: Krishna Kumar2 <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC 3/3] virtio_net: limit xmit polling
Date: Thu, 2 Jun 2011 19:47:48 +0530
Message-ID: <OF990F08C5.2ECE35B1-ON652578A3.004DC0FA-652578A3.004E3FE4@in.ibm.com>
References: <cover.1306921434.git.mst@redhat.com>
	<1ec8eec325839ecf2eac9930a230361e7956047c.1306921434.git.mst@redhat.com>
	<87pqmwj3am.fsf@rustcorp.com.au> <20110602133425.GJ7141@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=EABBF230DFDE466A8f9e8a93df938690918cEABBF230DFDE466A"
Cc: habanero-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Shirley Ma <xma-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Carsten Otte <cotte-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, steved-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Tom Lendacky <tahm-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20110602133425.GJ7141-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.ozlabs.org/options/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/lguest>
List-Post: <mailto:lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/lguest>,
	<mailto:lguest-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: lguest-bounces+glkvl-lguest=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

--0__=EABBF230DFDE466A8f9e8a93df938690918cEABBF230DFDE466A
Content-type: text/plain; charset=US-ASCII

> OK, I have something very similar, but I still dislike the screw the
> latency part: this path is exactly what the IBM guys seem to hit.  So I
> created two functions: one tries to free a constant number and another
> one up to capacity. I'll post that now.

Please review this patch to see if it looks reasonable (inline and
attachment):

1. Picked comments/code from Michael's code and Rusty's review.
2. virtqueue_min_capacity() needs to be called only if it returned
   empty the last time it was called.
3. Fix return value bug in free_old_xmit_skbs (hangs guest).
4. Stop queue only if capacity is not enough for next xmit.
5. Fix/clean some likely/unlikely checks (hopefully).
6. I think xmit_skb cannot return error since
    virtqueue_enable_cb_delayed() can return false only if
   3/4th space became available, which is what we check.
6. The comments for free_old_xmit_skbs needs to be more
    clear (not done).

I have done some minimal netperf tests with this.

With this patch, add_buf returning capacity seems to be useful - it
allows using fewer virtio API calls.

(See attached file: patch)

Signed-off-by: Krishna Kumar <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/virtio_net.c |  105 ++++++++++++++++++++++---------------
 1 file changed, 64 insertions(+), 41 deletions(-)

diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
--- org/drivers/net/virtio_net.c	2011-06-02 15:49:25.000000000 +0530
+++ new/drivers/net/virtio_net.c	2011-06-02 19:13:02.000000000 +0530
@@ -509,27 +509,43 @@ again:
 	return received;
 }

-/* Check capacity and try to free enough pending old buffers to enable
queueing
- * new ones.  If min_skbs > 0, try to free at least the specified number
of skbs
- * even if the ring already has sufficient capacity.  Return true if we
can
- * guarantee that a following virtqueue_add_buf will succeed. */
-static bool free_old_xmit_skbs(struct virtnet_info *vi, int min_skbs)
+/* Return true if freed a skb, else false */
+static inline bool free_one_old_xmit_skb(struct virtnet_info *vi)
 {
 	struct sk_buff *skb;
 	unsigned int len;
-	bool r;

-	while ((r = virtqueue_min_capacity(vi->svq) < MAX_SKB_FRAGS + 2) ||
-	       min_skbs-- > 0) {
-		skb = virtqueue_get_buf(vi->svq, &len);
-		if (unlikely(!skb))
+	skb = virtqueue_get_buf(vi->svq, &len);
+	if (unlikely(!skb))
+		return 0;
+
+	pr_debug("Sent skb %p\n", skb);
+	vi->dev->stats.tx_bytes += skb->len;
+	vi->dev->stats.tx_packets++;
+	dev_kfree_skb_any(skb);
+	return 1;
+}
+
+static bool free_old_xmit_skbs(struct virtnet_info *vi, int to_free)
+{
+	bool empty = virtqueue_min_capacity(vi->svq) < MAX_SKB_FRAGS + 2;
+
+	do {
+		if (!free_one_old_xmit_skb(vi)) {
+			/* No more skbs to free up */
 			break;
-		pr_debug("Sent skb %p\n", skb);
-		vi->dev->stats.tx_bytes += skb->len;
-		vi->dev->stats.tx_packets++;
-		dev_kfree_skb_any(skb);
-	}
-	return r;
+		}
+
+		if (empty) {
+			/* Check again if there is enough space */
+			empty = virtqueue_min_capacity(vi->svq) <
+				MAX_SKB_FRAGS + 2;
+		} else {
+			--to_free;
+		}
+	} while (to_free > 0);
+
+	return !empty;
 }

 static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
@@ -582,46 +598,53 @@ static int xmit_skb(struct virtnet_info
 static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
-	int ret, n;
+	int capacity;

-	/* Free up space in the ring in case this is the first time we get
-	 * woken up after ring full condition.  Note: this might try to free
-	 * more than strictly necessary if the skb has a small
-	 * number of fragments, but keep it simple. */
-	free_old_xmit_skbs(vi, 0);
+	/* Try to free 2 buffers for every 1 xmit, to stay ahead. */
+	free_old_xmit_skbs(vi, 2);

 	/* Try to transmit */
-	ret = xmit_skb(vi, skb);
+	capacity = xmit_skb(vi, skb);

-	/* Failure to queue is unlikely. It's not a bug though: it might happen
-	 * if we get an interrupt while the queue is still mostly full.
-	 * We could stop the queue and re-enable callbacks (and possibly
return
-	 * TX_BUSY), but as this should be rare, we don't bother. */
-	if (unlikely(ret < 0)) {
+	if (unlikely(capacity < 0)) {
+		/*
+		 * Failure to queue should be impossible. The only way to
+		 * reach here is if we got a cb before 3/4th of space was
+		 * available. We could stop the queue and re-enable
+		 * callbacks (and possibly return TX_BUSY), but we don't
+		 * bother since this is impossible.
+		 */
 		if (net_ratelimit())
-			dev_info(&dev->dev, "TX queue failure: %d\n", ret);
+			dev_info(&dev->dev, "TX queue failure: %d\n", capacity);
 		dev->stats.tx_dropped++;
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
+
 	virtqueue_kick(vi->svq);

 	/* Don't wait up for transmitted skbs to be freed. */
 	skb_orphan(skb);
 	nf_reset(skb);

-	/* Apparently nice girls don't return TX_BUSY; check capacity and stop
-	 * the queue before it gets out of hand.
-	 * Naturally, this wastes entries. */
-	/* We transmit one skb, so try to free at least two pending skbs.
-	 * This is so that we don't hog the skb memory unnecessarily. */
-	if (!likely(free_old_xmit_skbs(vi, 2))) {
-		netif_stop_queue(dev);
-		if (unlikely(!virtqueue_enable_cb_delayed(vi->svq))) {
-			/* More just got used, free them and recheck. */
-			if (!likely(free_old_xmit_skbs(vi, 0))) {
-				netif_start_queue(dev);
-				virtqueue_disable_cb(vi->svq);
+	/*
+	 * Apparently nice girls don't return TX_BUSY; check capacity and
+	 * stop the queue before it gets out of hand. Naturally, this wastes
+	 * entries.
+	 */
+	if (capacity < 2+MAX_SKB_FRAGS) {
+		/*
+		 * We don't have enough space for the next packet. Try
+		 * freeing more.
+		 */
+		if (likely(!free_old_xmit_skbs(vi, UINT_MAX))) {
+			netif_stop_queue(dev);
+			if (unlikely(!virtqueue_enable_cb_delayed(vi->svq))) {
+				/* More just got used, free them and recheck. */
+				if (likely(free_old_xmit_skbs(vi, UINT_MAX))) {
+					netif_start_queue(dev);
+					virtqueue_disable_cb(vi->svq);
+				}
 			}
 		}
 	}
--0__=EABBF230DFDE466A8f9e8a93df938690918cEABBF230DFDE466A
Content-type: application/octet-stream;
	name="patch"
Content-Disposition: attachment; filename="patch"
Content-transfer-encoding: base64

Ik1pY2hhZWwgUy4gVHNpcmtpbiIgPG1zdEByZWRoYXQuY29tPiB3cm90ZSBvbiAwNi8wMi8yMDEx
IDA3OjA0OjI1IFBNOgoKPiBPSywgSSBoYXZlIHNvbWV0aGluZyB2ZXJ5IHNpbWlsYXIsIGJ1dCBJ
IHN0aWxsIGRpc2xpa2UgdGhlIHNjcmV3IHRoZQo+IGxhdGVuY3kgcGFydDogdGhpcyBwYXRoIGlz
IGV4YWN0bHkgd2hhdCB0aGUgSUJNIGd1eXMgc2VlbSB0byBoaXQuICBTbyBJCj4gY3JlYXRlZCB0
d28gZnVuY3Rpb25zOiBvbmUgdHJpZXMgdG8gZnJlZSBhIGNvbnN0YW50IG51bWJlciBhbmQgYW5v
dGhlcgo+IG9uZSB1cCB0byBjYXBhY2l0eS4gSSdsbCBwb3N0IHRoYXQgbm93LgoKUGxlYXNlIHJl
dmlldyB0aGlzIHBhdGNoIHRvIHNlZSBpZiBpdCBsb29rcyByZWFzb25hYmxlOgoKMS4gUGlja2Vk
IGNvbW1lbnRzL2NvZGUgZnJvbSBNU1QncyBjb2RlIGFuZCBSdXN0eSdzIHJldmlldy4KMi4gdmly
dHF1ZXVlX21pbl9jYXBhY2l0eSgpIG5lZWRzIHRvIGJlIGNhbGxlZCBvbmx5IGlmIGl0IHJldHVy
bmVkCiAgIGVtcHR5IHRoZSBsYXN0IHRpbWUgaXQgd2FzIGNhbGxlZC4KMy4gRml4IHJldHVybiB2
YWx1ZSBidWcgaW4gZnJlZV9vbGRfeG1pdF9za2JzIChoYW5ncyBndWVzdCkuCjQuIFN0b3AgcXVl
dWUgb25seSBpZiBjYXBhY2l0eSBpcyBub3QgZW5vdWdoIGZvciBuZXh0IHhtaXQuCjUuIEZpeC9j
bGVhbiBzb21lIGxpa2VseS91bmxpa2VseSBjaGVja3MgKGhvcGVmdWxseSkuCgpJIGhhdmUgZG9u
ZSBzb21lIG1pbmltYWwgbmV0cGVyZiB0ZXN0cyB3aXRoIHRoaXMuCgpXaXRoIHRoaXMgcGF0Y2gs
IGFkZF9idWYgcmV0dXJuaW5nIGNhcGFjaXR5IHNlZW1zIHRvIGJlIHVzZWZ1bCAtIGl0CmFsbG93
cyBsZXNzIHZpcnRpbyBBUEkgY2FsbHMuCgpTaWduZWQtb2ZmLWJ5OiBLcmlzaG5hIEt1bWFyIDxr
cmt1bWFyMkBpbi5pYm0uY29tPgotLS0KIGRyaXZlcnMvbmV0L3ZpcnRpb19uZXQuYyB8ICAxMDUg
KysrKysrKysrKysrKysrKysrKysrKy0tLS0tLS0tLS0tLS0tLQogMSBmaWxlIGNoYW5nZWQsIDY0
IGluc2VydGlvbnMoKyksIDQxIGRlbGV0aW9ucygtKQoKZGlmZiAtcnVOcCBvcmcvZHJpdmVycy9u
ZXQvdmlydGlvX25ldC5jIG5ldy9kcml2ZXJzL25ldC92aXJ0aW9fbmV0LmMKLS0tIG9yZy9kcml2
ZXJzL25ldC92aXJ0aW9fbmV0LmMJMjAxMS0wNi0wMiAxNTo0OToyNS4wMDAwMDAwMDAgKzA1MzAK
KysrIG5ldy9kcml2ZXJzL25ldC92aXJ0aW9fbmV0LmMJMjAxMS0wNi0wMiAxOToxMzowMi4wMDAw
MDAwMDAgKzA1MzAKQEAgLTUwOSwyNyArNTA5LDQzIEBAIGFnYWluOgogCXJldHVybiByZWNlaXZl
ZDsKIH0KIAotLyogQ2hlY2sgY2FwYWNpdHkgYW5kIHRyeSB0byBmcmVlIGVub3VnaCBwZW5kaW5n
IG9sZCBidWZmZXJzIHRvIGVuYWJsZSBxdWV1ZWluZwotICogbmV3IG9uZXMuICBJZiBtaW5fc2ti
cyA+IDAsIHRyeSB0byBmcmVlIGF0IGxlYXN0IHRoZSBzcGVjaWZpZWQgbnVtYmVyIG9mIHNrYnMK
LSAqIGV2ZW4gaWYgdGhlIHJpbmcgYWxyZWFkeSBoYXMgc3VmZmljaWVudCBjYXBhY2l0eS4gIFJl
dHVybiB0cnVlIGlmIHdlIGNhbgotICogZ3VhcmFudGVlIHRoYXQgYSBmb2xsb3dpbmcgdmlydHF1
ZXVlX2FkZF9idWYgd2lsbCBzdWNjZWVkLiAqLwotc3RhdGljIGJvb2wgZnJlZV9vbGRfeG1pdF9z
a2JzKHN0cnVjdCB2aXJ0bmV0X2luZm8gKnZpLCBpbnQgbWluX3NrYnMpCisvKiBSZXR1cm4gdHJ1
ZSBpZiBmcmVlZCBhIHNrYiwgZWxzZSBmYWxzZSAqLworc3RhdGljIGlubGluZSBib29sIGZyZWVf
b25lX29sZF94bWl0X3NrYihzdHJ1Y3QgdmlydG5ldF9pbmZvICp2aSkKIHsKIAlzdHJ1Y3Qgc2tf
YnVmZiAqc2tiOwogCXVuc2lnbmVkIGludCBsZW47Ci0JYm9vbCByOwogCi0Jd2hpbGUgKChyID0g
dmlydHF1ZXVlX21pbl9jYXBhY2l0eSh2aS0+c3ZxKSA8IE1BWF9TS0JfRlJBR1MgKyAyKSB8fAot
CSAgICAgICBtaW5fc2ticy0tID4gMCkgewotCQlza2IgPSB2aXJ0cXVldWVfZ2V0X2J1Zih2aS0+
c3ZxLCAmbGVuKTsKLQkJaWYgKHVubGlrZWx5KCFza2IpKQorCXNrYiA9IHZpcnRxdWV1ZV9nZXRf
YnVmKHZpLT5zdnEsICZsZW4pOworCWlmICh1bmxpa2VseSghc2tiKSkKKwkJcmV0dXJuIDA7CisK
Kwlwcl9kZWJ1ZygiU2VudCBza2IgJXBcbiIsIHNrYik7CisJdmktPmRldi0+c3RhdHMudHhfYnl0
ZXMgKz0gc2tiLT5sZW47CisJdmktPmRldi0+c3RhdHMudHhfcGFja2V0cysrOworCWRldl9rZnJl
ZV9za2JfYW55KHNrYik7CisJcmV0dXJuIDE7Cit9CisKK3N0YXRpYyBib29sIGZyZWVfb2xkX3ht
aXRfc2ticyhzdHJ1Y3QgdmlydG5ldF9pbmZvICp2aSwgaW50IHRvX2ZyZWUpCit7CisJYm9vbCBl
bXB0eSA9IHZpcnRxdWV1ZV9taW5fY2FwYWNpdHkodmktPnN2cSkgPCBNQVhfU0tCX0ZSQUdTICsg
MjsKKworCWRvIHsKKwkJaWYgKCFmcmVlX29uZV9vbGRfeG1pdF9za2IodmkpKSB7CisJCQkvKiBO
byBtb3JlIHNrYnMgdG8gZnJlZSB1cCAqLwogCQkJYnJlYWs7Ci0JCXByX2RlYnVnKCJTZW50IHNr
YiAlcFxuIiwgc2tiKTsKLQkJdmktPmRldi0+c3RhdHMudHhfYnl0ZXMgKz0gc2tiLT5sZW47Ci0J
CXZpLT5kZXYtPnN0YXRzLnR4X3BhY2tldHMrKzsKLQkJZGV2X2tmcmVlX3NrYl9hbnkoc2tiKTsK
LQl9Ci0JcmV0dXJuIHI7CisJCX0KKworCQlpZiAoZW1wdHkpIHsKKwkJCS8qIENoZWNrIGFnYWlu
IGlmIHRoZXJlIGlzIGVub3VnaCBzcGFjZSAqLworCQkJZW1wdHkgPSB2aXJ0cXVldWVfbWluX2Nh
cGFjaXR5KHZpLT5zdnEpIDwKKwkJCQlNQVhfU0tCX0ZSQUdTICsgMjsKKwkJfSBlbHNlIHsKKwkJ
CS0tdG9fZnJlZTsKKwkJfQorCX0gd2hpbGUgKHRvX2ZyZWUgPiAwKTsKKworCXJldHVybiAhZW1w
dHk7CiB9CiAKIHN0YXRpYyBpbnQgeG1pdF9za2Ioc3RydWN0IHZpcnRuZXRfaW5mbyAqdmksIHN0
cnVjdCBza19idWZmICpza2IpCkBAIC01ODIsNDYgKzU5OCw1MyBAQCBzdGF0aWMgaW50IHhtaXRf
c2tiKHN0cnVjdCB2aXJ0bmV0X2luZm8gCiBzdGF0aWMgbmV0ZGV2X3R4X3Qgc3RhcnRfeG1pdChz
dHJ1Y3Qgc2tfYnVmZiAqc2tiLCBzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KQogewogCXN0cnVjdCB2
aXJ0bmV0X2luZm8gKnZpID0gbmV0ZGV2X3ByaXYoZGV2KTsKLQlpbnQgcmV0LCBuOworCWludCBj
YXBhY2l0eTsKIAotCS8qIEZyZWUgdXAgc3BhY2UgaW4gdGhlIHJpbmcgaW4gY2FzZSB0aGlzIGlz
IHRoZSBmaXJzdCB0aW1lIHdlIGdldAotCSAqIHdva2VuIHVwIGFmdGVyIHJpbmcgZnVsbCBjb25k
aXRpb24uICBOb3RlOiB0aGlzIG1pZ2h0IHRyeSB0byBmcmVlCi0JICogbW9yZSB0aGFuIHN0cmlj
dGx5IG5lY2Vzc2FyeSBpZiB0aGUgc2tiIGhhcyBhIHNtYWxsCi0JICogbnVtYmVyIG9mIGZyYWdt
ZW50cywgYnV0IGtlZXAgaXQgc2ltcGxlLiAqLwotCWZyZWVfb2xkX3htaXRfc2ticyh2aSwgMCk7
CisJLyogVHJ5IHRvIGZyZWUgMiBidWZmZXJzIGZvciBldmVyeSAxIHhtaXQsIHRvIHN0YXkgYWhl
YWQuICovCisJZnJlZV9vbGRfeG1pdF9za2JzKHZpLCAyKTsKIAogCS8qIFRyeSB0byB0cmFuc21p
dCAqLwotCXJldCA9IHhtaXRfc2tiKHZpLCBza2IpOworCWNhcGFjaXR5ID0geG1pdF9za2Iodmks
IHNrYik7CiAKLQkvKiBGYWlsdXJlIHRvIHF1ZXVlIGlzIHVubGlrZWx5LiBJdCdzIG5vdCBhIGJ1
ZyB0aG91Z2g6IGl0IG1pZ2h0IGhhcHBlbgotCSAqIGlmIHdlIGdldCBhbiBpbnRlcnJ1cHQgd2hp
bGUgdGhlIHF1ZXVlIGlzIHN0aWxsIG1vc3RseSBmdWxsLgotCSAqIFdlIGNvdWxkIHN0b3AgdGhl
IHF1ZXVlIGFuZCByZS1lbmFibGUgY2FsbGJhY2tzIChhbmQgcG9zc2libHkgcmV0dXJuCi0JICog
VFhfQlVTWSksIGJ1dCBhcyB0aGlzIHNob3VsZCBiZSByYXJlLCB3ZSBkb24ndCBib3RoZXIuICov
Ci0JaWYgKHVubGlrZWx5KHJldCA8IDApKSB7CisJaWYgKHVubGlrZWx5KGNhcGFjaXR5IDwgMCkp
IHsKKwkJLyoKKwkJICogRmFpbHVyZSB0byBxdWV1ZSBzaG91bGQgYmUgaW1wb3NzaWJsZS4gVGhl
IG9ubHkgd2F5IHRvCisJCSAqIHJlYWNoIGhlcmUgaXMgaWYgd2UgZ290IGEgY2IgYmVmb3JlIDMv
NHRoIG9mIHNwYWNlIHdhcworCQkgKiBhdmFpbGFibGUuIFdlIGNvdWxkIHN0b3AgdGhlIHF1ZXVl
IGFuZCByZS1lbmFibGUKKwkJICogY2FsbGJhY2tzIChhbmQgcG9zc2libHkgcmV0dXJuIFRYX0JV
U1kpLCBidXQgd2UgZG9uJ3QKKwkJICogYm90aGVyIHNpbmNlIHRoaXMgaXMgaW1wb3NzaWJsZS4K
KwkJICovCiAJCWlmIChuZXRfcmF0ZWxpbWl0KCkpCi0JCQlkZXZfaW5mbygmZGV2LT5kZXYsICJU
WCBxdWV1ZSBmYWlsdXJlOiAlZFxuIiwgcmV0KTsKKwkJCWRldl9pbmZvKCZkZXYtPmRldiwgIlRY
IHF1ZXVlIGZhaWx1cmU6ICVkXG4iLCBjYXBhY2l0eSk7CiAJCWRldi0+c3RhdHMudHhfZHJvcHBl
ZCsrOwogCQlrZnJlZV9za2Ioc2tiKTsKIAkJcmV0dXJuIE5FVERFVl9UWF9PSzsKIAl9CisKIAl2
aXJ0cXVldWVfa2ljayh2aS0+c3ZxKTsKIAogCS8qIERvbid0IHdhaXQgdXAgZm9yIHRyYW5zbWl0
dGVkIHNrYnMgdG8gYmUgZnJlZWQuICovCiAJc2tiX29ycGhhbihza2IpOwogCW5mX3Jlc2V0KHNr
Yik7CiAKLQkvKiBBcHBhcmVudGx5IG5pY2UgZ2lybHMgZG9uJ3QgcmV0dXJuIFRYX0JVU1k7IGNo
ZWNrIGNhcGFjaXR5IGFuZCBzdG9wCi0JICogdGhlIHF1ZXVlIGJlZm9yZSBpdCBnZXRzIG91dCBv
ZiBoYW5kLgotCSAqIE5hdHVyYWxseSwgdGhpcyB3YXN0ZXMgZW50cmllcy4gKi8KLQkvKiBXZSB0
cmFuc21pdCBvbmUgc2tiLCBzbyB0cnkgdG8gZnJlZSBhdCBsZWFzdCB0d28gcGVuZGluZyBza2Jz
LgotCSAqIFRoaXMgaXMgc28gdGhhdCB3ZSBkb24ndCBob2cgdGhlIHNrYiBtZW1vcnkgdW5uZWNl
c3NhcmlseS4gKi8KLQlpZiAoIWxpa2VseShmcmVlX29sZF94bWl0X3NrYnModmksIDIpKSkgewot
CQluZXRpZl9zdG9wX3F1ZXVlKGRldik7Ci0JCWlmICh1bmxpa2VseSghdmlydHF1ZXVlX2VuYWJs
ZV9jYl9kZWxheWVkKHZpLT5zdnEpKSkgewotCQkJLyogTW9yZSBqdXN0IGdvdCB1c2VkLCBmcmVl
IHRoZW0gYW5kIHJlY2hlY2suICovCi0JCQlpZiAoIWxpa2VseShmcmVlX29sZF94bWl0X3NrYnMo
dmksIDApKSkgewotCQkJCW5ldGlmX3N0YXJ0X3F1ZXVlKGRldik7Ci0JCQkJdmlydHF1ZXVlX2Rp
c2FibGVfY2IodmktPnN2cSk7CisJLyoKKwkgKiBBcHBhcmVudGx5IG5pY2UgZ2lybHMgZG9uJ3Qg
cmV0dXJuIFRYX0JVU1k7IGNoZWNrIGNhcGFjaXR5IGFuZAorCSAqIHN0b3AgdGhlIHF1ZXVlIGJl
Zm9yZSBpdCBnZXRzIG91dCBvZiBoYW5kLiBOYXR1cmFsbHksIHRoaXMgd2FzdGVzCisJICogZW50
cmllcy4gCisJICovCisJaWYgKGNhcGFjaXR5IDwgMitNQVhfU0tCX0ZSQUdTKSB7CisJCS8qCisJ
CSAqIFdlIGRvbid0IGhhdmUgZW5vdWdoIHNwYWNlIGZvciB0aGUgbmV4dCBwYWNrZXQuIFRyeQor
CQkgKiBmcmVlaW5nIG1vcmUuCisJCSAqLworCQlpZiAobGlrZWx5KCFmcmVlX29sZF94bWl0X3Nr
YnModmksIFVJTlRfTUFYKSkpIHsKKwkJCW5ldGlmX3N0b3BfcXVldWUoZGV2KTsKKwkJCWlmICh1
bmxpa2VseSghdmlydHF1ZXVlX2VuYWJsZV9jYl9kZWxheWVkKHZpLT5zdnEpKSkgeworCQkJCS8q
IE1vcmUganVzdCBnb3QgdXNlZCwgZnJlZSB0aGVtIGFuZCByZWNoZWNrLiAqLworCQkJCWlmIChs
aWtlbHkoZnJlZV9vbGRfeG1pdF9za2JzKHZpLCBVSU5UX01BWCkpKSB7CisJCQkJCW5ldGlmX3N0
YXJ0X3F1ZXVlKGRldik7CisJCQkJCXZpcnRxdWV1ZV9kaXNhYmxlX2NiKHZpLT5zdnEpOworCQkJ
CX0KIAkJCX0KIAkJfQogCX0K

--0__=EABBF230DFDE466A8f9e8a93df938690918cEABBF230DFDE466A
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Lguest mailing list
Lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
https://lists.ozlabs.org/listinfo/lguest

--0__=EABBF230DFDE466A8f9e8a93df938690918cEABBF230DFDE466A--
