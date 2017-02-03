From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [RFC PATCH 0/2] mac80211: use crypto shash for AES cmac
Date: Fri, 3 Feb 2017 21:55:36 +0000
Message-ID: <CAKv+Gu9zp+vptF2mHP5MW=x_K5m7WQgMxNNSD5hn93aT_-99xA@mail.gmail.com>
References: <1486149955-11825-1-git-send-email-ard.biesheuvel@linaro.org> <20170203214707.GA14147@jouni.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "johannes@sipsolutions.net" <johannes@sipsolutions.net>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Malinen, Jouni" <jouni@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:37123 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752291AbdBCVzh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:55:37 -0500
Received: by mail-it0-f47.google.com with SMTP id r185so21774492ita.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 13:55:37 -0800 (PST)
In-Reply-To: <20170203214707.GA14147@jouni.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3 February 2017 at 21:47, Malinen, Jouni <jouni@qca.qualcomm.com> wrote:
> On Fri, Feb 03, 2017 at 07:25:53PM +0000, Ard Biesheuvel wrote:
>> The mac80211 aes_cmac code reimplements the CMAC algorithm based on the
>> core AES cipher, which is rather restrictive in how platforms can satisfy
>> the dependency on this algorithm. For instance, SIMD implementations may
>> have a considerable setup time, which cannot be amortized over the entire
>> input when calling into the crypto API one block at a time. Also, it prevents
>> the use of more secure fixed time implementations, since not all AES drivers
>> expose the cipher interface.
>>
>> So switch aes_cmac to use a cmac(aes) shash. This requires a preparatory
>> patch so that we can remove the open coded implementation, which it shares
>> with the fils aead driver. That driver could receive the same treatment, in
>> which case we could replace patch #1 with one that carries it over first.
>>
>> Note that this is an RFC. I have no idea how I would go about testing this
>> code, but I am on a mission to remove as many dependencies on the generic
>> AES cipher as I can.
>
> Neither the BIP nor FILS cases have any real speed requirements taken
> into account how rarely they end up being used in practice (there is
> really no use case for BIP today and FILS is used only once per
> association). That said, there should be no issues with moving these to
> a more generic mechanism assuming one is available now (I don't think
> that was the case when I was working on BIP and I was too lazy to figure
> out how to convert it or the newer FILS implementation)..
>
> mac80211_hwsim show allow some of the testing to be done with wlantest
> confirming the results in user space (*). I think that would cover all
> of BIP (net/mac80211/aes_cmac.c), but not FILS.

OK, that looks like something I could figure out how to use. But are
you saying the CMAC code is never called in practice?

> For FILS, we do not
> currently have a convenient mechanism for running two different
> instances of kernel or even just mac80211 in the setup, so that would
> likely need testing with real WLAN hardware. I don't currently have a
> good setup for testing this (was using Backports-based solution in the
> past instead of full kernel build and Backports is a bit behind the
> current state..), but I guess I'll need to build something functional
> for this eventually.. Once that's in working condition on two devices,
> it would be straightforward to run a test (snapshot of hostap.git build
> to enable FILS functionality and go through one FILS authentication
> round)..
>
> Another alternative would be to extend wlantest to decrypt/validate FIPS
> AEAD use case based on keys exposed from hostapd or wpa_supplicant.
> There has not been sufficient use case for that so far and I have not
> bothered working on it yet.
>
>
> By the way, FILS AEAD uses SIV mode and I'm not sure it is supported in
> the current crypto code, so that would be one additional piece to take
> care of when considering net/mac80211/fils_aead.c conversion.
>

I did spot something peculiar when looking at the code: if I am
reading the following sequence correctly (from
fils_encrypt_assoc_req())

addr[0] = mgmt->sa;
len[0] = ETH_ALEN;
/* The AP's BSSID */
addr[1] = mgmt->da;
len[1] = ETH_ALEN;
/* The STA's nonce */
addr[2] = assoc_data->fils_nonces;
len[2] = FILS_NONCE_LEN;
/* The AP's nonce */
addr[3] = &assoc_data->fils_nonces[FILS_NONCE_LEN];
len[3] = FILS_NONCE_LEN;
/* The (Re)Association Request frame from the Capability Information
* field to the FILS Session element (both inclusive).
*/
addr[4] = capab;
len[4] = encr - capab;

crypt_len = skb->data + skb->len - encr;
skb_put(skb, AES_BLOCK_SIZE);
return aes_siv_encrypt(assoc_data->fils_kek, assoc_data->fils_kek_len,
      encr, crypt_len, 1, addr, len, encr);

the addr[]/len[] arrays are populated with 5 (addr, len) pairs, but
only one is actually passed into aes_siv_encrypt()? This is actually
the main reason I stopped looking into whether I could convert it to
CMAC, because I couldn't figure it out.
