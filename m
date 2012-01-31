From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] tcp: md5: fix md5 RST when both sides have listener
Date: Tue, 31 Jan 2012 14:33:48 +0100
Message-ID: <1328016828.2297.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1327975638-16530-1-git-send-email-shawn.lu@ericsson.com>
	 <CAL4WiipdO5+1Fi_ig5hB25d2LJvc+cjzyAbo8mxx3e4EiRx9YA@mail.gmail.com>
	 <62162DF05402B341B3DB59932A1FA992B5B5B929BD@EUSAACMS0702.eamcs.ericsson.se>
	 <1328000712.2422.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42029 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753200Ab2AaNdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 08:33:52 -0500
Received: by bkcjm19 with SMTP id jm19so501337bkc.19
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 05:33:50 -0800 (PST)
In-Reply-To: <1328000712.2422.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 31 janvier 2012 =C3=A0 10:05 +0100, Eric Dumazet a =C3=A9crit =
:

> Hmm... The second problem is that its not safe to call
> tcp_v4_md5_do_lookup() on an unlocked socket.
>=20
> And locking a listener is way too expensive, since a listener socket =
is
> already a contention point.
>=20
> An attacker could send forged tcp md5 packets to slow down a server.
>=20
> A proper patch needs RCU conversion first.

I am working on this RCU conversion and big md5 cleanup, using a single
list of keys.

You can then add your fix on top of this work.


union tcp_md5_addr {
        struct in_addr  a4;
#if IS_ENABLED(CONFIG_IPV6)
        struct in6_addr a6;
#endif
};

/* - key database */
struct tcp_md5sig_key {
        struct hlist_node       node;
        u8                      keylen;
        u8                      family; /* AF_INET or AF_INET6 */
        union tcp_md5_addr      addr;
        u8                      key[TCP_MD5SIG_MAXKEYLEN];
        struct rcu_head         rcu;
};

/* - sock block */
struct tcp_md5sig_info {
        struct hlist_head       head;
};
