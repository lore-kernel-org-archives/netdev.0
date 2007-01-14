From: Pavel Roskin <proski@gnu.org>
Subject: Re: What is in bcm43xx-wireless-dev.git?
Date: Sat, 13 Jan 2007 21:10:30 -0500
Message-ID: <20070113211030.11zo8cokcsoskccg@webmail.spamcop.net>
References: <20070113024543.aj2n40s4k0g0cgws@webmail.spamcop.net>
	<200701131509.26877.mb@bu3sch.de>
	<20070113143033.fi804so8ok04wc4k@webmail.spamcop.net>
	<200701132051.52559.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_1anlkapur4f4"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgate.cesmail.net ([216.154.195.36]:48614 "HELO
	mailgate.cesmail.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750896AbXANCKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jan 2007 21:10:31 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200701132051.52559.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message is in MIME format.

--=_1anlkapur4f4
Content-Type: text/plain; charset="ISO-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

Quoting Michael Buesch <mb@bu3sch.de>:

> > I haven't looked at the code yet, but I tried to locate the bad commit.  I
> tried
> > commit a13f85d8a8eb40dfd157ab78c2fb91b5765b7b9d, which is your last merge,
> just
> > before the SSB changes.
>
> Yeah, sure. I know that this is the commit which introduced this.

Basically, you set up DMA on the PCI device, but use it on the SSB device.
That's inconsistent.  dma_alloc_coherent() is very picky on x86_64 and crashes
if dev->dma_mask is NULL, which was the case for the SSB device.

Looking at the patch, it's clear that the SSB device is used instead of the PCI
device in some places.  I restored the old logic.  If you meant to switch to
SSB devices, then please remove the last PCI references from that file.

The patch is attached.  It fixes the crash.  I didn't check that it's complete.
I really don't like the long chain of dereferences, and I hope you'll come up
with something better.

I still cannot associate.  The kernel log is attached.  Notice massive assertion
failures.

> Note that LO calibration is horribly broken in my tree.

I guess that's what the assertion failures are about.

> So you have a very weak signal, if any. My 4318 has no signal, for example.
> So basically don't expect to be able to transmit any data.
> This includes association.

Actually, I could scan, and I got 7 access points around.  Only one is in my
apartment.

> But I think you should be able to assoc with a plain linville tree.

Nope.  Although I got DadWifi to work, and this message will we sent over it.
So it's not like I'm missing something essential about d80211 stack.

> > I'll try to look closely at the changes.  My immediate suspect is that we
> have
> > too many different fields called "dev".  All it takes is one cast to hide a
> > horrible mistake.  Although I think it would have affected you as well
> (unless
>
> We don't cast devs.

Yet I was pretty close :)

--
Regards,
Pavel Roskin

--=_1anlkapur4f4
Content-Type: text/x-patch; charset="ISO-8859-1"; name="devdevdev.diff"
Content-Disposition: attachment; filename="devdevdev.diff"
Content-Transfer-Encoding: 7bit

diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
index 4549f55..ce5c017 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
@@ -327,11 +327,11 @@ dma_addr_t map_descbuffer(struct bcm43xx_dmaring *ring,
 	dma_addr_t dmaaddr;
 
 	if (tx) {
-		dmaaddr = dma_map_single(&ring->dev->dev->dev,
+		dmaaddr = dma_map_single(&ring->dev->dev->bus->host_pci->dev,
 					 buf, len,
 					 DMA_TO_DEVICE);
 	} else {
-		dmaaddr = dma_map_single(&ring->dev->dev->dev,
+		dmaaddr = dma_map_single(&ring->dev->dev->bus->host_pci->dev,
 					 buf, len,
 					 DMA_FROM_DEVICE);
 	}
@@ -346,11 +346,11 @@ void unmap_descbuffer(struct bcm43xx_dmaring *ring,
 		      int tx)
 {
 	if (tx) {
-		dma_unmap_single(&ring->dev->dev->dev,
+		dma_unmap_single(&ring->dev->dev->bus->host_pci->dev,
 				 addr, len,
 				 DMA_TO_DEVICE);
 	} else {
-		dma_unmap_single(&ring->dev->dev->dev,
+		dma_unmap_single(&ring->dev->dev->bus->host_pci->dev,
 				 addr, len,
 				 DMA_FROM_DEVICE);
 	}
@@ -363,7 +363,7 @@ void sync_descbuffer_for_cpu(struct bcm43xx_dmaring *ring,
 {
 	assert(!ring->tx);
 
-	dma_sync_single_for_cpu(&ring->dev->dev->dev,
+	dma_sync_single_for_cpu(&ring->dev->dev->bus->host_pci->dev,
 				addr, len, DMA_FROM_DEVICE);
 }
 
@@ -374,7 +374,7 @@ void sync_descbuffer_for_device(struct bcm43xx_dmaring *ring,
 {
 	assert(!ring->tx);
 
-	dma_sync_single_for_device(&ring->dev->dev->dev,
+	dma_sync_single_for_device(&ring->dev->dev->bus->host_pci->dev,
 				   addr, len, DMA_FROM_DEVICE);
 }
 
@@ -393,7 +393,7 @@ void free_descriptor_buffer(struct bcm43xx_dmaring *ring,
 
 static int alloc_ringmemory(struct bcm43xx_dmaring *ring)
 {
-	struct device *dev = &(ring->dev->dev->dev);
+	struct device *dev = &(ring->dev->dev->bus->host_pci->dev);
 
 	ring->descbase = dma_alloc_coherent(dev, BCM43xx_DMA_RINGMEMSIZE,
 					    &(ring->dmabase), GFP_KERNEL);
@@ -408,7 +408,7 @@ static int alloc_ringmemory(struct bcm43xx_dmaring *ring)
 
 static void free_ringmemory(struct bcm43xx_dmaring *ring)
 {
-	struct device *dev = &(ring->dev->dev->dev);
+	struct device *dev = &(ring->dev->dev->bus->host_pci->dev);
 
 	dma_free_coherent(dev, BCM43xx_DMA_RINGMEMSIZE,
 			  ring->descbase, ring->dmabase);

--=_1anlkapur4f4
Content-Type: application/x-gzip; name="dmesg-fixed.gz"
Content-Disposition: attachment; filename="dmesg-fixed.gz"
Content-Transfer-Encoding: base64

H4sICFCPqUUAA2RtZXNnLWZpeGVkAO2bWW/jNhDH3/Mp5qmxAR+U5FOACyiJ0zWwaVM726YoioCW
qJiIJGpJykcf+tk7lI911k6auCiwBegHy6Jm/vzNIT6Ng8vbkQ+3lyPgmWZSFrmGWEiI2JyHDAh+
fBL6hDQIRFzRacKis2DnNNo57Vv+HvwB9e/hh8kInC5UEjZnSQ0Ssaia5dH4Z1w+Q3cfJkxrnj1C
QjXLwhVonjIJIj66vxbQaZ0pNUU/kfFQwYQnPBQZXNDwKU9oxpC9yCLAJUN3RGTtfikkLq+N8W7G
80uRpuhVCUMgyx4hNZBsjj8dpwZzlkWYErJsuS2vuqfgbBVGw+EQesRtOM5WwnG3EiR4RcLdSnya
XIDTcOCDUHqn0d1peK9oeFsNjLk+3Dq7uxjICzFMFlyHM5N+zOxeEkIUrWE/RGwJ5Ijpept9K29t
hQ/MKi5CmHCWaUhFtKnJ2SKlCpuFmKInLNQsAolVR51MS5EATR6F5HqWwrniaZ6w8yNb7yd6H8B5
D+YbFadh2vKWy4cInzqOD0EUGZ+y5WOKfaVXORbwwO66bMHbD7/58AuTimNGWzW4K41rMMaeLNd6
LziOacSFDzc0K2LTgN3r2k6HLF3SJnsih7t/FLTEjLlMFxSLMd/4em1sL7cDFZeQTp10624fSNtv
t3zi/suGeHsOy+BAFzJj5i09TMHo/maIjSSU4tNkBVMpnpgBiMqu2prns9UDz7h+rFSBaogkN1E2
M6abCy6xvZRqriWbG5fmnmsj9J1OmxxsbiIGI8tpwv/Ec+5rA8+tT7mGq5vgVbNfNwjrI7VsFaWp
xI7fewmuBFOQCQ2qyHMhNeQUY56jaUiz2pezdoHHGpqXAibd5vFuEX9jbszLor8F04M3ZjIZju9G
P/0I18Ho4/AKKpUko/Ad/EWW3SoMBkBM/fx3FTARWD/Xa/uJeEgZVYVkDzFjkZ5JUTzOKlWLYTEs
hsWwGBbDYlgMi2ExLIbFsBgWw2JYDIthMSyGxbAYFsNiWAyLYTEshsWwGBbDYlgMi2ExLIbFsBhv
xfjmBs+OTuCJPD9iOmapmL9prvPqJqh7rpmndQmByvi+CildQqFYBCoRWvngNjut1/wC9Ls74kea
jns4D7rn2DvVsXOqY+tUR/cFR/efHMm7dnw+SRrH/9UEa3DKgDzVs4cZTXwz/1wkDBI0zRSD81sp
cskZtvTqHDRFSQVPDGNIGl+cSKPfcHqoVwnGbdchNSivzuZqhoiv2465L6/lvdtyvPIer9VSKg/5
WqrVaNcjGi14zKGi5hlIp9/pVM/yMKTSjL/j90WhwNxhkIqZSVUTrSgrgPkqR/WHGcZm0vUscm8d
ecXcmeF+vLjVV/4g4B38QaB//A8C/VMGxhc8n63QIaUhtBt9wDtoNTz0M83iNTo7i09YjdkCPhes
YNArK3oZXICWNI55eNysX5pNGUUCtTMJ9IxJocBUBndm6YAsvRYpP9hG8vMAY8GCoCkeWmbiN5TM
xKFWKebzybRfxGJaJBpbYXXCiPBa/Pk5uVl7fkyuF0fr0WWgBXYJJnFANg/MAss0Dw0dvh0zCG7B
FC32Ox3fjX0W++1tLOP7fXszYB5LkR6aQ6XcwmQ2UzQ0lgPXwOpCDUj1yNZbTgxWhPyNLIExHjOV
v4gR0pxOsTbt3eZAeTToVr/eLnpPtXYAEXtjOlBOmRxs933m+Go131Wfo6X/P1d4zOipNe4dqfHf
Al0VFfk0AAA=

--=_1anlkapur4f4--
