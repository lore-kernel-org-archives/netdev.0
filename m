From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [BUG] icmpv6fuzz creates bad paging request
Date: Fri, 2 Jan 2009 10:53:18 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0901021040050.6207@wrl-59.cs.helsinki.fi>
References: <20090101201304.GA6698@alice>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-339086101-1230885952=:6207"
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org
To: Eric Sesterhenn <snakebyte@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44939 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbZABIxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 03:53:21 -0500
In-Reply-To: <20090101201304.GA6698@alice>
Content-ID: <Pine.LNX.4.64.0901021046160.6207@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-339086101-1230885952=:6207
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0901021046161.6207@wrl-59.cs.helsinki.fi>

On Thu, 1 Jan 2009, Eric Sesterhenn wrote:

> Hi,
> 
> running "icmpv6fuzz -r 2187" gives me the following oops with current -git
> 
> 
> [ 4320.851654] BUG: unable to handle kernel paging request at c9527000
> [ 4320.851749] IP: [<c04e5668>] __copy_from_user_ll+0x8c/0xd8
> [ 4320.851898] *pde = 0001f067 *pte = 09527160 
> [ 4320.851977] Oops: 0002 [#1] PREEMPT DEBUG_PAGEALLOC
> [ 4320.852011] last sysfs file: /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/resource
> [ 4320.852011] Modules linked in:
> [ 4320.852011] 
> [ 4320.852011] Pid: 5065, comm: icmpv6fuzz Tainted: G        W  (2.6.28-04928-g6a94cb7 #152) System Name
> [ 4320.852011] EIP: 0060:[<c04e5668>] EFLAGS: 00010202 CPU: 0
> [ 4320.852011] EIP is at __copy_from_user_ll+0x8c/0xd8
> [ 4320.852011] EAX: 00000000 EBX: 4b17b3d7 ECX: 4b1782d7 EDX: 00000000
> [ 4320.852011] ESI: 097d5f24 EDI: c9526fc8 EBP: c9523da0 ESP: c9523d98
> [ 4320.852011]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
> [ 4320.852011] Process icmpv6fuzz (pid: 5065, ti=c9523000 task=cee15b00 task.ti=c9523000)
> [ 4320.852011] Stack:
> [ 4320.852011]  c9523ec8 097d2e24 c9523db4 c04e5907 00000000 c9523ec8 cee431fc c9523f1c
> [ 4320.852011]  c06fd4db 00000032 cee42f00 00000000 cee15b00 00000002 00000000 00000000
> [ 4320.852011]  c951ea64 cee15b00 00000002 00000000 00000000 c951ea64 cee15b00 00000246
> [ 4320.852011] Call Trace:
> [ 4320.852011]  [<c04e5907>] ? copy_from_user+0x36/0x59
> [ 4320.852011]  [<c06fd4db>] ? ipv6_setsockopt+0x4ed/0xb8e
> [ 4320.852011]  [<c017c674>] ? might_fault+0x42/0x7e
> [ 4320.852011]  [<c04e5b25>] ? copy_to_user+0x38/0x43
> [ 4320.852011]  [<c01421d1>] ? print_lock_contention_bug+0x11/0xb2
> [ 4320.852011]  [<c0143f37>] ? trace_hardirqs_on+0xb/0xd
> [ 4320.852011] Code: 1c 8b 46 20 8b 56 24 89 47 20 89 57 24 8b 46 28 8b 56 2c 89 47 28 89 57 2c 8b 46 30 8b 56 34 89 47 30 89 57 34 8b 46 38 8b 56 3c <89> 47 38 89 57 3c 83 c1 c0 83 c6 40 83 c7 40 83 f9 3f 77 88 89 
> [ 4320.852011] EIP: [<c04e5668>] __copy_from_user_ll+0x8c/0xd8 SS:ESP 0068:c9523d98
> [ 4320.852011] ---[ end trace 4eaa2a86a8e2da22 ]---

Can you try the patch below.

I wonder btw what's the correct policy wrt. those optval == NULL checks 
that's visible in the patch' context (IPV6_PKTINFO is the only one which
is doing that while many there fetch to sizeof(struct something)).

-- 
 i.

[PATCH] ipv6: IPV6_PKTINFO relied userspace providing correct length

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Reported-by: Eric Sesterhenn <snakebyte@gmx.de>
---
 net/ipv6/ipv6_sockglue.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 0069b7e..d31df0f 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -403,7 +403,7 @@ sticky_done:
 		else if (optlen < sizeof(struct in6_pktinfo) || optval == NULL)
 			goto e_inval;
 
-		if (copy_from_user(&pkt, optval, optlen)) {
+		if (copy_from_user(&pkt, optval, sizeof(struct in6_pktinfo))) {
 				retv = -EFAULT;
 				break;
 		}
-- 
1.5.2.2
---696208474-339086101-1230885952=:6207--
