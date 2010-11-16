From: Eric Paris <eparis@redhat.com>
Subject: [PATCH 2/3] network: tcp_connect should return certain errors up the
	stack
Date: Tue, 16 Nov 2010 16:52:49 -0500
Message-ID: <20101116215249.6727.89763.stgit@paris.rdu.redhat.com>
References: <20101116215238.6727.39248.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: eparis@redhat.com, equinox@diac24.net, eric.dumazet@gmail.com,
	davem@davemloft.net, hzhong@gmail.com, jmorris@namei.org,
	kaber@trash.net, kuznet@ms2.inr.ac.ru, paul.moore@hp.com,
	pekkas@netcore.fi, sds@tycho.nsa.gov, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	selinux@tycho.nsa.gov, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101116215238.6727.39248.stgit@paris.rdu.redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current tcp_connect code completely ignores errors from sending an skb.
This makes sense in many situations (like -ENOBUFFS) but I want to be able to
immediately fail connections if they are denied by the SELinux netfilter hook.
Netfilter does not normally return ECONNREFUSED when it drops a packet so we
respect that error code as a final and fatal error that can not be recovered.

Based-on-patch-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Eric Paris <eparis@redhat.com>
---

 net/ipv4/tcp_output.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e961522..15dcd7b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2592,6 +2592,7 @@ int tcp_connect(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *buff;
+	int err;
 
 	tcp_connect_init(sk);
 
@@ -2614,7 +2615,9 @@ int tcp_connect(struct sock *sk)
 	sk->sk_wmem_queued += buff->truesize;
 	sk_mem_charge(sk, buff->truesize);
 	tp->packets_out += tcp_skb_pcount(buff);
-	tcp_transmit_skb(sk, buff, 1, sk->sk_allocation);
+	err = tcp_transmit_skb(sk, buff, 1, sk->sk_allocation);
+	if (err == -ECONNREFUSED)
+		return err;
 
 	/* We change tp->snd_nxt after the tcp_transmit_skb() call
 	 * in order to make this packet get counted in tcpOutSegs.

