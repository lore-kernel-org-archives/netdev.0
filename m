From: chrono <chrono@open-resource.org>
Subject: [PATCH V3] cdc_ncm: Add support for moving NDP to
	end of NCM frame
Date: Thu, 09 Jul 2015 13:11:51 +0000
Message-ID: <694ab88ace7ed81faad706a248dc465d@apollo.open-resource.org>
References: <00f181fc416046b5f3ea83b445ef85fe@apollo.open-resource.org>
 <5592E970.4020401@elisanet.fi>
 <75c1cffa49f050004339554141dfde77@apollo.open-resource.org>
 <alpine.LNX.2.20.1507030739360.1735@localhost.localdomain>
 <2bf03dff3347d3745f35225e77581ef5@apollo.open-resource.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_151aa8be7a230b5a5beba3fbb099b2c4"
Cc: netdev@vger.kernel.org, openwrt-devel@lists.openwrt.org,
 Oliver Neukum <oneukum@suse.com>, linux-usb@vger.kernel.org,
 Matti Laakso <malaakso@elisanet.fi>
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <openwrt-devel-bounces@lists.openwrt.org>
In-Reply-To: <2bf03dff3347d3745f35225e77581ef5@apollo.open-resource.org>
List-Unsubscribe: <https://lists.openwrt.org/cgi-bin/mailman/options/openwrt-devel>,
 <mailto:openwrt-devel-request@lists.openwrt.org?subject=unsubscribe>
List-Archive: <http://lists.openwrt.org/pipermail/openwrt-devel/>
List-Post: <mailto:openwrt-devel@lists.openwrt.org>
List-Help: <mailto:openwrt-devel-request@lists.openwrt.org?subject=help>
List-Subscribe: <https://lists.openwrt.org/cgi-bin/mailman/listinfo/openwrt-devel>,
 <mailto:openwrt-devel-request@lists.openwrt.org?subject=subscribe>
Errors-To: openwrt-devel-bounces@lists.openwrt.org
Sender: "openwrt-devel" <openwrt-devel-bounces@lists.openwrt.org>
List-Id: netdev.vger.kernel.org

--=_151aa8be7a230b5a5beba3fbb099b2c4
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=US-ASCII;
 format=flowed

Ahoy everyone,

more on the Telekom Speedstick LTE V (Huawei 3372s) from here:

http://www.amazon.de/dp/B00NLJE3O6

I've tested Enricos latest patch on MIPS (3.18.17) and x86_64 (3.18.11)
and had a little bit of trouble applying it to latest trunk, so here's
the latest tested patch from a diff against 3.18.17 (openwrt-trunk).

With that patch applied, a simple AT^NDISDUP=1,1,"your.apn.here" and
udhcpc -i wwan0 is online and routing immediately.

The following config snippet is also working directly with openwrt:

config interface '4g'
         option proto 'ncm'
         option ifname 'wwan0'
         option device '/dev/ttyUSB1'
         option apn 'internet.eplus.de'

Again, big thanks go to Enrico for fixing NDP/SKB issues, much obliged.

-------------------------------------------------------------------------------
--- fix-huawei-3372s-ncm.patch ---

diff -u a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
--- a/drivers/net/usb/cdc_mbim.c	2015-06-28 17:40:40.000000000 +0000
+++ b/drivers/net/usb/cdc_mbim.c	2015-07-04 15:05:14.546901702 +0000
@@ -158,7 +158,7 @@
  	if (!cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
  		goto err;

-	ret = cdc_ncm_bind_common(dev, intf, data_altsetting);
+	ret = cdc_ncm_bind_common(dev, intf, data_altsetting, 0);
  	if (ret)
  		goto err;

diff -u a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
--- a/drivers/net/usb/cdc_ncm.c	2015-06-28 17:40:40.000000000 +0000
+++ b/drivers/net/usb/cdc_ncm.c	2015-07-09 08:43:01.658770535 +0000
@@ -684,10 +684,11 @@
  		ctx->tx_curr_skb = NULL;
  	}

+	kfree(ctx->delayed_ndp16);
  	kfree(ctx);
  }

-int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf, 
u8 data_altsetting)
+int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf, 
u8 data_altsetting, int drvflags)
  {
  	const struct usb_cdc_union_desc *union_desc = NULL;
  	struct cdc_ncm_ctx *ctx;
@@ -855,6 +856,17 @@
  	/* finish setting up the device specific data */
  	cdc_ncm_setup(dev);

+	/* Device-specific flags */
+	ctx->drvflags = drvflags;
+
+	/* Allocate the delayed NDP if needed. */
+	if (ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END) {
+		ctx->delayed_ndp16 = kzalloc(ctx->max_ndp_size, GFP_KERNEL);
+		if (!ctx->delayed_ndp16)
+			goto error2;
+		dev_info(&intf->dev, "NDP will be placed at end of frame for this 
device.");
+	}
+
  	/* override ethtool_ops */
  	dev->net->ethtool_ops = &cdc_ncm_ethtool_ops;

@@ -954,8 +966,11 @@
  	if (cdc_ncm_select_altsetting(intf) != CDC_NCM_COMM_ALTSETTING_NCM)
  		return -ENODEV;

-	/* The NCM data altsetting is fixed */
-	ret = cdc_ncm_bind_common(dev, intf, CDC_NCM_DATA_ALTSETTING_NCM);
+	/* The NCM data altsetting is fixed, so we hard-coded it.
+	 * Additionally, generic NCM devices are assumed to accept arbitrarily
+	 * placed NDP.
+	 */
+	ret = cdc_ncm_bind_common(dev, intf, CDC_NCM_DATA_ALTSETTING_NCM, 0);

  	/*
  	 * We should get an event when network connection is "connected" or
@@ -986,6 +1001,14 @@
  	struct usb_cdc_ncm_nth16 *nth16 = (void *)skb->data;
  	size_t ndpoffset = le16_to_cpu(nth16->wNdpIndex);

+	/* If NDP should be moved to the end of the NCM package, we can't 
follow the
+	* NTH16 header as we would normally do. NDP isn't written to the SKB 
yet, and
+	* the wNdpIndex field in the header is actually not consistent with 
reality. It will be later.
+	*/
+	if (ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END)
+		if (ctx->delayed_ndp16->dwSignature == sign)
+			return ctx->delayed_ndp16;
+
  	/* follow the chain of NDPs, looking for a match */
  	while (ndpoffset) {
  		ndp16 = (struct usb_cdc_ncm_ndp16 *)(skb->data + ndpoffset);
@@ -995,7 +1018,8 @@
  	}

  	/* align new NDP */
-	cdc_ncm_align_tail(skb, ctx->tx_ndp_modulus, 0, ctx->tx_max);
+	if (!(ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END))
+		cdc_ncm_align_tail(skb, ctx->tx_ndp_modulus, 0, ctx->tx_max);

  	/* verify that there is room for the NDP and the datagram (reserve) */
  	if ((ctx->tx_max - skb->len - reserve) < ctx->max_ndp_size)
@@ -1008,7 +1032,11 @@
  		nth16->wNdpIndex = cpu_to_le16(skb->len);

  	/* push a new empty NDP */
-	ndp16 = (struct usb_cdc_ncm_ndp16 *)memset(skb_put(skb, 
ctx->max_ndp_size), 0, ctx->max_ndp_size);
+	if (!(ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END))
+		ndp16 = (struct usb_cdc_ncm_ndp16 *)memset(skb_put(skb, 
ctx->max_ndp_size), 0, ctx->max_ndp_size);
+	else
+		ndp16 = ctx->delayed_ndp16;
+
  	ndp16->dwSignature = sign;
  	ndp16->wLength = cpu_to_le16(sizeof(struct usb_cdc_ncm_ndp16) + 
sizeof(struct usb_cdc_ncm_dpe16));
  	return ndp16;
@@ -1023,6 +1051,15 @@
  	struct sk_buff *skb_out;
  	u16 n = 0, index, ndplen;
  	u8 ready2send = 0;
+	u32 delayed_ndp_size;
+
+	/* When our NDP gets written in cdc_ncm_ndp(), then skb_out->len gets 
updated
+	 * accordingly. Otherwise, we should check here.
+	 */
+	if (ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END)
+		delayed_ndp_size = ctx->max_ndp_size;
+	else
+		delayed_ndp_size = 0;

  	/* if there is a remaining skb, it gets priority */
  	if (skb != NULL) {
@@ -1077,7 +1114,7 @@
  		cdc_ncm_align_tail(skb_out,  ctx->tx_modulus, ctx->tx_remainder, 
ctx->tx_max);

  		/* check if we had enough room left for both NDP and frame */
-		if (!ndp16 || skb_out->len + skb->len > ctx->tx_max) {
+		if (!ndp16 || skb_out->len + skb->len + delayed_ndp_size > 
ctx->tx_max) {
  			if (n == 0) {
  				/* won't fit, MTU problem? */
  				dev_kfree_skb_any(skb);
@@ -1150,6 +1187,17 @@
  		/* variables will be reset at next call */
  	}

+	/* If requested, put NDP at end of frame. */
+	if (ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END) {
+		nth16 = (struct usb_cdc_ncm_nth16 *)skb_out->data;
+		cdc_ncm_align_tail(skb_out, ctx->tx_ndp_modulus, 0, ctx->tx_max);
+		nth16->wNdpIndex = cpu_to_le16(skb_out->len);
+		memcpy(skb_put(skb_out, ctx->max_ndp_size), ctx->delayed_ndp16, 
ctx->max_ndp_size);
+
+		/* Zero out delayed NDP - signature checking will naturally fail. */
+		ndp16 = memset(ctx->delayed_ndp16, 0, ctx->max_ndp_size);
+	}
+
  	/* If collected data size is less or equal ctx->min_tx_pkt
  	 * bytes, we send buffers as it is. If we get more data, it
  	 * would be more efficient for USB HS mobile device with DMA
diff -u a/drivers/net/usb/huawei_cdc_ncm.c 
b/drivers/net/usb/huawei_cdc_ncm.c
--- a/drivers/net/usb/huawei_cdc_ncm.c	2015-06-28 17:40:40.000000000 
+0000
+++ b/drivers/net/usb/huawei_cdc_ncm.c	2015-07-04 15:23:25.779014586 
+0000
@@ -73,11 +73,14 @@
  	struct usb_driver *subdriver = ERR_PTR(-ENODEV);
  	int ret = -ENODEV;
  	struct huawei_cdc_ncm_state *drvstate = (void *)&usbnet_dev->data;
+	int drvflags = 0;

  	/* altsetting should always be 1 for NCM devices - so we hard-coded
-	 * it here
+	 * it here. Some huawei devices will need the NDP part of the NCM 
package to
+	 * be at the end of the frame.
  	 */
-	ret = cdc_ncm_bind_common(usbnet_dev, intf, 1);
+	drvflags |= CDC_NCM_FLAG_NDP_TO_END;
+	ret = cdc_ncm_bind_common(usbnet_dev, intf, 1, drvflags);
  	if (ret)
  		goto err;

diff -u a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
--- a/include/linux/usb/cdc_ncm.h	2015-06-28 17:40:40.000000000 +0000
+++ b/include/linux/usb/cdc_ncm.h	2015-07-04 15:27:52.171388014 +0000
@@ -80,6 +80,9 @@
  #define CDC_NCM_TIMER_INTERVAL_MIN		5UL
  #define CDC_NCM_TIMER_INTERVAL_MAX		(U32_MAX / NSEC_PER_USEC)

+/* Driver flags */
+#define CDC_NCM_FLAG_NDP_TO_END			0x02	/* NDP is placed at end of frame 
*/
+
  #define cdc_ncm_comm_intf_is_mbim(x)  ((x)->desc.bInterfaceSubClass == 
USB_CDC_SUBCLASS_MBIM && \
  				       (x)->desc.bInterfaceProtocol == USB_CDC_PROTO_NONE)
  #define cdc_ncm_data_intf_is_mbim(x)  ((x)->desc.bInterfaceProtocol == 
USB_CDC_MBIM_PROTO_NTB)
@@ -103,9 +106,11 @@

  	spinlock_t mtx;
  	atomic_t stop;
+	int drvflags;

  	u32 timer_interval;
  	u32 max_ndp_size;
+	struct usb_cdc_ncm_ndp16 *delayed_ndp16;

  	u32 tx_timer_pending;
  	u32 tx_curr_frame_num;
@@ -133,7 +138,7 @@
  };

  u8 cdc_ncm_select_altsetting(struct usb_interface *intf);
-int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf, 
u8 data_altsetting);
+int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf, 
u8 data_altsetting, int drvflags);
  void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *intf);
  struct sk_buff *cdc_ncm_fill_tx_frame(struct usbnet *dev, struct 
sk_buff *skb, __le32 sign);
  int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff 
*skb_in);

--=_151aa8be7a230b5a5beba3fbb099b2c4
Content-Transfer-Encoding: base64
Content-Type: text/x-diff;
 name=fix-huawei-3372s-ncm.patch
Content-Disposition: attachment;
 filename=fix-huawei-3372s-ncm.patch;
 size=7439

ZGlmZiAtdSBhL2RyaXZlcnMvbmV0L3VzYi9jZGNfbWJpbS5jIGIvZHJpdmVycy9uZXQvdXNiL2Nk
Y19tYmltLmMKLS0tIGEvZHJpdmVycy9uZXQvdXNiL2NkY19tYmltLmMJMjAxNS0wNi0yOCAxNzo0
MDo0MC4wMDAwMDAwMDAgKzAwMDAKKysrIGIvZHJpdmVycy9uZXQvdXNiL2NkY19tYmltLmMJMjAx
NS0wNy0wNCAxNTowNToxNC41NDY5MDE3MDIgKzAwMDAKQEAgLTE1OCw3ICsxNTgsNyBAQAogCWlm
ICghY2RjX25jbV9jb21tX2ludGZfaXNfbWJpbShpbnRmLT5jdXJfYWx0c2V0dGluZykpCiAJCWdv
dG8gZXJyOwoKLQlyZXQgPSBjZGNfbmNtX2JpbmRfY29tbW9uKGRldiwgaW50ZiwgZGF0YV9hbHRz
ZXR0aW5nKTsKKwlyZXQgPSBjZGNfbmNtX2JpbmRfY29tbW9uKGRldiwgaW50ZiwgZGF0YV9hbHRz
ZXR0aW5nLCAwKTsKIAlpZiAocmV0KQogCQlnb3RvIGVycjsKCmRpZmYgLXUgYS9kcml2ZXJzL25l
dC91c2IvY2RjX25jbS5jIGIvZHJpdmVycy9uZXQvdXNiL2NkY19uY20uYwotLS0gYS9kcml2ZXJz
L25ldC91c2IvY2RjX25jbS5jCTIwMTUtMDYtMjggMTc6NDA6NDAuMDAwMDAwMDAwICswMDAwCisr
KyBiL2RyaXZlcnMvbmV0L3VzYi9jZGNfbmNtLmMJMjAxNS0wNy0wOSAwODo0MzowMS42NTg3NzA1
MzUgKzAwMDAKQEAgLTY4NCwxMCArNjg0LDExIEBACiAJCWN0eC0+dHhfY3Vycl9za2IgPSBOVUxM
OwogCX0KCisJa2ZyZWUoY3R4LT5kZWxheWVkX25kcDE2KTsKIAlrZnJlZShjdHgpOwogfQoKLWlu
dCBjZGNfbmNtX2JpbmRfY29tbW9uKHN0cnVjdCB1c2JuZXQgKmRldiwgc3RydWN0IHVzYl9pbnRl
cmZhY2UgKmludGYsIHU4IGRhdGFfYWx0c2V0dGluZykKK2ludCBjZGNfbmNtX2JpbmRfY29tbW9u
KHN0cnVjdCB1c2JuZXQgKmRldiwgc3RydWN0IHVzYl9pbnRlcmZhY2UgKmludGYsIHU4IGRhdGFf
YWx0c2V0dGluZywgaW50IGRydmZsYWdzKQogewogCWNvbnN0IHN0cnVjdCB1c2JfY2RjX3VuaW9u
X2Rlc2MgKnVuaW9uX2Rlc2MgPSBOVUxMOwogCXN0cnVjdCBjZGNfbmNtX2N0eCAqY3R4OwpAQCAt
ODU1LDYgKzg1NiwxNyBAQAogCS8qIGZpbmlzaCBzZXR0aW5nIHVwIHRoZSBkZXZpY2Ugc3BlY2lm
aWMgZGF0YSAqLwogCWNkY19uY21fc2V0dXAoZGV2KTsKCisJLyogRGV2aWNlLXNwZWNpZmljIGZs
YWdzICovCisJY3R4LT5kcnZmbGFncyA9IGRydmZsYWdzOworCisJLyogQWxsb2NhdGUgdGhlIGRl
bGF5ZWQgTkRQIGlmIG5lZWRlZC4gKi8KKwlpZiAoY3R4LT5kcnZmbGFncyAmIENEQ19OQ01fRkxB
R19ORFBfVE9fRU5EKSB7CisJCWN0eC0+ZGVsYXllZF9uZHAxNiA9IGt6YWxsb2MoY3R4LT5tYXhf
bmRwX3NpemUsIEdGUF9LRVJORUwpOworCQlpZiAoIWN0eC0+ZGVsYXllZF9uZHAxNikKKwkJCWdv
dG8gZXJyb3IyOworCQlkZXZfaW5mbygmaW50Zi0+ZGV2LCAiTkRQIHdpbGwgYmUgcGxhY2VkIGF0
IGVuZCBvZiBmcmFtZSBmb3IgdGhpcyBkZXZpY2UuIik7CisJfQorCiAJLyogb3ZlcnJpZGUgZXRo
dG9vbF9vcHMgKi8KIAlkZXYtPm5ldC0+ZXRodG9vbF9vcHMgPSAmY2RjX25jbV9ldGh0b29sX29w
czsKCkBAIC05NTQsOCArOTY2LDExIEBACiAJaWYgKGNkY19uY21fc2VsZWN0X2FsdHNldHRpbmco
aW50ZikgIT0gQ0RDX05DTV9DT01NX0FMVFNFVFRJTkdfTkNNKQogCQlyZXR1cm4gLUVOT0RFVjsK
Ci0JLyogVGhlIE5DTSBkYXRhIGFsdHNldHRpbmcgaXMgZml4ZWQgKi8KLQlyZXQgPSBjZGNfbmNt
X2JpbmRfY29tbW9uKGRldiwgaW50ZiwgQ0RDX05DTV9EQVRBX0FMVFNFVFRJTkdfTkNNKTsKKwkv
KiBUaGUgTkNNIGRhdGEgYWx0c2V0dGluZyBpcyBmaXhlZCwgc28gd2UgaGFyZC1jb2RlZCBpdC4K
KwkgKiBBZGRpdGlvbmFsbHksIGdlbmVyaWMgTkNNIGRldmljZXMgYXJlIGFzc3VtZWQgdG8gYWNj
ZXB0IGFyYml0cmFyaWx5CisJICogcGxhY2VkIE5EUC4KKwkgKi8KKwlyZXQgPSBjZGNfbmNtX2Jp
bmRfY29tbW9uKGRldiwgaW50ZiwgQ0RDX05DTV9EQVRBX0FMVFNFVFRJTkdfTkNNLCAwKTsKCiAJ
LyoKIAkgKiBXZSBzaG91bGQgZ2V0IGFuIGV2ZW50IHdoZW4gbmV0d29yayBjb25uZWN0aW9uIGlz
ICJjb25uZWN0ZWQiIG9yCkBAIC05ODYsNiArMTAwMSwxNCBAQAogCXN0cnVjdCB1c2JfY2RjX25j
bV9udGgxNiAqbnRoMTYgPSAodm9pZCAqKXNrYi0+ZGF0YTsKIAlzaXplX3QgbmRwb2Zmc2V0ID0g
bGUxNl90b19jcHUobnRoMTYtPndOZHBJbmRleCk7CgorCS8qIElmIE5EUCBzaG91bGQgYmUgbW92
ZWQgdG8gdGhlIGVuZCBvZiB0aGUgTkNNIHBhY2thZ2UsIHdlIGNhbid0IGZvbGxvdyB0aGUKKwkq
IE5USDE2IGhlYWRlciBhcyB3ZSB3b3VsZCBub3JtYWxseSBkby4gTkRQIGlzbid0IHdyaXR0ZW4g
dG8gdGhlIFNLQiB5ZXQsIGFuZAorCSogdGhlIHdOZHBJbmRleCBmaWVsZCBpbiB0aGUgaGVhZGVy
IGlzIGFjdHVhbGx5IG5vdCBjb25zaXN0ZW50IHdpdGggcmVhbGl0eS4gSXQgd2lsbCBiZSBsYXRl
ci4KKwkqLworCWlmIChjdHgtPmRydmZsYWdzICYgQ0RDX05DTV9GTEFHX05EUF9UT19FTkQpCisJ
CWlmIChjdHgtPmRlbGF5ZWRfbmRwMTYtPmR3U2lnbmF0dXJlID09IHNpZ24pCisJCQlyZXR1cm4g
Y3R4LT5kZWxheWVkX25kcDE2OworCiAJLyogZm9sbG93IHRoZSBjaGFpbiBvZiBORFBzLCBsb29r
aW5nIGZvciBhIG1hdGNoICovCiAJd2hpbGUgKG5kcG9mZnNldCkgewogCQluZHAxNiA9IChzdHJ1
Y3QgdXNiX2NkY19uY21fbmRwMTYgKikoc2tiLT5kYXRhICsgbmRwb2Zmc2V0KTsKQEAgLTk5NSw3
ICsxMDE4LDggQEAKIAl9CgogCS8qIGFsaWduIG5ldyBORFAgKi8KLQljZGNfbmNtX2FsaWduX3Rh
aWwoc2tiLCBjdHgtPnR4X25kcF9tb2R1bHVzLCAwLCBjdHgtPnR4X21heCk7CisJaWYgKCEoY3R4
LT5kcnZmbGFncyAmIENEQ19OQ01fRkxBR19ORFBfVE9fRU5EKSkKKwkJY2RjX25jbV9hbGlnbl90
YWlsKHNrYiwgY3R4LT50eF9uZHBfbW9kdWx1cywgMCwgY3R4LT50eF9tYXgpOwoKIAkvKiB2ZXJp
ZnkgdGhhdCB0aGVyZSBpcyByb29tIGZvciB0aGUgTkRQIGFuZCB0aGUgZGF0YWdyYW0gKHJlc2Vy
dmUpICovCiAJaWYgKChjdHgtPnR4X21heCAtIHNrYi0+bGVuIC0gcmVzZXJ2ZSkgPCBjdHgtPm1h
eF9uZHBfc2l6ZSkKQEAgLTEwMDgsNyArMTAzMiwxMSBAQAogCQludGgxNi0+d05kcEluZGV4ID0g
Y3B1X3RvX2xlMTYoc2tiLT5sZW4pOwoKIAkvKiBwdXNoIGEgbmV3IGVtcHR5IE5EUCAqLwotCW5k
cDE2ID0gKHN0cnVjdCB1c2JfY2RjX25jbV9uZHAxNiAqKW1lbXNldChza2JfcHV0KHNrYiwgY3R4
LT5tYXhfbmRwX3NpemUpLCAwLCBjdHgtPm1heF9uZHBfc2l6ZSk7CisJaWYgKCEoY3R4LT5kcnZm
bGFncyAmIENEQ19OQ01fRkxBR19ORFBfVE9fRU5EKSkKKwkJbmRwMTYgPSAoc3RydWN0IHVzYl9j
ZGNfbmNtX25kcDE2ICopbWVtc2V0KHNrYl9wdXQoc2tiLCBjdHgtPm1heF9uZHBfc2l6ZSksIDAs
IGN0eC0+bWF4X25kcF9zaXplKTsKKwllbHNlCisJCW5kcDE2ID0gY3R4LT5kZWxheWVkX25kcDE2
OworCiAJbmRwMTYtPmR3U2lnbmF0dXJlID0gc2lnbjsKIAluZHAxNi0+d0xlbmd0aCA9IGNwdV90
b19sZTE2KHNpemVvZihzdHJ1Y3QgdXNiX2NkY19uY21fbmRwMTYpICsgc2l6ZW9mKHN0cnVjdCB1
c2JfY2RjX25jbV9kcGUxNikpOwogCXJldHVybiBuZHAxNjsKQEAgLTEwMjMsNiArMTA1MSwxNSBA
QAogCXN0cnVjdCBza19idWZmICpza2Jfb3V0OwogCXUxNiBuID0gMCwgaW5kZXgsIG5kcGxlbjsK
IAl1OCByZWFkeTJzZW5kID0gMDsKKwl1MzIgZGVsYXllZF9uZHBfc2l6ZTsKKworCS8qIFdoZW4g
b3VyIE5EUCBnZXRzIHdyaXR0ZW4gaW4gY2RjX25jbV9uZHAoKSwgdGhlbiBza2Jfb3V0LT5sZW4g
Z2V0cyB1cGRhdGVkCisJICogYWNjb3JkaW5nbHkuIE90aGVyd2lzZSwgd2Ugc2hvdWxkIGNoZWNr
IGhlcmUuCisJICovCisJaWYgKGN0eC0+ZHJ2ZmxhZ3MgJiBDRENfTkNNX0ZMQUdfTkRQX1RPX0VO
RCkKKwkJZGVsYXllZF9uZHBfc2l6ZSA9IGN0eC0+bWF4X25kcF9zaXplOworCWVsc2UKKwkJZGVs
YXllZF9uZHBfc2l6ZSA9IDA7CgogCS8qIGlmIHRoZXJlIGlzIGEgcmVtYWluaW5nIHNrYiwgaXQg
Z2V0cyBwcmlvcml0eSAqLwogCWlmIChza2IgIT0gTlVMTCkgewpAQCAtMTA3Nyw3ICsxMTE0LDcg
QEAKIAkJY2RjX25jbV9hbGlnbl90YWlsKHNrYl9vdXQsICBjdHgtPnR4X21vZHVsdXMsIGN0eC0+
dHhfcmVtYWluZGVyLCBjdHgtPnR4X21heCk7CgogCQkvKiBjaGVjayBpZiB3ZSBoYWQgZW5vdWdo
IHJvb20gbGVmdCBmb3IgYm90aCBORFAgYW5kIGZyYW1lICovCi0JCWlmICghbmRwMTYgfHwgc2ti
X291dC0+bGVuICsgc2tiLT5sZW4gPiBjdHgtPnR4X21heCkgeworCQlpZiAoIW5kcDE2IHx8IHNr
Yl9vdXQtPmxlbiArIHNrYi0+bGVuICsgZGVsYXllZF9uZHBfc2l6ZSA+IGN0eC0+dHhfbWF4KSB7
CiAJCQlpZiAobiA9PSAwKSB7CiAJCQkJLyogd29uJ3QgZml0LCBNVFUgcHJvYmxlbT8gKi8KIAkJ
CQlkZXZfa2ZyZWVfc2tiX2FueShza2IpOwpAQCAtMTE1MCw2ICsxMTg3LDE3IEBACiAJCS8qIHZh
cmlhYmxlcyB3aWxsIGJlIHJlc2V0IGF0IG5leHQgY2FsbCAqLwogCX0KCisJLyogSWYgcmVxdWVz
dGVkLCBwdXQgTkRQIGF0IGVuZCBvZiBmcmFtZS4gKi8KKwlpZiAoY3R4LT5kcnZmbGFncyAmIENE
Q19OQ01fRkxBR19ORFBfVE9fRU5EKSB7CisJCW50aDE2ID0gKHN0cnVjdCB1c2JfY2RjX25jbV9u
dGgxNiAqKXNrYl9vdXQtPmRhdGE7CisJCWNkY19uY21fYWxpZ25fdGFpbChza2Jfb3V0LCBjdHgt
PnR4X25kcF9tb2R1bHVzLCAwLCBjdHgtPnR4X21heCk7CisJCW50aDE2LT53TmRwSW5kZXggPSBj
cHVfdG9fbGUxNihza2Jfb3V0LT5sZW4pOworCQltZW1jcHkoc2tiX3B1dChza2Jfb3V0LCBjdHgt
Pm1heF9uZHBfc2l6ZSksIGN0eC0+ZGVsYXllZF9uZHAxNiwgY3R4LT5tYXhfbmRwX3NpemUpOwor
CisJCS8qIFplcm8gb3V0IGRlbGF5ZWQgTkRQIC0gc2lnbmF0dXJlIGNoZWNraW5nIHdpbGwgbmF0
dXJhbGx5IGZhaWwuICovCisJCW5kcDE2ID0gbWVtc2V0KGN0eC0+ZGVsYXllZF9uZHAxNiwgMCwg
Y3R4LT5tYXhfbmRwX3NpemUpOworCX0KKwogCS8qIElmIGNvbGxlY3RlZCBkYXRhIHNpemUgaXMg
bGVzcyBvciBlcXVhbCBjdHgtPm1pbl90eF9wa3QKIAkgKiBieXRlcywgd2Ugc2VuZCBidWZmZXJz
IGFzIGl0IGlzLiBJZiB3ZSBnZXQgbW9yZSBkYXRhLCBpdAogCSAqIHdvdWxkIGJlIG1vcmUgZWZm
aWNpZW50IGZvciBVU0IgSFMgbW9iaWxlIGRldmljZSB3aXRoIERNQQpkaWZmIC11IGEvZHJpdmVy
cy9uZXQvdXNiL2h1YXdlaV9jZGNfbmNtLmMgYi9kcml2ZXJzL25ldC91c2IvaHVhd2VpX2NkY19u
Y20uYwotLS0gYS9kcml2ZXJzL25ldC91c2IvaHVhd2VpX2NkY19uY20uYwkyMDE1LTA2LTI4IDE3
OjQwOjQwLjAwMDAwMDAwMCArMDAwMAorKysgYi9kcml2ZXJzL25ldC91c2IvaHVhd2VpX2NkY19u
Y20uYwkyMDE1LTA3LTA0IDE1OjIzOjI1Ljc3OTAxNDU4NiArMDAwMApAQCAtNzMsMTEgKzczLDE0
IEBACiAJc3RydWN0IHVzYl9kcml2ZXIgKnN1YmRyaXZlciA9IEVSUl9QVFIoLUVOT0RFVik7CiAJ
aW50IHJldCA9IC1FTk9ERVY7CiAJc3RydWN0IGh1YXdlaV9jZGNfbmNtX3N0YXRlICpkcnZzdGF0
ZSA9ICh2b2lkICopJnVzYm5ldF9kZXYtPmRhdGE7CisJaW50IGRydmZsYWdzID0gMDsKCiAJLyog
YWx0c2V0dGluZyBzaG91bGQgYWx3YXlzIGJlIDEgZm9yIE5DTSBkZXZpY2VzIC0gc28gd2UgaGFy
ZC1jb2RlZAotCSAqIGl0IGhlcmUKKwkgKiBpdCBoZXJlLiBTb21lIGh1YXdlaSBkZXZpY2VzIHdp
bGwgbmVlZCB0aGUgTkRQIHBhcnQgb2YgdGhlIE5DTSBwYWNrYWdlIHRvCisJICogYmUgYXQgdGhl
IGVuZCBvZiB0aGUgZnJhbWUuCiAJICovCi0JcmV0ID0gY2RjX25jbV9iaW5kX2NvbW1vbih1c2Ju
ZXRfZGV2LCBpbnRmLCAxKTsKKwlkcnZmbGFncyB8PSBDRENfTkNNX0ZMQUdfTkRQX1RPX0VORDsK
KwlyZXQgPSBjZGNfbmNtX2JpbmRfY29tbW9uKHVzYm5ldF9kZXYsIGludGYsIDEsIGRydmZsYWdz
KTsKIAlpZiAocmV0KQogCQlnb3RvIGVycjsKCmRpZmYgLXUgYS9pbmNsdWRlL2xpbnV4L3VzYi9j
ZGNfbmNtLmggYi9pbmNsdWRlL2xpbnV4L3VzYi9jZGNfbmNtLmgKLS0tIGEvaW5jbHVkZS9saW51
eC91c2IvY2RjX25jbS5oCTIwMTUtMDYtMjggMTc6NDA6NDAuMDAwMDAwMDAwICswMDAwCisrKyBi
L2luY2x1ZGUvbGludXgvdXNiL2NkY19uY20uaAkyMDE1LTA3LTA0IDE1OjI3OjUyLjE3MTM4ODAx
NCArMDAwMApAQCAtODAsNiArODAsOSBAQAogI2RlZmluZSBDRENfTkNNX1RJTUVSX0lOVEVSVkFM
X01JTgkJNVVMCiAjZGVmaW5lIENEQ19OQ01fVElNRVJfSU5URVJWQUxfTUFYCQkoVTMyX01BWCAv
IE5TRUNfUEVSX1VTRUMpCgorLyogRHJpdmVyIGZsYWdzICovCisjZGVmaW5lIENEQ19OQ01fRkxB
R19ORFBfVE9fRU5ECQkJMHgwMgkvKiBORFAgaXMgcGxhY2VkIGF0IGVuZCBvZiBmcmFtZSAqLwor
CiAjZGVmaW5lIGNkY19uY21fY29tbV9pbnRmX2lzX21iaW0oeCkgICgoeCktPmRlc2MuYkludGVy
ZmFjZVN1YkNsYXNzID09IFVTQl9DRENfU1VCQ0xBU1NfTUJJTSAmJiBcCiAJCQkJICAgICAgICh4
KS0+ZGVzYy5iSW50ZXJmYWNlUHJvdG9jb2wgPT0gVVNCX0NEQ19QUk9UT19OT05FKQogI2RlZmlu
ZSBjZGNfbmNtX2RhdGFfaW50Zl9pc19tYmltKHgpICAoKHgpLT5kZXNjLmJJbnRlcmZhY2VQcm90
b2NvbCA9PSBVU0JfQ0RDX01CSU1fUFJPVE9fTlRCKQpAQCAtMTAzLDkgKzEwNiwxMSBAQAoKIAlz
cGlubG9ja190IG10eDsKIAlhdG9taWNfdCBzdG9wOworCWludCBkcnZmbGFnczsKCiAJdTMyIHRp
bWVyX2ludGVydmFsOwogCXUzMiBtYXhfbmRwX3NpemU7CisJc3RydWN0IHVzYl9jZGNfbmNtX25k
cDE2ICpkZWxheWVkX25kcDE2OwoKIAl1MzIgdHhfdGltZXJfcGVuZGluZzsKIAl1MzIgdHhfY3Vy
cl9mcmFtZV9udW07CkBAIC0xMzMsNyArMTM4LDcgQEAKIH07CgogdTggY2RjX25jbV9zZWxlY3Rf
YWx0c2V0dGluZyhzdHJ1Y3QgdXNiX2ludGVyZmFjZSAqaW50Zik7Ci1pbnQgY2RjX25jbV9iaW5k
X2NvbW1vbihzdHJ1Y3QgdXNibmV0ICpkZXYsIHN0cnVjdCB1c2JfaW50ZXJmYWNlICppbnRmLCB1
OCBkYXRhX2FsdHNldHRpbmcpOworaW50IGNkY19uY21fYmluZF9jb21tb24oc3RydWN0IHVzYm5l
dCAqZGV2LCBzdHJ1Y3QgdXNiX2ludGVyZmFjZSAqaW50ZiwgdTggZGF0YV9hbHRzZXR0aW5nLCBp
bnQgZHJ2ZmxhZ3MpOwogdm9pZCBjZGNfbmNtX3VuYmluZChzdHJ1Y3QgdXNibmV0ICpkZXYsIHN0
cnVjdCB1c2JfaW50ZXJmYWNlICppbnRmKTsKIHN0cnVjdCBza19idWZmICpjZGNfbmNtX2ZpbGxf
dHhfZnJhbWUoc3RydWN0IHVzYm5ldCAqZGV2LCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBfX2xlMzIg
c2lnbik7CiBpbnQgY2RjX25jbV9yeF92ZXJpZnlfbnRoMTYoc3RydWN0IGNkY19uY21fY3R4ICpj
dHgsIHN0cnVjdCBza19idWZmICpza2JfaW4pOwo=
--=_151aa8be7a230b5a5beba3fbb099b2c4
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
openwrt-devel mailing list
openwrt-devel@lists.openwrt.org
https://lists.openwrt.org/cgi-bin/mailman/listinfo/openwrt-devel

--=_151aa8be7a230b5a5beba3fbb099b2c4--
