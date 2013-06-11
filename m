From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: sctp: sctp_seq_dump_local_addrs: fix NULL pointer dereference
Date: Tue, 11 Jun 2013 18:47:46 +0200
Message-ID: <1370969266-16974-1-git-send-email-dborkman@redhat.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9004 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755378Ab3FKQrs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jun 2013 12:47:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following NULL pointer dereference has occured on a 2.6.32-358 kernel,
but upstream is affected as well since there are not many differences:

sctp protocol violation state 4 chunkid 8
BUG: unable to handle kernel NULL pointer dereference at 0000000000000078
IP: [<ffffffffa0354cac>] sctp_v4_cmp_addr+0xc/0x30 [sctp]
PGD c2758c067 PUD 87ecf1067 PMD 0
Oops: 0000 [#1] SMP
last sysfs file: /sys/devices/pci0000:00/0000:00:0a.0/0000:02:00.1/local_cpus
CPU 7
Modules linked in: [...]
Pid: 15475, comm: netstat Not tainted 2.6.32-358.el6.x86_64 #1 KONTRON AT8050/FYA/AT8050/FYA
RIP: 0010:[<ffffffffa0354cac>]  [<ffffffffa0354cac>] sctp_v4_cmp_addr+0xc/0x30 [sctp]
RSP: 0018:ffff880c280f3d08  EFLAGS: 00010206
RAX: 0000000000000002 RBX: ffff880827a25c00 RCX: 0000000000000001
RDX: 000000000000027f RSI: 0000000000000078 RDI: ffff880827a25c20
RBP: ffff880c280f3d08 R08: 00000000fffffffd R09: 0000000000000001
R10: 0000000000000003 R11: 0000000000000000 R12: ffff880c27d9d870
R13: ffffffffa03751c0 R14: ffff880827a25c20 R15: 0000000000000078
FS:  00007fb7b7d0f7a0(0000) GS:ffff8800282e0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 -- MORE --  forward: <SPACE>, <ENTER> or j  backward: b or k  quit: q
CR2: 0000000000000078 CR3: 000000087c36d000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process netstat (pid: 15475, threadinfo ffff880c280f2000, task ffff88091e361540)
Stack:
 ffff880c280f3d58 ffffffffa036dbac ffff880c280f3d28 ffff88098fefebc0
<d> ffff880c280f3d38 ffff880c27d9d800 ffff88098fefebc0 0000000000000f83
<d> ffff8808d12a7b80 ffff880c27d9d948 ffff880c280f3e18 ffffffffa036de3d
Call Trace:
 [<ffffffffa036dbac>] sctp_seq_dump_local_addrs+0x6c/0xc0 [sctp]
 [<ffffffffa036de3d>] sctp_assocs_seq_show+0x12d/0x250 [sctp]
 [<ffffffff811a4ee0>] ? seq_read+0x0/0x400
 [<ffffffff811a5169>] seq_read+0x289/0x400
 [<ffffffff811e966e>] proc_reg_read+0x7e/0xc0
 [<ffffffff811816c5>] vfs_read+0xb5/0x1a0
 [<ffffffff81181801>] sys_read+0x51/0x90
 [<ffffffff810dc565>] ? __audit_syscall_exit+0x265/0x290
 [<ffffffff8100b072>] system_call_fastpath+0x16/0x1b
Code: 02 00 08 8b 47 04 89 46 04 b8 08 00 00 00 c9 c3 66 66 66 66 66 66
      2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 0f 1f 44 00 00 0f b7 07 <66>
      3b 06 74 07 31 c0 c9 c3 0f 1f 00 0f b7 47 02 66 3b 46 02 75
RIP  [<ffffffffa0354cac>] sctp_v4_cmp_addr+0xc/0x30 [sctp]
 RSP <ffff880c280f3d08>
CR2: 0000000000000078

./decodecode < oops.file:
  ...
  1f:	55                   	push   %rbp
  20:	48 89 e5             	mov    %rsp,%rbp
  23:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  28:	0f b7 07             	movzwl (%rdi),%eax
  2b:*	66 3b 06             	cmp    (%rsi),%ax  <-- trapping instruction
  2e:	74 07                	je     0x37       (1st 'if' in sctp_v4_cmp_addr)
  30:	31 c0                	xor    %eax,%eax
  32:	c9                   	leaveq
  33:	c3                   	retq
  34:	0f 1f 00             	nopl   (%rax)
  37:	0f b7 47 02          	movzwl 0x2(%rdi),%eax
  ...

There have been some approaches to fix corruptions with the same or
very similar stack trace such as 2eebc1e ("sctp: Fix list corruption
resulting from freeing an association on a list"), 0b0fe913 ("sctp:
proc: protect bind_addr->address_list accesses with rcu_read_lock()"),
45122ca ("sctp: Add RCU protection to assoc->transport_addr_list")
that are all important fixes, but the panic still can occur in some
cases with such a stack trace above.

When entering into sctp_seq_dump_local_addrs(), the sctp_ep_common
structure is correctly of type SCTP_EP_TYPE_ASSOCIATION, and has a
refcnt of 1 and dead is 0. Also from kdump, the ebp's pointer members
do not look corrupted. When entering sctp_v4_cmp_addr(), the first
sctp_addr argument looks good/valid, but the second sctp_addr argument
('primary') is 0000000000000078 and results suddenly in a NULL pointer
_dereference_ in sctp_v4_cmp_addr() although in the test before it
seems to have been "primary != NULL".

Now, how can this happen? Let's assume asoc->peer.primary_path is NULL
which is possible to happen. Here, we do not check for it, but take the
address (note we do not actually dereference it!) of its saddr member.
This is then exactly 0000000000000078 as reported in the trace, since
that is equal to the offset of saddr from the primary_path container
(in the reported kernel). Thus, the check for NULL (== (void *) 0) will
pass, eventually leading to the NULL pointer dereference in cmp_addr()
since this address is within the NULL page.

Lets fix it by being paranoid and checking first if our primary transport
is != NULL and in case of != NULL if it is alive. Then, let us hold a
copy of the sctp_addr on the stack instead of using a pointer just in
case the transport could be destroyed at a later point in time (we're not
in a hurry anyway). By that, we can avoid this very scenario, only just
for the sake of printing this asterisk and can fix the NULL pointer
dereference eventually. Introduced by bca735bd ("Extend the info exported
via /proc/net/sctp to support netstat for SCTP.").

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Reported-by: Madhavprasad Pai <mkpai@redhat.com>
Reported-by: Vivek Dasgupta <vdasgupt@redhat.com>
---
 Also should go to stable kernels.

 net/sctp/proc.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 4e45ee3..9564b90 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -127,16 +127,19 @@ void sctp_snmp_proc_exit(struct net *net)
 /* Dump local addresses of an association/endpoint. */
 static void sctp_seq_dump_local_addrs(struct seq_file *seq, struct sctp_ep_common *epb)
 {
-	struct sctp_association *asoc;
+	struct sctp_association *assoc;
 	struct sctp_sockaddr_entry *laddr;
-	struct sctp_transport *peer;
-	union sctp_addr *addr, *primary = NULL;
+	union sctp_addr *addr, primary;
 	struct sctp_af *af;
+	bool have_primary = false;
 
 	if (epb->type == SCTP_EP_TYPE_ASSOCIATION) {
-	    asoc = sctp_assoc(epb);
-	    peer = asoc->peer.primary_path;
-	    primary = &peer->saddr;
+		assoc = sctp_assoc(epb);
+		if (assoc->peer.primary_path != NULL &&
+		    !assoc->peer.primary_path->dead) {
+			primary = assoc->peer.primary_path->saddr;
+			have_primary = true;
+		}
 	}
 
 	rcu_read_lock();
@@ -146,9 +149,8 @@ static void sctp_seq_dump_local_addrs(struct seq_file *seq, struct sctp_ep_commo
 
 		addr = &laddr->a;
 		af = sctp_get_af_specific(addr->sa.sa_family);
-		if (primary && af->cmp_addr(addr, primary)) {
+		if (have_primary && af->cmp_addr(addr, &primary))
 			seq_printf(seq, "*");
-		}
 		af->seq_dump_addr(seq, addr);
 	}
 	rcu_read_unlock();
-- 
1.7.11.7
