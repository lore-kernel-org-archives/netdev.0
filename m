From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Question about Mellanox FW reporting (incorrect) port types
Date: Wed, 17 Oct 2012 13:27:09 -0300
Message-ID: <507EDC5D.4070602@redhat.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Doug Ledford <dledford@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1182 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932325Ab2JQQ1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2012 12:27:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

We have a customer that is having issues bringing the 1st port up after 
upgrading RHEL. You may somewhat ignore the 6.2/6.3, just consider it as 
"old" and "new" please. The thing is:

- RHEL 6.2 works with warnings, it brings both ports up as ETH, as 
expected, just dmesg that gives repeated:
mlx4_core 0000:05:00.0: Requested port type for port 1 is not supported 
on this HCA

- RHEL 6.3 doesn't, it brings only the 2nd port up
The 1st one is tagged as IB, checked via /sys/.../mxl4_port1

NIC:
05:00.0 Network controller: Mellanox Technologies MT26438 [ConnectX VPI 
PCIe 2.0 5GT/s - IB QDR / 10GigE Virtualization+] (rev b0)
05:00.0 0280: 15b3:6746 (rev b0)

Issue seen at 14 servers, different firmware revisions, including at 
least 2.8.0 and 2.7.9294. We couldn't reproduce it, while using 2.7.9100.


To narrow down, I placed a debug msg at mlx4_QUERY_DEV_CAP() at 6.3 kernel:

         for (i = 1; i <= dev_cap->num_ports; ++i) {
             err = mlx4_cmd_box(dev, 0, mailbox->dma, i, 0, 
MLX4_CMD_QUERY_PORT,
                        MLX4_CMD_TIME_CLASS_B,
                        !mlx4_is_slave(dev));
             if (err)
                 goto out;

             MLX4_GET(field, outbox, QUERY_PORT_SUPPORTED_TYPE_OFFSET);
             dev_cap->supported_port_types[i] = field & 3;
             dev_cap->suggested_type[i] = (field >> 3) & 1;
             dev_cap->default_sense[i] = (field >> 4) & 1;
...
             mlx4_dbg(dev, "Port %d type flags: %x %x %x\n", i,
                 dev_cap->supported_port_types[i],
                 dev_cap->suggested_type[i],
                 dev_cap->default_sense[i]);
         }

This gave us:
[   12.368187] mlx4_core 0000:05:00.0: Port 1 type flags: 1 0 0
[   12.378232] mlx4_core 0000:05:00.0: Port 2 type flags: 2 0 0

And that's mapped to:
enum mlx4_port_type {
     MLX4_PORT_TYPE_NONE = 0,
     MLX4_PORT_TYPE_IB   = 1,
     MLX4_PORT_TYPE_ETH  = 2,
     MLX4_PORT_TYPE_AUTO = 3
};

So actually seems that the new driver is doing just as expected. It is 
honoring what firmware is saying.

Then I checked why previous driver worked. It seems to me (now based 
only on code review) that it was because of this forced sense, which was 
removed in 6.3, which integrated this commit:

commit 8d0fc7b61191c9433a4f738987b89e1d962eb637
Author: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date:   Mon Dec 19 04:00:34 2011 +0000

     mlx4_core: Changing link sensing logic

has the chunk:
@@ -1329,12 +1353,6 @@ static int mlx4_setup_hca(struct mlx4_dev *dev)

         if (!mlx4_is_slave(dev)) {
                 for (port = 1; port <= dev->caps.num_ports; port++) {
-                       if (!mlx4_is_mfunc(dev)) {
-                               enum mlx4_port_type port_type = 0;
-                               mlx4_SENSE_PORT(dev, port, &port_type);
-                               if (port_type)
-                                       dev->caps.port_type[port] = 
port_type;
-                       }
                         ib_port_default_caps = 0;
                         err = mlx4_get_port_ib_caps(dev, port,

This code would allow changing the port type to ETH, as it was executed 
after the query cap and it didn't check for supported_types before setting.

So my questions are: is it possible to the firmware report a wrong port 
type like that? Is it somehow configurable by sysadmin (via fw update, 
..), can we flip that byte or is it a manufacturing issue?

Any other info needed? I can't try upstream driver, but I can 
cherry-pick some changes if needed/recommended.

dmesg snippet for 6.3 with debugs:
[   10.573469] mlx4_core 0000:05:00.0: PCI INT A -> GSI 26 (level, low) 
-> IRQ 26
[   10.573509] mlx4_core 0000:05:00.0: setting latency timer to 64
[   11.593401] mlx4_core 0000:05:00.0: FW version 2.8.000 (cmd intf rev 
3), max commands 16
[   11.606423] mlx4_core 0000:05:00.0: Catastrophic error buffer at 
0x1f020, size 0x10, BAR 0
[   11.619459] mlx4_core 0000:05:00.0: Communication vector bar:2 
offset:0x800
[   11.631071] mlx4_core 0000:05:00.0: FW size 385 KB
[   11.640232] mlx4_core 0000:05:00.0: Clear int @ 1000, BAR 2
[   11.651984] mlx4_core 0000:05:00.0: Mapped 26 chunks/6168 KB for FW.
[   12.355826] mlx4_core 0000:05:00.0: BlueFlame available (reg size 
512, regs/page 8)
[   12.368187] mlx4_core 0000:05:00.0: Port 1 type flags: 1 0 0
[   12.378232] mlx4_core 0000:05:00.0: Port 2 type flags: 2 0 0
[   12.388158] mlx4_core 0000:05:00.0: Base MM extensions: flags 
00000cc0, rsvd L_Key 00000500
[   12.401071] mlx4_core 0000:05:00.0: Max ICM size 4294967296 MB
[   12.411183] mlx4_core 0000:05:00.0: Max QPs: 16777216, reserved QPs: 
64, entry size: 256
[   12.423786] mlx4_core 0000:05:00.0: Max SRQs: 16777216, reserved 
SRQs: 64, entry size: 128
[   12.436568] mlx4_core 0000:05:00.0: Max CQs: 16777216, reserved CQs: 
128, entry size: 128
[   12.449241] mlx4_core 0000:05:00.0: Max EQs: 512, reserved EQs: 8, 
entry size: 128
[   12.461221] mlx4_core 0000:05:00.0: reserved MPTs: 16, reserved MTTs: 16
[   12.472270] mlx4_core 0000:05:00.0: Max PDs: 8388608, reserved PDs: 
4, reserved UARs: 2
[   12.484711] mlx4_core 0000:05:00.0: Max QP/MCG: 8388608, reserved MGMs: 0
[   12.495786] mlx4_core 0000:05:00.0: Max CQEs: 4194304, max WQEs: 
16384, max SRQ WQEs: 16384
[   12.508587] mlx4_core 0000:05:00.0: Local CA ACK delay: 15, max MTU: 
4096, port width cap: 3
[   12.521485] mlx4_core 0000:05:00.0: Max SQ desc size: 1008, max SQ 
S/G: 62
[   12.532639] mlx4_core 0000:05:00.0: Max RQ desc size: 512, max RQ S/G: 32
[   12.543651] mlx4_core 0000:05:00.0: Max GSO size: 131072
[   12.552996] mlx4_core 0000:05:00.0: Max counters: 256
[   12.561998] mlx4_core 0000:05:00.0: DEV_CAP flags:
[   12.570660] mlx4_core 0000:05:00.0:     RC transport
[   12.570661] mlx4_core 0000:05:00.0:     UC transport
[   12.570662] mlx4_core 0000:05:00.0:     UD transport
[   12.570662] mlx4_core 0000:05:00.0:     XRC transport
[   12.570663] mlx4_core 0000:05:00.0:     FCoIB support
[   12.570664] mlx4_core 0000:05:00.0:     SRQ support
[   12.570665] mlx4_core 0000:05:00.0:     IPoIB checksum offload
[   12.570666] mlx4_core 0000:05:00.0:     P_Key violation counter
[   12.570667] mlx4_core 0000:05:00.0:     Q_Key violation counter
[   12.570667] mlx4_core 0000:05:00.0:     DPDP
[   12.570668] mlx4_core 0000:05:00.0:     Big LSO headers
[   12.570669] mlx4_core 0000:05:00.0:     APM support
[   12.570670] mlx4_core 0000:05:00.0:     Atomic ops support
[   12.570671] mlx4_core 0000:05:00.0:     Address vector port checking 
support
[   12.570672] mlx4_core 0000:05:00.0:     UD multicast support
[   12.570672] mlx4_core 0000:05:00.0:     Router support
[   12.570673] mlx4_core 0000:05:00.0:     IBoE support
[   12.570674] mlx4_core 0000:05:00.0:     Unicast loopback support
[   12.570675] mlx4_core 0000:05:00.0:     Wake On LAN support
[   12.570676] mlx4_core 0000:05:00.0:     UDP RSS support
[   12.570676] mlx4_core 0000:05:00.0:     Unicast VEP steering support
[   12.570677] mlx4_core 0000:05:00.0:     Multicast VEP steering support
[   12.570678] mlx4_core 0000:05:00.0:     Counters support
[   12.570680] mlx4_core 0000:05:00.0: Initial port 1 type: 1, 
port_type_array[0]=0  <-- (this is log of mine too)
[   12.570681] mlx4_core 0000:05:00.0: Sense allowed for port 1: 0
[   12.570682] mlx4_core 0000:05:00.0: Initial port 2 type: 2, 
port_type_array[1]=0
[   12.570683] mlx4_core 0000:05:00.0: Sense allowed for port 2: 0
[   12.570686] mlx4_core 0000:05:00.0:   profile[ 0] (  CMPT): 2^26 
entries @ 0x         0, size 0x 100000000
[   12.570687] mlx4_core 0000:05:00.0:   profile[ 1] (RDMARC): 2^22 
entries @ 0x 100000000, size 0x   8000000
[   12.570689] mlx4_core 0000:05:00.0:   profile[ 2] (    QP): 2^18 
entries @ 0x 108000000, size 0x   4000000
[   12.570690] mlx4_core 0000:05:00.0:   profile[ 3] (   MTT): 2^23 
entries @ 0x 10c000000, size 0x   4000000
[   12.570691] mlx4_core 0000:05:00.0:   profile[ 4] (  DMPT): 2^19 
entries @ 0x 110000000, size 0x   2000000
[   12.570693] mlx4_core 0000:05:00.0:   profile[ 5] (  ALTC): 2^18 
entries @ 0x 112000000, size 0x   1000000
[   12.570694] mlx4_core 0000:05:00.0:   profile[ 6] (   SRQ): 2^16 
entries @ 0x 113000000, size 0x    800000
[   12.570696] mlx4_core 0000:05:00.0:   profile[ 7] (    CQ): 2^16 
entries @ 0x 113800000, size 0x    800000
[   12.570697] mlx4_core 0000:05:00.0:   profile[ 8] (   MCG): 2^13 
entries @ 0x 114000000, size 0x    800000
[   12.570699] mlx4_core 0000:05:00.0:   profile[ 9] (  AUXC): 2^18 
entries @ 0x 114800000, size 0x     40000
[   12.570701] mlx4_core 0000:05:00.0:   profile[10] (    EQ): 2^06 
entries @ 0x 114840000, size 0x      2000
[   12.570702] mlx4_core 0000:05:00.0: HCA context memory: reserving 
4530440 KB
[   12.570722] mlx4_core 0000:05:00.0: 4530440 KB of HCA context 
requires 8936 KB aux memory.
[   12.599185] mlx4_core 0000:05:00.0: Mapped 38 chunks/8936 KB for ICM aux.
[   12.600516] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 0 for ICM.
[   12.601811] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
40000000 for ICM.
[   12.603105] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
80000000 for ICM.
[   12.603139] mlx4_core 0000:05:00.0: Mapped 1 chunks/4 KB at c0000000 
for ICM.
[   12.603192] mlx4_core 0000:05:00.0: Mapped 1 chunks/8 KB at 114840000 
for ICM.
[   12.604464] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
10c000000 for ICM.
[   12.605772] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
110000000 for ICM.
[   12.607047] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
108000000 for ICM.
[   12.608324] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114800000 for ICM.
[   12.609600] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
112000000 for ICM.
[   12.610875] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
100000000 for ICM.
[   12.612146] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
113800000 for ICM.
[   12.613419] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
113000000 for ICM.
[   12.614693] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114000000 for ICM.
[   12.615966] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114040000 for ICM.
[   12.617240] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114080000 for ICM.
[   12.618512] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
1140c0000 for ICM.
[   12.619787] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114100000 for ICM.
[   12.621061] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114140000 for ICM.
[   12.622334] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114180000 for ICM.
[   12.623603] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
1141c0000 for ICM.
[   12.624880] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114200000 for ICM.
[   12.626154] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114240000 for ICM.
[   12.627426] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114280000 for ICM.
[   12.628699] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
1142c0000 for ICM.
[   12.629974] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114300000 for ICM.
[   12.631247] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114340000 for ICM.
[   12.632521] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114380000 for ICM.
[   12.633793] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
1143c0000 for ICM.
[   12.635069] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114400000 for ICM.
[   12.636342] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114440000 for ICM.
[   12.637616] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114480000 for ICM.
[   12.638890] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
1144c0000 for ICM.
[   12.640162] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114500000 for ICM.
[   12.641435] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114540000 for ICM.
[   12.642714] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114580000 for ICM.
[   12.643989] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
1145c0000 for ICM.
[   12.645265] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114600000 for ICM.
[   12.646536] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114640000 for ICM.
[   12.647807] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114680000 for ICM.
[   12.649082] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
1146c0000 for ICM.
[   12.650354] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114700000 for ICM.
[   12.651628] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114740000 for ICM.
[   12.652902] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
114780000 for ICM.
[   12.654177] mlx4_core 0000:05:00.0: Mapped 1 chunks/256 KB at 
1147c0000 for ICM.
... irq allocs ...
[   13.222583] mlx4_core 0000:05:00.0: irq 128 for MSI/MSI-X
[   13.602288] mlx4_core 0000:05:00.0: NOP command IRQ test passed
[   13.653457] mlx4_en: Mellanox ConnectX HCA Ethernet driver v2.0 (Dec 
2011)
[   13.662601] mlx4_en 0000:05:00.0: Activating port:2
[   13.669411] mlx4_en: 0000:05:00.0: Port 2: Using 8 TX rings
[   13.676497] mlx4_en: 0000:05:00.0: Port 2: Using 8 RX rings
[   13.683772] mlx4_en: 0000:05:00.0: Port 2: Initializing port
[   13.731168] mlx4_ib: Mellanox ConnectX InfiniBand driver v1.0 (April 
4, 2008)

Previous kernel (I don't have it with debugs):
mlx4_core 0000:05:00.0: irq 105 for MSI/MSI-X
mlx4_en: Mellanox ConnectX HCA Ethernet driver v1.5.4.1 (March 2011)
mlx4_en 0000:05:00.0: Activating port:1
mlx4_en: 0000:05:00.0: Port 1: Using 8 TX rings
mlx4_en: 0000:05:00.0: Port 1: Using 8 RX rings
mlx4_en: 0000:05:00.0: Port 1: Initializing port
mlx4_en 0000:05:00.0: Activating port:2
mlx4_en: 0000:05:00.0: Port 2: Using 8 TX rings
mlx4_en: 0000:05:00.0: Port 2: Using 8 RX rings
mlx4_en: 0000:05:00.0: Port 2: Initializing port

Same host, same nic, just rebooted.

Thanks,
Marcelo.
