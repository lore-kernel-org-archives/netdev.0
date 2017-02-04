From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [RFC PATCH 0/2] mac80211: use crypto shash for AES cmac
Date: Sat, 4 Feb 2017 14:24:36 +0000
Message-ID: <CAKv+Gu9p_yng=_=sri8VtRpBCpvL-r1iZ=YgEqNhuQf55p1xBA@mail.gmail.com>
References: <1486149955-11825-1-git-send-email-ard.biesheuvel@linaro.org>
 <20170203214707.GA14147@jouni.qca.qualcomm.com> <CAKv+Gu9zp+vptF2mHP5MW=x_K5m7WQgMxNNSD5hn93aT_-99xA@mail.gmail.com>
 <20170204113514.GA4350@jouni.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "johannes@sipsolutions.net" <johannes@sipsolutions.net>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Malinen, Jouni" <jouni@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:35911 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750890AbdBDOYh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 09:24:37 -0500
Received: by mail-it0-f44.google.com with SMTP id c7so29700070itd.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 06:24:37 -0800 (PST)
In-Reply-To: <20170204113514.GA4350@jouni.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 February 2017 at 11:35, Malinen, Jouni <jouni@qca.qualcomm.com> wrote:
> On Fri, Feb 03, 2017 at 09:55:36PM +0000, Ard Biesheuvel wrote:
>> OK, that looks like something I could figure out how to use. But are
>> you saying the CMAC code is never called in practice?
>
> It will get called if there is a frame that were to need to use BIP.
> There are some APs that do send broadcast addressed Deauthentication and
> Disassociation frames when terminating the network and those would get
> here. In theory, someone could come up with a new Action frame use case
> as well with a group addressed Robust Action frame, but no such thing is
> defined today. Anyway, this will be needed for certification purposes
> and to block DoS with broadcast addressed Deauthentication and
> Disassociation frames even if there is not really a common use case
> using BIP frames today.
>
>> I did spot something peculiar when looking at the code: if I am
>> reading the following sequence correctly (from
>> fils_encrypt_assoc_req())
>
>> addr[0] = mgmt->sa;
> ...
>> addr[4] = capab;
>> len[4] = encr - capab;
>>
>> crypt_len = skb->data + skb->len - encr;
>> skb_put(skb, AES_BLOCK_SIZE);
>> return aes_siv_encrypt(assoc_data->fils_kek, assoc_data->fils_kek_len,
>>       encr, crypt_len, 1, addr, len, encr);
>>
>> the addr[]/len[] arrays are populated with 5 (addr, len) pairs, but
>> only one is actually passed into aes_siv_encrypt()? This is actually
>> the main reason I stopped looking into whether I could convert it to
>> CMAC, because I couldn't figure it out.
>
> Argh.. Thanks for finding this!
>
> That is indeed supposed to have num_elems == 5. This "works" since the
> other end of the exchange is actually in user space (hostapd) and a
> similar error is there..
>

Interesting.

> This comes from the development history of FILS support.. The draft
> standard changed this AES-SIV AAD design from P802.11ai/D7.0 to D8.0
> from a single AAD vector with concatenated fields to separate vectors.
> Clearly I added the vectors here in addr[] and len[] arrays, but forgot
> to update the num_elems parameter in this direction (STA->AP); the other
> direction for Association Response frame is actually using correct
> number of AAD vectors.
>
> I'll fix this in hostapd and mac80211.
>

There is another issue I spotted: the skcipher you allocate may be of
the async variant, which may return from skcipher_encrypt() with
-EINPROGRESS as soon as it has queued the request. Since you don't
deal with that result, you should allocate a sync cipher explicitly:

diff --git a/net/mac80211/fils_aead.c b/net/mac80211/fils_aead.c
index ecfdd97758a3..a31be5262283 100644
--- a/net/mac80211/fils_aead.c
+++ b/net/mac80211/fils_aead.c
@@ -124,7 +124,7 @@ static int aes_siv_encrypt(const u8 *key, size_t key_len,

        /* CTR */

-       tfm2 = crypto_alloc_skcipher("ctr(aes)", 0, 0);
+       tfm2 = crypto_alloc_skcipher("ctr(aes)", 0, CRYPTO_ALG_ASYNC);
        if (IS_ERR(tfm2)) {
                kfree(tmp);
                return PTR_ERR(tfm2);
@@ -183,7 +183,7 @@ static int aes_siv_decrypt(const u8 *key, size_t key_len,

        /* CTR */

-       tfm2 = crypto_alloc_skcipher("ctr(aes)", 0, 0);
+       tfm2 = crypto_alloc_skcipher("ctr(aes)", 0, CRYPTO_ALG_ASYNC);
        if (IS_ERR(tfm2))
                return PTR_ERR(tfm2);
        /* K2 for CTR */

> I did not actually remember that the AP side was still in hostapd for
> FILS AEAD in case of mac80211, but with that in mind, the answer to your
> earlier question about testing these becomes much simpler.. All you need
> to do is this with hostap.git hwsim tests:
>
> hostap/tests/hwsim/vm$ ./vm-run.sh ap_cipher_bip fils_sk_erp
> Starting test run in a virtual machine
> ./run-all.sh: passing the following args to run-tests.py: ap_cipher_bip fils_sk_erp
> START ap_cipher_bip 1/2
> PASS ap_cipher_bip 0.703048 2017-02-04 11:21:35.341174
> START fils_sk_erp 2/2
> PASS fils_sk_erp 0.667927 2017-02-04 11:21:36.029205
> passed all 2 test case(s)
> ALL-PASSED
>
>
> ap_cipher_bip uses wlantest to verify the BIP (AES-128-CMAC) protection
> in the frames and fils_sk_erp goes through FILS AEAD exchange with one
> side of the operation in mac80211 and the other one in hostapd. This
> should be able to discover if something is broken in the AES related
> changes in crypto.
>
> And this particular example run here was with your two patches applied,
> to the proposed net/mac80211/aes_cmac.c change seems to work fine.

Thanks for the instructions and thanks for testing. If I manage to run
this locally, I will follow up with an alternative patch #1 that
switches FILS to use cmac(aes) as well (which looks reasonably
feasible now that I understand the code)

Regards,
Ard.
