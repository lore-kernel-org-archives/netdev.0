From: "Luke Yang" <luke.adi@gmail.com>
Subject: [PATCH]unaligned access in irda protocol stack
Date: Tue, 11 Jul 2006 12:50:48 +0800
Message-ID: <489ecd0c0607102150pa905b24g6a7ca10de19ee4a9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_17335_19259067.1152593448090"
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:44117 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S965164AbWGKEut (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 00:50:49 -0400
Received: by ug-out-1314.google.com with SMTP id a2so4170758ugf
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2006 21:50:48 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_17335_19259067.1152593448090
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi all,

 For "struct irda_device_info" in irda.h:
struct irda_device_info {
       __u32       saddr;    /* Address of local interface */
       __u32       daddr;    /* Address of remote device */
       char        info[22]; /* Description */
       __u8        charset;  /* Charset used for description */
       __u8        hints[2]; /* Hint bits */
};
  The "hints" member aligns at the third byte of a word, an odd
address. So if we visit "hints" as a short in irlmp.c and discorery.c:

   u16ho(irlmp->discovery_cmd.data.hints) = irlmp->hints.word;

 will cause alignment problem on some machines. Architectures with
strict alignment rules do not allow 16-bit read on an odd address.

Signed-off-by: Luke Yang <luke.adi@gmail.com>
Acked-by: David Miller <davem@davemloft.net>

 discovery.c |    6 ++++--
 irlmp.c     |    8 +++++---
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/irda/discovery.c b/net/irda/discovery.c
index 3fefc82..bc5280c 100644
--- a/net/irda/discovery.c
+++ b/net/irda/discovery.c
@@ -38,6 +38,7 @@ #include <net/irda/irda.h>
 #include <net/irda/irlmp.h>

 #include <net/irda/discovery.h>
+#include <asm/unaligned.h>

 /*
  * Function irlmp_add_discovery (cachelog, discovery)
@@ -86,7 +87,8 @@ void irlmp_add_discovery(hashbin_t *cach
                         */
                        hashbin_remove_this(cachelog, (irda_queue_t *) node);
                        /* Check if hints bits are unchanged */
-                       if(u16ho(node->data.hints) == u16ho(new->data.hints))
+                       if(get_unaligned(node->data.hints) ==
+                          get_unaligned(new->data.hints))
                                /* Set time of first discovery for this node */
                                new->firststamp = node->firststamp;
                        kfree(node);
@@ -280,7 +282,7 @@ struct irda_device_info *irlmp_copy_disc
                /* Mask out the ones we don't want :
                 * We want to match the discovery mask, and to get only
                 * the most recent one (unless we want old ones) */
-               if ((u16ho(discovery->data.hints) & mask) &&
+               if ((get_unaligned(discovery->data.hints) & mask) &&
                    ((old_entries) ||
                     ((jiffies - discovery->firststamp) < j_timeout)) ) {
                        /* Create buffer as needed.
diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
index 129ad64..dc36528 100644
--- a/net/irda/irlmp.c
+++ b/net/irda/irlmp.c
@@ -42,7 +42,6 @@ #include <net/irda/irlap.h>
 #include <net/irda/iriap.h>
 #include <net/irda/irlmp.h>
 #include <net/irda/irlmp_frame.h>
-
 #include <asm/unaligned.h>

 static __u8 irlmp_find_free_slsap(void);
@@ -1063,7 +1062,8 @@ void irlmp_discovery_expiry(discinfo_t *
                for(i = 0; i < number; i++) {
                        /* Check if we should notify client */
                        if ((client->expir_callback) &&
-                           (client->hint_mask.word & u16ho(expiries[i].hints)
+                           (client->hint_mask.word &
+                            get_unaligned(expiries[i].hints)
                             & 0x7f7f) )
                                client->expir_callback(&(expiries[i]),
                                                       EXPIRY_TIMEOUT,
@@ -1083,11 +1083,13 @@ void irlmp_discovery_expiry(discinfo_t *
  */
 discovery_t *irlmp_get_discovery_response(void)
 {
+       __u16 *data_hintsp;
        IRDA_DEBUG(4, "%s()\n", __FUNCTION__);

        IRDA_ASSERT(irlmp != NULL, return NULL;);

-       u16ho(irlmp->discovery_rsp.data.hints) = irlmp->hints.word;
+       data_hintsp = (__u16 *) irlmp->discovery_rsp.data.hints;
+       put_unaligned(irlmp->hints.word, data_hintsp);

        /*
         *  Set character set for device name (we use ASCII), and

--
Best regards,
Luke Yang
luke.adi@gmail.com

------=_Part_17335_19259067.1152593448090
Content-Type: text/x-patch; name="irda_unaligned.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="irda_unaligned.patch"
X-Attachment-Id: f_ephsajr7

ZGlmZiAtLWdpdCBhL25ldC9pcmRhL2Rpc2NvdmVyeS5jIGIvbmV0L2lyZGEvZGlzY292ZXJ5LmMK
aW5kZXggM2ZlZmM4Mi4uYmM1MjgwYyAxMDA2NDQKLS0tIGEvbmV0L2lyZGEvZGlzY292ZXJ5LmMK
KysrIGIvbmV0L2lyZGEvZGlzY292ZXJ5LmMKQEAgLTM4LDYgKzM4LDcgQEAgI2luY2x1ZGUgPG5l
dC9pcmRhL2lyZGEuaD4KICNpbmNsdWRlIDxuZXQvaXJkYS9pcmxtcC5oPgogCiAjaW5jbHVkZSA8
bmV0L2lyZGEvZGlzY292ZXJ5Lmg+CisjaW5jbHVkZSA8YXNtL3VuYWxpZ25lZC5oPgogCiAvKgog
ICogRnVuY3Rpb24gaXJsbXBfYWRkX2Rpc2NvdmVyeSAoY2FjaGVsb2csIGRpc2NvdmVyeSkKQEAg
LTg2LDcgKzg3LDggQEAgdm9pZCBpcmxtcF9hZGRfZGlzY292ZXJ5KGhhc2hiaW5fdCAqY2FjaAog
CQkJICovCiAJCQloYXNoYmluX3JlbW92ZV90aGlzKGNhY2hlbG9nLCAoaXJkYV9xdWV1ZV90ICop
IG5vZGUpOwogCQkJLyogQ2hlY2sgaWYgaGludHMgYml0cyBhcmUgdW5jaGFuZ2VkICovCi0JCQlp
Zih1MTZobyhub2RlLT5kYXRhLmhpbnRzKSA9PSB1MTZobyhuZXctPmRhdGEuaGludHMpKQorCQkJ
aWYoZ2V0X3VuYWxpZ25lZChub2RlLT5kYXRhLmhpbnRzKSA9PQorCQkJICAgZ2V0X3VuYWxpZ25l
ZChuZXctPmRhdGEuaGludHMpKQogCQkJCS8qIFNldCB0aW1lIG9mIGZpcnN0IGRpc2NvdmVyeSBm
b3IgdGhpcyBub2RlICovCiAJCQkJbmV3LT5maXJzdHN0YW1wID0gbm9kZS0+Zmlyc3RzdGFtcDsK
IAkJCWtmcmVlKG5vZGUpOwpAQCAtMjgwLDcgKzI4Miw3IEBAIHN0cnVjdCBpcmRhX2RldmljZV9p
bmZvICppcmxtcF9jb3B5X2Rpc2MKIAkJLyogTWFzayBvdXQgdGhlIG9uZXMgd2UgZG9uJ3Qgd2Fu
dCA6CiAJCSAqIFdlIHdhbnQgdG8gbWF0Y2ggdGhlIGRpc2NvdmVyeSBtYXNrLCBhbmQgdG8gZ2V0
IG9ubHkKIAkJICogdGhlIG1vc3QgcmVjZW50IG9uZSAodW5sZXNzIHdlIHdhbnQgb2xkIG9uZXMp
ICovCi0JCWlmICgodTE2aG8oZGlzY292ZXJ5LT5kYXRhLmhpbnRzKSAmIG1hc2spICYmCisJCWlm
ICgoZ2V0X3VuYWxpZ25lZChkaXNjb3ZlcnktPmRhdGEuaGludHMpICYgbWFzaykgJiYKIAkJICAg
ICgob2xkX2VudHJpZXMpIHx8CiAJCSAgICAgKChqaWZmaWVzIC0gZGlzY292ZXJ5LT5maXJzdHN0
YW1wKSA8IGpfdGltZW91dCkpICkgewogCQkJLyogQ3JlYXRlIGJ1ZmZlciBhcyBuZWVkZWQuCmRp
ZmYgLS1naXQgYS9uZXQvaXJkYS9pcmxtcC5jIGIvbmV0L2lyZGEvaXJsbXAuYwppbmRleCAxMjlh
ZDY0Li5kYzM2NTI4IDEwMDY0NAotLS0gYS9uZXQvaXJkYS9pcmxtcC5jCisrKyBiL25ldC9pcmRh
L2lybG1wLmMKQEAgLTQyLDcgKzQyLDYgQEAgI2luY2x1ZGUgPG5ldC9pcmRhL2lybGFwLmg+CiAj
aW5jbHVkZSA8bmV0L2lyZGEvaXJpYXAuaD4KICNpbmNsdWRlIDxuZXQvaXJkYS9pcmxtcC5oPgog
I2luY2x1ZGUgPG5ldC9pcmRhL2lybG1wX2ZyYW1lLmg+Ci0KICNpbmNsdWRlIDxhc20vdW5hbGln
bmVkLmg+CiAKIHN0YXRpYyBfX3U4IGlybG1wX2ZpbmRfZnJlZV9zbHNhcCh2b2lkKTsKQEAgLTEw
NjMsNyArMTA2Miw4IEBAIHZvaWQgaXJsbXBfZGlzY292ZXJ5X2V4cGlyeShkaXNjaW5mb190ICoK
IAkJZm9yKGkgPSAwOyBpIDwgbnVtYmVyOyBpKyspIHsKIAkJCS8qIENoZWNrIGlmIHdlIHNob3Vs
ZCBub3RpZnkgY2xpZW50ICovCiAJCQlpZiAoKGNsaWVudC0+ZXhwaXJfY2FsbGJhY2spICYmCi0J
CQkgICAgKGNsaWVudC0+aGludF9tYXNrLndvcmQgJiB1MTZobyhleHBpcmllc1tpXS5oaW50cykK
KwkJCSAgICAoY2xpZW50LT5oaW50X21hc2sud29yZCAmCisJCQkgICAgIGdldF91bmFsaWduZWQo
ZXhwaXJpZXNbaV0uaGludHMpCiAJCQkgICAgICYgMHg3ZjdmKSApCiAJCQkJY2xpZW50LT5leHBp
cl9jYWxsYmFjaygmKGV4cGlyaWVzW2ldKSwKIAkJCQkJCSAgICAgICBFWFBJUllfVElNRU9VVCwK
QEAgLTEwODMsMTEgKzEwODMsMTMgQEAgdm9pZCBpcmxtcF9kaXNjb3ZlcnlfZXhwaXJ5KGRpc2Np
bmZvX3QgKgogICovCiBkaXNjb3ZlcnlfdCAqaXJsbXBfZ2V0X2Rpc2NvdmVyeV9yZXNwb25zZSh2
b2lkKQogeworCV9fdTE2ICpkYXRhX2hpbnRzcDsKIAlJUkRBX0RFQlVHKDQsICIlcygpXG4iLCBf
X0ZVTkNUSU9OX18pOwogCiAJSVJEQV9BU1NFUlQoaXJsbXAgIT0gTlVMTCwgcmV0dXJuIE5VTEw7
KTsKIAotCXUxNmhvKGlybG1wLT5kaXNjb3ZlcnlfcnNwLmRhdGEuaGludHMpID0gaXJsbXAtPmhp
bnRzLndvcmQ7CisJZGF0YV9oaW50c3AgPSAoX191MTYgKikgaXJsbXAtPmRpc2NvdmVyeV9yc3Au
ZGF0YS5oaW50czsKKwlwdXRfdW5hbGlnbmVkKGlybG1wLT5oaW50cy53b3JkLCBkYXRhX2hpbnRz
cCk7CiAKIAkvKgogCSAqICBTZXQgY2hhcmFjdGVyIHNldCBmb3IgZGV2aWNlIG5hbWUgKHdlIHVz
ZSBBU0NJSSksIGFuZAo=
------=_Part_17335_19259067.1152593448090--
