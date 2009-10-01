From: Kalle Valo <kalle.valo@iki.fi>
Subject: Re: [PATCH 0/2] cfg80211: firmware and hardware version
Date: Thu, 01 Oct 2009 17:18:33 +0300
Message-ID: <87fxa3qjt2.fsf@purkki.valot.fi>
References: <20090924180048.14503.9579.stgit@tikku>
	<43e72e890909241320j592e347die8a14f8bdd962ffb@mail.gmail.com>
	<20090925044258.GA2722@tuxdriver.com>
	<da94abde0909250947k5084db85vccafe0d3e74e2ecf@mail.gmail.com>
	<43e72e890909250953r1714c79bsa679b96ca6f5797@mail.gmail.com>
	<20091001011340.GA3123@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f211.google.com ([209.85.219.211]:60224 "EHLO
	mail-ew0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932309AbZJAOSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 10:18:34 -0400
In-Reply-To: <20091001011340.GA3123@tuxdriver.com> (John W. Linville's message of "Wed\, 30 Sep 2009 21\:13\:41 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"John W. Linville" <linville@tuxdriver.com> writes:

> On Fri, Sep 25, 2009 at 09:53:35AM -0700, Luis R. Rodriguez wrote:
>
>> So for Wake-on-Wireless I ran into the same, ethtool just did not
>> offer the same wake up events needed for wireless. I could have
>> technically used ethtool and expanded it to support wireless but it
>> just seemed dirty.
>> 
>> I agree that using ethtool seems overkill compared to the patches
>> you posted.
>
> I think you either overestimate the amount of trouble for implementing
> (minimal) ethtool support or you underestimate the amount of
> functionality available through that interface.

I'm not worried about the implementation complexity, and as your
patches show it was easy. My concern is the overall design for
wireless devices. Instead of using nl80211 for everything, with some
features we would use nl80211/iw and with some ethtool. That's just
confusing and I don't like that. I would prefer that nl80211 provides
everything, it makes things so much easier.

> That, or you just don't like using something named "eth"tool for
> wireless -- but hey, let's be honest about the frames we
> send/receive to/from the kernel... :-)

I don't have a problem with the name :) But ethernet is still so much
different from 802.11 that there isn't that much to share and we in
wireless will need different features.

One example is the hw version, ethtool only provides u32 to userspace
and moves the burden of translating hw id to the user. For us a string
is much better choise because when debuggin we need to often (or
always?) know the chip version.

But this is not something I will start fighting about. If you still
think that ethtool is the way to go, I'm perfectly fine with it.

>> The ethtool interface provides functionality for viewing and modifying
> eeprom contents, dumping registers, trigger self-tests, basic driver
> info, getting and setting message reporting levels, external card
> identification (hey, _could_ be useful!), and some other bits like
> checksum offload that might(?) be useful in the future.  I understand
> regarding the WoW vs. WoL issue but probably the answer is just to
> add a new method for WoW...?

I took a look at ethtool help output from debian unstable and I think
this is the set of features we can use in wireless:

        ethtool -i|--driver DEVNAME     Show driver information
        ethtool -d|--register-dump DEVNAME      Do a register dump
                [ raw on|off ]
                [ file FILENAME ]
        ethtool -e|--eeprom-dump DEVNAME        Do a EEPROM dump
                [ raw on|off ]
                [ offset N ]
                [ length N ]
        ethtool -E|--change-eeprom DEVNAME      Change bytes in device
        EEPROM
                [ magic N ]
                [ offset N ]
                [ value N ]
        ethtool -p|--identify DEVNAME   Show visible port
        identification (e.g. blinking)
               [ TIME-IN-SECONDS ]
        ethtool -t|--test DEVNAME       Execute adapter self test
               [ online | offline ]

But here are the features which I doubt we will ever use:

        ethtool -s|--change DEVNAME     Change generic options
                [ speed %%d ]
                [ duplex half|full ]
                [ port tp|aui|bnc|mii|fibre ]
                [ autoneg on|off ]
                [ advertise %%x ]
                [ phyad %%d ]
                [ xcvr internal|external ]
                [ wol p|u|m|b|a|g|s|d... ]
                [ sopass %%x:%%x:%%x:%%x:%%x:%%x ]
                [ msglvl %%d ] 
        ethtool -a|--show-pause DEVNAME Show pause options
        ethtool -A|--pause DEVNAME      Set pause options
                [ autoneg on|off ]
                [ rx on|off ]
                [ tx on|off ]
        ethtool -c|--show-coalesce DEVNAME      Show coalesce options
        ethtool -C|--coalesce DEVNAME   Set coalesce options
                [adaptive-rx on|off]
                [adaptive-tx on|off]
                [rx-usecs N]
                [rx-frames N]
                [rx-usecs-irq N]
                [rx-frames-irq N]
                [tx-usecs N]
                [tx-frames N]
                [tx-usecs-irq N]
                [tx-frames-irq N]
                [stats-block-usecs N]
                [pkt-rate-low N]
                [rx-usecs-low N]
                [rx-frames-low N]
                [tx-usecs-low N]
                [tx-frames-low N]
                [pkt-rate-high N]
                [rx-usecs-high N]
                [rx-frames-high N]
                [tx-usecs-high N]
                [tx-frames-high N]
                [sample-interval N]
        ethtool -g|--show-ring DEVNAME  Query RX/TX ring parameters
        ethtool -G|--set-ring DEVNAME   Set RX/TX ring parameters
                [ rx N ]
                [ rx-mini N ]
                [ rx-jumbo N ]
                [ tx N ]
        ethtool -k|--show-offload DEVNAME       Get protocol offload
                information
        ethtool -K|--offload DEVNAME    Set protocol offload
                [ rx on|off ]
                [ tx on|off ]
                [ sg on|off ]
                [ tso on|off ]
                [ ufo on|off ]
                [ gso on|off ]
                [ gro on|off ]
                [ lro on|off ]
        ethtool -r|--negotiate DEVNAME  Restart N-WAY negotation
        ethtool -n|--show-nfc DEVNAME   Show Rx network flow
                classificationoptions
                [ rx-flow-hash
                tcp4|udp4|ah4|sctp4|tcp6|udp6|ah6|sctp6 ]
        ethtool -N|--config-nfc DEVNAME Configure Rx network flow
                classification options
                [ rx-flow-hash tcp4|udp4|ah4|sctp4|tcp6|udp6|ah6|sctp6
                m|v|t|s|d|f|n|r... ]

-- 
Kalle Valo
