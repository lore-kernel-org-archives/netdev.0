From: Shawn Lu <shawn.lu@ericsson.com>
Subject: RE: [PATCH] tcp: md5: fix md5 RST when both sides have listener
Date: Tue, 31 Jan 2012 13:15:17 -0500
Message-ID: <62162DF05402B341B3DB59932A1FA992B5B5B92D9D@EUSAACMS0702.eamcs.ericsson.se>
References: <1327975638-16530-1-git-send-email-shawn.lu@ericsson.com>
	 <CAL4WiipdO5+1Fi_ig5hB25d2LJvc+cjzyAbo8mxx3e4EiRx9YA@mail.gmail.com>
	 <62162DF05402B341B3DB59932A1FA992B5B5B929BD@EUSAACMS0702.eamcs.ericsson.se>
	 <1328000712.2422.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1328016828.2297.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr4.ericy.com ([198.24.6.9]:56010 "EHLO imr4.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753431Ab2AaSP3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 13:15:29 -0500
In-Reply-To: <1328016828.2297.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks! Eric. Good catch.  Will using RCU to pretect the md5 key.=20

-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
Sent: Tuesday, January 31, 2012 5:34 AM
To: Shawn Lu
Cc: davem@davemloft.net; netdev@vger.kernel.org; xiaoclu@gmail.com
Subject: RE: [PATCH] tcp: md5: fix md5 RST when both sides have listene=
r

Le mardi 31 janvier 2012 =E0 10:05 +0100, Eric Dumazet a =E9crit :

> Hmm... The second problem is that its not safe to call
> tcp_v4_md5_do_lookup() on an unlocked socket.
>=20
> And locking a listener is way too expensive, since a listener socket=20
> is already a contention point.
>=20
> An attacker could send forged tcp md5 packets to slow down a server.
>=20
> A proper patch needs RCU conversion first.

I am working on this RCU conversion and big md5 cleanup, using a single=
 list of keys.

You can then add your fix on top of this work.
[shawnlu] Good idea. I will resumit using rcu.

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
