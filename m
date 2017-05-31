From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [net-bluetooth] question about potential null pointer dereference
Date: Wed, 31 May 2017 02:52:22 +0200
Message-ID: <62DD828F-D88E-4916-BD0B-347E433ACCE6@holtmann.org>
References: <20170530112328.Horde.PY1jf3InPf-6SU3kH9l7mtw@gator4166.hostgator.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Gustavo A. R. Silva" <garsilva-L1vi/lXTdts+Va1GwOuvDg@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170530112328.Horde.PY1jf3InPf-6SU3kH9l7mtw-fU+oOHjIBR1LoJgMfuPDHBfZZeVsHd8q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Gustavo,

> While looking into Coverity ID 1357456 I ran into the following piece of code at net/bluetooth/smp.c:166
> 
> 166/* The following functions map to the LE SC SMP crypto functions
> 167 * AES-CMAC, f4, f5, f6, g2 and h6.
> 168 */
> 169
> 170static int aes_cmac(struct crypto_shash *tfm, const u8 k[16], const u8 *m,
> 171                    size_t len, u8 mac[16])
> 172{
> 173        uint8_t tmp[16], mac_msb[16], msg_msb[CMAC_MSG_MAX];
> 174        SHASH_DESC_ON_STACK(desc, tfm);
> 175        int err;
> 176
> 177        if (len > CMAC_MSG_MAX)
> 178                return -EFBIG;
> 179
> 180        if (!tfm) {
> 181                BT_ERR("tfm %p", tfm);
> 182                return -EINVAL;
> 183        }
> 184
> 185        desc->tfm = tfm;
> 186        desc->flags = 0;
> 187
> 188        /* Swap key and message from LSB to MSB */
> 189        swap_buf(k, tmp, 16);
> 190        swap_buf(m, msg_msb, len);
> 191
> 192        SMP_DBG("msg (len %zu) %*phN", len, (int) len, m);
> 193        SMP_DBG("key %16phN", k);
> 194
> 195        err = crypto_shash_setkey(tfm, tmp, 16);
> 196        if (err) {
> 197                BT_ERR("cipher setkey failed: %d", err);
> 198                return err;
> 199        }
> 200
> 201        err = crypto_shash_digest(desc, msg_msb, len, mac_msb);
> 202        shash_desc_zero(desc);
> 203        if (err) {
> 204                BT_ERR("Hash computation error %d", err);
> 205                return err;
> 206        }
> 207
> 208        swap_buf(mac_msb, mac, 16);
> 209
> 210        SMP_DBG("mac %16phN", mac);
> 211
> 212        return 0;
> 213}
> 
> The issue here is that line 180 implies that pointer tfm might be NULL. If this is the case, there is a potential NULL pointer dereference at line 174 once pointer tfm is indirectly dereferenced inside macro SHASH_DESC_ON_STACK().
> 
> My question is if there is any chance that pointer tfm maybe be NULL when calling macro SHASH_DESC_ON_STACK()?

I think the part you are after is this:

        smp->tfm_cmac = crypto_alloc_shash("cmac(aes)", 0, 0);                   
        if (IS_ERR(smp->tfm_cmac)) {                                             
                BT_ERR("Unable to create CMAC crypto context");                  
                crypto_free_cipher(smp->tfm_aes);                                
                kzfree(smp);                                                     
                return NULL;                                                     
        }         

So the tfm_cmac is part of the smp structure. However if there is no cipher, we destroy the smp structure and essentially run without SMP support. So it can not really be called anyway.

Maybe commenting this might be a good idea.

Regards

Marcel
