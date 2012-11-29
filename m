From: Tommi Rantala <tt.rantala@gmail.com>
Subject: RDS: sendto() with very large buffer triggering WARNING: at mm/page_alloc.c:2403
Date: Thu, 29 Nov 2012 10:39:30 +0200
Message-ID: <CA+ydwtrVyun4LhMufd44ip4eXSwXp9Tw34+5yEdm3UdTVb9hQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dave Jones <davej@redhat.com>
To: netdev@vger.kernel.org,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	rds-devel@oss.oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:37937 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab2K2Ijc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 03:39:32 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so6234328eek.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 00:39:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Is RDS supposed to cap the sendto() buffer size? Saw the WARNING while
fuzzing with Trinity.

#include <string.h>
#include <arpa/inet.h>
#include <sys/socket.h>

static const char buf[1234000567];

int main(void)
{
        int fd;
        struct sockaddr_in sa;

        fd = socket(21 /* AF_RDS */, SOCK_SEQPACKET, 0);
        if (fd < 0)
                return 1;

        memset(&sa, 0, sizeof(sa));
        sa.sin_family = AF_INET;
        sa.sin_addr.s_addr = inet_addr("127.0.0.1");
        sa.sin_port = htons(11111);

        bind(fd, (struct sockaddr *)&sa, sizeof(sa));

        sendto(fd, buf, sizeof(buf), 0, (struct sockaddr *)&sa, sizeof(sa));

        return 0;
}

$ strace -e sendto ./rds-sendto
sendto(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
1234000567, 0, {sa_family=AF_INET, sin_port=htons(11111),
sin_addr=inet_addr("127.0.0.1")}, 16) = -1 ENOMEM (Cannot allocate
memory)

[ 7421.592595] ------------[ cut here ]------------
[ 7421.592621] WARNING: at mm/page_alloc.c:2403
__alloc_pages_nodemask+0x2c0/0x9f0()
[ 7421.592628] Hardware name: EB1012
[ 7421.592633] Modules linked in:
[ 7421.592645] Pid: 3082, comm: rds-sendto Not tainted 3.7.0-rc7+ #58
[ 7421.592650] Call Trace:
[ 7421.592667]  [<ffffffff810a197b>] warn_slowpath_common+0x7b/0xc0
[ 7421.592678]  [<ffffffff810a19d5>] warn_slowpath_null+0x15/0x20
[ 7421.592689]  [<ffffffff81171900>] __alloc_pages_nodemask+0x2c0/0x9f0
[ 7421.592700]  [<ffffffff81107c90>] ? __lock_acquire+0x3a0/0x9f0
[ 7421.592711]  [<ffffffff81107c90>] ? __lock_acquire+0x3a0/0x9f0
[ 7421.592724]  [<ffffffff811ac6bf>] alloc_pages_current+0x7f/0xf0
[ 7421.592735]  [<ffffffff8116cc19>] __get_free_pages+0x9/0x40
[ 7421.592746]  [<ffffffff811b3d8a>] kmalloc_order_trace+0x3a/0x190
[ 7421.592755]  [<ffffffff81107c90>] ? __lock_acquire+0x3a0/0x9f0
[ 7421.592765]  [<ffffffff811b4f59>] __kmalloc+0x229/0x240
[ 7421.592778]  [<ffffffff81d1b06e>] rds_message_alloc+0x1e/0xa0
[ 7421.592789]  [<ffffffff81d1db66>] rds_sendmsg+0x196/0x720
[ 7421.592802]  [<ffffffff81a72a80>] ? sock_update_classid+0xf0/0x2b0
[ 7421.592813]  [<ffffffff81a6abec>] sock_sendmsg+0xdc/0xf0
[ 7421.592828]  [<ffffffff8118e9e5>] ? might_fault+0x85/0x90
[ 7421.592838]  [<ffffffff8118e99c>] ? might_fault+0x3c/0x90
[ 7421.592848]  [<ffffffff81a6e0fa>] sys_sendto+0xfa/0x130
[ 7421.592859]  [<ffffffff8110953d>] ? trace_hardirqs_on_caller+0x10d/0x1a0
[ 7421.592868]  [<ffffffff811095dd>] ? trace_hardirqs_on+0xd/0x10
[ 7421.592881]  [<ffffffff81e94c9d>] ? _raw_spin_unlock_irq+0x3d/0x70
[ 7421.592892]  [<ffffffff810bab44>] ? ptrace_notify+0x74/0x90
[ 7421.592904]  [<ffffffff81e96250>] tracesys+0xdd/0xe2
[ 7421.592911] ---[ end trace d9d681d0d60abf69 ]---

Tommi
