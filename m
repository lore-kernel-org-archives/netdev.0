From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] iwlwifi: mvm: avoid harmless -Wmaybe-uninialized warning
Date: Fri, 27 May 2016 15:07:03 +0200
Message-ID: <1464354462-1940949-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Johannes Berg <johannes.berg@intel.com>,
	Luca Coelho <luciano.coelho@intel.com>,
	Intel Linux Wireless <linuxwifi@intel.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Moshe Harel <moshe.harel@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Matti Gottlieb <matti.gottlieb@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc is apparently unablel to track the state of the local 'resp_v2'
variable across the kzalloc() function, and warns about the response
variable being used without an initialization:

drivers/net/wireless/intel/iwlwifi/mvm/nvm.c: In function =E2=80=98iwl_=
mvm_update_mcc=E2=80=99:
drivers/net/wireless/intel/iwlwifi/mvm/nvm.c:727:36: warning: =E2=80=98=
mcc_resp_v1=E2=80=99 may be used uninitialized in this function [-Wmayb=
e-uninitialized]
   resp_cp->n_channels =3D mcc_resp_v1->n_channels;
drivers/net/wireless/intel/iwlwifi/mvm/nvm.c:721:3: warning: =E2=80=98m=
cc_resp=E2=80=99 may be used uninitialized in this function [-Wmaybe-un=
initialized]
   memcpy(resp_cp, mcc_resp, resp_len);

The warning showed up in x86 allmodconfig after my patch to
unhide -Wmaybe-uninitialized warnings by default was merged,
though it always existed in randconfig builds. I did not
catch the warning earlier because I was testing on ARM, which
never produced the warning.

This rearranges the code in a way that improves readability for
both humans and the compiler, and that avoids the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
=46ixes: 6fa52430f0b3 ("iwlwifi: mvm: change mcc update API")
---
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c | 41 ++++++++++++++------=
--------
 1 file changed, 21 insertions(+), 20 deletions(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/mvm/nvm.c b/drivers/net=
/wireless/intel/iwlwifi/mvm/nvm.c
index 25a98401a64f..0551a4bb163c 100644
--- a/drivers/net/wireless/intel/iwlwifi/mvm/nvm.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/nvm.c
@@ -667,8 +667,7 @@ iwl_mvm_update_mcc(struct iwl_mvm *mvm, const char =
*alpha2,
 		.mcc =3D cpu_to_le16(alpha2[0] << 8 | alpha2[1]),
 		.source_id =3D (u8)src_id,
 	};
-	struct iwl_mcc_update_resp *mcc_resp, *resp_cp =3D NULL;
-	struct iwl_mcc_update_resp_v1 *mcc_resp_v1 =3D NULL;
+	struct iwl_mcc_update_resp *resp_cp;
 	struct iwl_rx_packet *pkt;
 	struct iwl_host_cmd cmd =3D {
 		.id =3D MCC_UPDATE_CMD,
@@ -701,34 +700,36 @@ iwl_mvm_update_mcc(struct iwl_mvm *mvm, const cha=
r *alpha2,
=20
 	/* Extract MCC response */
 	if (resp_v2) {
-		mcc_resp =3D (void *)pkt->data;
+		struct iwl_mcc_update_resp *mcc_resp =3D (void *)pkt->data;
+
 		n_channels =3D  __le32_to_cpu(mcc_resp->n_channels);
+		resp_len =3D sizeof(struct iwl_mcc_update_resp) +
+			   n_channels * sizeof(__le32);
+		resp_cp =3D kmemdup(mcc_resp, resp_len, GFP_KERNEL);
 	} else {
-		mcc_resp_v1 =3D (void *)pkt->data;
+		struct iwl_mcc_update_resp_v1 *mcc_resp_v1 =3D (void *)pkt->data;
+
 		n_channels =3D  __le32_to_cpu(mcc_resp_v1->n_channels);
+		resp_len =3D sizeof(struct iwl_mcc_update_resp) +
+			   n_channels * sizeof(__le32);
+		resp_cp =3D kzalloc(resp_len, GFP_KERNEL);
+
+		if (resp_cp) {
+			resp_cp->status =3D mcc_resp_v1->status;
+			resp_cp->mcc =3D mcc_resp_v1->mcc;
+			resp_cp->cap =3D mcc_resp_v1->cap;
+			resp_cp->source_id =3D mcc_resp_v1->source_id;
+			resp_cp->n_channels =3D mcc_resp_v1->n_channels;
+			memcpy(resp_cp->channels, mcc_resp_v1->channels,
+			       n_channels * sizeof(__le32));
+		}
 	}
=20
-	resp_len =3D sizeof(struct iwl_mcc_update_resp) + n_channels *
-		sizeof(__le32);
-
-	resp_cp =3D kzalloc(resp_len, GFP_KERNEL);
 	if (!resp_cp) {
 		ret =3D -ENOMEM;
 		goto exit;
 	}
=20
-	if (resp_v2) {
-		memcpy(resp_cp, mcc_resp, resp_len);
-	} else {
-		resp_cp->status =3D mcc_resp_v1->status;
-		resp_cp->mcc =3D mcc_resp_v1->mcc;
-		resp_cp->cap =3D mcc_resp_v1->cap;
-		resp_cp->source_id =3D mcc_resp_v1->source_id;
-		resp_cp->n_channels =3D mcc_resp_v1->n_channels;
-		memcpy(resp_cp->channels, mcc_resp_v1->channels,
-		       n_channels * sizeof(__le32));
-	}
-
 	status =3D le32_to_cpu(resp_cp->status);
=20
 	mcc =3D le16_to_cpu(resp_cp->mcc);
--=20
2.7.0
