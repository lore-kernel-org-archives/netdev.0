From: "Dongsheng.Wang@freescale.com" <Dongsheng.Wang@freescale.com>
Subject: Powerpc: e1000e cannot work normally after system resume from
 sleep(standby)
Date: Thu, 17 Apr 2014 07:00:16 +0000
Message-ID: <5f7a898d9d6e4b7ea5c781d40c483a88@BN1PR03MB188.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Now I'm developing Freescale PCIe power management feature. The following is my PCIe
suspend/resume code.

when I test system wake up from sleep(STANDBY), I got below calltrace. Looks like e1000e
cannot transfer data, maybe watchdog has some issue. Or maybe some of the other causes.
I think this is not root cause. Because If changed mdelay(10) to 20ms. E1000 will work normal.
Maybe e1000e need more time to recover? Or ?

Here are my test results:
E1000e plug in PCIe slot 1, we need to delay 10ms.
E1000e plug in PCIe slot 2, we need to delay 20ms.
E1000e plug in PCIe slot 3, we need to delay 60ms.

Anyone have any idea about this?


*Suspend flow*: 
if (fsl_pcie_check_link(hose))
		return;

/* Send PME_Turn_Off Message Request */
setbits32(&pci->pex_pmcr, PEX_PMCR_PTOMR);

/* Wait trun off done */
/* RC will get this detect quickly */
for (i = 0; i < 50; i++) {
	dr = in_be32(&pci->pex_pme_mes_dr);
	if (dr & ENL23_DETECT_BIT) {
			out_be32(&pci->pex_pme_mes_dr, dr);
			break;
	}

	udelay(1000);
}

/*
 * "PCI Bus Power Management Interface Specification" define
 * Minimum System Software Guaranteed Delays
 *
 * D0, D1 or D2 --> D3, need delay 10ms.
 * But we need to delay more time when EP plug in p1022 slot2.
 */
mdelay(10);


*Resume flow*:
if (fsl_pcie_check_link(hose))
		return;

/* Send Exit L2 State Message */
setbits32(&pci->pex_pmcr, PEX_PMCR_EXL2S);

/* Wait exit done */
/* RC will get this detect quickly */
for (i = 0; i < 50; i++) {
	dr = in_be32(&pci->pex_pme_mes_dr);
	if (dr & EXL23_DETECT_BIT) {
			out_be32(&pci->pex_pme_mes_dr, dr);
			break;
	}

	udelay(1000);
}

/*
 * "PCI Bus Power Management Interface Specification" define
 * Minimum System Software Guaranteed Delays
 *
 * D3 hot --> D0, need delay 10ms.
 * But we need to delay more time when EP plug in p1022 slot2.
 */
mdelay(10);

================================================================================
					CALL TRACE
================================================================================

[root@p1022 /root]# udhcpc -i eth0
udhcpc (v1.11.2) started
IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
Sending discover...
e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx/Tx
IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
Sending discover...
Sending discover...
NETDEV WATCHDOG: eth0 (e1000e): transmit queue 0 timed out
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:264
Modules linked in:
CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.14.0-173871-g9964256-dirty #42
task: ee0534e0 ti: ee070000 task.ti: ee070000
NIP: c036267c LR: c036267c CTR: c028b834
REGS: ee071d00 TRAP: 0700   Not tainted  (3.14.0-173871-g9964256-dirty)
MSR: 00029000 <CE,EE,ME>  CR: 42000022  XER: 20000000

GPR00: c036267c ee071db0 ee0534e0 0000003a c16393b0 c16398e8 01079000 c05c03a8
GPR08: 00000001 00000001 01079000 00000132 00000132 00000000 00000004 c05ed040
GPR16: 00000001 00000100 00000004 fffef539 00000000 c05c10c0 00000038 ffffffff
GPR24: 00000000 00000001 ee070000 00000004 c05e0000 c05f0000 ee3c0000 00000000
NIP [c036267c] dev_watchdog+0x2c8/0x2d8
LR [c036267c] dev_watchdog+0x2c8/0x2d8
Call Trace:
[ee071db0] [c036267c] dev_watchdog+0x2c8/0x2d8 (unreliable)
[ee071de0] [c004778c] call_timer_fn.isra.24+0x28/0x84
[ee071e00] [c00479b8] run_timer_softirq+0x1d0/0x248
[ee071e40] [c004090c] __do_softirq+0x104/0x20c
[ee071ea0] [c0040cd8] irq_exit+0xa4/0xc8
[ee071eb0] [c0009ef4] timer_interrupt+0xb8/0xdc
[ee071ed0] [c000f57c] ret_from_except+0x0/0x18
--- Exception: 901 at arch_cpu_idle+0x24/0x5c
    LR = arch_cpu_idle+0x24/0x5c
[ee071f90] [c0089534] rcu_idle_enter+0xa4/0xd0 (unreliable)
[ee071fa0] [c0076010] cpu_startup_entry+0x120/0x17c
[ee071fd0] [c0010bbc] start_secondary+0x214/0x224
[ee071ff0] [c0002154] __secondary_start+0x7c/0xc8
Instruction dump:
4e800421 80fe0224 4bffff4c 7fc3f378 4bfe5401 7fc4f378 7c651b78 3c60c055
7fe6fb78 3863e0f4 4cc63182 480e9a05 <0fe00000> 39200001 993c6f38 4bffffb4
---[ end trace 2d4f2cedfa86e32f ]---
e1000e 0002:05:00.0: Net device Info
e1000e: Device Name     state            trans_start      last_rx
e1000e: eth0            0000000000000003 00000000FFFEF040 0000000000000000
e1000e 0002:05:00.0: Register Dump
e1000e:  Register Name   Value
e1000e: CTRL            58100248
e1000e: STATUS          00080783
e1000e: CTRL_EXT        18580000
e1000e: ICR             00000000
e1000e: RCTL            04008002
e1000e: RDLEN           00001000
e1000e: RDH             0000001d
e1000e: RDT             000000f0
e1000e: RDTR            00000020
e1000e: RXDCTL[0-1]     01040420 01040420
e1000e: ERT             00000000
e1000e: RDBAL           2d390000
e1000e: RDBAH           00000000
e1000e: RDFH            0000020a
e1000e: RDFT            0000020a
e1000e: RDFHS           0000020a
e1000e: RDFTS           0000020a
e1000e: RDFPC           00000000
e1000e: TCTL            3103f0fa
e1000e: TDBAL           2e158000
e1000e: TDBAH           00000000
e1000e: TDLEN           00001000
e1000e: TDH             00000001
e1000e: TDT             00000001
e1000e: TIDV            00000008
e1000e: TXDCTL[0-1]     0141011f 0141011f
e1000e: TADV            00000020
e1000e: TARC[0-1]       04000403 00000403
e1000e: TDFH            00001000
e1000e: TDFT            00001012
e1000e: TDFHS           00001000
e1000e: TDFTS           00001000
e1000e: TDFPC           00000000
e1000e 0002:05:00.0: Tx Ring Summary
e1000e: Queue [NTU] [NTC] [bi(ntc)->dma  ] leng ntw timestamp
e1000e:      0     1     0 000000002C809802 005A   0 00000000FFFEF044
e1000e 0002:05:00.0: Rx Ring Summary
e1000e: Queue [NTU] [NTC]
e1000e:      0    FF     0
e1000e 0002:05:00.0 eth0: Reset adapter unexpectedly
