From: Jamie Lentin <jm@lentin.co.uk>
Subject: Re: [PATCH v0 00/10] Convert Netgear WNR854T to devicetree
Date: Tue, 19 Jul 2016 10:33:49 +0100 (BST)
Message-ID: <alpine.DEB.2.11.1607190933590.19980@marmot.wormnet.eu>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
 <20160716205304.GA5075@lunn.ch>
 <alpine.DEB.2.11.1607171043100.19980@marmot.wormnet.eu>
 <20160717153338.GA13611@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>, netdev@vger.kernel.org,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Imre Kaloz <kaloz@openwrt.org>, linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20160717153338.GA13611@lunn.ch>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Sun, 17 Jul 2016, Andrew Lunn wrote:

>> Firstly I've tried to to rebase against net-next[0], but after
>> adding 6131 to mv88e6xxx_of_match, &chip->ppu_work seems to be
>> causing a NULL pointer ooops. I'll assume it's not done yet and
>> ignore net-next for now.
>
> You don't need to modify mv88e6xxx_of_match, the 6131 is compatible
> with the mv88e6085. Just use the compatible string of
> "marvell,mv88e6085". So far, ever Marvell chip we support is
> compatible with the mv88e6085, in terms of probing. Once the driver
> has probed, and read the device ID from a register, it knows enough to
> decide for itself what features the chip has.

Okay, besides the DT mistakes you mention below (changes are pushed to the 
same branch), I've worked out out what my problem was here. The switch was 
probed before the ethernet device is available, so mv88e6xxx_probe() has 
to back out with EPROBE_DEFER at mv88e6xxx_register_switch().

However mv88e6xxx_mdio_unregister() doesn't tidy up fully. The following 
lets me boot, but I'm not really clear what the usleep is helping solve 
and don't like it:

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 5cb06f7..c46ac54 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3387,6 +3387,10 @@ static void mv88e6xxx_mdio_unregister(struct mv88e6xxx_chip *chip)
  {
  	struct mii_bus *bus = chip->mdio_bus;

+	/* Stop any timers attempting to re-activate the PPU */
+	del_timer(&chip->ppu_timer);
+	usleep_range(1000, 2000);
+
  	mdiobus_unregister(bus);

  	if (chip->mdio_np)

FWIW I now get:

libphy: Fixed MDIO Bus: probed
libphy: mdio_driver_register: mv88e6085
libphy: orion_mdio_bus: probed
mdio_bus f1072004.mdio-bu:00: mdio_device_register
mv88e6085 f1072004.mdio-bu:00: switch 0x106 detected: Marvell 88E6131, revision 6
libphy: /soc/internal-regs/mdio-bus@72004/switch@0: probed
mv643xx_eth: MV-643xx 10/100/1000 ethernet driver version 1.4
mv643xx_eth_port mv643xx_eth_port.0 eth0: port 0 with MAC address 00:1b:2f:d5:9d:f4
  . . .
mv88e6085 f1072004.mdio-bu:00: switch 0x106 detected: Marvell 88E6131, revision 6
libphy: /soc/internal-regs/mdio-bus@72004/switch@0: probed
DSA: switch 0 0 parsed
DSA: tree 0 parsed
Marvell 88E1121R !soc!internal-re:00: attached PHY driver [Marvell 88E1121R] (mii_bus:phy_addr=!soc!internal-re:00, irq=-1)
Marvell 88E1121R !soc!internal-re:01: attached PHY driver [Marvell 88E1121R] (mii_bus:phy_addr=!soc!internal-re:01, irq=-1)
Marvell 88E1121R !soc!internal-re:02: attached PHY driver [Marvell 88E1121R] (mii_bus:phy_addr=!soc!internal-re:02, irq=-1)
Marvell 88E1112 !soc!internal-re:05: attached PHY driver [Marvell 88E1112] (mii_bus:phy_addr=!soc!internal-re:05, irq=-1)
Marvell 88E1112 !soc!internal-re:07: attached PHY driver [Marvell 88E1112] (mii_bus:phy_addr=!soc!internal-re:07, irq=-1)

However, nothing's changed since 4.7-rc7 in terms of getting the switch 
to work.

> In order to get the LEDs working as you want, you are going to have to
> use the new binding. So i would suggest sticking with that.

Some have suggested I should be more worried about being able to shift 
packets than getting the LEDs working, but where's the fun in that? :)

>>> I see you have NET_TAG_DSA, but not NET_TAG_EDSA in your
>>> configuration. Try swapping to EDSA. I even removed support for
>>> TAG_DSA in one of the recent patches.
>>
>> Okay, back to my original wnr854t-support-v0a branch based on 4.6,
>> switched to .tag_protocol = DSA_TAG_PROTO_EDSA and reconfig'ed to
>> add support, but there's no traffic in/out of any port. tcpdump on
>> the underlying ethernet port shows encapsulated broadcast traffic,
>> e.g. this ARP request from enp0:10.100.4.41:
>>
>> 00:15:31.173399 1a:ff:0f:fe:10:22 (oui Unknown) > Broadcast,
>> ethertype Unknown (0xc008), length 64:
>>         0x0000:  0000 0806 0001 0800 0604 0001 1aff 0ffe  ................
>>         0x0010:  1022 0a64 0429 0000 0000 0000 0a64 0437  .".d.).......d.7
>>         0x0020:  0000 0000 0000 0000 0000 0000 0000 0000  ................
>>         0x0030:  0000                                     ..
>>
>> ...but no unicast traffic.
>
> Uh, that does not look like EDSA tagging. Expect an ethertype of
> 0xdada. Also, if you get the latest tcpdump sources, it knows how to
> decode the additional EDSA header which is added.

Okay. Frames sent from the port are EDSA-tagged (which isn't exactly 
surprising), but I'm yet to see the switch receive 0xdada frames. Even 
with the net-next branch which uses DSA_TAG_PROTO_EDSA for all chip types.

However, the ethertype is reflecting the port:-

lan1/5 : ethertype Unknown (0xc028), length 176:
lan2/7 : ethertype Unknown (0xc038), length 176:
lan3/0 : ethertype Unknown (0xc000), length 176:
lan4/1 : ethertype Unknown (0xc008), length 176:
wan/2  : ethertype Unknown (0xc010), length 176:

My other one of these routers, running OpenWRT / Linux 3.3.8, shows the 
same ethertypes, which suggests that the switch is still in DSA tagging 
mode. I'll poke around further and see what I find.

>>> Please also can you get https://github.com/vivien/linux.git commit
>>> 323321875671dfe95b6b91ce051a74d415c7158c which will give you some
>>> extra debug files /sys/kernel/debug/mv88e6xxx.
>>>
>>> The reg, stats, and atu would be interesting.
>>
>> Okay, I rebased 4.7-rc7, ignoring my ropey attempts to configure the
>> LEDs, cherry-picked the above commit. Pushed the result if it's
>> useful[1]. The debugfs code wouldn't patch cleanly onto 4.6 or
>> net-next.
>
> Yes, the debug code is a real pain. Something i'm working on in the
> background, get something generic which is acceptable for mainline.
>
>> On boot up I get:
>>
>> mdio_bus f1072004.mdio-bu: switch 0x106 probed: Marvell 88E6131, revision 6
>> mv643xx_eth_port mv643xx_eth_port.0 eth0: [0]: detected a Marvell 88E6131 switch
>> libphy: dsa slave smi: probed
>> Marvell 88E1121R dsa-0:00:00: attached PHY driver [Marvell 88E1121R]  (mii_bus:phy_addr=dsa-0:00:00, irq=-1)
>> Marvell 88E1121R dsa-0:00:01: attached PHY driver [Marvell 88E1121R] (mii_bus:phy_addr=dsa-0:00:01, irq=-1)
>> Marvell 88E1121R dsa-0:00:02: attached PHY driver [Marvell 88E1121R] (mii_bus:phy_addr=dsa-0:00:02, irq=-1)
>> Marvell 88E1112 dsa-0:00:05: attached PHY driver [Marvell 88E1112] (mii_bus:phy_addr=dsa-0:00:05, irq=-1)
>> Marvell 88E1112 dsa-0:00:07: attached PHY driver [Marvell 88E1112] (mii_bus:phy_addr=dsa-0:00:07, irq=-1)
>
> That looks good, it found the PHYs etc.
>
>> Like above (since 4.7 seems to use DSA_TAG_PROTO_EDSA), there's no
>> traffic visible with tcpdump on lan1/4 (broadcast or unicast), only
>> broadcast traffic on the backing port, eth0.
>>
>> # cat /sys/kernel/debug/mv88e6xxx.0/regs
>>     GLOBAL GLOBAL2 SERDES     0    1    2    3    4    5    6    7
>>  0:  c800       0       0  7080 7d80 7080 6e88 6086 7e86 6086 7086
>>  1:    1b       0       0     3    3    3   3e  403  403  403  403
>>  2:  2fd5       0       0     0    0    0    0    0    0    0    0
>>  3:  9df4    ffff       0  1066 1066 1066 1066 1066 1066 1066 1066
>>  4:  4000     191       0   433  433  433 3533  433  433  433  433
>>  5:  1000      ff       0     0    0    0    0    0    0    0    0
>>  6:  c000    1f0f       0   708  708  708  7f7  708  708  708  708
>>  7:     0    70ff       0     0    0    0    0    0    0    0    0
>>  8:     0    7800       0    83   83   83   c3   83   83   83   83
>>  9:     0       0       0     1    1    1    1    1    1    1    1
>>  a:  f148       0       0     0    0    0    0    0    0    0    0
>>  b:  400f       0       0     1    2    4    0   10   20   40   80
>>  c:     0       0       0     0    0    0    0    0    0    0    0
>>  d:  ffff       0       0     0    0    0    0    0    0    0    0
>>  e:  ffff       0       0     0    0    0    0    0    0    0    0
>>  f:  ffff      77       0     0    0    0    0    0    0    0    0
>> 10:     0       0       0     0    0    0    0    0    0    0    0
>> 11:     0       0       0     0    0    0    0    0    0    0    0
>> 12:  5555       0       0     0    0    0   12    0    0    0    0
>> 13:  5555       0       0     0    0    0    0    0    0    0    0
>> 14:  aaaa       0       0   403  403  403 8403  403  403  403  403
>> 15:  aaaa       0       0     0    0    0    0    0    0    0    0
>> 16:  ffff       0       0   700  70d  700  700  f41  f0e  f41  f02
>> 17:  ffff       0       0     0    0    0    0    0    0    0    0
>> 18:  fa41       0       0  3210 3210 3210 3210 3210 3210 3210 3210
>> 19:  8100       0       0  7654 7654 7654 7654 7654 7654 7654 7654
>> 1a:  3330       0       0     -    -    -    -    -    -    -    -
>> 1b:    f4       0       0     -    -    -    -    -    -    -    -
>> 1c:  f000       0       0     -    -    -    -    -    -    -    -
>> 1d:  5c07       0       0     -    -    -    -    -    -    -    -
>> 1e:     0      f0       0     -    -    -    -    -    -    -    -
>> 1f:     0       0       0     -    -    -    -    -    -    -    -
>>
>> # cat /sys/kernel/debug/mv88e6xxx.0/stats
>>                                (lan4)             (cpu)             (lan1)
>>           Statistic   Port  0  Port  1  Port  2  Port  3  Port  4  Port  5  Port  6  Port  7
>>      in_good_octets:        0     1064        0     1152        0   112155        0        0
>>       in_bad_octets:        0        0        0        0        0        0        0        0
>>          in_unicast:        0        0        0        0        0        0        0        0
>>       in_broadcasts:        0        6        0       18        0      335        0        0
>>       in_multicasts:        0        8        0        0        0      490        0        0
>>            in_pause:        0        0        0        0        0        0        0        0
>>        in_undersize:        0        0        0        0        0        0        0        0
>>        in_fragments:        0        0        0        0        0        0        0        0
>>         in_oversize:        0        0        0        0        0        0        0        0
>>           in_jabber:        0        0        0        0        0        0        0        0
>>         in_rx_error:        0        0        0        0        0        0        0        0
>>        in_fcs_error:        0        0        0        0        0        0        0        0
>>          out_octets:        0        0        0   131331        0        0        0        0
>>         out_unicast:        0        0        0        0        0        0        0        0
>>      out_broadcasts:        0        0        0      558        0        0        0        0
>>      out_multicasts:        0        0        0      498        0        0        0        0
>>           out_pause:        0        0        0        0        0        0        0        0
>>           excessive:        0        0        0        0        0        0        0        0
>>          collisions:        0        0        0        0        0        0        0        0
>>            deferred:        0        0        0        0        0        0        0        0
>>              single:        0        0        0        0        0        0        0        0
>>            multiple:        0        0        0        0        0        0        0        0
>>       out_fcs_error:        0        0        0        0        0        0        0        0
>>                late:        0        0        0        0        0        0        0        0
>>        hist_64bytes:        0        6        0       18        0      188        0        0
>>    hist_65_127bytes:        0        8        0      440        0       69        0        0
>>   hist_128_255bytes:        0        0        0      376        0      376        0        0
>>   hist_256_511bytes:        0        0        0        0        0        0        0        0
>>  hist_512_1023bytes:        0        0        0        0        0        0        0        0
>> hist_1024_max_bytes:        0        0        0        0        0        0        0        0
>>      sw_in_discards:        0        0        0        0        0        0        0        0
>>      sw_in_filtered:        0        0        0       18        0        0        0        0
>>     sw_out_filtered:        0        0        0        0        0        0        0        0
>
> So as you say, no unicast traffic to/from the CPU port. The 18
> sw_in_filtered also look suspicious.

Yes, I've also noticed this, but not got anywhere in finding out what 
filtered means---is it a set of rules the PHY applies, if so where do they 
come from?

>> [0] https://github.com/lentinj/linux/tree/wnr854t-support-v0b-net-next-experiment
>
> +	port@3 {
> +			reg = <3>;
> +			label = "cpu";
> +			ethernet = <&eth>;
> +			fixed-link {
> +				speed = <1000>;
> +				full-duplex;
> +			};
>
> You don't need a fixed-link here. The cpu port is automatically
> configured fixed at the highest speed the port will do.
>
> However,
>
> &eth {
>      status = "okay";
> -     ethernet-port@0 {
> -     		speed = <1000>;
> -		duplex = <1>;
> -    };
> };
>
> here you do need the fixed link, otherwise it thinks there is a PHY
> connected and tried to do auto-negotiation. That will never work.
>
> 	  Andrew
>

-- 
Jamie Lentin
