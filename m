From: Sasha Levin <sasha.levin@oracle.com>
Subject: net: raw socket accessing invalid memory
Date: Fri, 23 Jan 2015 17:18:45 -0500
Message-ID: <54C2C8C5.7020300@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	yoshfuji@linux-ipv6.org, Patrick McHardy <kaber@trash.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Andrey Ryabinin <a.ryabinin@samsung.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43192 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbbAWWTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 17:19:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel and the KASan patchset, I've stumbled on the following spew:

[ 2560.693067] BUG: AddressSanitizer: out of bounds on stack in memcpy_fromiovec+0x24d/0x260 at addr ffff880200697dd0
[ 2560.693067] Read of size 8 by task trinity-c9/25362
[ 2560.693067] page:ffffea000801a5c0 count:0 mapcount:0 mapping:          (null) index:0x0
[ 2560.693067] flags: 0x1afffff80000000()
[ 2560.693067] page dumped because: kasan: bad access detected
[ 2560.693067] CPU: 9 PID: 25362 Comm: trinity-c9 Not tainted 3.19.0-rc5-next-20150121-sasha-00064-g3c37e35-dirty #1810
[ 2560.693067]  0000000000000000 0000000000000000 ffff880200697790 ffff8802006976d8
[ 2560.693067]  ffffffff92e9e8b7 1ffffd40010034bf ffffea000801a5c0 ffff880200697778
[ 2560.693067]  ffffffff81b4a7b2 ffffed00629442ba dffffc0000000000 ffffed00629442b8
[ 2560.693067] Call Trace:
[ 2560.693067] dump_stack (lib/dump_stack.c:52)
[ 2560.693067] kasan_report_error (mm/kasan/report.c:136 mm/kasan/report.c:194)
[ 2560.693067] __asan_report_load8_noabort (mm/kasan/report.c:236)
[ 2560.693067] memcpy_fromiovec (lib/iovec.c:14)
[ 2560.693067] raw_sendmsg (net/ipv4/raw.c:444 net/ipv4/raw.c:606)
[ 2560.693067] inet_sendmsg (net/ipv4/af_inet.c:734)
[ 2560.693067] ? inet_sendmsg (include/net/sock.h:875 net/ipv4/af_inet.c:726)
[ 2560.693067] do_sock_sendmsg (net/socket.c:645 (discriminator 4))
[ 2560.771124] SYSC_sendto (net/socket.c:1782)
[ 2560.794593] SyS_sendto (net/socket.c:1748)
[ 2560.794593] tracesys_phase2 (arch/x86/kernel/entry_64.S:530)
[ 2560.794593] Memory state around the buggy address:
[ 2560.794593]  ffff880200697c80: 00 f4 f4 f3 f3 f3 f3 00 00 00 00 00 00 00 00 00
[ 2560.794593]  ffff880200697d00: 00 00 00 f1 f1 f1 f1 04 f4 f4 f4 f2 f2 f2 f2 04
[ 2560.794593] >ffff880200697d80: f4 f4 f4 f2 f2 f2 f2 00 00 f4 f4 f2 f2 f2 f2 00
[ 2560.794593]                                                  ^
[ 2560.794593]  ffff880200697e00: 00 00 00 00 00 00 00 00 00 f4 f4 f2 f2 f2 f2 00
[ 2560.794593]  ffff880200697e80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 f3


Thanks,
Sasha
