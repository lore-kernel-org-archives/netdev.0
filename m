From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net: relax PKTINFO non local ipv6 udp xmit check
Date: Fri, 26 Aug 2011 14:56:28 -0700
Message-ID: <1314395788-20179-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	"Erik Kline" <ek@google.com>,
	"Lorenzo Colitti" <lorenzo@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:36520 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407Ab1HZV5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 17:57:05 -0400
Received: by pzk37 with SMTP id 37so4921013pzk.1
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2011 14:57:05 -0700 (PDT)
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
 net/ipv6/ip6_flowlabel.c |    2 +-
 net/ipv6/ipv6_sockglue.c |    2 +-
 net/ipv6/raw.c           |    2 +-
 net/ipv6/udp.c           |    2 +-
 6 files changed, 8 insertions(+), 6 deletions(-)

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
index 9ef1831..03e20fa 100644
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
+				if (!(sk && inet_sk(sk)->transparent) &&
+				    !ipv6_chk_addr(net, &src_info->ipi6_addr,
 						   strict ? dev : NULL, 0))
 					err =3D -EINVAL;
 				else
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index f3caf1b..a896987 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -360,7 +360,7 @@ fl_create(struct net *net, struct in6_flowlabel_req=
 *freq, char __user *optval,
 		msg.msg_control =3D (void*)(fl->opt+1);
 		memset(&flowi6, 0, sizeof(flowi6));
=20
-		err =3D datagram_send_ctl(net, &msg, &flowi6, fl->opt, &junk,
+		err =3D datagram_send_ctl(net, NULL, &msg, &flowi6, fl->opt, &junk,
 					&junk, &junk);
 		if (err)
 			goto done;
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
index f34902f..131be5e 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -817,7 +817,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct=
 sock *sk,
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len =3D sizeof(struct ipv6_txoptions);
=20
-		err =3D datagram_send_ctl(sock_net(sk), msg, &fl6, opt, &hlimit,
+		err =3D datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt, &hlimit,
 					&tclass, &dontfrag);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 35bbdc4..b0fb25c 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1090,7 +1090,7 @@ do_udp_sendmsg:
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len =3D sizeof(*opt);
=20
-		err =3D datagram_send_ctl(sock_net(sk), msg, &fl6, opt, &hlimit,
+		err =3D datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt, &hlimit,
 					&tclass, &dontfrag);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
--=20
1.7.3.1
