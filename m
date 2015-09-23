From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: Race with ip=dhcp bootparameter in ip_rcv_finish on am335x
Date: Wed, 23 Sep 2015 13:58:02 +0200
Message-ID: <20150923115757.GA23260@omega>
References: <20150923102953.GA8918@omega>
 <5602809D.2020500@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:34190 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753654AbbIWL6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 07:58:10 -0400
Received: by wicfx3 with SMTP id fx3so234573541wic.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 04:58:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5602809D.2020500@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 23, 2015 at 12:36:13PM +0200, Nikolay Aleksandrov wrote:
> On 09/23/2015 12:29 PM, Alexander Aring wrote:
> > Hi,
> > 
> > I am using am335x (beaglebone white) with "ip=dhcp" inside my
> > bootparameters. It seems there exists some race, rarely it boots fine
> > and often it crashed with following messages:
> > 
> > First (Without successful dhcp ip assign and is very rarely):
> > 
> > [    6.249083] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> > [    6.398943] .
> > [    7.400822] Unable to handle kernel paging request at virtual address 7402a8c8
> > [    7.408419] pgd = c0004000
> > [    7.411351] [7402a8c8] *pgd=00000000
> > [    7.415121] Internal error: Oops: 5 [#1] SMP ARM
> > [    7.419968] Modules linked in:
> > [    7.423197] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W       4.2.0-11195-ge81be90 #124
> > [    7.432118] Hardware name: Generic AM33XX (Flattened Device Tree)
> > [    7.438509] task: c0a996c8 ti: c0a92000 task.ti: c0a92000
> > [    7.444189] PC is at ip_route_input_noref+0x620/0xeb4
> > [    7.449491] LR is at trace_hardirqs_on_caller+0xb0/0x1e8
> <<<snip>>>
> > [    7.759169] [<c054b49c>] (ip_route_input_noref) from [<c0550668>] (ip_rcv_finish+0xd4/0x67c)
> <<<snip>>>
> > 
> > --------
> > 
> > I tried to bisect this issue without success, sometimes it's booting fine
> > and sometimes I got the above messages. Could anybody help me here to
> > fixing this issue?
> > 
> > - Alex
> 
> Hi Alex,
> This should be fixed by commit bde6f9ded1bd 
> ("net: Initialize table in fib result") in net-next.
> 

Ok, I think I have two issues with two different races the first one was
fixed by bde6f9ded1bd ("net: Initialize table in fib result"), but the
second one is still there:

[    8.615806] ------------[ cut here ]------------
[    8.620678] Kernel BUG at c016c3d0 [verbose debug info unavailable]
[    8.627229] Internal error: Oops - BUG: 0 [#1] SMP ARM
[    8.632611] Modules linked in:
[    8.635836] CPU: 0 PID: 766 Comm: kworker/0:1H Tainted: G        W       4.2.0-11248-gfbd0351 #140
[    8.645208] Hardware name: Generic AM33XX (Flattened Device Tree)
[    8.651616] Workqueue: rpciod xprt_autoclose
[    8.656091] task: ce3c52c0 ti: ce642000 task.ti: ce642000
[    8.661744] PC is at iput+0x1a8/0x1f0
[    8.665579] LR is at xprt_autoclose+0x2c/0x54
[    8.670136] pc : [<c016c3d0>]    lr : [<c066c884>]    psr: 20000113
[    8.670136] sp : ce643e80  ip : 00000000  fp : c0b56688
[    8.682133] r10: 00000001  r9 : ce643ec8  r8 : 00000000
[    8.687599] r7 : feff3000  r6 : ce615800  r5 : ce615bc0  r4 : ce615b54
[    8.694421] r3 : 00000060  r2 : 0000000f  r1 : 0f10e000  r0 : cdbed720
[    8.701254] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[    8.708718] Control: 10c5387d  Table: 80004019  DAC: 00000051
[    8.714732] Process kworker/0:1H (pid: 766, stack limit = 0xce642218)
[    8.721464] Stack: (0xce643e80 to 0xce644000)
[    8.726033] 3e80: c066f828 ce615b54 ce615bc0 ce615800 feff3000 00000000 ce643ec8 c066c884
[    8.734596] 3ea0: ce615b54 ce5ff440 cfb9e340 c0057928 00000001 00000000 c00578b4 cfb9e340
[    8.743152] 3ec0: c0057cc8 00000000 c137972c c0cc1960 00000000 c09979f4 cfb9e340 cfb9e340
[    8.751714] 3ee0: ce5ff458 cfb9e370 ce642000 00000008 c0b55ba0 ce5ff440 cfb9e340 c0057c54
[    8.760274] 3f00: ce659940 ce5ff440 c0057c18 00000000 ce659940 ce5ff440 c0057c18 00000000
[    8.768834] 3f20: 00000000 00000000 00000000 c005d918 c0b5697c 00000000 00000000 ce5ff440
[    8.777390] 3f40: 00000000 00000000 dead4ead ffffffff ffffffff c0b65d60 00000000 00000000
[    8.785951] 3f60: c0922088 ce643f64 ce643f64 00000000 00000000 dead4ead ffffffff ffffffff
[    8.794513] 3f80: c0b65d60 00000000 00000000 c0922088 ce643f90 ce643f90 ce643fac ce659940
[    8.803069] 3fa0: c005d844 00000000 00000000 c000f770 00000000 00000000 00000000 00000000
[    8.811628] 3fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[    8.820185] 3fe0: 00000000 00000000 00000000 00000000 00000013 00000000 8fdf6861 8fdf6c61
[    8.828741] [<c016c3d0>] (iput) from [<c066c884>] (xprt_autoclose+0x2c/0x54)
[    8.836133] [<c066c884>] (xprt_autoclose) from [<c0057928>] (process_one_work+0x19c/0x48c)
[    8.844784] [<c0057928>] (process_one_work) from [<c0057c54>] (worker_thread+0x3c/0x4a0)
[    8.853256] [<c0057c54>] (worker_thread) from [<c005d918>] (kthread+0xd4/0xf0)
[    8.860827] [<c005d918>] (kthread) from [<c000f770>] (ret_from_fork+0x14/0x24)
[    8.868387] Code: e59f0044 e59f1044 ebfb467a eaffffc1 (e7f001f2) 
[    8.874771] ---[ end trace 6c5e5808fb5c8423 ]---
[    8.880045] Unable to handle kernel paging request at virtual address ffffffd0
[    8.887603] pgd = c0004000
[    8.890438] [ffffffd0] *pgd=8fdf6861, *pte=00000000, *ppte=00000000
[    8.897034] Internal error: Oops: 37 [#2] SMP ARM
[    8.901950] Modules linked in:
[    8.905165] CPU: 0 PID: 766 Comm: kworker/0:1H Tainted: G      D W       4.2.0-11248-gfbd0351 #140
[    8.914530] Hardware name: Generic AM33XX (Flattened Device Tree)
[    8.920923] task: ce3c52c0 ti: ce642000 task.ti: ce642000
[    8.926576] PC is at kthread_data+0x4/0xc
[    8.930776] LR is at wq_worker_sleeping+0xc/0xd4
[    8.935609] pc : [<c005dff0>]    lr : [<c00589ec>]    psr: 20000193
[    8.935609] sp : ce643c18  ip : ce0b6e1c  fp : ce643c7c
[    8.947599] r10: 00000000  r9 : cfb9e640  r8 : ce3c568c
[    8.953059] r7 : c0a90640  r6 : cfb9e650  r5 : ce3c52c0  r4 : 00000000
[    8.959883] r3 : 00000000  r2 : 00000000  r1 : 00000000  r0 : ce3c52c0
[    8.966708] Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment none
[    8.974263] Control: 10c5387d  Table: 80004019  DAC: 00000051
[    8.980271] Process kworker/0:1H (pid: 766, stack limit = 0xce642218)
[    8.987000] Stack: (0xce643c18 to 0xce644000)
[    8.991563] 3c00:                                                       00000020 cfb9e640
[    9.000123] 3c20: ce3c52c0 c0767578 ce3c52c0 c003fd14 00000001 00000000 c004046c c0ad6460
[    9.008679] 3c40: c0b5697c c004046c ce2c31c4 c076792c ce390808 00000001 c0a8c400 ce642000
[    9.017237] 3c60: ce643954 ce643c98 ce3c55e8 00000000 00000001 c016c3d2 ce643c8c c076792c
[    9.025794] 3c80: 0420816c ce3c52c0 00000051 c0040554 c009b3f4 ce643cb4 ce643c98 ce643c98
[    9.034347] 3ca0: c0a9b228 c0b64244 c0a9b228 60000193 0000000b 00000001 c0a9b228 c016c3d2
[    9.042911] 3cc0: 00000051 c0013ca4 ce642218 0000000b c016c3d4 00000000 00000008 00000055
[    9.051470] 3ce0: 00000051 00000055 65000000 30663935 20343430 66393565 34343031 66626520
[    9.060030] 3d00: 37363462 61652061 66666666 28203163 30663765 32663130 c0002029 c016c3d0
[    9.068591] 3d20: ce643df0 00030001 e7f001f2 c016c3d0 ce643df0 00000000 c076d064 ce642000
[    9.077155] 3d40: c0b56688 c0009174 00000006 c13261e4 00000004 00000000 00030001 c016c3d0
[    9.085710] 3d60: c0cc0a80 c00136c0 c10b33c8 c000f770 00000000 00000000 00000000 ce643fb0
[    9.094274] 3d80: c000f770 c000f770 c10b33c8 c0eb2788 00000020 c0cc1960 c0cc0a80 ce3c5840
[    9.102834] 3da0: c1351adc c008fd70 985722ac 0000000a ce3c5818 ce3c57f0 00000001 ce3c5838
[    9.111390] 3dc0: 00000000 ce3c5820 ce3c5300 00000000 00000000 c016c3d4 00000000 c076d518
[    9.119949] 3de0: 00000000 e7100000 c076d064 c076d064 cdbed720 0f10e000 0000000f 00000060
[    9.128508] 3e00: ce615b54 ce615bc0 ce615800 feff3000 00000000 ce643ec8 00000001 c0b56688
[    9.137066] 3e20: 00000000 ce643e80 c066c884 c016c3d0 20000113 ffffffff 00000051 00000004
[    9.145618] 3e40: 00000006 ce643ec8 00000001 c008e0b8 c0042974 ce3c52c0 00000001 ce6619b4
[    9.154183] 3e60: 00000000 c008e21c 00000200 c066f764 cdbed700 c0042974 ce3c52c0 ce615800
[    9.162742] 3e80: c066f828 ce615b54 ce615bc0 ce615800 feff3000 00000000 ce643ec8 c066c884
[    9.171301] 3ea0: ce615b54 ce5ff440 cfb9e340 c0057928 00000001 00000000 c00578b4 cfb9e340
[    9.179856] 3ec0: c0057cc8 00000000 c137972c c0cc1960 00000000 c09979f4 cfb9e340 cfb9e340
[    9.188414] 3ee0: ce5ff458 cfb9e370 ce642000 00000008 c0b55ba0 ce5ff440 cfb9e340 c0057c54
[    9.196969] 3f00: ce659940 ce5ff440 c0057c18 00000000 ce659940 ce5ff440 c0057c18 00000000
[    9.205528] 3f20: 00000000 00000000 00000000 c005d918 c0b5697c 00000000 00000000 ce5ff440
[    9.214086] 3f40: 00000000 00000000 dead4ead ffffffff ffffffff c0b65d60 00000000 00000000
[    9.222642] 3f60: c0922088 ce643f64 ce643f64 00000001 00010001 dead4ead ffffffff ffffffff
[    9.231196] 3f80: c0b65d60 00000000 00000000 c0922088 ce643f90 ce643f90 ce643fac ce659940
[    9.239755] 3fa0: c005d844 00000000 00000000 c000f770 00000000 00000000 00000000 00000000
[    9.248316] 3fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[    9.256869] 3fe0: 00000000 00000000 00000000 00000000 00000013 00000000 8fdf6861 8fdf6c61
[    9.265435] [<c005dff0>] (kthread_data) from [<c00589ec>] (wq_worker_sleeping+0xc/0xd4)
[    9.273822] [<c00589ec>] (wq_worker_sleeping) from [<c0767578>] (__schedule+0x684/0x9f8)
[    9.282288] [<c0767578>] (__schedule) from [<c076792c>] (schedule+0x40/0x98)
[    9.289673] [<c076792c>] (schedule) from [<c0040554>] (do_exit+0x660/0x9bc)
[    9.296958] [<c0040554>] (do_exit) from [<c0013ca4>] (die+0x210/0x474)
[    9.303790] [<c0013ca4>] (die) from [<c0009174>] (do_undefinstr+0x15c/0x21c)
[    9.311177] [<c0009174>] (do_undefinstr) from [<c076d064>] (__und_svc_finish+0x0/0x3c)
[    9.319453] Exception stack(0xce643df0 to 0xce643e38)
[    9.324738] 3de0:                                     cdbed720 0f10e000 0000000f 00000060
[    9.333293] 3e00: ce615b54 ce615bc0 ce615800 feff3000 00000000 ce643ec8 00000001 c0b56688
[    9.341848] 3e20: 00000000 ce643e80 c066c884 c016c3d0 20000113 ffffffff
[    9.348771] [<c076d064>] (__und_svc_finish) from [<c016c3d0>] (iput+0x1a8/0x1f0)
[    9.356513] [<c016c3d0>] (iput) from [<c066c884>] (xprt_autoclose+0x2c/0x54)
[    9.363897] [<c066c884>] (xprt_autoclose) from [<c0057928>] (process_one_work+0x19c/0x48c)
[    9.372543] [<c0057928>] (process_one_work) from [<c0057c54>] (worker_thread+0x3c/0x4a0)
[    9.381005] [<c0057c54>] (worker_thread) from [<c005d918>] (kthread+0xd4/0xf0)
[    9.388565] [<c005d918>] (kthread) from [<c000f770>] (ret_from_fork+0x14/0x24)
[    9.396129] Code: e3a02002 eafffec7 c0774688 e5903380 (e5130030) 
[    9.402509] ---[ end trace 6c5e5808fb5c8424 ]---
[    9.407333] Fixing recursive fault but reboot is needed!

- Alex
