From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 5/5] net: dsa: Stop accessing ds->dst->cpu_dp
 in drivers
Date: Wed, 7 Jun 2017 17:27:04 -0700
Message-ID: <a4da565e-7339-5501-205f-540941059d51@gmail.com>
References: <20170607000317.14729-1-f.fainelli@gmail.com>
 <20170607000317.14729-6-f.fainelli@gmail.com>
 <87ink8tum2.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <CAGVrzcb_ve=gOAnAo73-TqzZgWN6F3gr7Tu0BtWS8UBYQ2MciQ@mail.gmail.com>
 <87ink7oh1h.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <c8ecc6c3-2780-cf63-24f6-b546e837430e@gmail.com>
 <87wp8nv0tr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        John Crispin <john@phrozen.org>,
        David Miller <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34234 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751433AbdFHA1H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 20:27:07 -0400
Received: by mail-qt0-f196.google.com with SMTP id o21so4888737qtb.1
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 17:27:07 -0700 (PDT)
In-Reply-To: <87wp8nv0tr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2017 04:24 PM, Vivien Didelot wrote:
> Hi Florian,
> 
> Sorry to bother you again, I don't want to be annoying but I might not
> get things right still.
> 
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
>>>>> So as I said in v2, now that a driver is guaranteed that dp->cpu_dp is
>>>>> correctly assigned at setup time, isn't better (especially for future
>>>>> multi-CPU support) to provide an helper which returns the CPU port for a
>>>>> given port? i.e. dsa_get_cpu_port(struct dsa_switch *ds, int port).
>>>>>
>>>>> Or is there something blocking? I might be wrong.
>>>>
>>>> mt7530.c needs access to the CPU port at ops->setup() time which is
>>>> why this is still here.
>>>
>>> Yes, mt7530 is the only one doing this and has an hardcoded CPU port. So
>>> what I meant was, shouldn't we have this instead:
>>>
>>>     struct dsa_port *dsa_get_cpu_port(struct dsa_switch *ds, int port)
>>>     {
>>>         return ds->ports[port].cpu_dp;
>>>     }
>>
>> We don't actually have a CPU port point to itself:
>>
>> +
>> +		for (i = 0; i < ds->num_ports; i++) {
>> +			p = &ds->ports[i];
>> +			if (!dsa_port_is_valid(p) ||
>> +			    i == index) <=============
>> +				continue;
>> +
>> +			p->cpu_dp = port;
>> +		}
>>  	}
>>
>>>
>>> And:
>>>
>>> -       dn = ds->dst->cpu_dp->netdev->dev.of_node->parent;
>>> +       cpu_dp = dsa_get_cpu_port(ds, MT7530_CPU_PORT);
>>> +       dn = cpu_dp->netdev->dev.of_node->parent;
>>
>> If we are giving the port number to get its cpu_dp pointer back, that
>> seems a bit pointless.
> 
> What a driver may want is the master interface (e.g. eth0), actually
> soldered to the dedicated switch CPU port, that will be used to
> send/receive frames.>
> Also I do not think that it is a good thing that a DSA driver play much
> in dsa_port structures (they are ideally DSA core only specific data).
> They only seem to need the master interface, so what I see is:
> 
>     static inline struct net_device *dsa_get_master(struct dsa_switch *ds, int port)
>     {
>             struct dsa_port *dp = &ds->ports[port];
> 
>             if (!dsa_is_cpu_port(ds, port))
>                     dp = dp->cpu_dp;
> 
>             return dp->netdev;
>     }

The port parameter is kind of pointless, that is what I was trying to
say, see below.

> 
>> I still think the helper with fls(ds->cpu_port_mask) - 1 is better in
>> that it will return what you have configured from Device Tree/platform
>> data. MT7530 does allow the CPU port being arbitrary, and it would
>> disable MTK tags in that case.
> 
> If MT7530 allows several CPU ports, what is MT7530_CPU_PORT then?
> (Maybe Sean can give me some details here?)

MT7530_CPU_PORT = 6 and there is a define above for 7 ports, so it is
presumably the default CPU port that the switch uses. With Broadcom
switches you could have port 5, 7 or 8 as CPU ports but 8 is still the
default for most 9-ports capable switches.

> 
> Now let's think that you can have several CPU ports (as with mv88e6xxx).
> I think it is the driver responsibility to iterate over CPU capable
> ports and inspect the master devices if they need to, instead of having
> DSA core return an arbitrary one (which might be the wrong one.)

OK, then are you okay if I do this in mt7530.c instead:

diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index 1e46418a3b74..d5b63958dd85 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -907,17 +907,26 @@ static int
 mt7530_setup(struct dsa_switch *ds)
 {
        struct mt7530_priv *priv = ds->priv;
+       struct dsa_port *port;
        int ret, i;
        u32 id, val;
        struct device_node *dn;
        struct mt7530_dummy_poll p;

-       /* The parent node of cpu_dp->netdev which holds the common system
-        * controller also is the container for two GMACs nodes representing
-        * as two netdev instances.
-        */
-       dn = ds->dst->cpu_dp->netdev->dev.of_node->parent;
-       priv->ethernet = syscon_node_to_regmap(dn);
+       for (i = 0; i < ds->num_ports; i++) {
+               port = &ds->ports[i];
+               /* The parent node of cpu_dp->netdev which holds the common
+                * system controller also is the container for two GMACs
nodes
+                * representing as two netdev instances.
+                */
+               if (dsa_is_cpu_port(ds, i)) {
+                       dn = port->netdev->dev.of_node->parent;
+                       if (priv->ethernet)
+                               return -EEXIST;
+                       priv->ethernet = syscon_node_to_regmap(dn);
+               }
+       }
+
        if (IS_ERR(priv->ethernet))
                return PTR_ERR(priv->ethernet);



> 
> This is a static data (describing to which SoC interface a switch CPU
> port is wired) that should've been parsed by DSA core before setup.

Yes, sure.
-- 
Florian
