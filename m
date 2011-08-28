From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net: relax PKTINFO non local ipv6 udp xmit check
Date: Sun, 28 Aug 2011 15:35:31 -0700
Message-ID: <1314570931-6233-1-git-send-email-zenczykowski@gmail.com>
References: <20110828.171154.1746224796788156557.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	"Erik Kline" <ek@google.com>,
	"Lorenzo Colitti" <lorenzo@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:60775 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357Ab1H1WgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2011 18:36:19 -0400
Received: by pzk37 with SMTP id 37so7416061pzk.1
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2011 15:36:18 -0700 (PDT)
In-Reply-To: <20110828.171154.1746224796788156557.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Allow transparent sockets to be less restrictive about
the source ip of ipv6 udp packets being sent.

Google-Bug-Id: 5018138
Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
CC: "Erik Kline" <ek@google.com>
CC: "Lorenzo Colitti" <lorenzo@google.com>
---
 include/net/transp_v6.h  |    1 +
 net/ipv6/datagram.c      |    5 +++--
 net/ipv6/ip6_flowlabel.c |    8 ++++----
 net/ipv6/ipv6_sockglue.c |    2 +-
 net/ipv6/raw.c           |    4 ++--
 net/ipv6/udp.c           |    4 ++--
 6 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index 5271a74..498433d 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -39,6 +39,7 @@ extern int			datagram_recv_ctl(struct sock *sk,
 						  struct sk_buff *skb);
=20
 extern int			datagram_send_ctl(struct net *net,
+						  struct sock *sk,
 						  struct msghdr *msg,
 						  struct flowi6 *fl6,
 						  struct ipv6_txoptions *opt,
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 9ef1831..b46e9f8 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -599,7 +599,7 @@ int datagram_recv_ctl(struct sock *sk, struct msghd=
r *msg, struct sk_buff *skb)
 	return 0;
 }
=20
-int datagram_send_ctl(struct net *net,
+int datagram_send_ctl(struct net *net, struct sock *sk,
 		      struct msghdr *msg, struct flowi6 *fl6,
 		      struct ipv6_txoptions *opt,
 		      int *hlimit, int *tclass, int *dontfrag)
@@ -658,7 +658,8 @@ int datagram_send_ctl(struct net *net,
=20
 			if (addr_type !=3D IPV6_ADDR_ANY) {
 				int strict =3D __ipv6_addr_src_scope(addr_type) <=3D IPV6_ADDR_SCO=
PE_LINKLOCAL;
-				if (!ipv6_chk_addr(net, &src_info->ipi6_addr,
+				if (!inet_sk(sk)->transparent &&
+				    !ipv6_chk_addr(net, &src_info->ipi6_addr,
 						   strict ? dev : NULL, 0))
 					err =3D -EINVAL;
 				else
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index f3caf1b..5430394 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -322,8 +322,8 @@ static int fl6_renew(struct ip6_flowlabel *fl, unsi=
gned long linger, unsigned lo
 }
=20
 static struct ip6_flowlabel *
-fl_create(struct net *net, struct in6_flowlabel_req *freq, char __user=
 *optval,
-	  int optlen, int *err_p)
+fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *=
freq,
+	  char __user *optval, int optlen, int *err_p)
 {
 	struct ip6_flowlabel *fl =3D NULL;
 	int olen;
@@ -360,7 +360,7 @@ fl_create(struct net *net, struct in6_flowlabel_req=
 *freq, char __user *optval,
 		msg.msg_control =3D (void*)(fl->opt+1);
 		memset(&flowi6, 0, sizeof(flowi6));
=20
-		err =3D datagram_send_ctl(net, &msg, &flowi6, fl->opt, &junk,
+		err =3D datagram_send_ctl(net, sk, &msg, &flowi6, fl->opt, &junk,
 					&junk, &junk);
 		if (err)
 			goto done;
@@ -528,7 +528,7 @@ int ipv6_flowlabel_opt(struct sock *sk, char __user=
 *optval, int optlen)
 		if (freq.flr_label & ~IPV6_FLOWLABEL_MASK)
 			return -EINVAL;
=20
-		fl =3D fl_create(net, &freq, optval, optlen, &err);
+		fl =3D fl_create(net, sk, &freq, optval, optlen, &err);
 		if (fl =3D=3D NULL)
 			return err;
 		sfl1 =3D kmalloc(sizeof(*sfl1), GFP_KERNEL);
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 147ede38..2fbda5f 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -475,7 +475,7 @@ sticky_done:
 		msg.msg_controllen =3D optlen;
 		msg.msg_control =3D (void*)(opt+1);
=20
-		retv =3D datagram_send_ctl(net, &msg, &fl6, opt, &junk, &junk,
+		retv =3D datagram_send_ctl(net, sk, &msg, &fl6, opt, &junk, &junk,
 					 &junk);
 		if (retv)
 			goto done;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index f34902f..3486f62 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -817,8 +817,8 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct=
 sock *sk,
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len =3D sizeof(struct ipv6_txoptions);
=20
-		err =3D datagram_send_ctl(sock_net(sk), msg, &fl6, opt, &hlimit,
-					&tclass, &dontfrag);
+		err =3D datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
+					&hlimit, &tclass, &dontfrag);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 35bbdc4..f4ca0a5 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1090,8 +1090,8 @@ do_udp_sendmsg:
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len =3D sizeof(*opt);
=20
-		err =3D datagram_send_ctl(sock_net(sk), msg, &fl6, opt, &hlimit,
-					&tclass, &dontfrag);
+		err =3D datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
+					&hlimit, &tclass, &dontfrag);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
--=20
1.7.3.1
