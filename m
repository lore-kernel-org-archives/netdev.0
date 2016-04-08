From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH] net: force inlining of netif_tx_start/stop_queue, sock_hold, __sock_put
Date: Fri,  8 Apr 2016 17:51:54 +0200
Message-ID: <1460130714-7779-1-git-send-email-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sometimes gcc mysteriously doesn't inline
very small functions we expect to be inlined. See
    https://gcc.gnu.org/bugzilla/show_bug.cgi?id=66122
Arguably, gcc should do better, but gcc people aren't willing
to invest time into it, asking to use __always_inline instead.

With this .config:
http://busybox.net/~vda/kernel_config_OPTIMIZE_INLINING_and_Os,
the following functions get deinlined many times.

netif_tx_stop_queue: 207 copies, 590 calls:
	55                      push   %rbp
	48 89 e5                mov    %rsp,%rbp
	f0 80 8f e0 01 00 00 01 lock orb $0x1,0x1e0(%rdi)
	5d                      pop    %rbp
	c3                      retq

netif_tx_start_queue: 47 copies, 111 calls
	55                      push   %rbp
	48 89 e5                mov    %rsp,%rbp
	f0 80 a7 e0 01 00 00 fe lock andb $0xfe,0x1e0(%rdi)
	5d                      pop    %rbp
	c3                      retq

sock_hold: 39 copies, 124 calls
	55                      push   %rbp
	48 89 e5                mov    %rsp,%rbp
	f0 ff 87 80 00 00 00    lock incl 0x80(%rdi)
	5d                      pop    %rbp
	c3                      retq

__sock_put: 6 copies, 13 calls
	55                      push   %rbp
	48 89 e5                mov    %rsp,%rbp
	f0 ff 8f 80 00 00 00    lock decl 0x80(%rdi)
	5d                      pop    %rbp
	c3                      retq

This patch fixes this via s/inline/__always_inline/.

Code size decrease after the patch is ~2.5k:

    text      data      bss       dec     hex filename
56719876  56364551 36196352 149280779 8e5d80b vmlinux_before
56717440  56364551 36196352 149278343 8e5ce87 vmlinux

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: David S. Miller <davem@davemloft.net>
CC: linux-kernel@vger.kernel.org
CC: netdev@vger.kernel.org
CC: netfilter-devel@vger.kernel.org
---
 include/linux/netdevice.h | 4 ++--
 include/net/sock.h        | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cb0d5d0..f924ddc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2801,7 +2801,7 @@ static inline void netif_tx_schedule_all(struct net_device *dev)
 		netif_schedule_queue(netdev_get_tx_queue(dev, i));
 }
 
-static inline void netif_tx_start_queue(struct netdev_queue *dev_queue)
+static __always_inline void netif_tx_start_queue(struct netdev_queue *dev_queue)
 {
 	clear_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state);
 }
@@ -2851,7 +2851,7 @@ static inline void netif_tx_wake_all_queues(struct net_device *dev)
 	}
 }
 
-static inline void netif_tx_stop_queue(struct netdev_queue *dev_queue)
+static __always_inline void netif_tx_stop_queue(struct netdev_queue *dev_queue)
 {
 	set_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state);
 }
diff --git a/include/net/sock.h b/include/net/sock.h
index 255d3e0..fd15eb1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -564,7 +564,7 @@ static inline bool __sk_del_node_init(struct sock *sk)
    modifications.
  */
 
-static inline void sock_hold(struct sock *sk)
+static __always_inline void sock_hold(struct sock *sk)
 {
 	atomic_inc(&sk->sk_refcnt);
 }
@@ -572,7 +572,7 @@ static inline void sock_hold(struct sock *sk)
 /* Ungrab socket in the context, which assumes that socket refcnt
    cannot hit zero, f.e. it is true in context of any socketcall.
  */
-static inline void __sock_put(struct sock *sk)
+static __always_inline void __sock_put(struct sock *sk)
 {
 	atomic_dec(&sk->sk_refcnt);
 }
-- 
1.8.1.4
