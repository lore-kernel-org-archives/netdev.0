From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [BUG] in inet6_create
Date: Fri, 02 Nov 2007 12:59:38 +0300
Message-ID: <472AF50A.5070706@openvz.org>
References: <472A3218.20708@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roel Kluin <12o3l@tiscali.nl>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47280 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752275AbXKBJ7u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2007 05:59:50 -0400
In-Reply-To: <472A3218.20708@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roel Kluin wrote:
> I got this bug recently, I am not sure whether this is related to any previously 
> reported ones. It was a recently pulled git kernel. Also I have been hacking my
> kernel a bit lately, but I think that I haven't got any changes in the currently
> running kernel.
> 
> FYI: my network card was not running (module not loaded, and I just started 
> thunderbird)
> 
> Roel
> 
> More information needed?

I've tried to objdump my ipv6.ko, and found (at the different offset,
but) the same codeline. It showed that the buggy place was in:

        list_for_each_rcu(p, &inetsw6[sock->type]) {

some list_head pointer was NULL.

I looked at the inet6_init (which seems to run at the moment of the
oops according to the calltrace) and found that the ipv6 protocol 
is first registered and only after this the inetsw6 lists are
properly initialized.

I suspect that this is a race: we create the socket right after
the new protocol is registered, but before the list heads are 
ready. The ->init call is called without the stopmachine, so
other process run in parallel with it.

This patch should help, but I don't think that such a situation
is easily reproducible.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index ecbd388..f9bd26f 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -769,6 +769,10 @@ static int __init inet6_init(void)
 #endif
 #endif
 
+	/* Register the socket-side information for inet6_create.  */
+	for(r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)
+		INIT_LIST_HEAD(r);
+
 	err = proto_register(&tcpv6_prot, 1);
 	if (err)
 		goto out;
@@ -786,10 +790,6 @@ static int __init inet6_init(void)
 		goto out_unregister_udplite_proto;
 
 
-	/* Register the socket-side information for inet6_create.  */
-	for(r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)
-		INIT_LIST_HEAD(r);
-
 	/* We MUST register RAW sockets before we create the ICMP6,
 	 * IGMP6, or NDISC control sockets.
 	 */
