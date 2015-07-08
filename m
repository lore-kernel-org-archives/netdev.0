From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 0/3] net: dsa: mv88e6xxx: add support for VLAN Table
 Unit
Date: Wed, 8 Jul 2015 16:38:05 +0200
Message-ID: <20150708143805.GA32208@lunn.ch>
References: <1436303900-24259-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436303900-24259-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 07, 2015 at 05:18:17PM -0400, Vivien Didelot wrote:
> Hi all,
> 
> This patchset brings full support for hardware VLANs in DSA, and the Marvell
> 88E6xxx compatible switch chips.

Hi Vivien

I would like to do a proper review and testing of these patchset, but
i go on vacation this afternoon. So it will be in about 2 weeks time.

I spent 15 minutes tests just now. I spotted two things:

1) I played with a configuration, and then rebooted the machine. After
login i see:

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
# cat /sys/kernel/debug/dsa0/vtu 
 VID  FID  SID  0  1  2  3  4  5  6
   1    1    0  u  u  u  u  x  x  t
 500  500    0  t  t  t  t  x  x  t
 550  550    0  t  x  x  x  x  x  t
# bridge vlan show
port    vlan ids
lan0     1 PVID Egress Untagged

lan0     1 PVID Egress Untagged

lan1
lan2
lan3
lan4
lan5
lan6
lan7
lan8     1 PVID Egress Untagged

lan8     1 PVID Egress Untagged

optical3
optical4
br0      1 PVID Egress Untagged


So the switch seems to have some VTU table entries, but the bridge
command does not show them. I suspect that a warm boot does not clear
out the VTU entries in the switch.

Until recently we had a similar problem with the statistics
counters. I wounder if we have the same problem with other tables? Do
static ATU entries get removed on a reboot?

2) I cold booted the machine, to be sure to have a clean state. Then:

# cat /sys/kernel/debug/dsa0/vtu 
 VID  FID  SID  0  1  2  3  4  5  6
   1    1    0  u  x  x  x  x  x  t

So a good initial state. I then configure two bridges:

# brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.92647a2160c4       yes             lan0
                                                        lan1
br1             8000.92647a2160c4       yes             lan2
                                                        lan3

and then add vlan 500 to the four interfaces.

# bridge vlan add vid 500 dev lan0 master
# bridge vlan add vid 500 dev lan1 master                                                                     
# bridge vlan add vid 500 dev lan2 master                                                                     
# bridge vlan add vid 500 dev lan3 master

# cat /sys/kernel/debug/dsa0/vtu 
 VID  FID  SID  0  1  2  3  4  5  6
   1    1    0  u  u  u  u  x  x  t
 500  500    0  t  t  t  t  x  x  t

Does this mean we have one hardware bridge? All four ports can talk to
each other? I've not actually sent any frames to test this, so i'm
just speculating. Given that i have two software bridges, this is not
what i would expect, if frames from lan0 or lan1, also went out lan2
or lan3.

Thanks

	Andrew
