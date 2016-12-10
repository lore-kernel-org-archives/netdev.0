From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Fri, 09 Dec 2016 20:14:58 -0800
Message-ID: <1481343298.4930.208.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CALx6S36OVUqAxq9vNnfHp2eJOuG+gSSg896zzaZoc3Og4tyxFw@mail.gmail.com>
         <1481231024.1911284.813071977.72AF4DEE@webmail.messagingengine.com>
         <1481233016.11849.1@smtp.office365.com>
         <1481243432.4930.145.camel@edumazet-glaptop3.roam.corp.google.com>
         <6C6EE0ED-7E78-4866-8AAF-D75FD4719EF3@fb.com>
         <1481335192.3663.0@smtp.office365.com>
         <1481341624.4930.204.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36094 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751623AbcLJEPB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 23:15:01 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so4208768pgx.3
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 20:15:01 -0800 (PST)
In-Reply-To: <1481341624.4930.204.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-12-09 at 19:47 -0800, Eric Dumazet wrote:

> 
> Hmm... Is your ephemeral port range includes the port your load
> balancing app is using ?

I suspect that you might have processes doing bind( port = 0) that are
trapped into the bind_conflict() scan ?

With 100,000 + timewaits there, this possibly hurts.

Can you try the following loop breaker ?

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index d5d3ead0a6c31e42e8843d30f8c643324a91b8e9..74f0f5ee6a02c624edb0263b9ddd27813f68d0a5 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -51,7 +51,7 @@ int inet_csk_bind_conflict(const struct sock *sk,
 	int reuse = sk->sk_reuse;
 	int reuseport = sk->sk_reuseport;
 	kuid_t uid = sock_i_uid((struct sock *)sk);
-
+	unsigned int max_count;
 	/*
 	 * Unlike other sk lookup places we do not check
 	 * for sk_net here, since _all_ the socks listed
@@ -59,6 +59,7 @@ int inet_csk_bind_conflict(const struct sock *sk,
 	 * one this bucket belongs to.
 	 */
 
+	max_count = relax ? ~0U : 100;
 	sk_for_each_bound(sk2, &tb->owners) {
 		if (sk != sk2 &&
 		    !inet_v6_ipv6only(sk2) &&
@@ -84,6 +85,8 @@ int inet_csk_bind_conflict(const struct sock *sk,
 					break;
 			}
 		}
+		if (--max_count == 0)
+			return 1;
 	}
 	return sk2 != NULL;
 }
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 1c86c478f578b49373e61a4c397f23f3dc7f3fc6..4f63d06e0d601da94eb3f2b35a988abd060e156c 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -35,12 +35,14 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 	int reuse = sk->sk_reuse;
 	int reuseport = sk->sk_reuseport;
 	kuid_t uid = sock_i_uid((struct sock *)sk);
+	unsigned int max_count;
 
 	/* We must walk the whole port owner list in this case. -DaveM */
 	/*
 	 * See comment in inet_csk_bind_conflict about sock lookup
 	 * vs net namespaces issues.
 	 */
+	max_count = relax ? ~0U : 100;
 	sk_for_each_bound(sk2, &tb->owners) {
 		if (sk != sk2 &&
 		    (!sk->sk_bound_dev_if ||
@@ -61,6 +63,8 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 			    ipv6_rcv_saddr_equal(sk, sk2, true))
 				break;
 		}
+		if (--max_count == 0)
+			return 1;
 	}
 
 	return sk2 != NULL;
