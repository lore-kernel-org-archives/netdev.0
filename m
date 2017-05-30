From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [net-wireless-orinoco] question about potential null pointer
 dereference
Date: Tue, 30 May 2017 12:00:32 -0500
Message-ID: <20170530120032.Horde.GHW0X8-B795CdxPjQOfDPa9@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello everybody,

While looking into Coverity ID 1357460 I ran into the following piece  
of code at drivers/net/wireless/intersil/orinoco/mic.c:48

48int orinoco_mic(struct crypto_shash *tfm_michael, u8 *key,
49                u8 *da, u8 *sa, u8 priority,
50                u8 *data, size_t data_len, u8 *mic)
51{
52        SHASH_DESC_ON_STACK(desc, tfm_michael);
53        u8 hdr[ETH_HLEN + 2]; /* size of header + padding */
54        int err;
55
56        if (tfm_michael == NULL) {
57                printk(KERN_WARNING "orinoco_mic: tfm_michael == NULL\n");
58                return -1;
59        }
60
61        /* Copy header into buffer. We need the padding on the end zeroed */
62        memcpy(&hdr[0], da, ETH_ALEN);
63        memcpy(&hdr[ETH_ALEN], sa, ETH_ALEN);
64        hdr[ETH_ALEN * 2] = priority;
65        hdr[ETH_ALEN * 2 + 1] = 0;
66        hdr[ETH_ALEN * 2 + 2] = 0;
67        hdr[ETH_ALEN * 2 + 3] = 0;
68
69        desc->tfm = tfm_michael;
70        desc->flags = 0;
71
72        err = crypto_shash_setkey(tfm_michael, key, MIC_KEYLEN);
73        if (err)
74                return err;
75
76        err = crypto_shash_init(desc);
77        if (err)
78                return err;
79
80        err = crypto_shash_update(desc, hdr, sizeof(hdr));
81        if (err)
82                return err;
83
84        err = crypto_shash_update(desc, data, data_len);
85        if (err)
86                return err;
87
88        err = crypto_shash_final(desc, mic);
89        shash_desc_zero(desc);
90
91        return err;
92}

The issue here is that line 56 implies that pointer tfm_michael might  
be NULL. If this is the case, there is a potential NULL pointer  
dereference at line 52 once pointer tfm_michael is indirectly  
dereferenced inside macro SHASH_DESC_ON_STACK().

My question is if there is any chance that pointer tfm_michael might  
be NULL when calling macro SHASH_DESC_ON_STACK() ?

I'm trying to figure out if this is a false positive or something that  
needs to be fixed somehow.

I'd really appreciate any comment on this.

Thank you!
--
Gustavo A. R. Silva
