From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: user space virtio-net exits with "truncating packet" error
Date: Fri, 15 May 2009 14:48:49 +0930
Message-ID: <200905151448.49851.rusty@rustcorp.com.au>
References: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com> <200905142128.58111.rusty@rustcorp.com.au> <4A0C2500.7090709@Voltaire.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	Gregory Haskins <ghaskins@novell.com>,
	Anthony Liguori <anthony@codemonkey.ws>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52598 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751219AbZEOFTI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2009 01:19:08 -0400
In-Reply-To: <4A0C2500.7090709@Voltaire.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 May 2009 11:34:48 pm Or Gerlitz wrote:
> Rusty Russell wrote:
> > The answer is that virtio_net by default only supports 1500
> > MTU; I've not tried larger MTUs.
>
> Rusty,
>
> I hoped to get some performance boost from using checksum and large-send
> offloads as an alternative to jumbo frames. Looking in the virtio-net
> kernel driver, I see that the probe function checks if virtio_has_feature
> VIRTIO_NET_F_CSUM ... VIRTIO_NET_F_HOST_TSO ... and if yes sets the
> relevant bits in the NIC features mask. Looking in the virtio qemu code, I
> also see some offload related code.

Yes, which is why MTU is a bit misleading.

This patch may help diagnostics tho.

Cheers,
Rusty.

virtio: expose features in sysfs

Each device negotiates feature bits; expose these in sysfs to help
diagnostics and debugging.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/virtio/virtio.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/virtio/virtio.c b/drivers/virtio/virtio.c
--- a/drivers/virtio/virtio.c
+++ b/drivers/virtio/virtio.c
@@ -31,11 +31,27 @@ static ssize_t modalias_show(struct devi
 	return sprintf(buf, "virtio:d%08Xv%08X\n",
 		       dev->id.device, dev->id.vendor);
 }
+static ssize_t features_show(struct device *_d,
+			     struct device_attribute *attr, char *buf)
+{
+	struct virtio_device *dev = container_of(_d, struct virtio_device, dev);
+	unsigned int i;
+	ssize_t len = 0;
+
+	/* We actually represent this as a bitstring, as it could be
+	 * arbitrary length in future. */
+	for (i = 0; i < ARRAY_SIZE(dev->features)*BITS_PER_LONG; i++)
+		len += sprintf(buf+len, "%c",
+			       test_bit(i, dev->features) ? '1' : '0');
+	len += sprintf(buf+len, "\n");
+	return len;
+}
 static struct device_attribute virtio_dev_attrs[] = {
 	__ATTR_RO(device),
 	__ATTR_RO(vendor),
 	__ATTR_RO(status),
 	__ATTR_RO(modalias),
+	__ATTR_RO(features),
 	__ATTR_NULL
 };
 

