From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 5/5] net: dsa: Stop accessing ds->dst->cpu_dp in drivers
Date: Wed, 07 Jun 2017 19:24:00 -0400
Message-ID: <87wp8nv0tr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170607000317.14729-1-f.fainelli@gmail.com> <20170607000317.14729-6-f.fainelli@gmail.com> <87ink8tum2.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <CAGVrzcb_ve=gOAnAo73-TqzZgWN6F3gr7Tu0BtWS8UBYQ2MciQ@mail.gmail.com> <87ink7oh1h.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <c8ecc6c3-2780-cf63-24f6-b546e837430e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        John Crispin <john@phrozen.org>,
        David Miller <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:33440 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751520AbdFGX0S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 19:26:18 -0400
In-Reply-To: <c8ecc6c3-2780-cf63-24f6-b546e837430e@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Sorry to bother you again, I don't want to be annoying but I might not
get things right still.

Florian Fainelli <f.fainelli@gmail.com> writes:

>>>> So as I said in v2, now that a driver is guaranteed that dp->cpu_dp is
>>>> correctly assigned at setup time, isn't better (especially for future
>>>> multi-CPU support) to provide an helper which returns the CPU port for a
>>>> given port? i.e. dsa_get_cpu_port(struct dsa_switch *ds, int port).
>>>>
>>>> Or is there something blocking? I might be wrong.
>>>
>>> mt7530.c needs access to the CPU port at ops->setup() time which is
>>> why this is still here.
>> 
>> Yes, mt7530 is the only one doing this and has an hardcoded CPU port. So
>> what I meant was, shouldn't we have this instead:
>> 
>>     struct dsa_port *dsa_get_cpu_port(struct dsa_switch *ds, int port)
>>     {
>>         return ds->ports[port].cpu_dp;
>>     }
>
> We don't actually have a CPU port point to itself:
>
> +
> +		for (i = 0; i < ds->num_ports; i++) {
> +			p = &ds->ports[i];
> +			if (!dsa_port_is_valid(p) ||
> +			    i == index) <=============
> +				continue;
> +
> +			p->cpu_dp = port;
> +		}
>  	}
>
>> 
>> And:
>> 
>> -       dn = ds->dst->cpu_dp->netdev->dev.of_node->parent;
>> +       cpu_dp = dsa_get_cpu_port(ds, MT7530_CPU_PORT);
>> +       dn = cpu_dp->netdev->dev.of_node->parent;
>
> If we are giving the port number to get its cpu_dp pointer back, that
> seems a bit pointless.

What a driver may want is the master interface (e.g. eth0), actually
soldered to the dedicated switch CPU port, that will be used to
send/receive frames.

Also I do not think that it is a good thing that a DSA driver play much
in dsa_port structures (they are ideally DSA core only specific data).
They only seem to need the master interface, so what I see is:

    static inline struct net_device *dsa_get_master(struct dsa_switch *ds, int port)
    {
            struct dsa_port *dp = &ds->ports[port];

            if (!dsa_is_cpu_port(ds, port))
                    dp = dp->cpu_dp;

            return dp->netdev;
    }

> I still think the helper with fls(ds->cpu_port_mask) - 1 is better in
> that it will return what you have configured from Device Tree/platform
> data. MT7530 does allow the CPU port being arbitrary, and it would
> disable MTK tags in that case.

If MT7530 allows several CPU ports, what is MT7530_CPU_PORT then?
(Maybe Sean can give me some details here?)

Now let's think that you can have several CPU ports (as with mv88e6xxx).
I think it is the driver responsibility to iterate over CPU capable
ports and inspect the master devices if they need to, instead of having
DSA core return an arbitrary one (which might be the wrong one.)

This is a static data (describing to which SoC interface a switch CPU
port is wired) that should've been parsed by DSA core before setup.

Thanks,

        Vivien
