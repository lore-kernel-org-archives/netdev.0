From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] af_unix: do not report POLLOUT on listeners
Date: Fri, 23 Oct 2015 10:59:16 -0700
Message-ID: <1445623156.22974.186.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151021185104.GM22011@ZenIV.linux.org.uk>
	 <20151021.182955.1434243485706993231.davem@davemloft.net>
	 <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk>
	 <20151022060304.GQ22011@ZenIV.linux.org.uk>
	 <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
	 <20151022172146.GS22011@ZenIV.linux.org.uk>
	 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
	 <20151022190701.GV22011@ZenIV.linux.org.uk>
	 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
	 <20151022215741.GW22011@ZenIV.linux.org.uk>
	 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
	 <1445605340.22974.140.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562A37A3.8000705@oracle.com>
	 <1445610118.22974.153.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562A563D.6020600@oracle.com>
	 <1445616011.22974.158.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1445617163.22974.163.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562A631B.6060207@oracle.com>
	 <1445622453.22974.180.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Alan Burlison <Alan.Burlison@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34242 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516AbbJWR7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 13:59:17 -0400
Received: by padhk11 with SMTP id hk11so124344109pad.1
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 10:59:17 -0700 (PDT)
In-Reply-To: <1445622453.22974.180.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

poll(POLLOUT) on a listener should not report fd is ready for
a write().

This would break some applications using poll() and pfd.events = -1,
as they would not block in poll()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Alan Burlison <Alan.Burlison@oracle.com>
Tested-by: Eric Dumazet <edumazet@google.com>
---
 net/unix/af_unix.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 94f658235fb4..aaa0b58d6aba 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -326,9 +326,10 @@ found:
 	return s;
 }
 
-static inline int unix_writable(struct sock *sk)
+static int unix_writable(const struct sock *sk)
 {
-	return (atomic_read(&sk->sk_wmem_alloc) << 2) <= sk->sk_sndbuf;
+	return sk->sk_state != TCP_LISTEN &&
+	       (atomic_read(&sk->sk_wmem_alloc) << 2) <= sk->sk_sndbuf;
 }
 
 static void unix_write_space(struct sock *sk)
