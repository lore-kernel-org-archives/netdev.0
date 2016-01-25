From: Laura Abbott <labbott@fedoraproject.org>
Subject: [RESEND][RFC][PATCH] vsock: Fix blocking ops call in prepare_to_wait
Date: Mon, 25 Jan 2016 15:10:02 -0800
Message-ID: <1453763402-20304-1-git-send-email-labbott@fedoraproject.org>
Cc: Laura Abbott <labbott@fedoraproject.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45636 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932412AbcAYXKG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2016 18:10:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We receoved a bug report from someone using vmware:

WARNING: CPU: 3 PID: 660 at kernel/sched/core.c:7389
__might_sleep+0x7d/0x90()
do not call blocking ops when !TASK_RUNNING; state=1 set at
[<ffffffff810fa68d>] prepare_to_wait+0x2d/0x90
Modules linked in: vmw_vsock_vmci_transport vsock snd_seq_midi
snd_seq_midi_event snd_ens1371 iosf_mbi gameport snd_rawmidi
snd_ac97_codec ac97_bus snd_seq coretemp snd_seq_device snd_pcm
snd_timer snd soundcore ppdev crct10dif_pclmul crc32_pclmul
ghash_clmulni_intel vmw_vmci vmw_balloon i2c_piix4 shpchp parport_pc
parport acpi_cpufreq nfsd auth_rpcgss nfs_acl lockd grace sunrpc btrfs
xor raid6_pq 8021q garp stp llc mrp crc32c_intel serio_raw mptspi vmwgfx
drm_kms_helper ttm drm scsi_transport_spi mptscsih e1000 ata_generic
mptbase pata_acpi
CPU: 3 PID: 660 Comm: vmtoolsd Not tainted
4.2.0-0.rc1.git3.1.fc23.x86_64 #1
Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop
Reference Platform, BIOS 6.00 05/20/2014
 0000000000000000 0000000049e617f3 ffff88006ac37ac8 ffffffff818641f5
 0000000000000000 ffff88006ac37b20 ffff88006ac37b08 ffffffff810ab446
 ffff880068009f40 ffffffff81c63bc0 0000000000000061 0000000000000000
Call Trace:
 [<ffffffff818641f5>] dump_stack+0x4c/0x65
 [<ffffffff810ab446>] warn_slowpath_common+0x86/0xc0
 [<ffffffff810ab4d5>] warn_slowpath_fmt+0x55/0x70
 [<ffffffff8112551d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
 [<ffffffff810fa68d>] ? prepare_to_wait+0x2d/0x90
 [<ffffffff810fa68d>] ? prepare_to_wait+0x2d/0x90
 [<ffffffff810da2bd>] __might_sleep+0x7d/0x90
 [<ffffffff812163b3>] __might_fault+0x43/0xa0
 [<ffffffff81430477>] copy_from_iter+0x87/0x2a0
 [<ffffffffa039460a>] __qp_memcpy_to_queue+0x9a/0x1b0 [vmw_vmci]
 [<ffffffffa0394740>] ? qp_memcpy_to_queue+0x20/0x20 [vmw_vmci]
 [<ffffffffa0394757>] qp_memcpy_to_queue_iov+0x17/0x20 [vmw_vmci]
 [<ffffffffa0394d50>] qp_enqueue_locked+0xa0/0x140 [vmw_vmci]
 [<ffffffffa039593f>] vmci_qpair_enquev+0x4f/0xd0 [vmw_vmci]
 [<ffffffffa04847bb>] vmci_transport_stream_enqueue+0x1b/0x20
[vmw_vsock_vmci_transport]
 [<ffffffffa047ae05>] vsock_stream_sendmsg+0x2c5/0x320 [vsock]
 [<ffffffff810fabd0>] ? wake_atomic_t_function+0x70/0x70
 [<ffffffff81702af8>] sock_sendmsg+0x38/0x50
 [<ffffffff81702ff4>] SYSC_sendto+0x104/0x190
 [<ffffffff8126e25a>] ? vfs_read+0x8a/0x140
 [<ffffffff817042ee>] SyS_sendto+0xe/0x10
 [<ffffffff8186d9ae>] entry_SYSCALL_64_fastpath+0x12/0x76

transport->stream_enqueue may call copy_to_user so it should
not be called inside a prepare_to_wait. Narrow the scope of
the prepare_to_wait to avoid the bad call.

Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
---
Resending since I never heard back. This has been reported by
a couple of times again but nobody ever gets back to me about
whether this actually works. Still seems to be an issue as well.
---
 net/vmw_vsock/af_vsock.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index df5fc6b..fd68c88 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1558,8 +1558,6 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 	if (err < 0)
 		goto out;
 
-	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
-
 	while (total_written < len) {
 		ssize_t written;
 
@@ -1579,7 +1577,9 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 				goto out_wait;
 
 			release_sock(sk);
+			prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 			timeout = schedule_timeout(timeout);
+			finish_wait(sk_sleep(sk), &wait);
 			lock_sock(sk);
 			if (signal_pending(current)) {
 				err = sock_intr_errno(timeout);
@@ -1589,8 +1589,6 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 				goto out_wait;
 			}
 
-			prepare_to_wait(sk_sleep(sk), &wait,
-					TASK_INTERRUPTIBLE);
 		}
 
 		/* These checks occur both as part of and after the loop
@@ -1636,7 +1634,6 @@ static int vsock_stream_sendmsg(struct socket *sock, struct msghdr *msg,
 out_wait:
 	if (total_written > 0)
 		err = total_written;
-	finish_wait(sk_sleep(sk), &wait);
 out:
 	release_sock(sk);
 	return err;
-- 
2.4.3
