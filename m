From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: ipt_CLUSTERIP: dont flood with "no
 conntrack!"
Date: Thu, 13 Jan 2011 12:32:45 +0100
Message-ID: <1294918365.3570.56.camel@edumazet-laptop>
References: <4D2E1A74.5080102@netfilter.org>
	 <1294917210.3570.48.camel@edumazet-laptop> <4D2EE09A.1010409@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D2EE09A.1010409@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 13 janvier 2011 =C3=A0 12:23 +0100, Pablo Neira Ayuso a =C3=A9=
crit :
> Hi Eric,
>=20
> On 13/01/11 12:13, Eric Dumazet wrote:
> > ipt_CLUSTERIP users might hit this annoying printk, if they forgot =
an
> > "iptables -I INPUT -m state --state INVALID -j DROP" before CLUSTER=
IP
> > rule. We could use net_ratelimit() here, or not log the message at =
all.
> > I chose to log it once per config.
>=20
> I think that this should be converted to pr_debug() instead, there's
> also another reference to "unknown protocol" that should be converted=
 as
> well.

Problem is pr_debug() is a noop most of the time,
and printk(KERN_DEBUG is a bit ugly ...

If we print the message once, better to really print it ;)

[PATCH] netfilter: ipt_CLUSTERIP: dont flood with "no conntrack!"

ipt_CLUSTERIP users might hit this annoying printk, if they forgot an
"iptables -I INPUT -m state --state INVALID -j DROP" before CLUSTERIP
rule. We could use net_ratelimit() here, or not log the message at all.
I chose to log it once per config.

Pablo suggested to use same logic for the "unknown protocol" message

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c |   22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ip=
t_CLUSTERIP.c
index 1e26a48..2968571 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -47,6 +47,8 @@ struct clusterip_config {
 	u_int8_t clustermac[ETH_ALEN];		/* the MAC address */
 	struct net_device *dev;			/* device */
 	u_int16_t num_total_nodes;		/* total number of nodes */
+	bool warned_no_conntrack;
+	bool warned_unknown_protocol;
 	unsigned long local_nodes;		/* node number array */
=20
 #ifdef CONFIG_PROC_FS
@@ -228,7 +230,7 @@ clusterip_del_node(struct clusterip_config *c, u_in=
t16_t nodenum)
=20
 static inline u_int32_t
 clusterip_hashfn(const struct sk_buff *skb,
-		 const struct clusterip_config *config)
+		 struct clusterip_config *config)
 {
 	const struct iphdr *iph =3D ip_hdr(skb);
 	unsigned long hashval;
@@ -236,7 +238,7 @@ clusterip_hashfn(const struct sk_buff *skb,
 	int poff;
=20
 	poff =3D proto_ports_offset(iph->protocol);
-	if (poff >=3D 0) {
+	if (likely(poff >=3D 0)) {
 		const u_int16_t *ports;
 		u16 _ports[2];
=20
@@ -246,8 +248,10 @@ clusterip_hashfn(const struct sk_buff *skb,
 			dport =3D ports[1];
 		}
 	} else {
-		if (net_ratelimit())
+		if (unlikely(!config->warned_unknown_protocol)) {
+			config->warned_unknown_protocol =3D true;
 			pr_info("unknown protocol %u\n", iph->protocol);
+		}
 	}
=20
 	switch (config->hash_mode) {
@@ -301,10 +305,14 @@ clusterip_tg(struct sk_buff *skb, const struct xt=
_action_param *par)
=20
 	ct =3D nf_ct_get(skb, &ctinfo);
 	if (ct =3D=3D NULL) {
-		pr_info("no conntrack!\n");
-			/* FIXME: need to drop invalid ones, since replies
-			 * to outgoing connections of other nodes will be
-			 * marked as INVALID */
+		if (unlikely(!cipinfo->config->warned_no_conntrack)) {
+			cipinfo->config->warned_no_conntrack =3D true;
+			pr_info("no conntrack!\n");
+		}
+		/* FIXME: need to drop invalid ones, since replies
+		 * to outgoing connections of other nodes will be
+		 * marked as INVALID
+		 */
 		return NF_DROP;
 	}
=20


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
