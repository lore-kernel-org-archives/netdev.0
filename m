From: Dmitry Safonov <0x7f454c46@gmail.com>
Subject: [PATCH] net: netfilter: fix false positive GCC warnings
Date: Fri,  6 Nov 2015 22:35:44 +0300
Message-ID: <1446838544-30487-1-git-send-email-0x7f454c46@gmail.com>
References: <20151106190705.GA20345@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Safonov <0x7f454c46@gmail.com>
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151106190705.GA20345@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With x86_64_defconfig:
GCC thinks that in nfulnl_recv_config flags parameter is not inited but
it was under the same condition (nfula[NFULA_CFG_FLAGS] =3D=3D true).
Suppress this warning:
        net/netfilter/nfnetlink_log.c: In function =E2=80=98nfulnl_recv=
_config=E2=80=99:
        net/netfilter/nfnetlink_log.c:320:14: warning: =E2=80=98flags=E2=
=80=99 may be used uninitialized in this function [-Wmaybe-uninitialize=
d]
        inst->flags =3D flags;
                    ^
GCC thinks that nfnl_ct wasn't inited, but it is used only under
	if (ct && diff)
where ct is not NULL only when nfnl_ct is inited.

Reported-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Dmitry Safonov <0x7f454c46@gmail.com>
---
 net/netfilter/nfnetlink_log.c   | 2 +-
 net/netfilter/nfnetlink_queue.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_lo=
g.c
index 06eb48fceb42e4..23f16b99e6388a 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -825,7 +825,7 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buf=
f *skb,
 	struct net *net =3D sock_net(ctnl);
 	struct nfnl_log_net *log =3D nfnl_log_pernet(net);
 	int ret =3D 0;
-	u16 flags;
+	u16 uninitialized_var(flags);
=20
 	if (nfula[NFULA_CFG_CMD]) {
 		u_int8_t pf =3D nfmsg->nfgen_family;
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_=
queue.c
index 7d81d280cb4ff3..66b006112921ca 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -313,7 +313,7 @@ nfqnl_build_packet_message(struct net *net, struct =
nfqnl_instance *queue,
 	struct net_device *outdev;
 	struct nf_conn *ct =3D NULL;
 	enum ip_conntrack_info uninitialized_var(ctinfo);
-	struct nfnl_ct_hook *nfnl_ct;
+	struct nfnl_ct_hook *uninitialized_var(nfnl_ct);
 	bool csum_verify;
 	char *secdata =3D NULL;
 	u32 seclen =3D 0;
@@ -1041,7 +1041,7 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_b=
uff *skb,
 	unsigned int verdict;
 	struct nf_queue_entry *entry;
 	enum ip_conntrack_info uninitialized_var(ctinfo);
-	struct nfnl_ct_hook *nfnl_ct;
+	struct nfnl_ct_hook *uninitialized_var(nfnl_ct);
 	struct nf_conn *ct =3D NULL;
=20
 	struct net *net =3D sock_net(ctnl);
--=20
2.6.2
