From: Matthias May <matthias.may@neratec.com>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 6 Sep 2017 16:46:51 +0200
Message-ID: <edf02eb7-e6bf-e88c-f655-40f6f71a3446@neratec.com>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
 <20170906004703.GB27385@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Woojung.Huh@microchip.com, jbe@pengutronix.de,
        sean.wang@mediatek.com, john@phrozen.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:2720 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932586AbdIFOxO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 10:53:14 -0400
In-Reply-To: <20170906004703.GB27385@lunn.ch>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/17 02:47, Andrew Lunn wrote:
>> The third and last issue will be explained in a followup email.
> 
> Hi DSA hackers
> 
> So there is the third issue. It affects just DSA, but it possible
> affects all DSA drivers.
> 
> This patchset broken broadcast with the Marvell drivers. It could
> break broadcast on others drivers as well.
> 
> What i found is that the Marvell chips don't flood broadcast frames
> between bridged ports. What appears to happen is there is a fdb miss,
> so it gets forwarded to the CPU port for the host to deal with. The
> software bridge when floods it out all ports of the bridge.
> 
> But the set offload_fwd_mark patch changes this. The software bridge
> now assumes the hardware has already flooded broadcast out all ports
> of the switch as needed. So it does not do any flooding itself. As a
> result, on Marvell devices, broadcast packets don't get flooded at
> all.
> 
> The issue can be fixed. I just need to add an mdb entry for the
> broadcast address to each port of the bridge in the switch, and the
> CPU port.  But i don't know at what level to do this.
> 
> Should this be done at the DSA level, or at the driver level?  Do any
> chips do broadcast flooding in hardware already? Hence they currently
> see broadcast duplication? If i add a broadcast mdb at the DSA level,
> and the chip is already hard wired to flooding broadcast, is it going
> to double flood?
> 
> 	Andrew
> 

Hi Andrew
We are using the 88E6321.
In our setup we are using openvswitch and not a bridge, however the problem you describe seems to be the same.

We had to configure the switch to flood unknown multicast (Egress Floods = 0x3, bits 3:2, offset 0x4 in port control)
and
unset FloodBC (FloodBC = 0x0, bit 12, offset 0x5 in global 2) which defines if a broadcast should be considered as
multicast for the above config.

Regarding the looping problem:
Since OVS isn't aware of the fdb of the switch, we configure the ports representing the switch ports (in ovs) as
"protected" which prevents looping them back between (even when flooding) see [1].
I'm not sure if the bridge has a similar feature.

BR
Matthias

[1]http://openvswitch.org/support/dist-docs/ovs-vswitchd.conf.db.5.txt ctrl-f: "protected: boolean"
