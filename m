From: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v3 1/2] mac80211: fils_aead: Use crypto api CMAC shash
 rather than bare cipher
Date: Wed, 8 Feb 2017 07:45:51 +0000
Message-ID: <CAKv+Gu9Be-bA-Trn5cMwVvf4+yMm8w2Krm59WGAhdM3bxBSJfw@mail.gmail.com>
References: <1486378168-31028-1-git-send-email-ard.biesheuvel@linaro.org>
 <1486378168-31028-2-git-send-email-ard.biesheuvel@linaro.org> <1486537227.4603.2.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Jouni Malinen <jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1486537227.4603.2.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 8 February 2017 at 07:00, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> This looks strange to me:
>
>> +static int aes_s2v(struct crypto_shash *tfm,
>>                  size_t num_elem, const u8 *addr[], size_t len[],
>> u8 *v)
>>  {
>> -     u8 d[AES_BLOCK_SIZE], tmp[AES_BLOCK_SIZE];
>> +     u8 d[AES_BLOCK_SIZE], tmp[AES_BLOCK_SIZE] = {};
>> +     SHASH_DESC_ON_STACK(desc, tfm);
>
> desc declared
>
>>
>> +     crypto_shash_digest(desc, tmp, AES_BLOCK_SIZE, d);
>
> used here
>

Each digest() call combines a init()/update()/final() sequence

>> +     crypto_shash_init(desc);
>
> but initialized now?
>

... for the 6th time, or so. The final vector may require two
update()s, so we cannot use digest() here. But we can use finup() for
the last one, which combines update() and final().

Hence,

init()/finup()

or

init()/update()/finup()

depending on the length of the last vector.
