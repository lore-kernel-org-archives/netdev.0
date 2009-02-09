From: Risto Suominen <risto.suominen@gmail.com>
Subject: Fwd: [PATCH 002/002] de2104x: support for systems lacking cache
	coherence
Date: Mon, 9 Feb 2009 09:27:49 +0200
Message-ID: <46e1c7760902082327s1c498ac3w56939960ac306426@mail.gmail.com>
References: <46e1c7760902071330i5362fe4fvd99fc7075fc666d3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001636c5b387cb420b0462774e76
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:47982 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753943AbZBIH1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 02:27:51 -0500
Received: by fxm13 with SMTP id 13so2381787fxm.13
        for <netdev@vger.kernel.org>; Sun, 08 Feb 2009 23:27:49 -0800 (PST)
In-Reply-To: <46e1c7760902071330i5362fe4fvd99fc7075fc666d3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001636c5b387cb420b0462774e76
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

---------- Forwarded message ----------
From: Risto Suominen <risto.suominen@gmail.com>
Date: 2009/2/7
Subject: [PATCH 002/002] de2104x: support for systems lacking cache coherence
To: Jeff Garzik <jgarzik@pobox.com>, lkml <linux-kernel@vger.kernel.org>


Add a configurable Descriptor Skip Length for systems that lack cache coherence.

Signed-off-by: Risto Suominen <Risto.Suominen@gmail.com>
---
The testing is done on kernel version 2.6.18.

--- drivers/net/tulip/Kconfig.org       2006-09-20 06:42:06.000000000 +0300
+++ drivers/net/tulip/Kconfig   2009-02-07 20:48:17.000000000 +0200
@@ -27,6 +27,18 @@ config DE2104X
         To compile this driver as a module, choose M here. The module will
         be called de2104x.

+config DE2104X_DSL
+       int "Descriptor Skip Length in 32 bit longwords"
+       depends on DE2104X
+       range 0 31
+       default 0
+       help
+         Setting this value allows to align ring buffer descriptors into their
+         own cache lines. Value of 4 corresponds to the typical 32 byte line
+         (the descriptor is 16 bytes). This is necessary on systems that lack
+         cache coherence, an example is PowerMac 5500. Otherwise 0 is safe.
+         Default is 0, and range is 0 to 31.
+
 config TULIP
       tristate "DECchip Tulip (dc2114x) PCI support"
       depends on PCI
--- drivers/net/tulip/de2104x.c.org     2006-09-20 06:42:06.000000000 +0300
+++ drivers/net/tulip/de2104x.c 2009-02-07 15:04:04.000000000 +0200
@@ -82,6 +82,13 @@ MODULE_PARM_DESC (rx_copybreak, "de2104x
                                NETIF_MSG_RX_ERR       | \
                                NETIF_MSG_TX_ERR)

+/* Descriptor skip length in 32 bit longwords. */
+#ifndef CONFIG_DE2104X_DSL
+#define DSL                    0
+#else
+#define DSL                    CONFIG_DE2104X_DSL
+#endif
+
 #define DE_RX_RING_SIZE                64
 #define DE_TX_RING_SIZE                64
 #define DE_RING_BYTES          \
@@ -153,6 +160,7 @@ enum {
       CmdReset                = (1 << 0),
       CacheAlign16            = 0x00008000,
       BurstLen4               = 0x00000400,
+       DescSkipLen             = (DSL << 2),

       /* Rx/TxPoll bits */
       NormalTxPoll            = (1 << 0),
@@ -246,7 +254,7 @@ static const u32 de_intr_mask =
 * Set the programmable burst length to 4 longwords for all:
 * DMA errors result without these values. Cache align 16 long.
 */
-static const u32 de_bus_mode = CacheAlign16 | BurstLen4;
+static const u32 de_bus_mode = CacheAlign16 | BurstLen4 | DescSkipLen;

 struct de_srom_media_block {
       u8                      opts;
@@ -266,6 +274,9 @@ struct de_desc {
       __le32                  opts2;
       __le32                  addr1;
       __le32                  addr2;
+#if DSL
+       __le32                  skip[DSL];
+#endif
 };

 struct media_info {

--001636c5b387cb420b0462774e76
Content-Type: text/x-diff; charset=US-ASCII; name="de2104x-dsl.patch"
Content-Disposition: attachment; filename="de2104x-dsl.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fqwsmz7m0

QWRkIGEgY29uZmlndXJhYmxlIERlc2NyaXB0b3IgU2tpcCBMZW5ndGggZm9yIHN5c3RlbXMgdGhh
dCBsYWNrIGNhY2hlIGNvaGVyZW5jZS4KClNpZ25lZC1vZmYtYnk6IFJpc3RvIFN1b21pbmVuIDxS
aXN0by5TdW9taW5lbkBnbWFpbC5jb20+Ci0tLQpUaGUgdGVzdGluZyBpcyBkb25lIG9uIGtlcm5l
bCB2ZXJzaW9uIDIuNi4xOC4KCi0tLSBkcml2ZXJzL25ldC90dWxpcC9LY29uZmlnLm9yZwkyMDA2
LTA5LTIwIDA2OjQyOjA2LjAwMDAwMDAwMCArMDMwMAorKysgZHJpdmVycy9uZXQvdHVsaXAvS2Nv
bmZpZwkyMDA5LTAyLTA3IDIwOjQ4OjE3LjAwMDAwMDAwMCArMDIwMApAQCAtMjcsNiArMjcsMTgg
QEAgY29uZmlnIERFMjEwNFgKIAkgIFRvIGNvbXBpbGUgdGhpcyBkcml2ZXIgYXMgYSBtb2R1bGUs
IGNob29zZSBNIGhlcmUuIFRoZSBtb2R1bGUgd2lsbAogCSAgYmUgY2FsbGVkIGRlMjEwNHguCiAK
K2NvbmZpZyBERTIxMDRYX0RTTAorCWludCAiRGVzY3JpcHRvciBTa2lwIExlbmd0aCBpbiAzMiBi
aXQgbG9uZ3dvcmRzIgorCWRlcGVuZHMgb24gREUyMTA0WAorCXJhbmdlIDAgMzEKKwlkZWZhdWx0
IDAKKwloZWxwCisJICBTZXR0aW5nIHRoaXMgdmFsdWUgYWxsb3dzIHRvIGFsaWduIHJpbmcgYnVm
ZmVyIGRlc2NyaXB0b3JzIGludG8gdGhlaXIKKwkgIG93biBjYWNoZSBsaW5lcy4gVmFsdWUgb2Yg
NCBjb3JyZXNwb25kcyB0byB0aGUgdHlwaWNhbCAzMiBieXRlIGxpbmUKKwkgICh0aGUgZGVzY3Jp
cHRvciBpcyAxNiBieXRlcykuIFRoaXMgaXMgbmVjZXNzYXJ5IG9uIHN5c3RlbXMgdGhhdCBsYWNr
CisJICBjYWNoZSBjb2hlcmVuY2UsIGFuIGV4YW1wbGUgaXMgUG93ZXJNYWMgNTUwMC4gT3RoZXJ3
aXNlIDAgaXMgc2FmZS4KKwkgIERlZmF1bHQgaXMgMCwgYW5kIHJhbmdlIGlzIDAgdG8gMzEuCisK
IGNvbmZpZyBUVUxJUAogCXRyaXN0YXRlICJERUNjaGlwIFR1bGlwIChkYzIxMTR4KSBQQ0kgc3Vw
cG9ydCIKIAlkZXBlbmRzIG9uIFBDSQotLS0gZHJpdmVycy9uZXQvdHVsaXAvZGUyMTA0eC5jLm9y
ZwkyMDA2LTA5LTIwIDA2OjQyOjA2LjAwMDAwMDAwMCArMDMwMAorKysgZHJpdmVycy9uZXQvdHVs
aXAvZGUyMTA0eC5jCTIwMDktMDItMDcgMTU6MDQ6MDQuMDAwMDAwMDAwICswMjAwCkBAIC04Miw2
ICs4MiwxMyBAQCBNT0RVTEVfUEFSTV9ERVNDIChyeF9jb3B5YnJlYWssICJkZTIxMDR4CiAJCQkJ
IE5FVElGX01TR19SWF9FUlIJfCBcCiAJCQkJIE5FVElGX01TR19UWF9FUlIpCiAKKy8qIERlc2Ny
aXB0b3Igc2tpcCBsZW5ndGggaW4gMzIgYml0IGxvbmd3b3Jkcy4gKi8KKyNpZm5kZWYgQ09ORklH
X0RFMjEwNFhfRFNMCisjZGVmaW5lIERTTAkJCTAKKyNlbHNlCisjZGVmaW5lIERTTAkJCUNPTkZJ
R19ERTIxMDRYX0RTTAorI2VuZGlmCisKICNkZWZpbmUgREVfUlhfUklOR19TSVpFCQk2NAogI2Rl
ZmluZSBERV9UWF9SSU5HX1NJWkUJCTY0CiAjZGVmaW5lIERFX1JJTkdfQllURVMJCVwKQEAgLTE1
Myw2ICsxNjAsNyBAQCBlbnVtIHsKIAlDbWRSZXNldAkJPSAoMSA8PCAwKSwKIAlDYWNoZUFsaWdu
MTYJCT0gMHgwMDAwODAwMCwKIAlCdXJzdExlbjQJCT0gMHgwMDAwMDQwMCwKKwlEZXNjU2tpcExl
bgkJPSAoRFNMIDw8IDIpLAogCiAJLyogUngvVHhQb2xsIGJpdHMgKi8KIAlOb3JtYWxUeFBvbGwJ
CT0gKDEgPDwgMCksCkBAIC0yNDYsNyArMjU0LDcgQEAgc3RhdGljIGNvbnN0IHUzMiBkZV9pbnRy
X21hc2sgPQogICogU2V0IHRoZSBwcm9ncmFtbWFibGUgYnVyc3QgbGVuZ3RoIHRvIDQgbG9uZ3dv
cmRzIGZvciBhbGw6CiAgKiBETUEgZXJyb3JzIHJlc3VsdCB3aXRob3V0IHRoZXNlIHZhbHVlcy4g
Q2FjaGUgYWxpZ24gMTYgbG9uZy4KICAqLwotc3RhdGljIGNvbnN0IHUzMiBkZV9idXNfbW9kZSA9
IENhY2hlQWxpZ24xNiB8IEJ1cnN0TGVuNDsKK3N0YXRpYyBjb25zdCB1MzIgZGVfYnVzX21vZGUg
PSBDYWNoZUFsaWduMTYgfCBCdXJzdExlbjQgfCBEZXNjU2tpcExlbjsKIAogc3RydWN0IGRlX3Ny
b21fbWVkaWFfYmxvY2sgewogCXU4CQkJb3B0czsKQEAgLTI2Niw2ICsyNzQsOSBAQCBzdHJ1Y3Qg
ZGVfZGVzYyB7CiAJX19sZTMyCQkJb3B0czI7CiAJX19sZTMyCQkJYWRkcjE7CiAJX19sZTMyCQkJ
YWRkcjI7CisjaWYgRFNMCisJX19sZTMyCQkJc2tpcFtEU0xdOworI2VuZGlmCiB9OwogCiBzdHJ1
Y3QgbWVkaWFfaW5mbyB7Cg==
--001636c5b387cb420b0462774e76--
