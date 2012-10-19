From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: listen(2) backlog changes in or around Linux 3.1?
Date: Fri, 19 Oct 2012 10:06:53 +0200
Message-ID: <1350634013.2293.262.camel@edumazet-glaptop>
References: <CAJgzZorigejCuFweNrvmkEJts3Um7exh1fYTH=4KrEcB=v=2SA@mail.gmail.com>
	 <507C4401.7050500@oracle.com>
	 <CAJgzZoqhw6HJxa6uRbekLMaVTDVOo92YDtzqHnZoRiQ8tq6G2g@mail.gmail.com>
	 <CAJgzZoq9+KZpQ1tVQJUK++VVk4JfY9u8timaJ5q6wSYoF+_tog@mail.gmail.com>
	 <5080279F.80008@oracle.com> <5080340F.3050207@oracle.com>
	 <CAJgzZooJM7aj=K-idvdbwUOOmtDM6u-=gsVOs2OFZjiZwQP0zw@mail.gmail.com>
	 <CAGK4HS-tOE1uZR2PE+_DShEb3y5ZAn=dtECY1AmmyO2AmTVzTA@mail.gmail.com>
	 <1350629413.2293.157.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: enh <enh@google.com>,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	netdev@vger.kernel.org
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50790 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753110Ab2JSIG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 04:06:59 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so67862bkc.19
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 01:06:57 -0700 (PDT)
In-Reply-To: <1350629413.2293.157.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-19 at 08:50 +0200, Eric Dumazet wrote:

> I came to the same analysis than you.
> 
> Current behavior is stupid, because the traffic for such 'sockets' is
> insane :
> 
> As we sent a SYNACK, client sends the 3rd packet (ACK), and we ignore
> it.
> 
> Then we keep retransmitting SYNACKS....
> 
> Oh well.


What about the following patch ?

 include/net/sock.h        |    7 ++++++-
 include/uapi/linux/snmp.h |    1 +
 net/ipv4/proc.c           |    1 +
 net/ipv4/tcp_ipv4.c       |    4 +++-
 net/ipv6/tcp_ipv6.c       |    3 ++-
 5 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 0baccb6..d2ecfbe 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -698,9 +698,14 @@ static inline void sk_acceptq_added(struct sock *sk)
 	sk->sk_ack_backlog++;
 }
 
+static inline bool __sk_acceptq_is_full(const struct sock *sk, unsigned int young)
+{
+	return (sk->sk_ack_backlog + young) > sk->sk_max_ack_backlog;
+}
+
 static inline bool sk_acceptq_is_full(const struct sock *sk)
 {
-	return sk->sk_ack_backlog > sk->sk_max_ack_backlog;
+	return __sk_acceptq_is_full(sk, 0);
 }
 
 /*
diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index fdfba23..5ff2daf 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -245,6 +245,7 @@ enum
 	LINUX_MIB_TCPFASTOPENPASSIVEFAIL,	/* TCPFastOpenPassiveFail */
 	LINUX_MIB_TCPFASTOPENLISTENOVERFLOW,	/* TCPFastOpenListenOverflow */
 	LINUX_MIB_TCPFASTOPENCOOKIEREQD,	/* TCPFastOpenCookieReqd */
+	LINUX_MIB_TCPSYNDROP,			/* TCPSynDrop */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 8de53e1..a5f59ab 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -267,6 +267,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPFastOpenPassiveFail", LINUX_MIB_TCPFASTOPENPASSIVEFAIL),
 	SNMP_MIB_ITEM("TCPFastOpenListenOverflow", LINUX_MIB_TCPFASTOPENLISTENOVERFLOW),
 	SNMP_MIB_ITEM("TCPFastOpenCookieReqd", LINUX_MIB_TCPFASTOPENCOOKIEREQD),
+	SNMP_MIB_ITEM("TCPSynDrop", LINUX_MIB_TCPSYNDROP),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ef998b0..0404926 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1507,7 +1507,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 * clogging syn queue with openreqs with exponentially increasing
 	 * timeout.
 	 */
-	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
+	if (__sk_acceptq_is_full(sk, inet_csk_reqsk_queue_young(sk)))
 		goto drop;
 
 	req = inet_reqsk_alloc(&tcp_request_sock_ops);
@@ -1673,6 +1673,7 @@ drop_and_release:
 drop_and_free:
 	reqsk_free(req);
 drop:
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNDROP);
 	return 0;
 }
 EXPORT_SYMBOL(tcp_v4_conn_request);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 26175bf..39ffc54 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1054,7 +1054,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 			goto drop;
 	}
 
-	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
+	if (__sk_acceptq_is_full(sk, inet_csk_reqsk_queue_young(sk)))
 		goto drop;
 
 	req = inet6_reqsk_alloc(&tcp6_request_sock_ops);
@@ -1204,6 +1204,7 @@ drop_and_release:
 drop_and_free:
 	reqsk_free(req);
 drop:
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNDROP);
 	return 0; /* don't send reset */
 }
 
