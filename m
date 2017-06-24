From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: RFC: sk leak in sock_graft?
Date: Sat, 24 Jun 2017 09:08:27 -0400
Message-ID: <20170624130827.GD6901@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42217 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750817AbdFXNIe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Jun 2017 09:08:34 -0400
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v5OD8Vhd015975
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Sat, 24 Jun 2017 13:08:31 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id v5OD8UV1024780
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Sat, 24 Jun 2017 13:08:30 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id v5OD8U8n012783
        for <netdev@vger.kernel.org>; Sat, 24 Jun 2017 13:08:30 GMT
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're seeing a memleak when we run an infinite loop that 
loads/unloads rds-tcp, and runs some traffic between each 
load/unload.

Analysis shows that this is happening for the following reason:

inet_accept -> sock_graft does
	parent->sk = sk
but if the parent->sk was previously pointing at some other
struct sock "old_sk" (happens in the case of rds_tcp_accept_one()
which has historically called sock_create_kern() to set up
the new_sock), we need to sock_put(old_sk), else we'd leak it.

In general, sock_graft() is cutting loose the parent->sk,
so it looks like it needs to release its refcnt on it?

Patch below takes care of the leak in our case, but I could use
some input on other locking considerations, and if this is ok
with other modules that use sock_graft()

-----------------------patch below---------------------------------

diff --git a/include/net/sock.h b/include/net/sock.h
index 5374c0d..014ad56 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1686,12 +1686,19 @@ static inline void sock_orphan(struct sock *sk)
 
 static inline void sock_graft(struct sock *sk, struct socket *parent)
 {
+       struct sock *old_sk;
+
        write_lock_bh(&sk->sk_callback_lock);
        sk->sk_wq = parent->wq;
+       old_sk = parent->sk;
        parent->sk = sk;
        sk_set_socket(sk, parent);
        security_sock_graft(sk, parent);
        write_unlock_bh(&sk->sk_callback_lock);
+       if (old_sk) {
+               sock_orphan(old_sk);
+               sock_put(old_sk);
+       }
 }
