From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: Use LIMIT_NETDEBUG in syn_flood_warning()
Date: Fri, 12 Aug 2011 08:08:30 +0200
Message-ID: <1313129310.2669.19.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1108102229130.5341@pokey.mtv.corp.google.com>
	 <20110810.231318.959972077845910551.davem@davemloft.net>
	 <1313044387.3066.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51336 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830Ab1HLGIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 02:08:35 -0400
Received: by wwf5 with SMTP id 5so2733394wwf.1
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2011 23:08:34 -0700 (PDT)
In-Reply-To: <1313044387.3066.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 11 ao=C3=BBt 2011 =C3=A0 08:33 +0200, Eric Dumazet a =C3=A9cri=
t :
> Le mercredi 10 ao=C3=BBt 2011 =C3=A0 23:13 -0700, David Miller a =C3=A9=
crit :
> > From: Tom Herbert <therbert@google.com>
> > Date: Wed, 10 Aug 2011 22:38:02 -0700 (PDT)
> >=20
> > > Rather than printing the message to the log, use a mib counter to=
 keep
> > > track of the count of occurences of syn cookies being used or syn
> > > being dropped when request queue is full.
> > >=20
> > > Rationale is these messages can fill up /var/log/messages on serv=
er
> > > which is simply under heavy load... I'm not sure how much more us=
eful
> > > they would be in identifying a server DOS attack (compared to
> > > counters).
> > >=20
> > > Signed-off-by: Tom Herbert <therbert@google.com>
> >=20
> > Print the message once, and also do the counters.
> >=20
> > Say something like "Possible SYN flooding, see SNMP counters." or
> > similar.
> >=20
> > Because if people are grepping for that message in their logs, they
> > will now have a false sense of confidence seeing it not being there
> > any more.
>=20
> An alternative would be to guard the message by net_msg_warn
> (/proc/sys/net/core/warnings)
>=20
> LIMIT_NETDEBUG(KERN_INFO "TCP: Possible SYN flooding on port %d. %s.\=
n"=20
> 	...)

Here is a patch implementing this.

We could add mib counters later in a second patch, inside
tcp_syn_flood_warning()

Thanks

[PATCH] tcp: Use LIMIT_NETDEBUG in syn_flood_warning()

LIMIT_NETDEBUG allows the admin to disable some warning messages :
echo 0 > /proc/sys/net/core/warnings

Use it to avoid filling syslog on busy servers.

Based on a previous patch from Tom Herbert

=46actorize syn_flood_warning() IPv4/IPv6 implementations

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Tom Herbert <therbert@google.com>
---
 include/net/tcp.h   |    1 +
 net/ipv4/tcp_ipv4.c |   14 ++++++--------
 net/ipv6/tcp_ipv6.c |   17 +----------------
 3 files changed, 8 insertions(+), 24 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 149a415..964341c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -460,6 +460,7 @@ extern int tcp_write_wakeup(struct sock *);
 extern void tcp_send_fin(struct sock *sk);
 extern void tcp_send_active_reset(struct sock *sk, gfp_t priority);
 extern int tcp_send_synack(struct sock *);
+extern void tcp_syn_flood_warning(const struct sk_buff *skb, const cha=
r *proto);
 extern void tcp_push_one(struct sock *, unsigned int mss_now);
 extern void tcp_send_ack(struct sock *sk);
 extern void tcp_send_delayed_ack(struct sock *sk);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1c12b8e..9e622da 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -808,20 +808,19 @@ static void tcp_v4_reqsk_destructor(struct reques=
t_sock *req)
 	kfree(inet_rsk(req)->opt);
 }
=20
-static void syn_flood_warning(const struct sk_buff *skb)
+void tcp_syn_flood_warning(const struct sk_buff *skb, const char *prot=
o)
 {
-	const char *msg;
+	const char *msg =3D "Dropping request";
=20
 #ifdef CONFIG_SYN_COOKIES
 	if (sysctl_tcp_syncookies)
 		msg =3D "Sending cookies";
-	else
 #endif
-		msg =3D "Dropping request";
=20
-	pr_info("TCP: Possible SYN flooding on port %d. %s.\n",
-				ntohs(tcp_hdr(skb)->dest), msg);
+	LIMIT_NETDEBUG(KERN_INFO "%s: Possible SYN flooding on port %d. %s.\n=
",
+		       proto, ntohs(tcp_hdr(skb)->dest), msg);
 }
+EXPORT_SYMBOL(tcp_syn_flood_warning);
=20
 /*
  * Save and compile IPv4 options into the request_sock if needed.
@@ -1250,8 +1249,7 @@ int tcp_v4_conn_request(struct sock *sk, struct s=
k_buff *skb)
 	 * evidently real one.
 	 */
 	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
-		if (net_ratelimit())
-			syn_flood_warning(skb);
+		tcp_syn_flood_warning(skb, "TCP");
 #ifdef CONFIG_SYN_COOKIES
 		if (sysctl_tcp_syncookies) {
 			want_cookie =3D 1;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d1fb63f..a043386 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -531,20 +531,6 @@ static int tcp_v6_rtx_synack(struct sock *sk, stru=
ct request_sock *req,
 	return tcp_v6_send_synack(sk, req, rvp);
 }
=20
-static inline void syn_flood_warning(struct sk_buff *skb)
-{
-#ifdef CONFIG_SYN_COOKIES
-	if (sysctl_tcp_syncookies)
-		printk(KERN_INFO
-		       "TCPv6: Possible SYN flooding on port %d. "
-		       "Sending cookies.\n", ntohs(tcp_hdr(skb)->dest));
-	else
-#endif
-		printk(KERN_INFO
-		       "TCPv6: Possible SYN flooding on port %d. "
-		       "Dropping request.\n", ntohs(tcp_hdr(skb)->dest));
-}
-
 static void tcp_v6_reqsk_destructor(struct request_sock *req)
 {
 	kfree_skb(inet6_rsk(req)->pktopts);
@@ -1192,8 +1178,7 @@ static int tcp_v6_conn_request(struct sock *sk, s=
truct sk_buff *skb)
 		goto drop;
=20
 	if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
-		if (net_ratelimit())
-			syn_flood_warning(skb);
+		tcp_syn_flood_warning(skb, "TCPv6");
 #ifdef CONFIG_SYN_COOKIES
 		if (sysctl_tcp_syncookies)
 			want_cookie =3D 1;


