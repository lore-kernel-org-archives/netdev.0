From: Dustin Byford <dustin@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/3] net: ethtool: add support for forward error
 correction modes
Date: Tue, 27 Jun 2017 22:46:10 -0700
Message-ID: <20170628054610.rirfrvzdwwmh3isg@cumulusnetworks.com>
References: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
 <1498331985-8525-2-git-send-email-roopa@cumulusnetworks.com>
 <11d024ad-6e09-e475-a448-e79b6eef5654@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net,
        linville@tuxdriver.com, netdev@vger.kernel.org,
        vidya.chowdary@gmail.com, olson@cumulusnetworks.com,
        leedom@chelsio.com, manojmalviya@chelsio.com, santosh@chelsio.com,
        yuval.mintz@qlogic.com, odedw@mellanox.com, ariela@mellanox.com,
        jeffrey.t.kirsher@intel.com
To: Gal Pressman <galp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34606 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750934AbdF1FqO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 01:46:14 -0400
Received: by mail-pf0-f181.google.com with SMTP id s66so27719684pfs.1
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 22:46:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <11d024ad-6e09-e475-a448-e79b6eef5654@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gal,

On Sun Jun 25 16:38, Gal Pressman wrote:
> 
> > ...
> >
> > SHOW FEC option:
> > root@tor: ethtool --show-fec  swp1
> > FEC parameters for swp1:
> > Active FEC encodings: RS
> > Configured FEC encodings:  RS | BaseR
> >
> > ETHTOOL DEVNAME output modification:
> >
> > ethtool devname output:
> > root@tor:~# ethtool swp1
> > Settings for swp1:
> > root@hpe-7712-03:~# ethtool swp18
> > Settings for swp18:
> >     Supported ports: [ FIBRE ]
> >     Supported link modes:   40000baseCR4/Full
> >                             40000baseSR4/Full
> >                             40000baseLR4/Full
> >                             100000baseSR4/Full
> >                             100000baseCR4/Full
> >                             100000baseLR4_ER4/Full
> >     Supported pause frame use: No
> >     Supports auto-negotiation: Yes
> >     Supported FEC modes: [RS | BaseR | None | Not reported]
> >     Advertised link modes:  Not reported
> >     Advertised pause frame use: No
> >     Advertised auto-negotiation: No
> >     Advertised FEC modes: [RS | BaseR | None | Not reported]
> > <<<< One or more FEC modes
> >     Speed: 100000Mb/s
> >     Duplex: Full
> >     Port: FIBRE
> >     PHYAD: 106
> >     Transceiver: internal
> >     Auto-negotiation: off
> >     Link detected: yes

> What is the difference between the information in ethtool DEVNAME and ethtool --show-fec DEVNAME?

I think there are two questions there.  First, how does the FEC-related
information from glinksettings differ from what's retrieved via
gfecparam.  Second, how is that expressed through the ethtool UI.

Regarding the uapi (as we imagined it), glinksettings returns FEC
information through three fields:

@supported: the complete set of FEC modes the hardware supports, at any
speed, medium, or autoneg combination.

@advertising: the set of modes advertised to the link partner through
the relevant autoneg mechanism.

@lp_advertising: the set of modes the link partner is advertising
through autoneg.


gfecparam is used to fetch a couple more important facts about the FEC
configuration:

1) What FEC mode is currently active, either as a result of the autoneg
process, or a previous call to sfecparam.  This is returned in
sfecparam->active_fec

2) If autoneg is off, what is the currently configured FEC mode.  This
is a bitmask returned in gfecparam->fec.  I imagine it's typically a
single mode, but a mask makes it easier to implement a "don't care" policy,
or otherwise allow the NIC/driver to pick between a set of modes.


Regarding the UI.  ethtool DEVNAME gets most of its info from
glinksettings and it's easy to represent the FEC parameters affected by
autoneg there.  ethtool --show-fec simply reports the output of
gfecparam.  I agree the difference is subtle, perhaps it makes sense to
combine all the FEC information into ethtool DEVNAME?

> I can't find a usage of LINK_MODE_FEC_* bits in downstream patches.

I'm not sure what patches you're looking at, but I think those bits
directly affect the "Advertised FEC modes" and "Supported FEC Modes"
fields.


		--Dustin
