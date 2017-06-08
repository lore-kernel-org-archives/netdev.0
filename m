From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 5/5] net: dsa: Stop accessing ds->dst->cpu_dp in drivers
Date: Wed, 07 Jun 2017 21:03:26 -0400
Message-ID: <87bmpz8f4x.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170607000317.14729-1-f.fainelli@gmail.com> <20170607000317.14729-6-f.fainelli@gmail.com> <87ink8tum2.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <CAGVrzcb_ve=gOAnAo73-TqzZgWN6F3gr7Tu0BtWS8UBYQ2MciQ@mail.gmail.com> <87ink7oh1h.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <c8ecc6c3-2780-cf63-24f6-b546e837430e@gmail.com> <87wp8nv0tr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <a4da565e-7339-5501-205f-540941059d51@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        John Crispin <john@phrozen.org>,
        David Miller <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36162 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751203AbdFHBFl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 21:05:41 -0400
In-Reply-To: <a4da565e-7339-5501-205f-540941059d51@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

>> Also I do not think that it is a good thing that a DSA driver play much
>> in dsa_port structures (they are ideally DSA core only specific data).
>> They only seem to need the master interface, so what I see is:
>> 
>>     static inline struct net_device *dsa_get_master(struct dsa_switch *ds, int port)
>>     {
>>             struct dsa_port *dp = &ds->ports[port];
>> 
>>             if (!dsa_is_cpu_port(ds, port))
>>                     dp = dp->cpu_dp;
>> 
>>             return dp->netdev;
>>     }
>
> The port parameter is kind of pointless, that is what I was trying to
> say, see below.
>
> MT7530_CPU_PORT = 6 and there is a define above for 7 ports, so it is
> presumably the default CPU port that the switch uses. With Broadcom
> switches you could have port 5, 7 or 8 as CPU ports but 8 is still the
> default for most 9-ports capable switches.
>
>> Now let's think that you can have several CPU ports (as with mv88e6xxx).
>> I think it is the driver responsibility to iterate over CPU capable
>> ports and inspect the master devices if they need to, instead of having
>> DSA core return an arbitrary one (which might be the wrong one.)
>
> OK, then are you okay if I do this in mt7530.c instead:
>
> diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
> index 1e46418a3b74..d5b63958dd85 100644
> --- a/drivers/net/dsa/mt7530.c
> +++ b/drivers/net/dsa/mt7530.c
> @@ -907,17 +907,26 @@ static int
>  mt7530_setup(struct dsa_switch *ds)
>  {
>         struct mt7530_priv *priv = ds->priv;
> +       struct dsa_port *port;
>         int ret, i;
>         u32 id, val;
>         struct device_node *dn;
>         struct mt7530_dummy_poll p;
>
> -       /* The parent node of cpu_dp->netdev which holds the common system
> -        * controller also is the container for two GMACs nodes representing
> -        * as two netdev instances.
> -        */
> -       dn = ds->dst->cpu_dp->netdev->dev.of_node->parent;
> -       priv->ethernet = syscon_node_to_regmap(dn);
> +       for (i = 0; i < ds->num_ports; i++) {
> +               port = &ds->ports[i];
> +               /* The parent node of cpu_dp->netdev which holds the common
> +                * system controller also is the container for two GMACs
> nodes
> +                * representing as two netdev instances.
> +                */
> +               if (dsa_is_cpu_port(ds, i)) {
> +                       dn = port->netdev->dev.of_node->parent;
> +                       if (priv->ethernet)
> +                               return -EEXIST;
> +                       priv->ethernet = syscon_node_to_regmap(dn);
> +               }
> +       }
> +
>         if (IS_ERR(priv->ethernet))
>                 return PTR_ERR(priv->ethernet);

I think it is the correct way to do this.

This was the reason why I suggested a dsa_get_master() alternative, even
though it is not necessary per-se, it was just to reduce boilerplate and
avoid exposing too much the dsa_port structures.

dsa_ds_get_cpu_dp() doesn't make much sense anymore, right? If there are
2 CPU ports in use, it is better that the driver iterates on them itself
as you did, instead of having DSA return the first one it knows about.

Thanks,

        Vivien
