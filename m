From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2/3] [SCTP] Correctly copy addresses in sctp_copy_laddrs
Date: Wed,  9 May 2007 15:43:49 -0400
Message-ID: <11787398301224-git-send-email-vladislav.yasevich@hp.com>
References: <11787398302375-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:58505 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754394AbXEITnw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 15:43:52 -0400
In-Reply-To: <11787398302375-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I broke the  non-wildcard case recently.  This is to fixes it.
Now, explictitly bound addresses can ge retrieved using the API.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index cc2ed54..ef03bc4 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4164,6 +4164,7 @@ static int sctp_getsockopt_local_addrs_old(struct sock *sk, int len,
 	rwlock_t *addr_lock;
 	int err = 0;
 	void *addrs;
+	void *buf;
 	int bytes_copied = 0;
 
 	if (len != sizeof(struct sctp_getaddrs_old))
@@ -4217,13 +4218,14 @@ static int sctp_getsockopt_local_addrs_old(struct sock *sk, int len,
 		}
 	}
 
+	buf = addrs;
 	list_for_each(pos, &bp->address_list) {
 		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
 		memcpy(&temp, &addr->a, sizeof(temp));
 		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sp, &temp);
 		addrlen = sctp_get_af_specific(temp.sa.sa_family)->sockaddr_len;
-		memcpy(addrs, &temp, addrlen);
-		to += addrlen;
+		memcpy(buf, &temp, addrlen);
+		buf += addrlen;
 		bytes_copied += addrlen;
 		cnt ++;
 		if (cnt >= getaddrs.addr_num) break;
@@ -4266,6 +4268,7 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
 	size_t space_left;
 	int bytes_copied = 0;
 	void *addrs;
+	void *buf;
 
 	if (len <= sizeof(struct sctp_getaddrs))
 		return -EINVAL;
@@ -4316,6 +4319,7 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
 		}
 	}
 
+	buf = addrs;
 	list_for_each(pos, &bp->address_list) {
 		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
 		memcpy(&temp, &addr->a, sizeof(temp));
@@ -4325,8 +4329,8 @@ static int sctp_getsockopt_local_addrs(struct sock *sk, int len,
 			err =  -ENOMEM; /*fixme: right error?*/
 			goto error;
 		}
-		memcpy(addrs, &temp, addrlen);
-		to += addrlen;
+		memcpy(buf, &temp, addrlen);
+		buf += addrlen;
 		bytes_copied += addrlen;
 		cnt ++;
 		space_left -= addrlen;
-- 
1.5.0.3.438.gc49b2

