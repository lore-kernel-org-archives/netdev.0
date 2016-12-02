From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv2 net-next 2/4] net: dsa: mv88e6xxx: Monitor and Management tables
Date: Fri, 02 Dec 2016 16:53:43 -0500
Message-ID: <87oa0u0zh4.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1480701779-30633-1-git-send-email-andrew@lunn.ch> <1480701779-30633-3-git-send-email-andrew@lunn.ch> <87mvgecejs.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me> <20161202205656.GD30716@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:35806 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754032AbcLBVzA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 16:55:00 -0500
In-Reply-To: <20161202205656.GD30716@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Fri, Dec 02, 2016 at 02:32:39PM -0500, Vivien Didelot wrote:
>> Hi Andrew,
>> 
>> Andrew Lunn <andrew@lunn.ch> writes:
>> 
>> > @@ -3184,6 +3186,8 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
>> >  	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
>> >  	.stats_get_strings = mv88e6095_stats_get_strings,
>> >  	.stats_get_stats = mv88e6095_stats_get_stats,
>> > +	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
>> > +	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
>> >  };
>> 
>> I like the implementation in this version better. But please explain me
>> why you are prefixing these operations with g1_?
>
> The prefix gives some basic grouping. port_ indicates it operates on a
> port, and is likely to be found in port.c. stats_ indicates it
> operates on statistics, ppu that is operates on the phy polling unit.

Yes, port_* operations operate on ports. But the port.c file is there to
implement the function of "Port Registers". "Port" can be confusing, but
it refers to the SMI internal device at address 0xsomething.

"port_", "ppu_", "stats_", in the mv88e6xxx_ops structure just give
implicit namespaces for the **features**, not their location!

> We are going to have some things which don't fall into a simple
> category, like these two. But it would however be nice to group them,
> so i picked which register bank they are in. These operations are
> always in g1. It is a useful hint as to where to find the different
> variants.

Absolutely not!

    .set_egress_port = mv88e6095_g1_set_egress_port,

                                 ^
                                 That is the useful hint!

At the higher level of chip.c, we don't care about where is implemented
the switch MAC setter. We just have to call the correctly defined
.set_switch_mac routine.

However if you do care to know, its _ops.set_switch_mac pointer will
tell you (_g1 vs _g2 prefix).

>> But let's imagine we can set the CPU port in some Global 2 registers.
>> You are going to wrap this in chip.c with something like:
>> 
>>     int mv88e6xxx_set_cpu_port(struct mv88e6xxx_chip *chip, int port)
>>     {
>>         if (chip->info->ops->g2_set_cpu_port)
>>             return chip->info->ops->g2_set_cpu_port(chip, port);
>>         else if (chip->info->ops->g1_set_cpu_port)
>>             return chip->info->ops->g1_set_cpu_port(chip, port);
>>         else
>>             return -EOPNOTSUPP;
>>     }
>
> I answered in one of my other emails. Frames with reserved MAC
> addresses can be forwarded to the CPU. For most devices, this is a g2
> operation. However, for 6390, it is a g1. In that case, my code does
> not use a prefix. Not having a prefix, when all the others do, also
> gives you information. It means the ops are spread around and you need
> to make a bigger effort to go find them.

Again, absolutely not. This is your interpretation of having a prefix or
not. A chip has only one way to access a feature, not two. Since you
seem to be focused on the Rsvd2CPU feature, here's an example with it:

What's the point of writing this:

    /* Consider the given MAC as MGMT */
    int mv88e6xxx_reserve_mac(struct mv88e6xxx_chip *chip, u8 *addr)
    {
            if (mac_is_0x(addr)) {
                    if (chip->info->ops->g1_set_rsvd2cpu0)
                            return chip->info->ops->g1_set_rsvd2cpu0(...);
                    else if (chip->info->ops->g2_set_rsvd2cpu0)
                            return chip->info->ops->g2_set_rsvd2cpu0(...);
            } else if (mac_is_2x(addr)) {
                    if (chip->info->ops->g1_set_rsvd2cpu2)
                            return chip->info->ops->g1_set_rsvd2cpu2(...);
                    else if (chip->info->ops->g2_set_rsvd2cpu2)
                            return chip->info->ops->g2_set_rsvd2cpu2(...);
            }

            return mv88e6xxx_atu_load(chip, addr, MGMT);
    }

Compared to this:

    /* Consider the given MAC as MGMT */
    int mv88e6xxx_reserve_mac(struct mv88e6xxx_chip *chip, u8 *addr)
    {
            if (mac_is_0x(addr)) {
                    if (chip->info->ops->set_rsvd2cpu0)
                            return chip->info->ops->set_rsvd2cpu0(...);
            } else if (mac_is_2x(addr)) {
                    if (chip->info->ops->set_rsvd2cpu2)
                            return chip->info->ops->set_rsvd2cpu2(...);
            }

            return mv88e6xxx_atu_load(chip, addr, MGMT);
    }

Your higher level API (chip.c) doesn't need to know where is implemented
a given feature. It just needs to know if it supports it or not.

Thanks,

        Vivien
