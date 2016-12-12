From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net:dsa:mv88e6xxx: use hashtable to store
 multicast entries
Date: Mon, 12 Dec 2016 20:09:15 +0100
Message-ID: <20161212190915.GA8885@lunn.ch>
References: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com>
 <87r35db35m.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <CAMr9Lbp5eCg1oyWGN+uiDEcF0VZuKUi87FH6JYTGj6pL82R+Mw@mail.gmail.com>
 <48ff1136-dd8f-7704-a512-c23b27989bf8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Volodymyr Bendiuga <valdr.linuxnext@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        netdev@vger.kernel.org,
        Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52730 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751792AbcLLTJS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 14:09:18 -0500
Content-Disposition: inline
In-Reply-To: <48ff1136-dd8f-7704-a512-c23b27989bf8@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2016 at 08:37:50AM -0800, Florian Fainelli wrote:
> On 12/12/2016 07:22 AM, Volodymyr Bendiuga wrote:
> > Hi,
> > 
> > I apologise for incorrectly formatted patch, I will fix and resend it.
> > The problem with the ATU right now is that it is too slow when inserting
> > entries.
> > When the OS boots up, it might insert some multicast entries into the
> > atu (if
> > they are preconfigured by user). I run a test with 10 mc entries being
> > configured for
> > each port (13 ports), and it took 15 seconds, which made system quite
> > slow on responding to
> > other commands, as it has been inserting mc entries. The implementation
> > with hashtable
> > made insert command for 13 ports and 10 entries per port about 700 msec
> > long.

Humm, it looks like we are doing the atu_get wrong. We are looking for
a specific MAC address. Yet we seem to be walking the whole table to
find it, rather than getting the hardware to do the search. 

The current code is:

static int mv88e6xxx_atu_get(struct mv88e6xxx_chip *chip, int fid,
                             const u8 *addr, struct mv88e6xxx_atu_entry *entry)
{
        struct mv88e6xxx_atu_entry next;
        int err;

        eth_broadcast_addr(next.mac);

        err = _mv88e6xxx_atu_mac_write(chip, next.mac);

We should be setting next.mac to one less than the address we are
looking for.

Volodymyr, please could you try that, and see how much of a speed up
you get.

There is another optimization which can be made. We only say there is
no such entry once we have reached the end of the table. But it will
return the entries in ascending order. So if the entry it returned is
bigger than what we are looking for, we can immediately abort the
search and say it does not exist.

   Andrew
