From: Cong Wang <cwang@twopensource.com>
Subject: Re: net: heap-out-of-bounds in sock_setsockopt
Date: Wed, 16 Dec 2015 12:22:34 -0800
Message-ID: <CAHA+R7PCNuyW7RhbzxPJvnrX0NA1bxDXR8cL58STXrWkwMXXyA@mail.gmail.com>
References: <CACT4Y+Y5jtsfn4U8C-iBT4njrjXH+fFmvajuyhA-VpEchjLKFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemb@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Craig Gallek <kraig@google.com>,
	Ying Xue <ying.xue@windriver.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Edward Jee <edjee@google.com>,
	Julia Lawall <julia.lawall@lip6.fr>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:35094 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934143AbbLPUWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 15:22:35 -0500
Received: by mail-qk0-f180.google.com with SMTP id u65so64397900qkh.2
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 12:22:34 -0800 (PST)
In-Reply-To: <CACT4Y+Y5jtsfn4U8C-iBT4njrjXH+fFmvajuyhA-VpEchjLKFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2015 at 11:34 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> BUG: KASAN: slab-out-of-bounds in sock_setsockopt+0x1284/0x13d0 at
> addr ffff88006563ec10
> Read of size 4 by task syzkaller_execu/4755
> =============================================================================
> BUG RAWv6 (Not tainted): kasan: bad access detected
> -----------------------------------------------------------------------------
> INFO: Allocated in sk_prot_alloc+0x69/0x340 age=17 cpu=3 pid=4755
> [<      none      >] kmem_cache_alloc+0x244/0x2c0 mm/slub.c:2607
> [<      none      >] sk_prot_alloc+0x69/0x340 net/core/sock.c:1343
> [<      none      >] sk_alloc+0x3a/0x6b0 net/core/sock.c:1418
> [<      none      >] inet6_create+0x2c4/0xfd0 net/ipv6/af_inet6.c:170
> [<      none      >] __sock_create+0x37c/0x640 net/socket.c:1162
> [<     inline     >] sock_create net/socket.c:1202
> [<     inline     >] SYSC_socket net/socket.c:1232
> [<      none      >] SyS_socket+0xef/0x1b0 net/socket.c:1212
> [<      none      >] entry_SYSCALL_64_fastpath+0x16/0x7a
> arch/x86/entry/entry_64.S:185
>
> Call Trace:
>  [<ffffffff816cec2e>] __asan_report_load4_noabort+0x3e/0x40
> mm/kasan/report.c:294
>  [<ffffffff84affb14>] sock_setsockopt+0x1284/0x13d0 net/core/sock.c:880
>  [<     inline     >] SYSC_setsockopt net/socket.c:1746
>  [<ffffffff84aed7ee>] SyS_setsockopt+0x1fe/0x240 net/socket.c:1729
>  [<ffffffff85c18c76>] entry_SYSCALL_64_fastpath+0x16/0x7a
> arch/x86/entry/entry_64.S:185

Hmm, we should exclude the raw socket case, something like the
following, but I am not sure if the check is too strict or not, also
not sure if we should return an error for this raw socket case.

diff --git a/net/core/sock.c b/net/core/sock.c
index 765be83..c26e80a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -872,7 +872,7 @@ int sock_setsockopt(struct socket *sock, int
level, int optname,

                if (val & SOF_TIMESTAMPING_OPT_ID &&
                    !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)) {
-                       if (sk->sk_protocol == IPPROTO_TCP) {
+                       if (sk->sk_protocol == IPPROTO_TCP &&
sk->sk_type == SOCK_STREAM) {
                                if (sk->sk_state != TCP_ESTABLISHED) {
                                        ret = -EINVAL;
                                        break;
