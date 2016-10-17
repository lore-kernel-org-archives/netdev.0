From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH v4] mac80211: move extra crypto data off the stack
Date: Mon, 17 Oct 2016 10:14:28 +0100
Message-ID: <CAKv+Gu-aZhCBvnEQoZUZLDPXCrvgxO1pSd=6EHz+tMB+dFz5hg@mail.gmail.com>
References: <1476693195-14071-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:36402 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933389AbcJQJO3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 05:14:29 -0400
Received: by mail-io0-f174.google.com with SMTP id j37so181583807ioo.3
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 02:14:29 -0700 (PDT)
In-Reply-To: <1476693195-14071-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17 October 2016 at 09:33, Johannes Berg <johannes@sipsolutions.net> wrote:
> From: Johannes Berg <johannes.berg@intel.com>
>
> As the stack can (on x86-64) now be virtually mapped rather than
> using "normal" kernel memory, Sergey noticed mac80211 isn't using
> the SG APIs correctly by putting on-stack buffers into SG tables.
> This leads to kernel crashes.
>
> Fix this by allocating the extra fields dynamically on the fly as
> needed, using a kmem cache.
>
> I used per-CPU memory in a previous iteration of this patch, but
> Ard Biesheuvel pointed out that was also vmalloc'ed on some
> architectures.
>
> Reported-by: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Apologies for going back and forth on this, but it appears there may
be another way to deal with this.

First of all, we only need this handling for the authenticated data,
and only for CCM and GCM, not CMAC (which does not use scatterlists at
all, it simply calls the AES cipher directly)

So that leaves a fixed 20 bytes for GCM and fixed 32 bytes for CCM,
which we could allocate along with the AEAD request, e..g.,

"""
diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
index 8e898a6e8de8..c0c33e6ad94e 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -24,13 +24,17 @@ int ieee80211_aes_ccm_encrypt(struct crypto_aead
*tfm, u8 *b_0, u8 *aad,
 {
        struct scatterlist sg[3];
        struct aead_request *aead_req;
+       u8 *__aad;

        aead_req = aead_request_alloc(tfm, GFP_ATOMIC);
        if (!aead_req)
                return -ENOMEM;

+       __aad = (u8 *)aead_req + crypto_aead_reqsize(tfm);
+       memcpy(__aad, aad, 2 * AES_BLOCK_SIZE);
+
        sg_init_table(sg, 3);
-       sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
+       sg_set_buf(&sg[0], &__aad[2], be16_to_cpup((__be16 *)__aad));
        sg_set_buf(&sg[1], data, data_len);
        sg_set_buf(&sg[2], mic, mic_len);

@@ -49,6 +53,7 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead
*tfm, u8 *b_0, u8 *aad,
 {
        struct scatterlist sg[3];
        struct aead_request *aead_req;
+       u8 *__aad;
        int err;

        if (data_len == 0)
@@ -58,8 +63,11 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead
*tfm, u8 *b_0, u8 *aad,
        if (!aead_req)
                return -ENOMEM;

+       __aad = (u8 *)aead_req + crypto_aead_reqsize(tfm);
+       memcpy(__aad, aad, 2 * AES_BLOCK_SIZE);
+
        sg_init_table(sg, 3);
-       sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
+       sg_set_buf(&sg[0], &__aad[2], be16_to_cpup((__be16 *)__aad));
        sg_set_buf(&sg[1], data, data_len);
        sg_set_buf(&sg[2], mic, mic_len);

@@ -90,6 +98,8 @@ struct crypto_aead
*ieee80211_aes_key_setup_encrypt(const u8 key[],
        if (err)
                goto free_aead;

+       crypto_aead_set_reqsize(tfm,
+                               crypto_aead_reqsize(tfm) + 2 * AES_BLOCK_SIZE));
        return tfm;

 free_aead:
"""
