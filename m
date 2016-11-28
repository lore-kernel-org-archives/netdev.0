From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [[PATCH net-next RFC] 2/4] net: dsa: mv88e6xxx: Monitor and Management tables
Date: Mon, 28 Nov 2016 12:42:33 -0500
Message-ID: <878ts3fqly.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1479944598-20372-1-git-send-email-andrew@lunn.ch> <1479944598-20372-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:55630 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbcK1Rmg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:42:36 -0500
In-Reply-To: <1479944598-20372-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> +/* Offset 0x1a: Monitor Control */

Thanks. We could also optionally add another line Offset 0x1A: Monitor &
MGMT Control, to mention the change on newer chips.

> +
> +int mv88e6095_monitor_ctrl(struct mv88e6xxx_chip *chip, int upstream_port)
> +{
> +	u16 reg;
> +
> +	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
> +		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
> +		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT;
> +
> +	return mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
> +}

Monitor Control is just one of these registers which control several
stuffs.

On 6185, it controls only the monitor destination port for ingress,
egress and ARP. On 6352, it controls the monitor destination port for
ingress and egress, sets the CPU destination port and the mirror port.

Hence using GLOBAL_MONITOR_CONTROL_ARP_SHIFT is bad since bits 7:4
differ in those two (CPU Dest vs. ARP Dest). Unless you tell me that
these are the same.

Please add a .set_monitor_port ops and provide a more explicit function
like mv88e6xxx_g1_set_monitor_port() which configures the ingress/egress
monitor destination port and eventually the CPU/ARP dest if the effect
is similar (otherwise a .set_cpu_port ops is needed).

> +
> +int mv88e6390_monitor_ctrl(struct mv88e6xxx_chip *chip, int upstream_port)
> +{
> +	u16 reg;
> +	int err;
> +
> +	/* Trap destination */
> +	reg = GLOBAL_MONITOR_CONTROL_UPDATE |
> +		GLOBAL_MONITOR_CONTROL_CPU_DEST |
> +		upstream_port;
> +	err = mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
> +	if (err)
> +		return err;
> +
> +	/* 01:c2:80:00:00:00:00-01:c2:80:00:00:00:07 are Management */
> +	reg = GLOBAL_MONITOR_CONTROL_UPDATE |
> +		GLOBAL_MONITOR_CONTROL_0180C280000000XLO | 0xff;
> +	err = mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
> +	if (err)
> +		return err;
> +
> +	/* 01:c2:80:00:00:00:08-01:c2:80:00:00:00:0f are Management */
> +	reg = GLOBAL_MONITOR_CONTROL_UPDATE |
> +		GLOBAL_MONITOR_CONTROL_0180C280000000XHI | 0xff;
> +	err = mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
> +	if (err)
> +		return err;
> +
> +	/* 01:c2:80:00:00:00:20-01:c2:80:00:00:00:27 are Management */
> +	reg = GLOBAL_MONITOR_CONTROL_UPDATE |
> +		GLOBAL_MONITOR_CONTROL_0180C280000002XLO | 0xff;
> +	err = mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
> +	if (err)
> +		return err;
> +
> +	/* 01:c2:80:00:00:00:28-01:c2:80:00:00:00:2f are Management */
> +	reg = GLOBAL_MONITOR_CONTROL_UPDATE |
> +		GLOBAL_MONITOR_CONTROL_0180C280000002XHI | 0xff;
> +
> +	return mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
> +}
> +

This function does more that the 6095 implementation.

First please provide a static helper to write the Monitor & MGMT Control
table. Something like:

    mv88e6xxx_g1_monitor_mgmt_write(struct mv88e6xxx_chip *chip,
                                    u8 pointer, u8 data)

Then use it to implement a mv88e6xxx_g1_set_trap_port() function.

Rsvd2CPU is a different thing. 6352 has 2 dedicated registers in Global
2 to configure the management addresses 01:c2:80:00:00:00:2x (offset
0x2) and 01:c2:80:00:00:00:0x (offset 0x3). 6185 only has register 0x3.
Then 6390 stores the Rsvd2CPU addresses in this MGMT table.

I'd expect something like new .set_rsvd2cpu{0,2}(chip, u16 x) ops and
the following implementation:

    int mv88e6xxx_g2_set_rsvd2cpu2(struct mv88e6xxx_chip *chip, u16 x);
    int mv88e6xxx_g2_set_rsvd2cpu0(struct mv88e6xxx_chip *chip, u16 x);

int global2.c, and:

    int mv88e6xxx_g1_set_rsvd2cpu2(struct mv88e6xxx_chip *chip, u16 x);
    int mv88e6xxx_g1_set_rsvd2cpu0(struct mv88e6xxx_chip *chip, u16 x);

in global1.c (which use mv88e6xxx_g1_monitor_mgmt_write()).

Later (not required now), a nice wrapper in chip.c could set a rsvd2cpu
bit for a given address, or fallback to loading it in the ATU as MGMT.

Thanks,

        Vivien
