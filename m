From: Alexander Aring <alex.aring@gmail.com>
Subject: Race with ip=dhcp bootparameter in ip_rcv_finish on am335x
Date: Wed, 23 Sep 2015 12:29:54 +0200
Message-ID: <20150923102953.GA8918@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37345 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753878AbbIWKaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 06:30:01 -0400
Received: by wicfx3 with SMTP id fx3so62288991wic.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 03:30:00 -0700 (PDT)
Received: from omega (p20030064A978CFB5E2CB4EFFFE1BB546.dip0.t-ipconnect.de. [2003:64:a978:cfb5:e2cb:4eff:fe1b:b546])
        by smtp.gmail.com with ESMTPSA id fs9sm7822344wic.24.2015.09.23.03.29.59
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 03:29:59 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am using am335x (beaglebone white) with "ip=dhcp" inside my
bootparameters. It seems there exists some race, rarely it boots fine
and often it crashed with following messages:

First (Without successful dhcp ip assign and is very rarely):

[    6.249083] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[    6.398943] .
[    7.400822] Unable to handle kernel paging request at virtual address 7402a8c8
[    7.408419] pgd = c0004000
[    7.411351] [7402a8c8] *pgd=00000000
[    7.415121] Internal error: Oops: 5 [#1] SMP ARM
[    7.419968] Modules linked in:
[    7.423197] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W       4.2.0-11195-ge81be90 #124
[    7.432118] Hardware name: Generic AM33XX (Flattened Device Tree)
[    7.438509] task: c0a996c8 ti: c0a92000 task.ti: c0a92000
[    7.444189] PC is at ip_route_input_noref+0x620/0xeb4
[    7.449491] LR is at trace_hardirqs_on_caller+0xb0/0x1e8
[    7.455055] pc : [<c054b49c>]    lr : [<c008e198>]    psr: 20000113
[    7.455055] sp : c0a93c70  ip : 0000000f  fp : ffffff8f
[    7.467072] r10: c0b35c80  r9 : 00000000  r8 : ce5f9400
[    7.472543] r7 : ce5ef000  r6 : 00000000  r5 : ce615640  r4 : ce5ffd40
[    7.479378] r3 : 7402a8c0  r2 : 00000001  r1 : c0549f74  r0 : ce5ffd40
[    7.486216] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[    7.493686] Control: 10c5387d  Table: 80004019  DAC: 00000051
[    7.499699] Process swapper/0 (pid: 0, stack limit = 0xc0a92218)
[    7.505989] Stack: (0xc0a93c70 to 0xc0a94000)
[    7.510561] 3c60:                                     00000000 00000000 c054afa4 00000000
[    7.519131] 3c80: 00000000 c0b56080 00000000 00000000 00000000 00070044 00000004 00000000
[    7.527705] 3ca0: 7402a8c0 0000012d 00000000 00000004 00000000 00000000 c0586298 00000000
[    7.536278] 3cc0: 00000000 00000000 0102a8c0 7402a8c0 cfba6c34 00000000 c0a996c8 ce615640
[    7.544852] 3ce0: c0551310 ce61b850 c07c6b10 c0b560b8 c0a95744 00000000 00000000 c0550668
[    7.553422] 3d00: ce5ef000 c0a5ed00 60000113 c0090d44 00000001 ce615640 c04f85d0 00000050
[    7.561996] 3d20: ce61b800 ce5ef000 c0a95744 00000000 00000000 c0551310 00000001 00000000
[    7.570563] 3d40: c04f85d0 ce000140 ce638100 00000050 ce61b800 cfba6b10 ce61b99a ce61b99a
[    7.579135] 3d60: c0a82730 c0a92000 ce61b850 c0a5ed94 00000100 0102a8c0 c0a996c8 c0a9791c
[    7.587709] 3d80: ce5ef000 ce5ef048 00000008 ce615640 ce5ef05c ce6156ec ce615640 c04f85d0
[    7.596289] 3da0: c0ad3f0c 00000000 c0a92000 ce5ef054 00000000 c04fb4e8 60000113 ce615640
[    7.604869] 3dc0: ce5ef05c 00000000 00000000 c04fb4e8 00000000 00000000 c0b5697c ce6381c0
[    7.613445] 3de0: 00000020 ce615640 c0b55f7e ce615640 ce5ef5c0 00000158 ce5f4550 ffff8db6
[    7.622027] 3e00: 00000100 c04fb534 00000000 00000000 c04fb4e8 ce5ef000 00000000 40000113
[    7.630603] 3e20: ce64f900 c04ed184 ce64f942 ce5ef000 ce5ef000 ce5ef000 ce6381c0 c041fec4
[    7.639172] 3e40: 00010000 d0978000 ce5f2c50 00010000 d0978000 ce5f2c70 00000158 c041d35c
[    7.647750] 3e60: 00000001 00000000 ce5f2c50 00000040 cfb9f0c0 c0a93eb0 00000040 c041d3d8
[    7.656322] 3e80: ce5ef5e8 ce5ef5e8 00000040 c0421f44 ce5ef5e8 00000001 0000012c c04fcd3c
[    7.664892] 3ea0: 60000193 0f10e000 cfb9f0c0 c0a910c0 c0a93eb0 c0a93eb0 c0a93eb8 c0a93eb8
[    7.673466] 3ec0: c0b5697c c0a9408c 00000000 00000008 00000003 c0b565c4 00000004 0000000c
[    7.682039] 3ee0: 00000100 c0042614 c0a996c8 ce199900 0000000a ffff8db5 00200000 00000001
[    7.690602] 3f00: 000000aa c0a8e828 00000000 c0a95744 00000000 00000001 ce017000 00000000
[    7.699170] 3f20: c077471c c0042b3c c0a8e828 c009bb5c c0a93f50 c0010218 20000113 ffffffff
[    7.707733] 3f40: c0a93f84 c0b56e14 00000000 c076cef8 00000001 00000001 00000000 c0a996c8
[    7.716309] 3f60: c0a92000 c0a94b2c 00000000 c0a94acc c0b56e14 00000000 00000000 c077471c
[    7.724881] 3f80: 00000000 c0a93fa0 c008e21c c0010218 20000113 ffffffff 00000051 c0010214
[    7.733453] 3fa0: 00000000 c0083cb4 c0a8c4e4 c0a8f8c8 c0b64000 c0a94a00 00000000 c0a19c1c
[    7.742025] 3fc0: ffffffff ffffffff 00000000 c0a1967c 00000000 c0a76a48 c0b64214 c0a94ab0
[    7.750588] 3fe0: c0a76a44 c0a9b258 80004059 413fc082 00000000 8000807c 00000000 00000000
[    7.759169] [<c054b49c>] (ip_route_input_noref) from [<c0550668>] (ip_rcv_finish+0xd4/0x67c)
[    7.768010] [<c0550668>] (ip_rcv_finish) from [<c0551310>] (ip_rcv+0x490/0x72c)
[    7.775672] [<c0551310>] (ip_rcv) from [<c04f85d0>] (__netif_receive_skb_core+0x240/0x97c)
[    7.784339] [<c04f85d0>] (__netif_receive_skb_core) from [<c04fb534>] (netif_receive_skb_internal+0x5c/0x1d8)
[    7.794742] [<c04fb534>] (netif_receive_skb_internal) from [<c041fec4>] (cpsw_rx_handler+0xac/0x1e8)
[    7.804318] [<c041fec4>] (cpsw_rx_handler) from [<c041d35c>] (__cpdma_chan_process+0xe8/0x128)
[    7.813346] [<c041d35c>] (__cpdma_chan_process) from [<c041d3d8>] (cpdma_chan_process+0x3c/0x5c)
[    7.822544] [<c041d3d8>] (cpdma_chan_process) from [<c0421f44>] (cpsw_rx_poll+0x14/0x94)
[    7.831024] [<c0421f44>] (cpsw_rx_poll) from [<c04fcd3c>] (net_rx_action+0x1dc/0x33c)
[    7.839232] [<c04fcd3c>] (net_rx_action) from [<c0042614>] (__do_softirq+0x138/0x340)
[    7.847432] [<c0042614>] (__do_softirq) from [<c0042b3c>] (irq_exit+0xbc/0x130)
[    7.855103] [<c0042b3c>] (irq_exit) from [<c009bb5c>] (__handle_domain_irq+0x6c/0xe0)
[    7.863324] [<c009bb5c>] (__handle_domain_irq) from [<c076cef8>] (__irq_svc+0x58/0x78)
[    7.871639] [<c076cef8>] (__irq_svc) from [<c0010218>] (arch_cpu_idle+0x20/0x3c)
[    7.879392] [<c0010218>] (arch_cpu_idle) from [<c0083cb4>] (cpu_startup_entry+0x274/0x2fc)
[    7.888063] [<c0083cb4>] (cpu_startup_entry) from [<c0a19c1c>] (start_kernel+0x35c/0x3d0)
[    7.896632] [<c0a19c1c>] (start_kernel) from [<8000807c>] (0x8000807c)
[    7.903470] Code: e3530000 e3a02001 e5c4205e e584102c (15933008)
[    7.909931] ---[ end trace 4db905a3f2d0c634 ]---
[    7.914774] Kernel panic - not syncing: Fatal exception in interrupt
[    7.921437] ---[ end Kernel panic - not syncing: Fatal exception in interrupt


Second (With successful ip assign from dhcp, happens often):

[    8.448158] task: ce58c540 ti: ce672000 task.ti: ce672000
[    8.453822] PC is at iput+0x1a8/0x1f0
[    8.457660] LR is at xprt_autoclose+0x2c/0x54
[    8.462227] pc : [<c016c3d0>]    lr : [<c066cc78>]    psr: 20000113
[    8.462227] sp : ce673e80  ip : 00000000  fp : c0b56688
[    8.474251] r10: 00000001  r9 : ce673ec8  r8 : 00000000
[    8.479720] r7 : feff3100  r6 : ce624800  r5 : ce624bc0  r4 : ce624b54
[    8.486548] r3 : 00000060  r2 : 0000000f  r1 : 0f10e000  r0 : cdbed720
[    8.493383] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[    8.500854] Control: 10c5387d  Table: 80004019  DAC: 00000051
[    8.506872] Process kworker/0:1H (pid: 768, stack limit = 0xce672218)
[    8.513619] Stack: (0xce673e80 to 0xce674000)
[    8.518195] 3e80: c066fc1c ce624b54 ce624bc0 ce624800 feff3100 00000000 ce673ec8 c066cc78
[    8.526766] 3ea0: ce624b54 ce60f1c0 cfb9e340 c0057928 00000001 00000000 c00578b4 cfb9e340
[    8.535336] 3ec0: c0057cc8 00000000 c137972c c0cc1960 00000000 c0997af8 cfb9e340 cfb9e340
[    8.543904] 3ee0: ce60f1d8 cfb9e370 ce672000 00000008 c0b55ba0 ce60f1c0 cfb9e340 c0057c54
[    8.552476] 3f00: ce654880 ce60f1c0 c0057c18 00000000 ce654880 ce60f1c0 c0057c18 00000000
[    8.561042] 3f20: 00000000 00000000 00000000 c005d918 c0b5697c 00000000 00000000 ce60f1c0
[    8.569613] 3f40: 00000000 00000000 dead4ead ffffffff ffffffff c0b65d60 00000000 00000000
[    8.578184] 3f60: c09220a8 ce673f64 ce673f64 00000000 00000000 dead4ead ffffffff ffffffff
[    8.586762] 3f80: c0b65d60 00000000 00000000 c09220a8 ce673f90 ce673f90 ce673fac ce654880
[    8.595340] 3fa0: c005d844 00000000 00000000 c000f770 00000000 00000000 00000000 00000000
[    8.603913] 3fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[    8.612489] 3fe0: 00000000 00000000 00000000 00000000 00000013 00000000 00000000 00000000
[    8.621059] [<c016c3d0>] (iput) from [<c066cc78>] (xprt_autoclose+0x2c/0x54)
[    8.628460] [<c066cc78>] (xprt_autoclose) from [<c0057928>] (process_one_work+0x19c/0x48c)
[    8.637118] [<c0057928>] (process_one_work) from [<c0057c54>] (worker_thread+0x3c/0x4a0)
[    8.645603] [<c0057c54>] (worker_thread) from [<c005d918>] (kthread+0xd4/0xf0)
[    8.653186] [<c005d918>] (kthread) from [<c000f770>] (ret_from_fork+0x14/0x24)
[    8.660755] Code: e59f0044 e59f1044 ebfb467a eaffffc1 (e7f001f2)
[    8.667150] ---[ end trace ea119a84b2295a26 ]---
[    8.672727] Unable to handle kernel paging request at virtual address ffffffd0
[    8.680317] pgd = c0004000 
[    8.683156] [ffffffd0] *pgd=8fdf6861, *pte=00000000, *ppte=00000000
[    8.689763] Internal error: Oops: 37 [#2] SMP ARM
[    8.694694] Modules linked in:
[    8.697915] CPU: 0 PID: 768 Comm: kworker/0:1H Tainted: G      D W       4.2.0-11404-g227b9e8 #137
[    8.707289] Hardware name: Generic AM33XX (Flattened Device Tree)
[    8.713689] task: ce58c540 ti: ce672000 task.ti: ce672000
[    8.719351] PC is at kthread_data+0x4/0xc             
[    8.723560] LR is at wq_worker_sleeping+0xc/0xd4
[    8.728397] pc : [<c005dff0>]    lr : [<c00589ec>]    psr: 20000193
[    8.728397] sp : ce673c18  ip : ce09ed9c  fp : ce673c7c
[    8.740412] r10: 00000000  r9 : cfb9e640  r8 : ce58c90c
[    8.745880] r7 : c0a90640  r6 : cfb9e650  r5 : ce58c540  r4 : 00000000
[    8.752712] r3 : 00000000  r2 : 00000000  r1 : 00000000  r0 : ce58c540
[    8.759543] Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment none
[    8.767105] Control: 10c5387d  Table: 80004019  DAC: 00000051
[    8.773123] Process kworker/0:1H (pid: 768, stack limit = 0xce672218)
[    8.779862] Stack: (0xce673c18 to 0xce674000)
[    8.784429] 3c00:                                                       00000020 cfb9e640
[    8.793009] 3c20: ce58c540 c07679c0 ce58c540 c003fd14 00000001 00000000 c004046c c0ad6460
[    8.801578] 3c40: c0b5697c c004046c ce297184 c0767d74 ce288dc8 00000001 c0a8c400 ce672000
[    8.810146] 3c60: ce673954 ce673c98 ce58c868 00000000 00000001 c016c3d2 ce673c8c c0767d74
[    8.818716] 3c80: 0420816c ce58c540 00000051 c0040554 c009b3f4 ce673cb4 ce673c98 ce673c98
[    8.827288] 3ca0: c0a9b228 c0b64244 c0a9b228 60000193 0000000b 00000001 c0a9b228 c016c3d2
[    8.835857] 3cc0: 00000051 c0013ca4 ce672218 0000000b c016c3d4 00000000 00000008 00000055
[    8.844423] 3ce0: 00000051 00000055 65000000 30663935 20343430 66393565 34343031 66626520
[    8.852995] 3d00: 37363462 61652061 66666666 28203163 30663765 32663130 c0002029 c016c3d0
[    8.861565] 3d20: ce673df0 00030001 e7f001f2 c016c3d0 ce673df0 00000000 c076d4a4 ce672000
[    8.870128] 3d40: c0b56688 c0009174 00000006 c13261e4 00000004 00000000 00030001 c016c3d0
[    8.878700] 3d60: c0cc0970 c00136c0 c10b33c8 c000f770 00000000 00000000 00000000 ce673fb0
[    8.887272] 3d80: c000f770 c000f770 c10b33c8 c0eb2788 00000020 c0cc1960 c0cc0970 ce58cac0
[    8.895839] 3da0: c1351adc c008fd70 945722ab 0000000a ce58ca98 ce58ca70 00000001 ce58cab8
[    8.904403] 3dc0: 00000000 ce58caa0 ce58c580 00000000 00000000 c016c3d4 00000000 c076d958
[    8.912978] 3de0: 00000000 e7100000 c076d4a4 c076d4a4 cdbed720 0f10e000 0000000f 00000060
[    8.921541] 3e00: ce624b54 ce624bc0 ce624800 feff3100 00000000 ce673ec8 00000001 c0b56688
[    8.930105] 3e20: 00000000 ce673e80 c066cc78 c016c3d0 20000113 ffffffff 00000051 00000004
[    8.938675] 3e40: 00000006 ce673ec8 00000001 c008e0b8 c0042974 ce58c540 00000001 ce6129b4
[    8.947250] 3e60: 00000000 c008e21c 00000200 c066fb58 cdbed700 c0042974 ce58c540 ce624800
[    8.955822] 3e80: c066fc1c ce624b54 ce624bc0 ce624800 feff3100 00000000 ce673ec8 c066cc78
[    8.964397] 3ea0: ce624b54 ce60f1c0 cfb9e340 c0057928 00000001 00000000 c00578b4 cfb9e340
[    8.972965] 3ec0: c0057cc8 00000000 c137972c c0cc1960 00000000 c0997af8 cfb9e340 cfb9e340
[    8.981536] 3ee0: ce60f1d8 cfb9e370 ce672000 00000008 c0b55ba0 ce60f1c0 cfb9e340 c0057c54
[    8.990104] 3f00: ce654880 ce60f1c0 c0057c18 00000000 ce654880 ce60f1c0 c0057c18 00000000
[    8.998677] 3f20: 00000000 00000000 00000000 c005d918 c0b5697c 00000000 00000000 ce60f1c0
[    9.007243] 3f40: 00000000 00000000 dead4ead ffffffff ffffffff c0b65d60 00000000 00000000
[    9.015816] 3f60: c09220a8 ce673f64 ce673f64 00000001 00010001 dead4ead ffffffff ffffffff
[    9.024387] 3f80: c0b65d60 00000000 00000000 c09220a8 ce673f90 ce673f90 ce673fac ce654880
[    9.032958] 3fa0: c005d844 00000000 00000000 c000f770 00000000 00000000 00000000 00000000
[    9.041522] 3fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[    9.050089] 3fe0: 00000000 00000000 00000000 00000000 00000013 00000000 00000000 00000000
[    9.058673] [<c005dff0>] (kthread_data) from [<c00589ec>] (wq_worker_sleeping+0xc/0xd4)
[    9.067071] [<c00589ec>] (wq_worker_sleeping) from [<c07679c0>] (__schedule+0x684/0x9f8)
[    9.075548] [<c07679c0>] (__schedule) from [<c0767d74>] (schedule+0x40/0x98)
[    9.082940] [<c0767d74>] (schedule) from [<c0040554>] (do_exit+0x660/0x9bc)
[    9.090235] [<c0040554>] (do_exit) from [<c0013ca4>] (die+0x210/0x474)
[    9.097075] [<c0013ca4>] (die) from [<c0009174>] (do_undefinstr+0x15c/0x21c)
[    9.104475] [<c0009174>] (do_undefinstr) from [<c076d4a4>] (__und_svc_finish+0x0/0x3c)
[    9.112770] Exception stack(0xce673df0 to 0xce673e38)
[    9.118061] 3de0:                                     cdbed720 0f10e000 0000000f 00000060
[    9.126633] 3e00: ce624b54 ce624bc0 ce624800 feff3100 00000000 ce673ec8 00000001 c0b56688
[    9.135199] 3e20: 00000000 ce673e80 c066cc78 c016c3d0 20000113 ffffffff
[    9.142136] [<c076d4a4>] (__und_svc_finish) from [<c016c3d0>] (iput+0x1a8/0x1f0)
[    9.149906] [<c016c3d0>] (iput) from [<c066cc78>] (xprt_autoclose+0x2c/0x54)
[    9.157301] [<c066cc78>] (xprt_autoclose) from [<c0057928>] (process_one_work+0x19c/0x48c)
[    9.165967] [<c0057928>] (process_one_work) from [<c0057c54>] (worker_thread+0x3c/0x4a0)
[    9.174450] [<c0057c54>] (worker_thread) from [<c005d918>] (kthread+0xd4/0xf0)
[    9.182025] [<c005d918>] (kthread) from [<c000f770>] (ret_from_fork+0x14/0x24)
[    9.189593] Code: e3a02002 eafffec7 c0774688 e5903380 (e5130030) 
[    9.195979] ---[ end trace ea119a84b2295a27 ]---
[    9.200814] Fixing recursive fault but reboot is needed!

--------

I tried to bisect this issue without success, sometimes it's booting fine
and sometimes I got the above messages. Could anybody help me here to
fixing this issue?

- Alex
