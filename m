From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv2 net-next 4/4] net: dsa: mv88e6xxx: Refactor CPU and DSA port setup
Date: Fri, 02 Dec 2016 17:03:30 -0500
Message-ID: <877f7i56q5.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1480701779-30633-1-git-send-email-andrew@lunn.ch> <1480701779-30633-5-git-send-email-andrew@lunn.ch> <87h96mcadj.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me> <20161202211806.GF30716@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36948 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750949AbcLBWE1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 17:04:27 -0500
In-Reply-To: <20161202211806.GF30716@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> The port's EgressMode, FrameMode and EtherType are really tied together
>> to compose the mode of the port.
>
> Setting the EtherType is somewhat separate. It is only needed on ports
> using EDSA. And that can only happen on a CPU port. Humm, actually, i
> set it when i should not. But putting this in a wrapper actually hides
> this.

Wrong. The datasheet says:

    > This Ether Type is used for many features depending upon the mode
    > of the port (as defined by the port’s EgressMode and FrameMode
    > bits – in Port Control, port offset 0x04).

It says that in Normal Network mode, this register can be used to trap,
mirror, etc. Also used in Provider and EDSA modes.

That is why it would be better to wrap them together to ensure correct
values when configuring a port's mode.

>
>> Could you add an helper in chip.c like:
>> 
>>     static int mv88e6xxx_set_port_mode(struct mv88e6xxx_chip *chip, int port,
>>                                        enum mv88e6xxx_frame_mode frame_mode,
>>                                        u16 egress_mode, bool egress_unknown,
>>                                        u16 ethertype)
>>     {
>>         int err;
>> 
>>         if (chip->info->ops->port_set_frame_mode) {
>>             err = chip->info->ops->port_set_frame_mode(chip, port, frame_mode);
>>             if (err)
>>                 return err;
>>         }
>
> Ignoring that it is not implemented here is wrong. It must be
> implemented, or the device is not going to work. It is a question of,
> do we want an oops, or return an error code.

Since that is done at setup time, returning an error is enough IMO to
inform the DSA layer that something went wrong.

Thanks,

        Vivien
