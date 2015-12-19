From: Sasha Levin <sasha.levin@oracle.com>
Subject: net, ipv6: out of bounds access in secret_stable
Date: Fri, 18 Dec 2015 20:13:31 -0500
Message-ID: <5674AF3B.6030903@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32921 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbbLSBNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 20:13:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,

I've hit the following out of bounds access while fuzzing on the latest -next kernel.

This code was added in 3d1bec9932 ("ipv6: introduce secret_stable to ipv6_devconf").

[  459.553655] BUG: KASAN: stack-out-of-bounds in strlen+0x58/0x90 at addr ffff8802ab0efb0e
[  459.554953] Read of size 1 by task trinity-c91/22576
[  459.555805] page:ffffea000aac3bc0 count:0 mapcount:0 mapping:          (null) index:0x0
[  459.556899] flags: 0x26fffff80000000()
[  459.557521] page dumped because: kasan: bad access detected
[  459.558320] CPU: 7 PID: 22576 Comm: trinity-c91 Not tainted 4.4.0-rc5-next-20151218-sasha-00021-gaba8d84-dirty #2750
[  459.559809]  0000000000000000 00000000549d0aa3 ffff8802ab0ef860 ffffffffa1042384
[  459.561036]  0000000041b58ab3 ffffffffac667cdb ffffffffa10422d9 ffff8802ab0ef848
[  459.562245]  ffffffff9f6a417e 00000000549d0aa3 ffff8802ab0efb0e ffff8802ab0efb0e
[  459.563429] Call Trace:
[  459.563831] dump_stack (lib/dump_stack.c:52)
[  459.564623] ? _atomic_dec_and_lock (lib/dump_stack.c:27)
[  459.565628] ? __dump_page (mm/debug.c:126)
[  459.566538] kasan_report_error (include/linux/kasan.h:28 mm/kasan/report.c:170 mm/kasan/report.c:237)
[  459.570997] __asan_report_load1_noabort (mm/kasan/report.c:277)
[  459.572119] ? check_preemption_disabled (lib/smp_processor_id.c:39)
[  459.573731] ? strlen (lib/string.c:481 (discriminator 1))
[  459.574646] strlen (lib/string.c:481 (discriminator 1))
[  459.575485] proc_dostring (kernel/sysctl.c:1825 kernel/sysctl.c:1906)
[  459.576445] ? alloc_debug_processing (mm/slub.c:1054)
[  459.577523] addrconf_sysctl_stable_secret (net/ipv6/addrconf.c:5395)
[  459.583431] proc_sys_call_handler (fs/proc/proc_sysctl.c:543)
[  459.587326] proc_sys_write (fs/proc/proc_sysctl.c:562)
[  459.588378] do_loop_readv_writev (fs/read_write.c:725)
[  459.589374] do_readv_writev (fs/read_write.c:853)
[  459.601113] vfs_writev (fs/read_write.c:891)
[  459.601895] ? __fdget_pos (fs/file.c:781)
[  459.602918] SyS_writev (fs/read_write.c:924 fs/read_write.c:915)
[  459.604122] ? SyS_readv (fs/read_write.c:915)
[  459.605163] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:186)
[  459.606131] Memory state around the buggy address:
[  459.607020]  ffff8802ab0efa00: 00 00 00 00 f1 f1 f1 f1 00 00 00 00 00 00 00 00
[  459.608442]  ffff8802ab0efa80: f2 f2 f2 f2 00 00 f4 f4 f2 f2 f2 f2 00 00 00 00
[  459.610252] >ffff8802ab0efb00: 00 06 f4 f4 f3 f3 f3 f3 00 00 00 00 00 00 00 00
[  459.612306]                       ^
[  459.613233]  ffff8802ab0efb80: 00 00 f1 f1 f1 f1 00 f4 f4 f4 f3 f3 f3 f3 00 00
[  459.615076]  ffff8802ab0efc00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00


Thanks,
Sasha
