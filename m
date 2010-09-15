From: arno@natisbad.org (Arnaud Ebalard)
Subject: E1000E/82567LM-3: link reported up too soon
Date: Wed, 15 Sep 2010 15:48:28 +0200
Message-ID: <87eicvi0cz.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

I have a Dell E4300 Laptop running 2.6.35.4. It contains an Intel
82567LM-3 Gigabit chipset. Here is what lspci reports:

00:19.0 Ethernet controller: Intel Corporation 82567LM Gigabit Network Connection (rev 03)
        Subsystem: Dell Device 024d
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0
        Interrupt: pin A routed to IRQ 44
        Region 0: Memory at f6ae0000 (32-bit, non-prefetchable) [size=128K]
        Region 1: Memory at f6adb000 (32-bit, non-prefetchable) [size=4K]
        Region 2: I/O ports at efe0 [size=32]
        Capabilities: [c8] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
                Address: 00000000fee0300c  Data: 41b1
        Capabilities: [e0] PCI Advanced Features
                AFCap: TP+ FLR+
                AFCtrl: FLR-
                AFStatus: TP-
        Kernel driver in use: e1000e

When connecting the laptop to an ethernet switch, the driver performs
autoneg and then reports the link up via Netlink. This is monitored by
both netplug and UMIP to emit a DHCP request and an IPv6 Router
Solicitation (respectively) as soon as the link is reported UP and
RUNNING.

Most of the time, those first packets never reach the switch, i.e. the
packets are visible locally via tcpdump but are not seen on the remote
side.

I tested it with 2 different 100M/s switches (Cisco Catalyst 2960 and a
Planex FX08-Mini) so I guess the switch is not the root of the issue. I
came to the conclusion that the link is reported up too soon by the
driver.

Because the first packets are losts, the result is that address
autoconfiguration is delayed by a few seconds as can be seen on
following capture on the laptop:

13.450 IPv6 (0x86dd), length  62: :: > ff02::2: ICMP6, router solicitation, length 8
13.469 IPv4 (0x0800), length 342: 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request
16.472 IPv4 (0x0800), length 342: 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request
17.204 IPv4 (0x0800), length 342: 10.1.4.254.67 > 10.1.4.2.68: BOOTP/DHCP, Reply, length 300
17.205 IPv4 (0x0800), length 356: 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request
17.210 IPv4 (0x0800), length 349: 10.1.4.254.67 > 10.1.4.2.68: BOOTP/DHCP, Reply, length 307
17.237 ARP  (0x0806), length  42: Request who-has 10.1.4.2 tell 0.0.0.0, length 28
17.437 ARP  (0x0806), length  42: Request who-has 10.1.4.2 tell 0.0.0.0, length 28
17.451 IPv6 (0x86dd), length  62: :: > ff02::2: ICMP6, router solicitation, length 8
17.451 IPv6 (0x86dd), length 214: fe80::21e:bff:fe5e:3b2 > ff02::1: ICMP6, router advertisement, length 160
17.461 IPv6 (0x86dd), length  90: :: > ff02::16: HBH ICMP6, multicast listener report v2, 1 group record(s), length 28
17.637 ARP  (0x0806), length  42: Request who-has 10.1.4.2 tell 0.0.0.0, length 28

Don't hesitate to tell if there may be another reason for that behavior
or ask if you need additional info or want me to test some patch.

Cheers,

a+

ps: please, keep me in CC

------------------------------------------------------------------------------
Start uncovering the many advantages of virtual appliances
and start using them to simplify application deployment and
accelerate your shift to cloud computing.
http://p.sf.net/sfu/novell-sfdev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
