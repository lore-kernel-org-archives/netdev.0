From: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Subject: Re: [PATCH net] bonding: fix 802.3ad aggregator reselection
Date: Tue, 5 Jul 2016 23:52:26 +0300
Message-ID: <CAKdSkDVKwveeuWXyP0q38oaP5fcZCas7w=5zM-S3J2ytc++K=A@mail.gmail.com>
References: <10542.1466716851@famine> <CAKdSkDVXe5jRgWU8WAvx43KvEuZvS4ak+a9qd9H4C3zy+OvkPQ@mail.gmail.com>
 <20295.1467215964@famine> <CAKdSkDXprDpOUbKqw7+sqAj8LZ2tGC17YONmX0D1oLLUnCvRYw@mail.gmail.com>
 <CAKdSkDXBhg-n=TrZ6UiVp-xSxgYmKJ3Oaa-5ei_N+kRu7Xf_5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	zhuyj <zyjzyj2000@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:32981 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868AbcGEUw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 16:52:28 -0400
Received: by mail-oi0-f49.google.com with SMTP id u201so245733605oie.0
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 13:52:28 -0700 (PDT)
In-Reply-To: <CAKdSkDXBhg-n=TrZ6UiVp-xSxgYmKJ3Oaa-5ei_N+kRu7Xf_5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-07-05 17:01 GMT+03:00 Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>:
> 2016-06-30 14:15 GMT+03:00 Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>:
>> 2016-06-29 18:59 GMT+03:00 Jay Vosburgh <jay.vosburgh@canonical.com>:
>>> Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:
>
>>>         I tried this locally, but don't see any failure (at the end, the
>>> "Switch A" agg is still active with the single port).  I am starting
>>> with just two ports in each aggregator (instead of three), so that may
>>> be relevant.
>>
>> When the connection problem occurs, /proc/net/bonding/bond0 always
>> shows the aggregator that has a link up active. Dumpcap sees at least
>> broadcast traffic on the port, but I haven't done extensive analysis
>> on that yet. All TCP connections are cut until the bond is up again
>> when more ports are enabled on the switch. ping doesn't work either
>> way.
>
> I did some further testing on this and it looks like I can get this
> working by enabling the ports in the new aggregator the same way as
> the ports in old aggregator are disabled in ad_agg_selection_logic().
>
> Normally the ports seem to get enabled from ad_mux_machine() in "case
> AD_MUX_COLLECTING_DISTRIBUTING", but something different happens there
> as the port does get enabled, but no traffic passes through. So far I
> haven't been able to figure out what happens. When the connection is
> lost, dumpcap sees traffic on the only active port in the bond, but it
> seems like nothing catches it. If I disable and re-enable the same
> port, traffic start flowing again normally.

One more thing to add here - I have tested the following
bond/bridge/vlan configurations:

1. bond0 has IP address, no bridges/vlans
2. bond0 belongs to a bridge that has the IP address, no vlans
3. bond0 belongs to a bridge that has the IP address + there are
bond0.X VLANs that belong to separate bridges

All configurations behave the same way.

It is also possible to reproduce this with two aggregators with two
links each. The steps are:

   Agg 1   Agg 2
   P1 P2   P3 P4
   X   X   X   X   OK (Agg 2 active)
   X   X   X   -   OK (Agg 1 active)
   X   -   X   -   OK (Agg 1 active)
   -   -   X   -   Fail (Agg 2 active)

The first disabled port needs to be in active aggregator so that the
aggregator is reselected and changed.

Veli-Matti


> Here's the patch I used for testing on top of 4.7.0-rc6. I haven't
> tested this with other modes or h/w setups yet.
>
>
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index ca81f46..45c06c4 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -1706,6 +1706,25 @@ static void ad_agg_selection_logic(struct
> aggregator *agg,
>                                 __disable_port(port);
>                         }
>                 }
> +
> +               /* Enable ports in the new aggregator */
> +                if (best) {
> +                       netdev_dbg(bond->dev, "Enable ports\n");
> +
> +                        for (port = best->lag_ports; port;
> +                             port = port->next_port_in_aggregator) {
> +                                netdev_dbg(bond->dev, "Agg: %d, P=%d:
> Port: %s; Enabled=%d\n",
> +                                            best->aggregator_identifier,
> +                                            best->num_of_ports,
> +                                            port->slave->dev->name,
> +                                            __port_is_enabled(port));
> +
> +                                if (!__port_is_enabled(port))
> +                                        __enable_port(port);
> +                        }
> +                }
> +
> +
>                 /* Slave array needs update. */
>                 *update_slave_arr = true;
>         }
>
> Veli-Matti
