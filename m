From: Mike Frysinger <vapier.adi@gmail.com>
Subject: bridge netpoll support: mismatch between net core and bridge headers
Date: Sat, 13 Nov 2010 18:26:27 -0500
Message-ID: <AANLkTimbf+yfJFU29rNWAc-hXBxj92J=dNaShM04GNZ7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41861 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754053Ab0KMX0x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Nov 2010 18:26:53 -0500
Received: by wyb28 with SMTP id 28so3205790wyb.19
        for <netdev@vger.kernel.org>; Sat, 13 Nov 2010 15:26:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 91d2c34a4eed32876ca333b0ca44f3bc56645805 added this bit of code
to net/bridge/br_private.h:
struct net_bridge_port {
    ....
+#ifdef CONFIG_NET_POLL_CONTROLLER
+   struct netpoll          *np;
+#endif
};
=2E...
#ifdef CONFIG_NET_POLL_CONTROLLER
+static inline struct netpoll_info *br_netpoll_info(struct net_bridge *=
br)
+{
+   return br->dev->npinfo;
+}
=2E...

unfortunately, this is not the define protection that is used in the
core net code (include/linux/netdevice.h):
#ifdef CONFIG_NETPOLL
    struct netpoll_info *npinfo;
#endif

so in my randconfig builds, i'm now seeing frequent failures along the =
lines of:

In file included from net/bridge/br.c:24:
net/bridge/br_private.h: In function =E2=80=98br_netpoll_info=E2=80=99:
net/bridge/br_private.h:293: error: =E2=80=98struct net_device=E2=80=99=
 has no member
named =E2=80=98npinfo=E2=80=99
make[2]: *** [net/bridge/br.o] Error 1
In file included from net/bridge/br_device.c:24:
net/bridge/br_private.h: In function =E2=80=98br_netpoll_info=E2=80=99:
net/bridge/br_private.h:293: error: =E2=80=98struct net_device=E2=80=99=
 has no member
named =E2=80=98npinfo=E2=80=99
In file included from net/bridge/br_fdb.c:27:
net/bridge/br_private.h: In function =E2=80=98br_netpoll_info=E2=80=99:
net/bridge/br_private.h:293: error: =E2=80=98struct net_device=E2=80=99=
 has no member
named =E2=80=98npinfo=E2=80=99
make[2]: *** [net/bridge/br_fdb.o] Error 1
make[2]: *** [net/bridge/br_device.o] Error 1
In file included from net/bridge/br_forward.c:23:
net/bridge/br_private.h: In function =E2=80=98br_netpoll_info=E2=80=99:
net/bridge/br_private.h:293: error: =E2=80=98struct net_device=E2=80=99=
 has no member
named =E2=80=98npinfo=E2=80=99
make[2]: *** [net/bridge/br_forward.o] Error 1

seems to be a regression introduced during the 2.6.36 cycle
-mike
