From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: dsa: fixup fail to get tag in mtk_get_tag_protocol
Date: Mon, 24 Jul 2017 09:37:12 -0700
Message-ID: <557d5c4b-118d-034f-5580-b57b06126965@gmail.com>
References: <77d2e1bb09314a27a08d02dec9ec62e217b2b9d6.1500908869.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mediatek@lists.infradead.org
To: sean.wang@mediatek.com, davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <77d2e1bb09314a27a08d02dec9ec62e217b2b9d6.1500908869.git.sean.wang@mediatek.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/24/2017 08:14 AM, sean.wang@mediatek.com wrote:
> From: Sean Wang <sean.wang@mediatek.com>
> 
> dsa_is_cpu_port() checking ds->cpu_port_mask is not available in
> ds->ops->get_tag_protocol
> 
> Since commit 14be36c2c96c ("net: dsa: Initialize all CPU and enabled
> ports masks in dsa_ds_parse()") So force returning DSA_TAG_PROTO_MTK
> inside mtk_get_tag_protocol call after that.

So a better fix could look like this then:

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 56e46090526b..c442051d5a55 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -509,21 +509,22 @@ static int dsa_cpu_parse(struct dsa_port *port,
u32 index,
                dst->cpu_dp->netdev = ethernet_dev;
        }

+       /* Initialize cpu_port_mask now for drv->setup()
+        * to have access to a correct value, just like what
+        * net/dsa/dsa.c::dsa_switch_setup_one does.
+        */
+       ds->cpu_port_mask |= BIT(index);
+
        tag_protocol = ds->ops->get_tag_protocol(ds);
        dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
        if (IS_ERR(dst->tag_ops)) {
                dev_warn(ds->dev, "No tagger for this switch\n");
+               ds->cpu_port_mask &= ~BIT(index);
                return PTR_ERR(dst->tag_ops);
        }

        dst->rcv = dst->tag_ops->rcv;

-       /* Initialize cpu_port_mask now for drv->setup()
-        * to have access to a correct value, just like what
-        * net/dsa/dsa.c::dsa_switch_setup_one does.
-        */
-       ds->cpu_port_mask |= BIT(index);
-
        return 0;
 }


> 
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
> ---
>  drivers/net/dsa/mt7530.c | 10 +---------
>  1 file changed, 1 insertion(+), 9 deletions(-)
> 
> diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
> index 1e46418..c265e7e 100644
> --- a/drivers/net/dsa/mt7530.c
> +++ b/drivers/net/dsa/mt7530.c
> @@ -892,15 +892,7 @@ mt7530_port_fdb_dump(struct dsa_switch *ds, int port,
>  static enum dsa_tag_protocol
>  mtk_get_tag_protocol(struct dsa_switch *ds)
>  {
> -	struct mt7530_priv *priv = ds->priv;
> -
> -	if (!dsa_is_cpu_port(ds, MT7530_CPU_PORT)) {
> -		dev_warn(priv->dev,
> -			 "port not matched with tagging CPU port\n");
> -		return DSA_TAG_PROTO_NONE;
> -	} else {
> -		return DSA_TAG_PROTO_MTK;
> -	}
> +	return DSA_TAG_PROTO_MTK;
>  }
>  
>  static int
> 


-- 
Florian
