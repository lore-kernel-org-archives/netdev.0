From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [net-bluetooth] question about potential null pointer dereference
Date: Tue, 30 May 2017 11:23:28 -0500
Message-ID: <20170530112328.Horde.PY1jf3InPf-6SU3kH9l7mtw@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway21.websitewelcome.com ([192.185.45.36]:31627 "EHLO
        gateway21.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750930AbdE3QXc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 12:23:32 -0400
Received: from cm2.websitewelcome.com (cm2.websitewelcome.com [192.185.178.13])
        by gateway21.websitewelcome.com (Postfix) with ESMTP id 9814F400CE337
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 11:23:29 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everybody,

While looking into Coverity ID 1357456 I ran into the following piece  
of code at net/bluetooth/smp.c:166

166/* The following functions map to the LE SC SMP crypto functions
167 * AES-CMAC, f4, f5, f6, g2 and h6.
168 */
169
170static int aes_cmac(struct crypto_shash *tfm, const u8 k[16], const u8 *m,
171                    size_t len, u8 mac[16])
172{
173        uint8_t tmp[16], mac_msb[16], msg_msb[CMAC_MSG_MAX];
174        SHASH_DESC_ON_STACK(desc, tfm);
175        int err;
176
177        if (len > CMAC_MSG_MAX)
178                return -EFBIG;
179
180        if (!tfm) {
181                BT_ERR("tfm %p", tfm);
182                return -EINVAL;
183        }
184
185        desc->tfm = tfm;
186        desc->flags = 0;
187
188        /* Swap key and message from LSB to MSB */
189        swap_buf(k, tmp, 16);
190        swap_buf(m, msg_msb, len);
191
192        SMP_DBG("msg (len %zu) %*phN", len, (int) len, m);
193        SMP_DBG("key %16phN", k);
194
195        err = crypto_shash_setkey(tfm, tmp, 16);
196        if (err) {
197                BT_ERR("cipher setkey failed: %d", err);
198                return err;
199        }
200
201        err = crypto_shash_digest(desc, msg_msb, len, mac_msb);
202        shash_desc_zero(desc);
203        if (err) {
204                BT_ERR("Hash computation error %d", err);
205                return err;
206        }
207
208        swap_buf(mac_msb, mac, 16);
209
210        SMP_DBG("mac %16phN", mac);
211
212        return 0;
213}

The issue here is that line 180 implies that pointer tfm might be  
NULL. If this is the case, there is a potential NULL pointer  
dereference at line 174 once pointer tfm is indirectly dereferenced  
inside macro SHASH_DESC_ON_STACK().

My question is if there is any chance that pointer tfm maybe be NULL  
when calling macro SHASH_DESC_ON_STACK()?

I'm trying to figure out if this is a false positive or something that  
needs to be fixed somehow.

I'd really appreciate any comment on this.

Thank you!
