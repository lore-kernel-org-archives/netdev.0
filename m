From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] sctp: fix warning at inet_sock_destruct() while release sctp
 socket
Date: Mon, 06 Jul 2009 13:42:55 +0800
Message-ID: <4A518EDF.9030501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60071 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752835AbZGFFn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2009 01:43:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 'net: Move rx skb_orphan call to where needed' broken sctp protocol
with warning at inet_sock_destruct(). Actually, sctp can do this right with
sctp_sock_rfree_frag() and sctp_skb_set_owner_r_frag() pair.

sctp_sock_rfree_frag(skb);
sctp_skb_set_owner_r_frag(skb, newsk);

This patch not revert the commit d55d87fdff8252d0e2f7c28c2d443aee17e9d70f,
instead remove the sctp_sock_rfree_frag() function.

------------[ cut here ]------------
WARNING: at net/ipv4/af_inet.c:151 inet_sock_destruct+0xe0/0x142()
Modules linked in: sctp ipv6 dm_mirror dm_region_hash dm_log dm_multipath
scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: scsi_wait_scan]
Pid: 1808, comm: sctp_test Not tainted 2.6.31-rc2 #40
Call Trace:
[<c042dd06>] warn_slowpath_common+0x6a/0x81
[<c064a39a>] ? inet_sock_destruct+0xe0/0x142
[<c042dd2f>] warn_slowpath_null+0x12/0x15
[<c064a39a>] inet_sock_destruct+0xe0/0x142
[<c05fde44>] __sk_free+0x19/0xcc
[<c05fdf50>] sk_free+0x18/0x1a
[<ca0d14ad>] sctp_close+0x192/0x1a1 [sctp]
[<c0649f7f>] inet_release+0x47/0x4d
[<c05fba4d>] sock_release+0x19/0x5e
[<c05fbab3>] sock_close+0x21/0x25
[<c049c31b>] __fput+0xde/0x189
[<c049c3de>] fput+0x18/0x1a
[<c049988f>] filp_close+0x56/0x60
[<c042f422>] put_files_struct+0x5d/0xa1
[<c042f49f>] exit_files+0x39/0x3d
[<c043086a>] do_exit+0x1a5/0x5dd
[<c04a86c2>] ? d_kill+0x35/0x3b
[<c0438fa4>] ? dequeue_signal+0xa6/0x115
[<c0430d05>] do_group_exit+0x63/0x8a
[<c0439504>] get_signal_to_deliver+0x2e1/0x2f9
[<c0401d9e>] do_notify_resume+0x7c/0x6b5
[<c043f601>] ? autoremove_wake_function+0x0/0x34
[<c04a864e>] ? __d_free+0x3d/0x40
[<c04a867b>] ? d_free+0x2a/0x3c
[<c049ba7e>] ? vfs_write+0x103/0x117
[<c05fc8fa>] ? sys_socketcall+0x178/0x182
[<c0402a56>] work_notifysig+0x13/0x19
---[ end trace 9db92c463e789fba ]---

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
net/sctp/socket.c | 25 ++-----------------------
1 files changed, 2 insertions(+), 23 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 35ba035..971890d 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6652,21 +6652,6 @@ static void sctp_wait_for_close(struct sock *sk,
long timeout)
finish_wait(sk->sk_sleep, &wait);
}

-static void sctp_sock_rfree_frag(struct sk_buff *skb)
-{
- struct sk_buff *frag;
-
- if (!skb->data_len)
- goto done;
-
- /* Don't forget the fragments. */
- skb_walk_frags(skb, frag)
- sctp_sock_rfree_frag(frag);
-
-done:
- sctp_sock_rfree(skb);
-}
-
static void sctp_skb_set_owner_r_frag(struct sk_buff *skb, struct sock *sk)
{
struct sk_buff *frag;
@@ -6776,7 +6761,6 @@ static void sctp_sock_migrate(struct sock *oldsk,
struct sock *newsk,
sctp_skb_for_each(skb, &oldsk->sk_receive_queue, tmp) {
event = sctp_skb2event(skb);
if (event->asoc == assoc) {
- sctp_sock_rfree_frag(skb);
__skb_unlink(skb, &oldsk->sk_receive_queue);
__skb_queue_tail(&newsk->sk_receive_queue, skb);
sctp_skb_set_owner_r_frag(skb, newsk);
@@ -6807,7 +6791,6 @@ static void sctp_sock_migrate(struct sock *oldsk,
struct sock *newsk,
sctp_skb_for_each(skb, &oldsp->pd_lobby, tmp) {
event = sctp_skb2event(skb);
if (event->asoc == assoc) {
- sctp_sock_rfree_frag(skb);
__skb_unlink(skb, &oldsp->pd_lobby);
__skb_queue_tail(queue, skb);
sctp_skb_set_owner_r_frag(skb, newsk);
@@ -6822,15 +6805,11 @@ static void sctp_sock_migrate(struct sock
*oldsk, struct sock *newsk,

}

- sctp_skb_for_each(skb, &assoc->ulpq.reasm, tmp) {
- sctp_sock_rfree_frag(skb);
+ sctp_skb_for_each(skb, &assoc->ulpq.reasm, tmp)
sctp_skb_set_owner_r_frag(skb, newsk);
- }

- sctp_skb_for_each(skb, &assoc->ulpq.lobby, tmp) {
- sctp_sock_rfree_frag(skb);
+ sctp_skb_for_each(skb, &assoc->ulpq.lobby, tmp)
sctp_skb_set_owner_r_frag(skb, newsk);
- }

/* Set the type of socket to indicate that it is peeled off from the
* original UDP-style socket or created with the accept() call on a
-- 
1.6.2.2


