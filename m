From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [net-bluetooth] question about potential null pointer
 dereference
Date: Tue, 30 May 2017 22:29:53 -0500
Message-ID: <20170530222953.Horde.lmsiZcFwJeJ7pN4QQZ_Fyk7@gator4166.hostgator.com>
References: <20170530112328.Horde.PY1jf3InPf-6SU3kH9l7mtw@gator4166.hostgator.com>
 <62DD828F-D88E-4916-BD0B-347E433ACCE6@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <62DD828F-D88E-4916-BD0B-347E433ACCE6@holtmann.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcel,

Quoting Marcel Holtmann <marcel@holtmann.org>:

> Hi Gustavo,
>
>> While looking into Coverity ID 1357456 I ran into the following  
>> piece of code at net/bluetooth/smp.c:166
>>
>> 166/* The following functions map to the LE SC SMP crypto functions
>> 167 * AES-CMAC, f4, f5, f6, g2 and h6.
>> 168 */
>> 169
>> 170static int aes_cmac(struct crypto_shash *tfm, const u8 k[16],  
>> const u8 *m,
>> 171                    size_t len, u8 mac[16])
>> 172{
>> 173        uint8_t tmp[16], mac_msb[16], msg_msb[CMAC_MSG_MAX];
>> 174        SHASH_DESC_ON_STACK(desc, tfm);
>> 175        int err;
>> 176
>> 177        if (len > CMAC_MSG_MAX)
>> 178                return -EFBIG;
>> 179
>> 180        if (!tfm) {
>> 181                BT_ERR("tfm %p", tfm);
>> 182                return -EINVAL;
>> 183        }
>> 184
>> 185        desc->tfm = tfm;
>> 186        desc->flags = 0;
>> 187
>> 188        /* Swap key and message from LSB to MSB */
>> 189        swap_buf(k, tmp, 16);
>> 190        swap_buf(m, msg_msb, len);
>> 191
>> 192        SMP_DBG("msg (len %zu) %*phN", len, (int) len, m);
>> 193        SMP_DBG("key %16phN", k);
>> 194
>> 195        err = crypto_shash_setkey(tfm, tmp, 16);
>> 196        if (err) {
>> 197                BT_ERR("cipher setkey failed: %d", err);
>> 198                return err;
>> 199        }
>> 200
>> 201        err = crypto_shash_digest(desc, msg_msb, len, mac_msb);
>> 202        shash_desc_zero(desc);
>> 203        if (err) {
>> 204                BT_ERR("Hash computation error %d", err);
>> 205                return err;
>> 206        }
>> 207
>> 208        swap_buf(mac_msb, mac, 16);
>> 209
>> 210        SMP_DBG("mac %16phN", mac);
>> 211
>> 212        return 0;
>> 213}
>>
>> The issue here is that line 180 implies that pointer tfm might be  
>> NULL. If this is the case, there is a potential NULL pointer  
>> dereference at line 174 once pointer tfm is indirectly dereferenced  
>> inside macro SHASH_DESC_ON_STACK().
>>
>> My question is if there is any chance that pointer tfm maybe be  
>> NULL when calling macro SHASH_DESC_ON_STACK()?
>
> I think the part you are after is this:
>
>         smp->tfm_cmac = crypto_alloc_shash("cmac(aes)", 0, 0);
>         if (IS_ERR(smp->tfm_cmac)) {
>                 BT_ERR("Unable to create CMAC crypto context");
>                 crypto_free_cipher(smp->tfm_aes);
>                 kzfree(smp);
>                 return NULL;
>         }
>

Yeah, this makes it all clear.

> So the tfm_cmac is part of the smp structure. However if there is no  
> cipher, we destroy the smp structure and essentially run without SMP  
> support. So it can not really be called anyway.
>

What I take from this is that as a general rule, I should first try to  
identify whether the code I'm debugging is reachable or not, depending  
on the specific structures and variables I'm interested in.

> Maybe commenting this might be a good idea.
>

Yep, it wouldn't hurt.

In the meantime I will triage and document this as a false positive.

Thank you very much for the clarification, Marcel,
I really appreciate it.
--
Gustavo A. R. Silva
