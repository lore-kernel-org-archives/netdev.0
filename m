From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: stmmac: Performance regression after commit aff3d9eff843 "net:
 stmmac: enable multiple buffers"
Date: Thu, 23 Mar 2017 12:55:28 +0000
Message-ID: <7b8736a3-d5ad-ab7d-7f79-2e5b694e74e0@synopsys.com>
References: <20170323100828.GC16625@Red>
 <68200e05-04fd-1cc1-f6d6-f77e9e6f1d9d@synopsys.com>
 <20170323102037.GD16625@Red>
 <a7c928ec-e4e5-b618-d0d4-2a833be10d53@synopsys.com>
 <465dc72e-8a1f-b41f-105f-add2164df6d5@st.com>
 <5c305629-0b61-88e5-5c48-4616cd687d9f@st.com>
 <89948183-5dba-af4e-8fd1-2a6add6750c8@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <alexandre.torgue@st.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <89948183-5dba-af4e-8fd1-2a6add6750c8@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Às 10:56 AM de 3/23/2017, Joao Pinto escreveu:
> Às 10:51 AM de 3/23/2017, Giuseppe CAVALLARO escreveu:
>> On 3/23/2017 11:48 AM, Giuseppe CAVALLARO wrote:
>>> Hello
>>>
>>> On 3/23/2017 11:20 AM, Corentin Labbe wrote:
>>>>> I have a 4.21 QoS Core with 4 RX + 4 TX and detected no regression.
>>>>>> Could you please share the iperf cmds you are using in order for me to
>>>>> reproduce
>>>>>> in my side?
>>>

HW Version: 4.21 QoS Core in HAPS DX7 (FPGA)
The connection between the FPGA and PC where stmmac is running is PCIe.
My configurations are done in stmmac_pci. Here they are:

@@ -68,10 +70,52 @@ static void stmmac_default_data(struct plat_stmmacenet_data
*plat)
 {
 	plat->bus_id = 1;
 	plat->phy_addr = 0;
-	plat->interface = PHY_INTERFACE_MODE_GMII;
-	plat->clk_csr = 2;	/* clk_csr_i = 20-35MHz & MDC = clk_csr_i/16 */
-	plat->has_gmac = 1;
-	plat->force_sf_dma_mode = 1;
+	plat->interface = PHY_INTERFACE_MODE_SGMII;
+	plat->clk_csr = 0x5;
+	plat->has_gmac = 0;
+	plat->has_gmac4 = 1;
+	plat->force_sf_dma_mode = 0;
+
+	plat->rx_queues_to_use = 4;
+	plat->tx_queues_to_use = 4;
+
+	plat->rx_sched_algorithm = MTL_RX_ALGORITHM_SP;
+
+	plat->rx_queues_cfg[0].mode_to_use = MTL_QUEUE_AVB;
+	plat->rx_queues_cfg[1].mode_to_use = MTL_QUEUE_DCB;
+	plat->rx_queues_cfg[2].mode_to_use = MTL_QUEUE_DCB;
+	plat->rx_queues_cfg[3].mode_to_use = MTL_QUEUE_DCB;
+
+	plat->tx_queues_cfg[0].mode_to_use = MTL_QUEUE_DCB;
+	plat->tx_queues_cfg[1].mode_to_use = MTL_QUEUE_AVB;
+	plat->tx_queues_cfg[2].mode_to_use = MTL_QUEUE_DCB;
+	plat->tx_queues_cfg[3].mode_to_use = MTL_QUEUE_DCB;
+
+	plat->tx_queues_cfg[1].send_slope = 0xCCC;
+	plat->tx_queues_cfg[1].idle_slope = 0x1333;
+	plat->tx_queues_cfg[1].high_credit = 0x4B0000;
+	plat->tx_queues_cfg[1].low_credit = 0xFFB50000;
+
+	plat->rx_queues_cfg[0].chan = 0;
+	plat->rx_queues_cfg[1].chan = 1;
+	plat->rx_queues_cfg[2].chan = 2;
+	plat->rx_queues_cfg[3].chan = 3;
+
+	plat->tx_sched_algorithm = MTL_TX_ALGORITHM_WRR;
+	plat->tx_queues_cfg[0].weight = 0x10;
+	plat->tx_queues_cfg[1].weight = 0x11;
+	plat->tx_queues_cfg[2].weight = 0x12;
+	plat->tx_queues_cfg[3].weight = 0x13;
+
+	/* Disable Priority config by default */
+	plat->tx_queues_cfg[0].use_prio = false;
+	plat->rx_queues_cfg[0].use_prio = false;
+
+	/* Disable RX queues routing by default */
+	plat->rx_queues_cfg[0].pkt_route = 0x0;
+	plat->rx_queues_cfg[1].pkt_route = 0x0;
+	plat->rx_queues_cfg[2].pkt_route = 0x0;
+	plat->rx_queues_cfg[3].pkt_route = 0x0;

 	plat->mdio_bus_data->phy_reset = NULL;
 	plat->mdio_bus_data->phy_mask = 0;
@@ -83,22 +127,14 @@ static void stmmac_default_data(struct plat_stmmacenet_data
*plat)
 	/* Set default value for multicast hash bins */
 	plat->multicast_filter_bins = HASH_TABLE_SIZE;

+	plat->dma_cfg->fixed_burst = 0;
+	plat->dma_cfg->aal = 0;
+
 	/* Set default value for unicast filter entries */
 	plat->unicast_filter_entries = 1;

 	/* Set the maxmtu to a default of JUMBO_LEN */
 	plat->maxmtu = JUMBO_LEN;
-
-	/* Set default number of RX and TX queues to use */
-	plat->tx_queues_to_use = 1;
-	plat->rx_queues_to_use = 1;
-
-	/* Disable Priority config by default */
-	plat->tx_queues_cfg[0].use_prio = false;
-	plat->rx_queues_cfg[0].use_prio = false;
-
-	/* Disable RX queues routing by default */
-	plat->rx_queues_cfg[0].pkt_route = 0x0;
 }


******* TESTS *******


*TEST 1: File (linux-next tarball) transfer of ~1.4G by scp to the DUT*

scp net-next-20170323.tar.gz xxxxx@XXXXXXX:/home/synopsys/
The authenticity of host 'XXXXX' can't be established.
ECDSA key fingerprint is SHA256:/XXXXXX.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'XXXXXX' (ECDSA) to the list of known hosts.
XXXXXX@XXXXX's password:
net-next20170323.tar.gz

             100% 1366MB  79.3MB/s   00:17

ifconfig after transfer:

eth1      Link encap:Ethernet  HWaddr XXXX
          inet addr:XXXX  Bcast:XXXX  Mask:XXXX
          inet6 addr: XXXXX Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1026614 errors:0 dropped:0 overruns:0 frame:0
          TX packets:56804 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1502856063 (1.5 GB)  TX bytes:4224767 (4.2 MB)
          Interrupt:16

*stmmac Log after transfer:

#:~/temp$ dmesg | grep stmmac
[    0.278200] stmmac - user ID: 0x10, Synopsys ID: 0x42
[    0.278207] stmmaceth 0000:01:00.0: DMA HW capability register supported
[    0.278209] stmmaceth 0000:01:00.0: RX Checksum Offload Engine supported
[    0.278211] stmmaceth 0000:01:00.0: TX Checksum insertion supported
[    0.278224] stmmaceth 0000:01:00.0: Enable RX Mitigation via HW Watchdog Timer
[    0.315596] libphy: stmmac: probed
[    0.315601] stmmaceth 0000:01:00.0 (unnamed net_device) (uninitialized): PHY
ID 01410cc2 at 0 IRQ POLL (stmmac-1:00) active
[    0.315605] stmmaceth 0000:01:00.0 (unnamed net_device) (uninitialized): PHY
ID 01410cc2 at 1 IRQ POLL (stmmac-1:01)
[    0.315608] stmmaceth 0000:01:00.0 (unnamed net_device) (uninitialized): PHY
ID 01410cc2 at 2 IRQ POLL (stmmac-1:02)
[    0.315612] stmmaceth 0000:01:00.0 (unnamed net_device) (uninitialized): PHY
ID 01410cc2 at 3 IRQ POLL (stmmac-1:03)
[   13.380009] Generic PHY stmmac-1:00: attached PHY driver [Generic PHY]
(mii_bus:phy_addr=stmmac-1:00, irq=-1)
[   13.390093] stmmaceth 0000:01:00.0 eth1: IEEE 1588-2008 Advanced Timestamp
supported
[   13.390200] stmmaceth 0000:01:00.0 eth1: registered PTP clock
[   14.436743] stmmaceth 0000:01:00.0 eth1: Link is Up - 1Gbps/Full - flow
control off
[   21.056476]  stmmac_set_wol+0x55/0xc0

Conclusions: No packets lost, clean stmmac log.


* TEST 2: iperf

Server side:

#:/media/DevDisk/gitrepo/mainline-net$ iperf -s -B XXXX.0.3
------------------------------------------------------------
Server listening on TCP port 5001
Binding to local address XXXXX.0.3
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local XXXX.0.3 port 5001 connected with XXXX.0.2 port 54092
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-20.1 sec  1.03 GBytes   443 Mbits/sec

Client side:

#:~/temp$ iperf -c XXXX.0.3 --port 5001 -t 20 -i 5
------------------------------------------------------------
Client connecting to XXXX.0.3, TCP port 5001
TCP window size: 85.0 KByte (default)
------------------------------------------------------------
[  3] local XXXXX.0.2 port 54092 connected with XXXXX.0.3 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 5.0 sec   265 MBytes   445 Mbits/sec
[  3]  5.0-10.0 sec   265 MBytes   444 Mbits/sec
[  3] 10.0-15.0 sec   264 MBytes   444 Mbits/sec
[  3] 15.0-20.0 sec   263 MBytes   442 Mbits/sec
[  3]  0.0-20.0 sec  1.03 GBytes   444 Mbits/sec


Thanks,
Joao
