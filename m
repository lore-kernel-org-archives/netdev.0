From: Srihari Vijayaraghavan <harisri@bigpond.com>
Subject: [PROBLEM] r8169 deadlocks
Date: Thu, 15 Jan 2004 20:38:59 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401152039.00182.harisri@bigpond.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

Hardware:
Athlon 64 3200+
Gigabyte K8VNXP
VIA K8T800
00:13.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 (rev 10)
        Subsystem: Giga-byte Technology: Unknown device e000
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (8000ns min, 16000ns max), cache line size 08
        Interrupt: pin A routed to IRQ 5
        Region 0: I/O ports at e800 [size=256]
        Region 1: Memory at e3005000 (32-bit, non-prefetchable) [size=256]
        Expansion ROM at <unassigned> [disabled] [size=64K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA 
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-

Software:
SuSE 9 for AMD64
2.6.1-mm3 kernel

Consider desktop as the computer with the RealTek r8169 card and laptop from 
where I perform these steps:
1. ssh desktop
2. while true; do ls -la /; done
3. In few seconds the desktop computer hangs
(And of course at the laptop computer the ssh session hangs)

Here is the sysrq-p from the desktop computer (captured using serial-console):
Pid: 1963, comm: ls Not tainted
RIP: 0010:[<ffffffffa008afd9>] 
<ffffffffa008afd9>{:r8169:rtl8169_tx_interrupt+73}
RSP: 0000:ffffffff80374dc8  EFLAGS: 00000286
RAX: 0000000000000420 RBX: ffffffff80374d18 RCX: 0000010000399000
RDX: ffffffff80370e80 RSI: 000000003525d05e RDI: 0000000080391bf0
RBP: ffffffff801100d9 R08: 0000000000000007 R09: 0000000000000000
R10: 0000002a95587de0 R11: 0000000000000003 R12: 0000000000000042
R13: 0000000000000001 R14: 00000000000000bc R15: 000001003f7d1340
FS:  00000000005144a0(005b) GS:ffffffff80370e80(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000002a957876d0 CR3: 0000000000101000 CR4: 00000000000006a0

Call Trace:<IRQ> <ffffffffa008b3c8>{:r8169:rtl8169_interrupt+120} 
<ffffffff8011222f>{handle_IRQ_event+47}
       <ffffffff801123b3>{do_IRQ+147} <ffffffff801100d9>{ret_from_intr+0}
        <EOI> <ffffffff80110152>{retint_careful+13}

And here is the sysrq-t:
                                                       sibling
  task                 PC          pid father child younger older
init          S ffffffff8014efa7     1      0     3               (NOTLB)
000001003ff8dd88 0000000000000002 ffffffff80311600 00000000000001f7
       ffffffff802c67e0 0000000000000000 000001003ff8b3e0 ffffffff802bb520
       00000000802c67e0 000000d000000010
Call Trace:<ffffffff8013a37e>{schedule_timeout+158} 
<ffffffff8013a2d0>{process_timeout+0}
       <ffffffff80172d3a>{pipe_poll+42} <ffffffff8017914a>{do_select+778}
       <ffffffff80178c80>{__pollwait+0} <ffffffff801795b0>{sys_select+992}
       <ffffffff8010fb60>{system_call+124}
events/0      R 000001003a4a1d48     3      1     4       5       (L-TLB)
000001000243de88 0000000000000046 ffffffff80311600 ffffffff80140870
       000000000000078a 000000693a4a1cd8 000001003ff8a2c0 000001003fd0d1e0
       000001003ffecd70 000001000243ded8
Call Trace:<ffffffff80140870>{__call_usermodehelper+0} 
<ffffffff80140c6c>{worker_thread+300}
       <ffffffff8012f340>{default_wake_function+0} 
<ffffffff8012f340>{default_wake_function+0}
       <ffffffff80140b40>{worker_thread+0} <ffffffff80140b40>{worker_thread+0}
       <ffffffff80143d86>{kthread+54} <ffffffff8011054b>{child_rip+8}
       <ffffffff80143d50>{kthread+0} <ffffffff80110543>{child_rip+0}

kblockd/0     S 0000000000000013     4      3             8       (L-TLB)
000001003fd3be88 0000000000000046 ffffffff80311600 0000000000000006
       0000000000000001 000000768020bc37 000001003ff89a30 000001003fd0d1e0
       000001003fd69870 000001003fd3bed8 
Call Trace:<ffffffff80140c6c>{worker_thread+300} 
<ffffffff8012f340>{default_wake_function+0}
       <ffffffff8012f340>{default_wake_function+0} 
<ffffffff80140b40>{worker_thread+0}
       <ffffffff80140b40>{worker_thread+0} <ffffffff80143d86>{kthread+54}
       <ffffffff8011054b>{child_rip+8} 
<ffffffff80143db0>{keventd_create_kthread+0}
       <ffffffff80143d50>{kthread+0} <ffffffff80110543>{child_rip+0} 

aio/0         S 000001003ff88948     8      3           199     4 (L-TLB)
000001003fd11e88 0000000000000046 ffffffff80311600 0000000000000003
       0000000000000000 0000007d00000000 000001003fd0f420 000001003ff88910 
       0000000000000000 0000000000000000
Call Trace:<ffffffff80140c6c>{worker_thread+300} 
<ffffffff8012f340>{default_wake_function+0}
       <ffffffff8012f340>{default_wake_function+0} 
<ffffffff80140b40>{worker_thread+0}
       <ffffffff80140b40>{worker_thread+0} <ffffffff80143d86>{kthread+54}
       <ffffffff8011054b>{child_rip+8} 
<ffffffff80143db0>{keventd_create_kthread+0}
       <ffffffff80143d50>{kthread+0} <ffffffff80110543>{child_rip+0}

pdflush       S 000000000003fff0     5      1             6     3 (L-TLB)
000001003fd19ee8 0000000000000046 ffffffff80311600 0000000000000000
       0000000000000000 0000007d00000000 000001003ff891a0 000001003ff88910
       0000000000000000 0000000000000000
Call Trace:<ffffffff8015091f>{__pdflush+159} <ffffffff80150a4c>{pdflush+12}
       <ffffffff8011054b>{child_rip+8} <ffffffff80150a40>{pdflush+0}
       <ffffffff80110543>{child_rip+0} 
pdflush       S 0000000000000000     6      1             7     5 (L-TLB)
000001003fd17ee8 0000000000000046 ffffffff80311600 0000000000000000
       0000000000000000 0000000000000000 000001003ff88910 ffffffff802bb520
       0000000000000000 0000000000000000
Call Trace:<ffffffff8015091f>{__pdflush+159} <ffffffff80150a4c>{pdflush+12} 
       <ffffffff8011054b>{child_rip+8} <ffffffff80150a40>{pdflush+0}
       <ffffffff80110543>{child_rip+0} 
kswapd0       S 000000000003fff0     7      1            10     6 (L-TLB)
000001003fd15da8 0000000000000046 ffffffff80311600 0000000000000000
       0000000000000000 0000007d00000000 000001003ff88080 000001003ff8b3e0 
       0000000000000000 0000000000000000
Call Trace:<ffffffff80155df5>{kswapd+277} 
<ffffffff801307a0>{autoremove_wake_function+0}
       <ffffffff801307a0>{autoremove_wake_function+0} 
<ffffffff8011054b>{child_rip+8} 
       <ffffffff80155ce0>{kswapd+0} <ffffffff80110543>{child_rip+0}
       
kjournald     S ffffffff8012f2a0    10      1           192     7 (L-TLB)
000001003fc17e68 0000000000000046 ffffffff80311600 0000010030748340 
       ffffffff802bb520 0000010030748280 000001003fd0c950 ffffffff802bb520 
       000001003fc9f298 000001003fc17eb8
Call Trace:<ffffffff801aef67>{kjournald+455} 
<ffffffff801307a0>{autoremove_wake_function+0}
       <ffffffff801307a0>{autoremove_wake_function+0} 
<ffffffff801aed80>{commit_timeout+0}
       <ffffffff8011054b>{child_rip+8} <ffffffff801aeda0>{kjournald+0} 
       <ffffffff80110543>{child_rip+0}
kjournald     S 0000000000000006   192      1           193    10 (L-TLB)
000001003e77be68 0000000000000046 ffffffff80311600 000001003fc9f078
       000001003e77be48 0000007d8012f388 000001003f6de340 000001003f6df460
       0000000000000000 0000000000000000 
Call Trace:<ffffffff801aef67>{kjournald+455} 
<ffffffff801307a0>{autoremove_wake_function+0}
       <ffffffff801307a0>{autoremove_wake_function+0} 
<ffffffff801aed80>{commit_timeout+0}
       <ffffffff8011054b>{child_rip+8} <ffffffff801aeda0>{kjournald+0}
       <ffffffff80110543>{child_rip+0} 
kjournald     S ffffffff8012f2a0   193      1           194   192 (L-TLB)
000001003e4a1e68 0000000000000046 ffffffff80311600 000001003e4a6e78 
       ffffffff802bb520 000000768012f388 000001003fd0eb90 ffffffff802bb520
       000001003e4a6e98 000001003e4a1eb8 
Call Trace:<ffffffff801aef67>{kjournald+455} 
<ffffffff801307a0>{autoremove_wake_function+0}
       <ffffffff801307a0>{autoremove_wake_function+0} 
<ffffffff801aed80>{commit_timeout+0}
       <ffffffff8011054b>{child_rip+8} <ffffffff801aeda0>{kjournald+0} 
       <ffffffff80110543>{child_rip+0}
kjournald     S ffffffff8012f2a0   194      1           195   193 (L-TLB)
000001003e51de68 0000000000000046 ffffffff80311600 000001003326ec40
       ffffffff802bb520 000000753326eb80 000001003f6ddab0 ffffffff802bb520 
       000001003e4a6c98 000001003e51deb8
Call Trace:<ffffffff801aef67>{kjournald+455} 
<ffffffff801307a0>{autoremove_wake_function+0}
       <ffffffff801307a0>{autoremove_wake_function+0} 
<ffffffff801aed80>{commit_timeout+0}
       <ffffffff8011054b>{child_rip+8} <ffffffff801aeda0>{kjournald+0} 
       <ffffffff80110543>{child_rip+0}
kjournald     S ffffffff8012f2a0   195      1           196   194 (L-TLB)
000001003e5f3e68 0000000000000046 ffffffff80311600 000001003e4a6a78
       ffffffff802bb520 000000738012f388 000001003f6debd0 ffffffff802bb520 
       000001003e4a6a98 000001003e5f3eb8
Call Trace:<ffffffff801aef67>{kjournald+455} 
<ffffffff801307a0>{autoremove_wake_function+0}
       <ffffffff801307a0>{autoremove_wake_function+0} 
<ffffffff801aed80>{commit_timeout+0}
       <ffffffff8011054b>{child_rip+8} <ffffffff801aeda0>{kjournald+0} 
       <ffffffff80110543>{child_rip+0}
kjournald     S ffffffff8012f2a0   196      1           200   195 (L-TLB)
000001003e4d5e68 0000000000000046 ffffffff80311600 0000010036f6b160
       ffffffff802bb520 0000007536f69fa0 000001003f6dc990 ffffffff802bb520 
       000001003e4a6898 000001003e4d5eb8
Call Trace:<ffffffff801aef67>{kjournald+455} 
<ffffffff801307a0>{autoremove_wake_function+0}
       <ffffffff801307a0>{autoremove_wake_function+0} 
<ffffffff801aed80>{commit_timeout+0}
       <ffffffff8011054b>{child_rip+8} <ffffffff801aeda0>{kjournald+0}
       <ffffffff80110543>{child_rip+0} 
reiserfs/0    S 0000000000000000   199      3                   8 (L-TLB)
000001003ee49e88 0000000000000046 ffffffff80311600 0000000000000206 
       0000000000000000 00000076a001f8bf 000001003f6dc100 0000010031492e10
       000001003fc8c570 000001003ee49ed8 
Call Trace:<ffffffff80140c6c>{worker_thread+300} 
<ffffffff8012f340>{default_wake_function+0}
       <ffffffff8012f340>{default_wake_function+0} 
<ffffffff80140b40>{worker_thread+0}
       <ffffffff80140b40>{worker_thread+0} <ffffffff80143d86>{kthread+54}
       <ffffffff8011054b>{child_rip+8} 
<ffffffff80143db0>{keventd_create_kthread+0}
       <ffffffff80143d50>{kthread+0} <ffffffff80110543>{child_rip+0}

kjournald     S ffffffff8012f2a0   200      1           240   196 (L-TLB)
000001003f09de68 0000000000000046 ffffffff80311600 000001003e4a6078 
       ffffffff802bb520 000000738012f388 000001003e4cf4a0 ffffffff802bb520
       000001003e4a6098 000001003f09deb8 
Call Trace:<ffffffff801aef67>{kjournald+455} 
<ffffffff801307a0>{autoremove_wake_function+0}
       <ffffffff801307a0>{autoremove_wake_function+0} 
<ffffffff801aed80>{commit_timeout+0}
       <ffffffff8011054b>{child_rip+8} <ffffffff801aeda0>{kjournald+0}
       <ffffffff80110543>{child_rip+0} 
scsi_eh_0     S 000001003f5a7dc0   240      1          1875   200 (L-TLB)
000001003f31fe48 0000000000000046 ffffffff80311600 0000000000000008 
       000001003f5e9ac0 0000007d801340a3 000001003e4ce380 000001003e4cec10
       000001003f31ff18 ffffffff80133d21 
Call Trace:<ffffffff80133d21>{reparent_to_init+481} 
<ffffffff8010ede6>{__down_interruptible+198}
       <ffffffff8012f340>{default_wake_function+0} 
<ffffffff801bbe81>{__down_failed_interruptible+53}
       <ffffffffa00531c4>{:scsi_mod:.text.lock.scsi_error+65}
       <ffffffff8011054b>{child_rip+8} 
<ffffffffa0052ea0>{:scsi_mod:scsi_error_handler+0}
       <ffffffff80110543>{child_rip+0} 
bash          S ffffffff80159b41  1875      1  1928    1895   240 (NOTLB)
00000100398ebeb8 0000000000000002 ffffffff80311600 00000100398ebf58 
       00000000005c7ac0 000000783e4cd260 000001003e4cd260 000001003f6df460
       000001003f6df460 ffffffff80131e39 
Call Trace:<ffffffff80131e39>{copy_process+2265} 
<ffffffff80135556>{sys_wait4+598}
       <ffffffff8012f340>{default_wake_function+0} 
<ffffffff8012f340>{default_wake_function+0}
       <ffffffff8010fb60>{system_call+124} 
sshd          S 0000000000000256  1895      1  1929          1875 (NOTLB)
0000010039915d88 0000000000000006 ffffffff80311600 0000000000000000 
       000001003fd0e300 000000758014f070 000001003fd0e300 000001003f6dd220
       0000000000000246 0000000000000000
Call Trace:<ffffffff8013a2fe>{schedule_timeout+30} 
<ffffffff802482e1>{tcp_poll+33} 
       <ffffffff8017914a>{do_select+778} <ffffffff80178c80>{__pollwait+0}
       <ffffffff801795b0>{sys_select+992} <ffffffff8010fb60>{system_call+124} 

slabdiff.py   S 0000000000000000  1928   1875                     (NOTLB)
000001003d78fd88 0000000000000006 ffffffff80311600 ffffffff801ec504
       000000000000000a 0000000000000202 000001003f6df460 ffffffff802bb520
       000000000000000a ffffffff801eee2d
Call Trace:<ffffffff801ec504>{lf+36} <ffffffff801eee2d>{do_con_write+1581}
       <ffffffff8013a37e>{schedule_timeout+158} 
<ffffffff8013a2d0>{process_timeout+0}
       <ffffffff8017914a>{do_select+778} <ffffffff801e3f07>{write_chan+551}
       <ffffffff80178c80>{__pollwait+0} <ffffffff801795b0>{sys_select+992}
       <ffffffff8010fb60>{system_call+124} 
sshd          S ffffffff8012f2a0  1929   1895  1932               (NOTLB)
000001003a4a1d88 0000000000000006 ffffffff80311600 00000000000001f7
       000001003fd0da70 0000007d00000000 000001003f6dd220 000001003fd0da70
       000000003a4a1ec0 000000d000000010 
Call Trace:<ffffffff8013a2fe>{schedule_timeout+30} 
<ffffffff801e4f0b>{pty_write_room+43}
       <ffffffff801e406c>{normal_poll+316} <ffffffff8017914a>{do_select+778} 
       <ffffffff80178c80>{__pollwait+0} <ffffffff801795b0>{sys_select+992}
       <ffffffff8010fb60>{system_call+124} 
bash          S ffffffff80159b41  1932   1929  1963               (NOTLB)
0000010036f1deb8 0000000000000002 ffffffff80311600 0000010036f1df58 
       00000000005b6018 0000007d3fd0d1e0 000001003fd0d1e0 000001003fd0da70
       000001003fd0da70 ffffffff80131e39 
Call Trace:<ffffffff80131e39>{copy_process+2265} 
<ffffffff8010fbe9>{sysret_signal+28}
       <ffffffff80135556>{sys_wait4+598} 
<ffffffff8012f340>{default_wake_function+0}
       <ffffffff8012f340>{default_wake_function+0} 
<ffffffff8010fb60>{system_call+124}

ls            R   current task    1963   1932                     (NOTLB)
000001003255df70 0000000000000006 ffffffff80311600 00000000000000a1
       000001003f6dd220 0000007500000000 000001003fd0da70 000001003f6dd220
       0000000000518200 000000000040c921
Call Trace:<ffffffff80110152>{retint_careful+13}

Please feel free to ask for more information. (please cc me in replies)

Thanks
Hari
harisri@bigpond.com
