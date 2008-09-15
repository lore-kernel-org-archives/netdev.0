From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 11572] New: udp: unbalanced unlock bug in
 udp_queue_rcv_skb with ipsec
Date: Mon, 15 Sep 2008 07:40:29 -0700
Message-ID: <20080915074029.022ad48c@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44986 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753463AbYIOOku (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2008 10:40:50 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 620F74F475E
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 07:40:47 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id rnOjwphWoTGQ for <netdev@vger.kernel.org>;
	Mon, 15 Sep 2008 07:40:45 -0700 (PDT)
Received: from extreme (pool-71-245-98-107.ptldor.fios.verizon.net [71.245.98.107])
	by mail.vyatta.com (Postfix) with ESMTP id 06B594F475B
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 07:40:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 15 Sep 2008 07:04:23 -0700 (PDT)
From: bugme-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 11572] New: udp: unbalanced unlock bug in udp_queue_rcv_skb with ipsec


http://bugzilla.kernel.org/show_bug.cgi?id=11572

           Summary: udp: unbalanced unlock bug in udp_queue_rcv_skb with
                    ipsec
           Product: Networking
           Version: 2.5
     KernelVersion: 2.6.26.4
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: thomas.jarosch@intra2net.com
                CC: herbert@gondor.apana.org.au


Hello together,

after upgrading our production firewall to kernel 2.6.26.4, it freezed numerous
times out of the blue. First problem was isolated and now fixed in bug #11142,
but the box still freezed every two days. Yesterday night it crashed during
setup of ipsec connections, so I've built a test box setting up over 25 ipsec
connections to invalid peers. This will issue the following backtrace:

====================================
[ BUG: bad unlock balance detected! ]
-------------------------------------
pluto/2943 is trying to release lock (slock-AF_INET) at:
[<c02b660f>] udp_queue_rcv_skb+0xa3/0x210
but there are no more locks to release!

other info that might help us debug this:
no locks held by pluto/2943.

stack backtrace:
Pid: 2943, comm: pluto Not tainted 2.6.26-2.i2nsmp #2
 [<c013ebb9>] print_unlock_inbalance_bug+0xd7/0xe1
 [<c02c73a5>] ? xfrm_sk_policy_lookup+0x44/0x4b
 [<c02c7d7b>] ? __xfrm_policy_check+0x19b/0x4a2
 [<c02b660f>] ? udp_queue_rcv_skb+0xa3/0x210
 [<c013ed95>] lock_release+0xad/0x15c
 [<c02e1056>] _spin_unlock+0x16/0x20
 [<c02b660f>] udp_queue_rcv_skb+0xa3/0x210
 [<c0279ce0>] release_sock+0x5e/0xab
 [<c02b75b6>] udp_sendmsg+0x421/0x4d5
 [<c02bc186>] inet_sendmsg+0x3b/0x48
 [<c02781c0>] sock_sendmsg+0xca/0xe1
 [<c0133471>] ? autoremove_wake_function+0x0/0x33
 [<c02789f7>] sys_sendto+0xa4/0xc3
 [<c02e0fe3>] ? _spin_unlock_irq+0x22/0x2f
 [<c013d99a>] ? trace_hardirqs_on+0xe9/0x10a
 [<c02e0fe3>] ? _spin_unlock_irq+0x22/0x2f
 [<c0279102>] sys_socketcall+0xfb/0x189
 [<c0102ffa>] syscall_call+0x7/0xb
 =======================

And a bit later:

BUG: soft lockup - CPU#0 stuck for 61s! [pluto:2943]
Modules linked in: authenc xfrm4_mode_tunnel deflate zlib_deflate twofish
twofish_common camellia serpent blowfish des_generic cbc aes_i586 aes_generic
xcbc sha256_generic crypto_null crypto_blkcid

Pid: 2943, comm: pluto Not tainted (2.6.26-2.i2nsmp #2)
EIP: 0060:[<c01cb395>] EFLAGS: 00000282 CPU: 0
EIP is at delay_tsc+0x20/0x59
EAX: 535984b0 EBX: 00000000 ECX: 03301000 EDX: 000001d6
ESI: 00000000 EDI: f682e6a4 EBP: f6947cc0 ESP: f6947c94
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
CR0: 8005003b CR2: 0016aea0 CR3: 37bd5000 CR4: 000006d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
 [<c01cb3e6>] __delay+0x9/0xb
 [<c01d8c0b>] _raw_spin_lock+0xa7/0x118
 [<c02e10ef>] _spin_lock+0x20/0x28
 [<c02b6623>] ? udp_queue_rcv_skb+0xb7/0x210
 [<c02b6623>] udp_queue_rcv_skb+0xb7/0x210
 [<c0279ce0>] release_sock+0x5e/0xab
 [<c02b75b6>] udp_sendmsg+0x421/0x4d5
 [<c02bc186>] inet_sendmsg+0x3b/0x48
 [<c02781c0>] sock_sendmsg+0xca/0xe1
 [<c0133471>] ? autoremove_wake_function+0x0/0x33
 [<c02789f7>] sys_sendto+0xa4/0xc3
 [<c02e0fe3>] ? _spin_unlock_irq+0x22/0x2f
 [<c013d99a>] ? trace_hardirqs_on+0xe9/0x10a
 [<c02e0fe3>] ? _spin_unlock_irq+0x22/0x2f
 [<c0279102>] sys_socketcall+0xfb/0x189
 [<c0102ffa>] syscall_call+0x7/0xb


The locking issue seems to be caused by 

commit d01885e51bf577745ba935c70b55fe1405d6b632
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Wed Aug 27 22:40:04 2008 -0700

    udp: Drop socket lock for encapsulated packets

    [ Upstream commit d97106ea52aa57e63ff40d04479016836bbb5a4e ]

    The socket lock is there to protect the normal UDP receive path.
    Encapsulation UDP sockets don't need that protection.  In fact
    the locking is deadly for them as they may contain another UDP
    packet within, possibly with the same addresses.

    Also the nested bit was copied from TCP.  TCP needs it because
    of accept(2) spawning sockets.  This simply doesn't apply to UDP
    so I've removed it.

    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>
    Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

of kernel 2.6.24.4. The test box freezes after around 30s, so I can easily test
any patch and give feedback.

Cheers,
Thomas


-- 
Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
