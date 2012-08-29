From: Kelvie Wong <kelvie@ieee.org>
Subject: Intel 82574L hang when sending short ethernet packets
	at 100BaseT
Date: Wed, 29 Aug 2012 13:06:53 -0700
Message-ID: <87k3whtqci.fsf@kwong-desktop.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kelvie Wong <kwong@wurldtech.com>
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
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

Hello all,

We (at Wurldtech) have found a problem with the Intel 82574L controller
or possibly the e1000e driver whilst trying to send out invalid
ethernet frames. We do understand that the ethernet frames should be
padded anyway, and it is our experience that other network cards just
pad the ethernet frame with nulls rather than hang.

We have found this to be the case on the e1000e driver on kernel version
3.6-rc3, 3.0-rc4, as well as kernel 2.6.22-14 with the e1000e driver
from sourceforge versions 1.9.5 and 2.0.0.1.

Anyway, here is the reproduction tool:

char HELP[] = 
"\n"
"Intel 82574L Ethernet controllers reset when short eth frames are written\n"
"to them, and the Linux e1000e driver detects and restarts them, during\n"
"which time link goes down and packet loss occurs.\n"
"\n"
"Adding enough zero pad bytes to bring frame size up to 17 bytes causes\n"
"the reset to no longer occur. The frame addresses and ethtype seems\n"
"unrelated to the reset\n"
"\n"
"This is a reproduction utility. Similar effects can be seen on Windows, it\n"
"is not specific to the driver.\n"
"\n"
"When card resets, kernel messages are seen, like:\n"
"\n"
"e1000e 0000:02:00.0: eth1: Detected Hardware Unit Hang:\n"
"  ...\n"
"e1000e 0000:02:00.0: eth1: Reset adapter\n"
;

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <netinet/ether.h>
#include <netpacket/packet.h>
#include <sys/ioctl.h>
#include <sys/socket.h>

static int check(const char* call, int ret)
{
    if(ret < 0) {
        fprintf(stderr, "%s failed with [%d] %m\n", call, errno);
        exit(1);
    }
    return ret;
}

#define Check(X) check(#X, X)

int main(int argc, char* argv[])
{
    struct ether_header* eth;
    char* optdev = "eth0";
    int optcount = 4;
    int optlen = 14;
    /* valid eth macs, pulled from random cards */
    const char* optsrc = "00:a1:b0:00:00:f9";
    const char* optdst = "20:cf:30:b4:50:87";
    int opttype = 0;
    int opt;

    while(-1 != (opt = getopt(argc, argv, "i:c:l:s:d:t:"))) {
        switch(opt) {
            case 'i':
                optdev = optarg;
                break;
            case 'c':
                optcount = atoi(optarg);
                break;
            case 'l':
                optlen = atoi(optarg);
                break;
            case 's':
                optsrc = optarg;
                break;
            case 'd':
                optdst = optarg;
                break;
            case 't':
                opttype = strtol(optarg, NULL, 0);
                break;
            default:
                fprintf(stderr, "usage: %s -i ifx -c count -l len -s ethsrc -d ethdst -t ethtype\n%s", argv[0], HELP);
                return 1;
        }
    }

    eth = alloca(optlen > sizeof(*eth) ? optlen : sizeof(*eth));

    memset(eth, 0, optlen);

    memcpy(eth->ether_dhost, ether_aton(optdst), 6);
    memcpy(eth->ether_shost, ether_aton(optsrc), 6);
    eth->ether_type = htons(opttype);

    int fd = Check(socket(AF_PACKET,SOCK_RAW,0));

    struct ifreq ifreq;

    memset(&ifreq, 0, sizeof(ifreq));
    strcpy(ifreq.ifr_name,optdev);

    Check(ioctl(fd,SIOCGIFINDEX,&ifreq));

    struct sockaddr_ll ifaddr = {
        .sll_ifindex = ifreq.ifr_ifindex,
        .sll_family = AF_PACKET
    };

    Check(bind(fd, (struct sockaddr *)&ifaddr, sizeof(ifaddr)));

    printf("dev %s count %d len %d src %s dst %s ethtype %d\n",
            optdev, optcount, optlen, optsrc, optdst, opttype);

    for(; optcount > 0; optcount--) {
        Check(send(fd, eth, optlen, 0));
        /* TODO add a nanosleep() here? */
    }
    return 0;
}

The default settings should be sufficient, given:

1. eth0 is a 82574L
2. It is connected at 100Mbit

This only works (for whatever reason) when the link rate is set to
100BaseT; in my most recent tests, I used ethtool to set the card to not
advertise the Gigabit rate, if that matters.

The relevant dmesg is:

Aug 29 06:53:01 localmachine kernel: ------------[ cut here ]------------
Aug 29 06:53:01 localmachine kernel: WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x1e9/0x200()
Aug 29 06:53:01 localmachine kernel: Hardware name: MX945GSE
Aug 29 06:53:01 localmachine kernel: NETDEV WATCHDOG: eth1 (e1000e): transmit queue 0 timed out
Aug 29 06:53:01 localmachine kernel: ACPI: Invalid Power Resource to register!
Aug 29 06:53:01 localmachine kernel: Modules linked in: ipt_REJECT xt_state iptable_filter xt_dscp xt_string xt_multiport xt_hashlimit xt_mark xt_connmark ip_tables xt_conntrack nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 coretemp serio_raw rng_core
Aug 29 06:53:01 localmachine kernel: Pid: 3979, comm: python Not tainted 3.6.0-rc3 #1
Aug 29 06:53:01 localmachine kernel: Call Trace:
Aug 29 06:53:01 localmachine kernel:  [<c12f3709>] ? dev_watchdog+0x1e9/0x200
Aug 29 06:53:01 localmachine kernel:  [<c102fccc>] warn_slowpath_common+0x7c/0xa0
Aug 29 06:53:01 localmachine kernel:  [<c12f3709>] ? dev_watchdog+0x1e9/0x200
Aug 29 06:53:01 localmachine kernel:  [<c102fd6e>] warn_slowpath_fmt+0x2e/0x30
Aug 29 06:53:01 localmachine kernel:  [<c12f3709>] dev_watchdog+0x1e9/0x200
Aug 29 06:53:01 localmachine kernel:  [<c103b185>] run_timer_softirq+0x105/0x1c0
Aug 29 06:53:01 localmachine kernel:  [<c107c6ae>] ? rcu_process_callbacks+0x27e/0x420
Aug 29 06:53:01 localmachine kernel:  [<c12f3520>] ? dev_trans_start+0x50/0x50
Aug 29 06:53:01 localmachine kernel:  [<c1036bb7>] __do_softirq+0x87/0x130
Aug 29 06:53:01 localmachine kernel:  [<c1036b30>] ? _local_bh_enable+0x10/0x10
Aug 29 06:53:01 localmachine kernel:  <IRQ>  [<c1036ef2>] ? irq_exit+0x32/0x70
Aug 29 06:53:01 localmachine kernel:  [<c1021f79>] ? smp_apic_timer_interrupt+0x59/0x90
Aug 29 06:53:01 localmachine kernel:  [<c137102a>] ? apic_timer_interrupt+0x2a/0x30
Aug 29 06:53:01 localmachine kernel: ---[ end trace a6b1fdf47766ee1f ]---
Aug 29 06:53:01 localmachine kernel: e1000e 0000:02:00.0: eth1: Reset adapter
Aug 29 06:53:03 localmachine kernel: e1000e: eth1 NIC Link is Up 100 Mbps Full Duplex, Flow Control: Rx/Tx
Aug 29 06:53:03 localmachine kernel: e1000e 0000:02:00.0: eth1: 10/100 speed: disabling TSO

Relevant lspci -vv (8086:10d3 is the Intel 82574L Gigabit Ethernet
Controller; pciutils is out of date on this machine)

01:00.0 Class 0200: Device 8086:10d3
    Subsystem: Device 8086:0000
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 16
    Region 0: Memory at fe9e0000 (32-bit, non-prefetchable) [size=128K]
    Region 2: I/O ports at dc80 [size=32]
    Region 3: Memory at fe9dc000 (32-bit, non-prefetchable) [size=16K]
    Capabilities: [c8] Power Management version 2
        Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=1 PME-
    Capabilities: [d0] MSI: Mask- 64bit+ Count=1/1 Enable-
        Address: 0000000000000000  Data: 0000
    Capabilities: [e0] Express (v1) Endpoint, MSI 00
        DevCap:    MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
            ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
        DevCtl:    Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
            RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
            MaxPayload 128 bytes, MaxReadReq 512 bytes
        DevSta:    CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
        LnkCap:    Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <128ns, L1 <64us
            ClockPM- Surprise- LLActRep- BwNot-
        LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
    Capabilities: [a0] MSI-X: Enable- Mask- TabSize=3
        Vector table: BAR=3 offset=00000000
        PBA: BAR=3 offset=00002000
    Capabilities: [100] Advanced Error Reporting
        UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
        UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
        UESvrt:    DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
        CEMsk:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
        AERCap:    First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
    Kernel driver in use: e1000e

02:00.0 Class 0200: Device 8086:10d3
    Subsystem: Device 8086:0000
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 17
    Region 0: Memory at feae0000 (32-bit, non-prefetchable) [size=128K]
    Region 2: I/O ports at ec80 [size=32]
    Region 3: Memory at feadc000 (32-bit, non-prefetchable) [size=16K]
    Capabilities: [c8] Power Management version 2
        Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=1 PME-
    Capabilities: [d0] MSI: Mask- 64bit+ Count=1/1 Enable-
        Address: 0000000000000000  Data: 0000
    Capabilities: [e0] Express (v1) Endpoint, MSI 00
        DevCap:    MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
            ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
        DevCtl:    Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
            RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
            MaxPayload 128 bytes, MaxReadReq 512 bytes
        DevSta:    CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
        LnkCap:    Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <128ns, L1 <64us
            ClockPM- Surprise- LLActRep- BwNot-
        LnkCtl:    ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
    Capabilities: [a0] MSI-X: Enable- Mask- TabSize=3
        Vector table: BAR=3 offset=00000000
        PBA: BAR=3 offset=00002000
    Capabilities: [100] Advanced Error Reporting
        UESta:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
        UEMsk:    DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
        UESvrt:    DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
        CESta:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
        CEMsk:    RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
        AERCap:    First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
    Kernel driver in use: e1000e

And finally:

# ethtool -e eth1
Offset          Values
------          ------
0x0000          00 04 5f b0 9a e5 ff ff ff ff 30 00 ff ff ff ff 
0x0010          ff ff ff ff 6b 02 00 00 86 80 d3 10 ff ff d8 80 
0x0020          00 00 01 20 74 7e ff ff 00 00 c8 00 00 00 00 27 
0x0030          c9 6c 50 21 0e 07 03 45 84 2d 40 00 00 f0 07 06 
0x0040          00 60 80 00 04 0f ff 7f 01 4d ec 92 5c fc 83 f0 
0x0050          20 00 83 00 a0 00 1f 7d 61 19 83 01 50 00 ff ff 
0x0060          00 01 00 40 1c 12 07 40 ff ff ff ff ff ff ff ff 
0x0070          ff ff ff ff ff ff ff ff ff ff ff ff ff ff cf 5e

Thank you,
-- 
Kelvie Wong

P.S. I sent this from my personal email because my work email (Cc'd)
doesn't deal with mailing lists well.

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
