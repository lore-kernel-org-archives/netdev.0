From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH] Uninitialized dst in ip6_dst_lookup
Date: Tue, 20 Jan 2004 11:46:02 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401201115500.23508-100000@linux-udp15191261uds.beaverton.ibm.com>
References: <20040119211156.4bff1640.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, KK <krkumar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040119211156.4bff1640.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

ip6_dst_lookup() is supposed to fill in the *dst, hence it must not
dereference *dst until it allocates it. However if the passed sk is
NULL and *dst is not set by the caller, the following code will
dereference uninitialized memory :

	if (*dst == NULL)
		*dst = ip6_route_output(sk, fl); >>>>> will not execute
	if ((err = (*dst)->error))  >>>>> dereference bad stack address.
		goto out_err_release;

I am suggesting moving the responsibility of ensuring a good *dst from the
callers to ip6_dst_lookup().

Currently the existing code doesn't cause any problem since this routine
is called either with sk!=NULL or if sk is NULL, the *dst passed is NULL
(tcp_v6_send_reset() and tcp_v6_send_ack() do alloc_skb() which sets all
fields till truesize to NULL). However if some code is added/changed such
that sk is NULL and an uninitialized *dst is passed, we will reference
uninitialized *dst.

Suggesting following patch to handle this case.

thanks,

- KK

diff -ruN linux-2.6.1.bk2/net/ipv6/ip6_output.c linux-2.6.1.bk2.new/net/ipv6/ip6_output.c
--- linux-2.6.1.bk2/net/ipv6/ip6_output.c	2004-01-20 11:12:06.000000000 -0800
+++ linux-2.6.1.bk2.new/net/ipv6/ip6_output.c	2004-01-20 11:13:28.000000000 -0800
@@ -725,6 +725,7 @@
 {
 	int err = 0;

+	*dst = NULL;
 	if (sk) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
