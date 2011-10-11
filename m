From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: e100 + VLANs?
Date: Tue, 11 Oct 2011 13:25:22 +0200
Message-ID: <CAL4WiiphpyizVaNkvOdJp1+UK53TkGw9RXnC-vzH7fTNpBAAEA@mail.gmail.com>
References: <4E90212D.8030009@msgid.tls.msk.ru>
	<1318091046.5276.22.camel@edumazet-laptop>
	<4E9097C0.2030307@gmail.com>
	<20111010101954.GB2840382@jupiter.n2.diac24.net>
	<4E9307CB.4050704@msgid.tls.msk.ru>
	<1318259152.3227.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111010151343.GB3260852@jupiter.n2.diac24.net>
	<4E932278.8010802@tls.msk.ru>
	<4E941198.9000307@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=90e6ba47677fcde36c04af04290a
Cc: David Lamparter <equinox@diac24.net>, jeffrey.t.kirsher@intel.com,
	netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:55043 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266Ab1JKLZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 07:25:23 -0400
Received: by iaek3 with SMTP id k3so510832iae.19
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 04:25:23 -0700 (PDT)
In-Reply-To: <4E941198.9000307@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--90e6ba47677fcde36c04af04290a
Content-Type: text/plain; charset=ISO-8859-1

> So, is that a hardware limitation?

Its a driver bug

This comes from fact that sizeof(struct rfd) = 16

and VLAN_ETH_FRAME_LEN is 1518

driver mixes VLAN_ETH_FRAME_LEN and 1500+4+sizeof(struct rfd)   (1520, not 1518)

It therefore misses 2 bytes for large frames (VLAN tagged)

Fix is to remove VLAN_ETH_FRAME_LEN references for good...

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index c1352c6..3287d31 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -435,6 +435,7 @@ struct rfd {
        __le16 actual_size;
        __le16 size;
 };
+#define RFD_BUF_LEN (sizeof(struct rfd) + ETH_DATA_LEN + VLAN_HLEN)

 struct rx {
        struct rx *next, *prev;
@@ -1075,7 +1076,7 @@ static void e100_get_defaults(struct nic *nic)
        /* Template for a freshly allocated RFD */
        nic->blank_rfd.command = 0;
        nic->blank_rfd.rbd = cpu_to_le32(0xFFFFFFFF);
-       nic->blank_rfd.size = cpu_to_le16(VLAN_ETH_FRAME_LEN);
+       nic->blank_rfd.size = cpu_to_le16(RFD_BUF_LEN);

        /* MII setup */
        nic->mii.phy_id_mask = 0x1F;
@@ -1881,7 +1882,6 @@ static inline void e100_start_receiver(struct
nic *nic, struct rx *rx)
        }
 }

-#define RFD_BUF_LEN (sizeof(struct rfd) + VLAN_ETH_FRAME_LEN)
 static int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
 {
        if (!(rx->skb = netdev_alloc_skb_ip_align(nic->netdev, RFD_BUF_LEN)))
@@ -2058,7 +2058,7 @@ static void e100_rx_clean(struct nic *nic,
unsigned int *work_done,
                pci_dma_sync_single_for_device(nic->pdev,
                        old_before_last_rx->dma_addr, sizeof(struct rfd),
                        PCI_DMA_BIDIRECTIONAL);
-               old_before_last_rfd->size = cpu_to_le16(VLAN_ETH_FRAME_LEN);
+               old_before_last_rfd->size = cpu_to_le16(RFD_BUF_LEN);
                pci_dma_sync_single_for_device(nic->pdev,
                        old_before_last_rx->dma_addr, sizeof(struct rfd),
                        PCI_DMA_BIDIRECTIONAL);

--90e6ba47677fcde36c04af04290a
Content-Type: application/octet-stream; name=patch
Content-Disposition: attachment; filename=patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gtmszd8w0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2UxMDAuYyBiL2RyaXZlcnMvbmV0L2UxMDAuYwppbmRl
eCBjMTM1MmM2Li4zMjg3ZDMxIDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9lMTAwLmMKKysrIGIv
ZHJpdmVycy9uZXQvZTEwMC5jCkBAIC00MzUsNiArNDM1LDcgQEAgc3RydWN0IHJmZCB7CiAJX19s
ZTE2IGFjdHVhbF9zaXplOwogCV9fbGUxNiBzaXplOwogfTsKKyNkZWZpbmUgUkZEX0JVRl9MRU4g
KHNpemVvZihzdHJ1Y3QgcmZkKSArIEVUSF9EQVRBX0xFTiArIFZMQU5fSExFTikKIAogc3RydWN0
IHJ4IHsKIAlzdHJ1Y3QgcnggKm5leHQsICpwcmV2OwpAQCAtMTA3NSw3ICsxMDc2LDcgQEAgc3Rh
dGljIHZvaWQgZTEwMF9nZXRfZGVmYXVsdHMoc3RydWN0IG5pYyAqbmljKQogCS8qIFRlbXBsYXRl
IGZvciBhIGZyZXNobHkgYWxsb2NhdGVkIFJGRCAqLwogCW5pYy0+YmxhbmtfcmZkLmNvbW1hbmQg
PSAwOwogCW5pYy0+YmxhbmtfcmZkLnJiZCA9IGNwdV90b19sZTMyKDB4RkZGRkZGRkYpOwotCW5p
Yy0+YmxhbmtfcmZkLnNpemUgPSBjcHVfdG9fbGUxNihWTEFOX0VUSF9GUkFNRV9MRU4pOworCW5p
Yy0+YmxhbmtfcmZkLnNpemUgPSBjcHVfdG9fbGUxNihSRkRfQlVGX0xFTik7CiAKIAkvKiBNSUkg
c2V0dXAgKi8KIAluaWMtPm1paS5waHlfaWRfbWFzayA9IDB4MUY7CkBAIC0xODgxLDcgKzE4ODIs
NiBAQCBzdGF0aWMgaW5saW5lIHZvaWQgZTEwMF9zdGFydF9yZWNlaXZlcihzdHJ1Y3QgbmljICpu
aWMsIHN0cnVjdCByeCAqcngpCiAJfQogfQogCi0jZGVmaW5lIFJGRF9CVUZfTEVOIChzaXplb2Yo
c3RydWN0IHJmZCkgKyBWTEFOX0VUSF9GUkFNRV9MRU4pCiBzdGF0aWMgaW50IGUxMDBfcnhfYWxs
b2Nfc2tiKHN0cnVjdCBuaWMgKm5pYywgc3RydWN0IHJ4ICpyeCkKIHsKIAlpZiAoIShyeC0+c2ti
ID0gbmV0ZGV2X2FsbG9jX3NrYl9pcF9hbGlnbihuaWMtPm5ldGRldiwgUkZEX0JVRl9MRU4pKSkK
QEAgLTIwNTgsNyArMjA1OCw3IEBAIHN0YXRpYyB2b2lkIGUxMDBfcnhfY2xlYW4oc3RydWN0IG5p
YyAqbmljLCB1bnNpZ25lZCBpbnQgKndvcmtfZG9uZSwKIAkJcGNpX2RtYV9zeW5jX3NpbmdsZV9m
b3JfZGV2aWNlKG5pYy0+cGRldiwKIAkJCW9sZF9iZWZvcmVfbGFzdF9yeC0+ZG1hX2FkZHIsIHNp
emVvZihzdHJ1Y3QgcmZkKSwKIAkJCVBDSV9ETUFfQklESVJFQ1RJT05BTCk7Ci0JCW9sZF9iZWZv
cmVfbGFzdF9yZmQtPnNpemUgPSBjcHVfdG9fbGUxNihWTEFOX0VUSF9GUkFNRV9MRU4pOworCQlv
bGRfYmVmb3JlX2xhc3RfcmZkLT5zaXplID0gY3B1X3RvX2xlMTYoUkZEX0JVRl9MRU4pOwogCQlw
Y2lfZG1hX3N5bmNfc2luZ2xlX2Zvcl9kZXZpY2UobmljLT5wZGV2LAogCQkJb2xkX2JlZm9yZV9s
YXN0X3J4LT5kbWFfYWRkciwgc2l6ZW9mKHN0cnVjdCByZmQpLAogCQkJUENJX0RNQV9CSURJUkVD
VElPTkFMKTsK
--90e6ba47677fcde36c04af04290a--
