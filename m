From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hv_netvsc: Use simple parser for IPv4 and v6
 headers
Date: Wed, 16 Dec 2015 19:20:44 +0000
Message-ID: <BN1PR0301MB0770A1CB185D1AB82D5F9E44CAEF0@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <1450289022-9958-1-git-send-email-haiyangz@microsoft.com>
 <1450285688.8474.86.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1450285688.8474.86.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> Sent: Wednesday, December 16, 2015 12:08 PM
> 
> This looks very very wrong to me.
> 
> How many times this is called per second, for the 'one flow' case ?
> 
> Don't you use TSO in this driver ?
> 
> What about encapsulation ?
> 
> I suspect you have a quite different issue here.
> 
> You simply could use skb_get_hash() since local TCP flows will provide a
> l4 skb->hash and you have no further flow dissection to do.

In our test, we have bisected and found the following patch introduced big 
overhead into skb_flow_dissect_flow_keys(), and caused performance 
regression:
commit: d34af823
net: Add VLAN ID to flow_keys

This patch didn't add too many instructions, but we think the change to 
the size of struct flow_keys may cause different cache missing rate...

To avoid affecting other drivers using this function, our patch limits the 
change inside our driver to fix this performance regression.

Regarding your suggestion on skb_get_hash(), I looked at the code and ran 
some tests, and found the skb->l4_hash and skb->sw_hash bits are not set, 
so it calls __skb_get_hash() which eventually calls 
skb_flow_dissect_flow_keys(). So it still includes the performance 
overhead mentioned above.

static inline __u32 skb_get_hash(struct sk_buff *skb)
{
        if (!skb->l4_hash && !skb->sw_hash)
                __skb_get_hash(skb);

        return skb->hash;
}


void __skb_get_hash(struct sk_buff *skb)
{
        struct flow_keys keys;

        __flow_hash_secret_init();

        __skb_set_sw_hash(skb, ___skb_get_hash(skb, &keys, hashrnd),
                          flow_keys_have_l4(&keys));
}


static inline u32 ___skb_get_hash(const struct sk_buff *skb,
                                  struct flow_keys *keys, u32 keyval)
{
        skb_flow_dissect_flow_keys(skb, keys,
                                   FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL);

        return __flow_hash_from_keys(keys, keyval);
}


Thanks,
- Haiyang
