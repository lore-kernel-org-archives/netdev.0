From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/3] net:dsa:mv88e6xxx: use hashtable to store multicast entries
Date: Mon, 12 Dec 2016 15:03:12 -0500
Message-ID: <87vauo9apr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com> <87r35db35m.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <CAMr9Lbp5eCg1oyWGN+uiDEcF0VZuKUi87FH6JYTGj6pL82R+Mw@mail.gmail.com> <48ff1136-dd8f-7704-a512-c23b27989bf8@gmail.com> <20161212190915.GA8885@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Volodymyr Bendiuga <valdr.linuxnext@gmail.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        netdev@vger.kernel.org,
        Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:57160 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752165AbcLLUD1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 15:03:27 -0500
In-Reply-To: <20161212190915.GA8885@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> Humm, it looks like we are doing the atu_get wrong. We are looking for
> a specific MAC address. Yet we seem to be walking the whole table to
> find it, rather than getting the hardware to do the search. 

We are not doing it wrong, the hardware does the search. A classic dump
of an ATU database consists of starting from the broadcast address
ff:ff:ff:ff:ff:ff and issuing GetNext operation until we reach back the
broadcast address. Only addresses in used are returned by GetNext, thus
dumping an empty database is completed in a single operation.

I implemented atu_get intentionally this way because it provides simpler
code, rather than doing arithmetic on MAC addresses (Unless I am unaware
of simple increment/decrement code.)

> The current code is:
>
> static int mv88e6xxx_atu_get(struct mv88e6xxx_chip *chip, int fid,
>                              const u8 *addr, struct mv88e6xxx_atu_entry *entry)
> {
>         struct mv88e6xxx_atu_entry next;
>         int err;
>
>         eth_broadcast_addr(next.mac);
>
>         err = _mv88e6xxx_atu_mac_write(chip, next.mac);
>
> We should be setting next.mac to one less than the address we are
> looking for.
>
> Volodymyr, please could you try that, and see how much of a speed up
> you get.
>
> There is another optimization which can be made. We only say there is
> no such entry once we have reached the end of the table. But it will
> return the entries in ascending order. So if the entry it returned is
> bigger than what we are looking for, we can immediately abort the
> search and say it does not exist.

However your two suggestions to optimize the lookup are correct. It'd be
interesting to see if that makes a significant difference or not.

Thanks,

        Vivien
