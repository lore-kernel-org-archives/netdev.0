From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 5/5] net: dsa: Stop accessing ds->dst->cpu_dp
 in drivers
Date: Wed, 7 Jun 2017 12:21:51 -0700
Message-ID: <c8ecc6c3-2780-cf63-24f6-b546e837430e@gmail.com>
References: <20170607000317.14729-1-f.fainelli@gmail.com>
 <20170607000317.14729-6-f.fainelli@gmail.com>
 <87ink8tum2.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <CAGVrzcb_ve=gOAnAo73-TqzZgWN6F3gr7Tu0BtWS8UBYQ2MciQ@mail.gmail.com>
 <87ink7oh1h.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        John Crispin <john@phrozen.org>,
        David Miller <davem@davemloft.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36224 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751945AbdFGTWD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 15:22:03 -0400
Received: by mail-wm0-f68.google.com with SMTP id k15so4000517wmh.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 12:22:03 -0700 (PDT)
In-Reply-To: <87ink7oh1h.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2017 10:15 AM, Vivien Didelot wrote:
> Hi Florian,
> 
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
>>> So as I said in v2, now that a driver is guaranteed that dp->cpu_dp is
>>> correctly assigned at setup time, isn't better (especially for future
>>> multi-CPU support) to provide an helper which returns the CPU port for a
>>> given port? i.e. dsa_get_cpu_port(struct dsa_switch *ds, int port).
>>>
>>> Or is there something blocking? I might be wrong.
>>
>> mt7530.c needs access to the CPU port at ops->setup() time which is
>> why this is still here.
> 
> Yes, mt7530 is the only one doing this and has an hardcoded CPU port. So
> what I meant was, shouldn't we have this instead:
> 
>     struct dsa_port *dsa_get_cpu_port(struct dsa_switch *ds, int port)
>     {
>         return ds->ports[port].cpu_dp;
>     }

We don't actually have a CPU port point to itself:

+
+		for (i = 0; i < ds->num_ports; i++) {
+			p = &ds->ports[i];
+			if (!dsa_port_is_valid(p) ||
+			    i == index) <=============
+				continue;
+
+			p->cpu_dp = port;
+		}
 	}

> 
> And:
> 
> -       dn = ds->dst->cpu_dp->netdev->dev.of_node->parent;
> +       cpu_dp = dsa_get_cpu_port(ds, MT7530_CPU_PORT);
> +       dn = cpu_dp->netdev->dev.of_node->parent;

If we are giving the port number to get its cpu_dp pointer back, that
seems a bit pointless.

I still think the helper with fls(ds->cpu_port_mask) - 1 is better in
that it will return what you have configured from Device Tree/platform
data. MT7530 does allow the CPU port being arbitrary, and it would
disable MTK tags in that case.

Thanks!
-- 
Florian
