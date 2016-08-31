From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [RT PATCH 2/2] net: add a lock around icmp_sk()
Date: Wed, 31 Aug 2016 18:00:49 +0200
Message-ID: <20160831160049.14303-2-bigeasy@linutronix.de>
References: <20160831160049.14303-1-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de,
        Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org,
        Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: linux-rt-users@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160831160049.14303-1-bigeasy@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It looks like the this_cpu_ptr() access in icmp_sk() is protected with
local_bh_disable(). To avoid missing serialization in -RT I am adding
here a local lock. No crash has been observed, this is just precaution.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 net/ipv4/icmp.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index c1f1d5030d37..63731fd6af3e 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -78,6 +78,7 @@
 #include <linux/string.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/slab.h>
+#include <linux/locallock.h>
 #include <net/snmp.h>
 #include <net/ip.h>
 #include <net/route.h>
@@ -205,6 +206,8 @@ static const struct icmp_control icmp_pointers[NR_ICMP_=
TYPES+1];
  *
  *	On SMP we have one ICMP socket per-cpu.
  */
+static DEFINE_LOCAL_IRQ_LOCK(icmp_sk_lock);
+
 static struct sock *icmp_sk(struct net *net)
 {
 	return *this_cpu_ptr(net->ipv4.icmp_sk);
@@ -216,12 +219,14 @@ static inline struct sock *icmp_xmit_lock(struct net =
*net)
=20
 	local_bh_disable();
=20
+	local_lock(icmp_sk_lock);
 	sk =3D icmp_sk(net);
=20
 	if (unlikely(!spin_trylock(&sk->sk_lock.slock))) {
 		/* This can happen if the output path signals a
 		 * dst_link_failure() for an outgoing ICMP packet.
 		 */
+		local_unlock(icmp_sk_lock);
 		local_bh_enable();
 		return NULL;
 	}
@@ -231,6 +236,7 @@ static inline struct sock *icmp_xmit_lock(struct net *n=
et)
 static inline void icmp_xmit_unlock(struct sock *sk)
 {
 	spin_unlock_bh(&sk->sk_lock.slock);
+	local_unlock(icmp_sk_lock);
 }
=20
 int sysctl_icmp_msgs_per_sec __read_mostly =3D 1000;
@@ -359,6 +365,7 @@ static void icmp_push_reply(struct icmp_bxm *icmp_param,
 	struct sock *sk;
 	struct sk_buff *skb;
=20
+	local_lock(icmp_sk_lock);
 	sk =3D icmp_sk(dev_net((*rt)->dst.dev));
 	if (ip_append_data(sk, fl4, icmp_glue_bits, icmp_param,
 			   icmp_param->data_len+icmp_param->head_len,
@@ -381,6 +388,7 @@ static void icmp_push_reply(struct icmp_bxm *icmp_param,
 		skb->ip_summed =3D CHECKSUM_NONE;
 		ip_push_pending_frames(sk, fl4);
 	}
+	local_unlock(icmp_sk_lock);
 }
=20
 /*
--=20
2.9.3
