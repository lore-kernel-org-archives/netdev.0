From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Wed, 10 Mar 2010 15:32:53 -0800
Message-ID: <1268263973.9775.95.camel@nseg_linux_HP1.broadcom.com>
References: <20091229084929.54912c0c@pluto.restena.lu>
 <1262077540.12520.4.camel@localhost>
 <20091229145403.39f82773@pluto.restena.lu>
 <1262149691.2788.63.camel@localhost>
 <20100219091034.5fbb0165@pluto.restena.lu>
 <1266609426.2610.36.camel@dhcp-10-12-137-130.broadcom.com>
 <20100223131508.4c6cb866@neptune.home>
 <1267493170.2762.45.camel@dhcp-10-12-137-104.broadcom.com>
 <20100302081051.3d1b1c53@pluto.restena.lu>
 <20100302092020.52cfcd0e@pluto.restena.lu>
 <1267567926.19491.175.camel@nseg_linux_HP1.broadcom.com>
 <4B90189B.2040801@hp.com> <4B98268D.2020206@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Bruno =?ISO-8859-1?Q?Pr=E9mont?=" <bonbons@linux-vserver.org>,
	"Benjamin Li" <benli@broadcom.com>,
	NetDEV <netdev@vger.kernel.org>,
	Linux-Kernel <linux-kernel@vger.kernel.org>
To: "Brian Haley" <brian.haley@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B98268D.2020206@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2010-03-10 at 15:09 -0800, Brian Haley wrote:
> Brian Haley wrote:
> > Hi Michael,
> > 
> > Michael Chan wrote:
> >> Do we have timers running in this environment?  The timer in the bnx2
> >> driver, bnx2_timer(), needs to run to provide a heart beat to the
> >> firmware.  In netpoll mode without timer interrupts, if we are regularly
> >> calling the NAPI poll function, it should also be able to provide the
> >> heartbeat.  Without the heartbeat, the firmware will reset the chip and
> >> result in the NETDEV WATCHDOG.
> > 
> > We have also been seeing watchdog timeouts with bnx2, below is a
> > stack trace with Benjamin's debug patch applied.  Normally we were
> > only seeing them under heavy load, but this one was at boot.  We haven't
> > tried the latest firmware/driver from 2.6.33 yet.  You can contact me
> > offline if you need more detailed info.
> 
> Following-up since I have more info on this issue.
> 
> I'm able to cause a netdev_watchdog timeout by changing the coalesce
> settings on my bnx2, I built a little test program for it:

Do you run this program in a loop?  How quickly do you see the NETDEV
WATCHDOG?

> 
> #include <stdio.h>
> #include <stdlib.h>
> #include <strings.h>
> #include <unistd.h>
> #include <sys/types.h>
> #include <sys/socket.h>
> #include <netinet/in.h>
> #include <linux/if.h>
> #include <linux/ethtool.h>
> #include <linux/sockios.h>
> 
> main()
> {
> 	struct ifreq ifr;
> 	struct ethtool_coalesce ecoal;
> 	int fd, err;
> 	int sleeptime = 5;
> 	char *ifname = "eth0";
> 
> 	fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
> 	if (fd < 0) {
> 		perror("socket");
> 		exit(1);
> 	}
> 
> 	bzero(&ifr, sizeof(ifr));
> 	bcopy(ifname, ifr.ifr_name, sizeof(ifname));
> 
> 	bzero(&ecoal, sizeof(ecoal));
> 
> 	printf("Running ETHTOOL_GCOALESCE on %s\n", ifname);
> 	ecoal.cmd = ETHTOOL_GCOALESCE;
> 	ifr.ifr_data = (caddr_t)&ecoal;
> 	err = ioctl(fd, SIOCETHTOOL, &ifr);
> 	if (err)
> 		perror("ETHTOOL_GCOALESCE");
> 	printf("Sleeping %d seconds\n", sleeptime);
> 	sleep(sleeptime);
> 
> 	ecoal.rx_coalesce_usecs = 0;
> 	ecoal.rx_max_coalesced_frames = 1;
> 	ecoal.rx_coalesce_usecs_irq = 0;
> 	ecoal.rx_max_coalesced_frames_irq = 1;

These rx settings should be ok.  Did you change the tx settings?  If the
tx settings are all zeros, you won't get any TX interrupts and you can
get a NETDEV WATCHDOG.

Run ethtool -c eth0 to see what the tx settings are.  Thanks.

> 
> 	printf("Setting ETHTOOL_SCOALESCE on %s\n", ifname);
> 	ecoal.cmd = ETHTOOL_SCOALESCE;
> 	ifr.ifr_data = (caddr_t)&ecoal;
> 	err = ioctl(fd, SIOCETHTOOL, &ifr);
> 	if (err)
> 		perror("ETHTOOL_SCOALESCE");
> }
> 
> [    2.428093] bnx2 0000:04:00.0: firmware: requesting bnx2/bnx2-rv2p-06-5.0.0.j3.fw
> [    2.432526] eth0: Broadcom NetXtreme II BCM5708 1000Base-T (B2) PCI-X 64-bit 133MHz found at mem f6000000, IRQ 41, node addr 00:1c:c4:e1:cc:ea
> [    2.439520] bnx2 0000:42:00.0: PCI INT A -> GSI 34 (level, low) -> IRQ 34
> 
> lspci shows this is a HP 373i, it's the onboard NIC.
> 
> Running this on one particular system I get:
> 
> Mar 10 07:48:58 N1002563 kernel: [  870.780023] ------------[ cut here ]------------
> Mar 10 07:48:58 N1002563 kernel: [  870.780037] WARNING: at net/sched/sch_generic.c:261 dev_watchdog+0x12d/0x1d5()
> Mar 10 07:48:58 N1002563 kernel: [  870.780041] Hardware name: ProLiant DL385 G5 
> Mar 10 07:48:58 N1002563 kernel: [  870.780046] NETDEV WATCHDOG: eth0 (bnx2): transmit queue 0 timed out
> Mar 10 07:48:58 N1002563 kernel: [  870.780050] Modules linked in: mptctl ipmi_devintf deflate zlib_deflate ctr twofish twofish_common camellia serpent blowfish cast5 des_generic cbc cryptd aes_x86_64 aes_generic xcbc rmd160 sha256_generic sha1_generic crypto_null af_key sg bonding sctp crc32c libcrc32c loop psmouse serio_raw container amd64_edac_mod edac_core i2c_piix4 shpchp pci_hotplug ipmi_si i2c_core ipmi_msghandler hpilo processor evdev ext3 jbd mbcache sd_mod crc_t10dif usbhid hid ata_generic libata ide_pci_generic e1000e bnx2 mptsas mptscsih mptbase serverworks scsi_transport_sas ide_core ehci_hcd scsi_mod ohci_hcd uhci_hcd button thermal fan thermal_sys edd [last unloaded: scsi_wait_scan]
> Mar 10 07:48:58 N1002563 kernel: [  870.780133] Pid: 0, comm: swapper Not tainted 2.6.32-clim-4-amd64 #1
> Mar 10 07:48:58 N1002563 kernel: [  870.780137] Call Trace:
> Mar 10 07:48:58 N1002563 kernel: [  870.780141]  <IRQ>  [<ffffffff812697a0>] ? dev_watchdog+0x12d/0x1d5
> Mar 10 07:48:58 N1002563 kernel: [  870.780156]  [<ffffffff81049914>] warn_slowpath_common+0x77/0xa4
> Mar 10 07:48:58 N1002563 kernel: [  870.780170]  [<ffffffff810499b6>] warn_slowpath_fmt+0x64/0x66
> Mar 10 07:48:58 N1002563 kernel: [  870.780177]  [<ffffffff81045df7>] ? default_wake_function+0xd/0xf
> Mar 10 07:48:58 N1002563 kernel: [  870.780184]  [<ffffffff81035fa7>] ? __wake_up_common+0x46/0x76
> Mar 10 07:48:58 N1002563 kernel: [  870.780191]  [<ffffffff8103b414>] ? __wake_up+0x43/0x50
> Mar 10 07:48:58 N1002563 kernel: [  870.780198]  [<ffffffff81253829>] ? netdev_drivername+0x43/0x4b
> Mar 10 07:48:58 N1002563 kernel: [  870.780204]  [<ffffffff812697a0>] dev_watchdog+0x12d/0x1d5
> Mar 10 07:48:58 N1002563 kernel: [  870.780214]  [<ffffffff8105e84a>] ? delayed_work_timer_fn+0x0/0x3d
> Mar 10 07:48:58 N1002563 kernel: [  870.780219]  [<ffffffff8105e7ee>] ? __queue_work+0x35/0x3d
> Mar 10 07:48:58 N1002563 kernel: [  870.780227]  [<ffffffff81269673>] ? dev_watchdog+0x0/0x1d5
> Mar 10 07:48:58 N1002563 kernel: [  870.780234]  [<ffffffff8105655a>] run_timer_softirq+0x1ff/0x2a1
> Mar 10 07:48:58 N1002563 kernel: [  870.780242]  [<ffffffff810205a1>] ? lapic_next_event+0x18/0x1c
> Mar 10 07:48:58 N1002563 kernel: [  870.780249]  [<ffffffff8104f9e3>] __do_softirq+0xde/0x19f
> Mar 10 07:48:58 N1002563 kernel: [  870.780256]  [<ffffffff8100ccec>] call_softirq+0x1c/0x28
> Mar 10 07:48:58 N1002563 kernel: [  870.780262]  [<ffffffff8100e8b1>] do_softirq+0x41/0x81
> Mar 10 07:48:58 N1002563 kernel: [  870.780268]  [<ffffffff8104f7bd>] irq_exit+0x36/0x75
> Mar 10 07:48:58 N1002563 kernel: [  870.780274]  [<ffffffff81020f33>] smp_apic_timer_interrupt+0x88/0x96
> Mar 10 07:48:58 N1002563 kernel: [  870.780287]  [<ffffffff8100c6b3>] apic_timer_interrupt+0x13/0x20
> Mar 10 07:48:58 N1002563 kernel: [  870.780291]  <EOI>  [<ffffffff81027740>] ? native_safe_halt+0x6/0x8
> Mar 10 07:48:58 N1002563 kernel: [  870.780304]  [<ffffffff81012da3>] ? default_idle+0x55/0x74
> Mar 10 07:48:58 N1002563 kernel: [  870.780309]  [<ffffffff810131ce>] ? c1e_idle+0xf4/0xfb
> Mar 10 07:48:58 N1002563 kernel: [  870.780315]  [<ffffffff81065529>] ? atomic_notifier_call_chain+0x13/0x15
> Mar 10 07:48:58 N1002563 kernel: [  870.780321]  [<ffffffff8100aeec>] ? cpu_idle+0x5b/0x93
> Mar 10 07:48:58 N1002563 kernel: [  870.780329]  [<ffffffff81304144>] ? start_secondary+0x1a8/0x1ac
> Mar 10 07:48:58 N1002563 kernel: [  870.780334] ---[ end trace 08b420ca1e09a176 ]---
> Mar 10 07:48:58 N1002563 kernel: [  870.780339] bnx2: eth0 DEBUG: intr_sem[0]
> Mar 10 07:48:58 N1002563 kernel: [  870.780345] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
> Mar 10 07:48:58 N1002563 kernel: [  870.780352] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
> Mar 10 07:48:58 N1002563 kernel: [  870.780357] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
> Mar 10 07:49:03 N1002563 kernel: [  875.780020] bnx2: eth0 DEBUG: intr_sem[0]
> Mar 10 07:49:03 N1002563 kernel: [  875.780026] bnx2: eth0 DEBUG: EMAC_TX_STATUS[00000008] RPM_MGMT_PKT_CTRL[00000000]
> Mar 10 07:49:03 N1002563 kernel: [  875.780038] bnx2: eth0 DEBUG: MCP_STATE_P0[00000000] MCP_STATE_P1[00000000]
> Mar 10 07:49:03 N1002563 kernel: [  875.780043] bnx2: eth0 DEBUG: HC_STATS_INTERRUPT_STATUS[00000000]
> 
> This debug message would repeat every 5 seconds, eventually
> the systems locks-up.
> 
> This is running a 2.6.32-8 stable kernel, I've tried a version with Ben's
> patch from this thread installed with no change in behavior.  I'm in the
> process of backporting all the upstream changes to see if that helps.
> 
> Guessing it's a race condition caused by these calls in bnx2_set_coalesce():
> 
>         if (netif_running(bp->dev)) {
>                 bnx2_netif_stop(bp);
>                 bnx2_init_nic(bp, 0);
>                 bnx2_netif_start(bp);
>         }
> 
> Thanks for any help,
> 
> -Brian
> 
