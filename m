From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH] mac80211: port CCMP to cryptoapi's CCM driver
Date: Tue, 8 Oct 2013 22:00:41 +0200
Message-ID: <CAKv+Gu_dOUnOBnGy7rwfxLx18dTUMHYeH+5owYHEtzpfCPA3qA@mail.gmail.com>
References: <1381231915-24232-1-git-send-email-ard.biesheuvel@linaro.org>
	<1381259316.13359.17.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Patch Tracking <patches@linaro.org>, linville@tuxdriver.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:49611 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378Ab3JHUAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 16:00:43 -0400
Received: by mail-la0-f45.google.com with SMTP id eh20so7280006lab.4
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 13:00:42 -0700 (PDT)
In-Reply-To: <1381259316.13359.17.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8 October 2013 21:08, Johannes Berg <johannes@sipsolutions.net> wrote:
> I'm not too familiar with the aead API, so here's another question:
>
>> +     sg_init_one(&pt, data, data_len);
>> +     sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
>> +     sg_init_table(ct, 2);
>> +     sg_set_buf(&ct[0], cdata, data_len);
>> +     sg_set_buf(&ct[1], mic, IEEE80211_CCMP_MIC_LEN);
>
> Is it guaranteed to be allowed that the input and output are the same
> buffer? It seems we rely on that for encrypt_one(), but is it true here
> as well?
>

Yes, the crypto layer handles all of that without issue.

> (Btw - why pass in data/cdata as separate pointers into the function?)
>

That is just a leftover of the old implementation. I will remove that
in v2, that will cut down the number of function args as well.

>> @@ -343,7 +337,7 @@ static void ccmp_special_blocks(struct sk_buff *skb, u8 *pn, u8 *scratch,
>>               data_len -= IEEE80211_CCMP_MIC_LEN;
>>
>>       /* First block, b_0 */
>> -     b_0[0] = 0x59; /* flags: Adata: 1, M: 011, L: 001 */
>> +     b_0[0] = 0x1; /* set L := 1, M and Adata flags are implied */
>
> Hmm. I don't think I understand, can you explain this to me?
>

Well M is implied by the setauthsize() in init() [M := (MIC_LEN-2)/2
== 3], and the set_assoc() call in en/decrypt() indicates the presence
of assoc (A) data. Instead of setting the flags here, and clearing
them by anding with ~0x7 (as in the old implementation), this lets the
CCM layer handle that.

-- 
Ard.
