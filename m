From: Dmitry Petukhov <dmgenp@gmail.com>
Subject: net/l2tp/l2tp_ppp.c should take pmtu from tunnel socket
Date: Sun, 6 Apr 2014 00:58:27 +0600
Message-ID: <CAP6LPsDCgCCxRhF4Pc+JZu_ZRou9RJ6SEEyk6Sa2sxtbqs_Gog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:44504 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753382AbaDES62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2014 14:58:28 -0400
Received: by mail-ob0-f179.google.com with SMTP id va2so4914329obc.24
        for <netdev@vger.kernel.org>; Sat, 05 Apr 2014 11:58:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

currently when it tries to get PMTU, it does

dst = sk_dst_get(sk);
...
u32 pmtu = dst_mtu(__sk_dst_get(sk));

where sk represents PPPoX socket

it should use tunnel UDP socket instead, tunnel->sock

This bug bite me when I tried to use l2tp vpn over the link with mtu <
1500 but where fragments were dropped somewere along the path. I tried
to use this mechanism with

ip route add <dst> via ... mtu <lower_mtu>

but it didn't work.

After the fix I was able to use this feature of l2tp_ppp driver, it
picked up mtu set by ip route and used it.

patch against https://github.com/torvalds/linux master:

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index d276e2d..950909f 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -753,9 +753,9 @@ static int pppol2tp_connect(struct socket *sock,
struct sockaddr *uservaddr,
        session->deref = pppol2tp_session_sock_put;

        /* If PMTU discovery was enabled, use the MTU that was discovered */
-       dst = sk_dst_get(sk);
+       dst = sk_dst_get(tunnel->sock);
        if (dst != NULL) {
-               u32 pmtu = dst_mtu(__sk_dst_get(sk));
+               u32 pmtu = dst_mtu(__sk_dst_get(tunnel->sock));
                if (pmtu != 0)
                        session->mtu = session->mru = pmtu -
                                PPPOL2TP_HEADER_OVERHEAD;
