From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net 3/3] macsec: validate ICV length on link creation
Date: Fri, 22 Jul 2016 15:07:58 +0200
Message-ID: <2a7e1975d5613d733f7aa0f09584b2bbf9eb8a0c.1469191850.git.dcaratti@redhat.com>
References: <cover.1469191850.git.dcaratti@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61240 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754040AbcGVNJQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 09:09:16 -0400
In-Reply-To: <cover.1469191850.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Test the cipher suite initialization in case ICV length has a value
different than its default. If this test fails, creation of a new macsec
link will also fail. This avoids situations where further security
associations can't be added due to failures of crypto_aead_setauthsize(),
caused by unsupported user-provided values of the ICV length.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 drivers/net/macsec.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 6d45ba6..5441517 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -3206,8 +3206,20 @@ static int macsec_validate_attr(struct nlattr *tb[], struct nlattr *data[])
 	if (data[IFLA_MACSEC_CIPHER_SUITE])
 		csid = nla_get_u64(data[IFLA_MACSEC_CIPHER_SUITE]);
 
-	if (data[IFLA_MACSEC_ICV_LEN])
+	if (data[IFLA_MACSEC_ICV_LEN]) {
 		icv_len = nla_get_u8(data[IFLA_MACSEC_ICV_LEN]);
+		if (icv_len != DEFAULT_ICV_LEN) {
+			char dummy_key[DEFAULT_SAK_LEN] = { 0 };
+			struct crypto_aead *dummy_tfm;
+
+			dummy_tfm = macsec_alloc_tfm(dummy_key,
+						     DEFAULT_SAK_LEN,
+						     icv_len);
+			if (IS_ERR(dummy_tfm))
+				return PTR_ERR(dummy_tfm);
+			crypto_free_aead(dummy_tfm);
+		}
+	}
 
 	switch (csid) {
 	case MACSEC_DEFAULT_CIPHER_ID:
-- 
2.5.5
