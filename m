From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: sctp: clone options to avoid use after free
Date: Wed, 09 Dec 2015 07:25:06 -0800
Message-ID: <1449674706.9768.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+YjXJoh3uGDp=FJkYVnjaMxFSPY252ptbDGZ-LQ9JAEWw@mail.gmail.com>
	 <CANn89i+V-GeD3zCzGPAo4jY8Z6iTjFN3U1ixG44WyKKLOZ9Txw@mail.gmail.com>
	 <20151209145917.GA3884@mrl.redhat.com>
	 <CANn89iLhetNbtO6h99zZOrCiMYON50vzVsk7j_AtosXejvvm4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iLhetNbtO6h99zZOrCiMYON50vzVsk7j_AtosXejvvm4Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

SCTP is lacking proper np->opt cloning at accept() time.

TCP and DCCP use ipv6_dup_options() helper, do the same
in SCTP.

We might later factorize this code in a common helper to avoid
future mistakes.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sctp/ipv6.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index d28c0b4c9128..ec529121f38a 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -641,6 +641,7 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
 	struct sock *newsk;
 	struct ipv6_pinfo *newnp, *np = inet6_sk(sk);
 	struct sctp6_sock *newsctp6sk;
+	struct ipv6_txoptions *opt;
 
 	newsk = sk_alloc(sock_net(sk), PF_INET6, GFP_KERNEL, sk->sk_prot, 0);
 	if (!newsk)
@@ -660,6 +661,13 @@ static struct sock *sctp_v6_create_accept_sk(struct sock *sk,
 
 	memcpy(newnp, np, sizeof(struct ipv6_pinfo));
 
+	rcu_read_lock();
+	opt = rcu_dereference(np->opt);
+	if (opt)
+		opt = ipv6_dup_options(newsk, opt);
+	RCU_INIT_POINTER(newnp->opt, opt);
+	rcu_read_unlock();
+
 	/* Initialize sk's sport, dport, rcv_saddr and daddr for getsockname()
 	 * and getpeername().
 	 */
