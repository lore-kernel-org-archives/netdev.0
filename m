From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v1 net-next 1/5] net: dsa: mv88e6xxx: Reserved Management frames to CPU
Date: Sun, 04 Dec 2016 15:03:33 -0500
Message-ID: <87y3zvcvhm.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1480736720-12608-1-git-send-email-andrew@lunn.ch> <1480736720-12608-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37066 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbcLDUFI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 15:05:08 -0500
In-Reply-To: <1480736720-12608-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> +	/* Some generations have the configuration of sending reserved
> +	 * management frames to the CPU in global2, others in
> +	 * global1. Hence it does not fit the two setup functions
> +	 * above.
> +	 */
> +	if (chip->info->ops->mgmt_rsvd2cpu) {
> +		err = chip->info->ops->mgmt_rsvd2cpu(chip);
> +		if (err)
> +			goto unlock;
> +	}

Correct. The old mv88e6xxx_g*_setup() are bad. Ideally we'll get rid of
them once we have the complete set of features implemented in the API.

> +/* Offset 0x02: Management Enable 2x */
> +/* Offset 0x03: Management Enable 0x */
> +
> +int mv88e6095_g2_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip)
> +{
> +	int err;
> +
> +	/* Consider the frames with reserved multicast destination
> +	 * addresses matching 01:80:c2:00:00:2x as MGMT.
> +	 */
> +	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_2X)) {

Please don't just move the old code. You shouldn't need flags anymore.

> +		err = mv88e6xxx_g2_write(chip, GLOBAL2_MGMT_EN_2X, 0xffff);
> +		if (err)
> +			return err;
> +	}
> +
> +	/* Consider the frames with reserved multicast destination
> +	 * addresses matching 01:80:c2:00:00:0x as MGMT.
> +	 */
> +	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_MGMT_EN_0X))
> +		return mv88e6xxx_g2_write(chip, GLOBAL2_MGMT_EN_0X, 0xffff);
> +
> +	return 0;
> +}

[...]

>  	int (*g1_set_cpu_port)(struct mv88e6xxx_chip *chip, int port);
>  	int (*g1_set_egress_port)(struct mv88e6xxx_chip *chip, int port);
> +
> +	/* Can be either in g1 or g2, so don't use a prefix */

We have to discuss this and find an agreement.

The mv88e6xxx_ops actually implements the *features*. They can be
prefixed for clarity (e.g. .ppu_*, port_*, .atu_*, etc.). They don't
describe the register layout.

But we can discuss two ways of seeing this structure implementation:

1) Either we describe the exact register layout, and provide
.g1_mgmt_rsv2cpu and .g2_mgmt_rsvd2cpu. One or the other being NULL.

This will have the impact of expliciting the features location. One can
say it'll ease adding support for new chips, but that's not true when
the feature at the same location is implemented differently (e.g. port's
speed, switch reset). This will make the structure unnecessarily big as
well as cluttering the wrapping code.

2) We describe the feature. No *location* prefix.

To explain this point, please understand what Marvell does with their
chips, using the example of Rsvd2CPU feature and (old-to-new) models:

  - 6060 doesn't have the feature
  - 6185 introduced one G2 register for 0x MAC addresses
  - 6352 added a second G2 register for 2x MAC addresses
  - 6390 packed the feature in a single-register indirect table in G1

That's all. They are just relocating features to free a few registers.

So .g1_set_cpu_port, .g1_reset, or whatever location-prefixed operation
does not make sense, unless you want to describe the register layout.
But we should not mix 1) and 2).

Thanks,

        Vivien
