From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next V2] igb: fix stats handling
Date: Mon, 11 Oct 2010 17:12:13 -0700
Message-ID: <AANLkTi=vf7s70zWmTJ65Mvxd5KV0RuiG+U5yCn7MeToB@mail.gmail.com>
References: <20101005141833.20929.10943.stgit@localhost>
	<1286289703.2796.292.camel@edumazet-laptop>
	<1286290393.7071.38.camel@firesoul.comx.local>
	<1286291947.2796.387.camel@edumazet-laptop>
	<1286312479.2593.35.camel@edumazet-laptop>
	<Pine.LNX.4.64.1010052313370.30765@ask.diku.dk>
	<AANLkTi=+rkietX9jAMy5BRVwAENf-mK15py7y+LYQ-XJ@mail.gmail.com>
	<1286335729.4861.13.camel@edumazet-laptop>
	<1286339791.4861.26.camel@edumazet-laptop>
	<EA929A9653AAE14F841771FB1DE5A1366027AC5DB5@rrsmsx501.amr.corp.intel.com>
	<1286698484.2692.205.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:58690 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754833Ab0JLAS4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 20:18:56 -0400
Received: by iwn7 with SMTP id 7so5789iwn.19
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 17:18:56 -0700 (PDT)
In-Reply-To: <1286698484.2692.205.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 10, 2010 at 01:14, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
> Le samedi 09 octobre 2010 =C3=A0 17:57 -0600, Tantilov, Emil S a =C3=A9=
crit :
>> Eric Dumazet wrote:
>> > Le mercredi 06 octobre 2010 =C3=A0 05:28 +0200, Eric Dumazet a =C3=
=A9crit :
>> >
>> >> I'll let Intel guys doing the backporting work, but for old kerne=
ls,
>> >> you'll probably need to use "unsigned long" instead of "u64"
>> >>
>> >> My plan is :
>> >>
>> >> - Provide 64bit counters even on 32bit arch
>> >> - with proper synchro (include/linux/u64_stats_sync.h)
>> >> - Add a spinlock so we can apply Jesper patch.
>> >
>> > Here is the net-next-2.6 patch, I am currently enable to test it, =
the
>> > dev machine with IGB NIC cannot be restarted until tomorrow, my so=
n
>> > Nicolas is currently using it ;)
>> >
>> > Could you and/or Jesper test it, possibly on 32 and 64 bit kernels=
 ?
>> >
>> > Thanks !
>> >
>> > [PATCH net-next] igb: fix stats handling
>> >
>> > There are currently some problems with igb.
>> >
>> > - On 32bit arches, maintaining 64bit counters without proper
>> > synchronization between writers and readers.
>> >
>> > - Stats updated every two seconds, as reported by Jesper.
>> > =C2=A0 =C2=A0(Jesper provided a patch for this)
>> >
>> > - Potential problem between worker thread and ethtool -S
>> >
>> > This patch uses u64_stats_sync, and convert everything to be 64bit
>> > safe,
>> > SMP safe, even on 32bit arches.
>> >
>> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> > ---
>> > =C2=A0drivers/net/igb/igb.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=
=A07 +-
>> > =C2=A0drivers/net/igb/igb_ethtool.c | =C2=A0 10 +-
>> > =C2=A0drivers/net/igb/igb_main.c =C2=A0 =C2=A0| =C2=A0111 ++++++++=
+++++++++++++++---------
>> > =C2=A03 files changed, 94 insertions(+), 34 deletions(-)
>>
>> This patch is causing a hang when testing with 2 sessions in a while=
 loop reading /proc/net/dev/ and ethtool -S. I think even just reading =
/proc/net/dev/ is sufficient, but have not confirmed it yet. I have see=
n the hang somewhere between 15 min to an hour. Without the patch same =
test ran 24+ hours without issues.
>>
>> There was no trace on the screen, I got this with magic sysrq:
>>
>> [15388.393579] SysRq : Show Regs
>> [15388.397341] Modules linked in: igb [last unloaded: scsi_wait_scan=
] [15388.404846]
>> [15388.406889] Pid: 16218, comm: kworker/4:1 Not tainted 2.6.36-rc3-=
net-next-igb-100810+ #2 S5520HC/S5520HC
>> [15388.418393] EIP: 0060:[<c13fead2>] EFLAGS: 00000297 CPU: 4
>> [15388.424908] EIP is at _raw_spin_lock+0x13/0x19
>> [15388.430257] EAX: f6eab55c EBX: f6eab380 ECX: 00000001 EDX: 00004e=
4a [15388.437629] ESI: f6eab000 EDI: f6eab41c EBP: f3d9bf4c ESP: f3d9bf=
4c [15388.445011] =C2=A0DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
>> [15388.451422] Process kworker/4:1 (pid: 16218, ti=3Df3d9a000 task=3D=
f5ce0ed0 task.ti=3Df3d9a000)
>> [15388.461173] Stack:
>> [15388.463796] =C2=A0f3d9bf64 f8586c57 f3d9bf5c f6eab41c f6901e00 c8=
703cc0 f3d9bf90 c1041379
>> [15388.473116] <0> 00000004 00000000 f8586b16 00000000 c8707b05 c870=
7b00 f6901e00 c8703cc4
>> [15388.483379] <0> c8703cc0 f3d9bfb8 c1042879 c16bb640 c8703cc4 0000=
0c54 c16bb640 f6901e10
>> [15388.494219] Call Trace:
>> [15388.497336] =C2=A0[<f8586c57>] ? igb_watchdog_task+0x141/0x21a [i=
gb]
>> [15388.504336] =C2=A0[<c1041379>] ? process_one_work+0x18e/0x265
>> [15388.510643] =C2=A0[<f8586b16>] ? igb_watchdog_task+0x0/0x21a [igb=
]
>> [15388.517455] =C2=A0[<c1042879>] ? worker_thread+0xf3/0x1ef
>> [15388.523384] =C2=A0[<c1042786>] ? worker_thread+0x0/0x1ef
>> [15388.529222] =C2=A0[<c104506b>] ? kthread+0x62/0x67
>> [15388.534475] =C2=A0[<c1045009>] ? kthread+0x0/0x67
>> [15388.539623] =C2=A0[<c1002d36>] ? kernel_thread_helper+0x6/0x10
>> [15388.546034] Code: 00 75 05 f0 66 0f b1 0a 0f 94 c1 0f b6 c1 85 c0=
 0f 95 c0 0f b6 c0 5d c3 55 ba 00 01 00 00 89 e5 f0 66 0f c1 10 38 f2 7=
4 06 f3 90 <8a> 10 eb f6 5d c3 55 89 e5 9c 59 fa ba 00 01 00 00 f0 66 0=
f c1
>>
>> Thanks,
>> Emil
>>
>
> Hi Emil, thanks for testing.
>
> It seems one one the u64_stats_sync invariant is not met.
>
> I believe problem comes from "restart_queue"
>
> This one can be updated in // by two cpus.
>
> So we can lose one of the u64_stats_update_begin() /
> u64_stats_update_end() increment and freeze a reader.
>
> So igb had a previous bug here, un-noticed :)
>
> restart_queue can be updated by start_xmit() (so only one cpu can be
> there, because of txqueue lock serialization), but it also can be
> updated by the igb_clean_tx_irq() function (one cpu there too).
>
> One solution to this problem is to use two separate counters, with tw=
o
> separate syncp.
>
> [PATCH net-next V2] igb: fix stats handling
>
> There are currently some problems with igb.
>
> - On 32bit arches, maintaining 64bit counters without proper
> synchronization between writers and readers.
>
> - Stats updated every two seconds, as reported by Jesper.
> =C2=A0 (Jesper provided a patch for this)
>
> - Potential problem between worker thread and ethtool -S
>
> This patch uses u64_stats_sync, and convert everything to be 64bit sa=
fe,
> SMP safe, even on 32bit arches. It integrates Jesper idea of providin=
g
> accurate stats at the time user reads them.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> V2: Add a second restart_queue field, with separate syncp, because
> original restart_queue was potentially udpated by two cpus.
> =C2=A0 Corrected igb_get_ethtool_stats() to also use appropriate sync=
p,
> =C2=A0 and do the sum of two restart_queue fields.
>
> =C2=A0drivers/net/igb/igb.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A0=
9 ++
> =C2=A0drivers/net/igb/igb_ethtool.c | =C2=A0 52 ++++++++++----
> =C2=A0drivers/net/igb/igb_main.c =C2=A0 =C2=A0| =C2=A0113 +++++++++++=
++++++++++++---------
> =C2=A03 files changed, 129 insertions(+), 45 deletions(-)
>

Thanks Eric, I have added the updated patch to my queue.

--=20
Cheers,
Jeff
