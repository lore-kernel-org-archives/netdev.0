From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net] ipv6: Count in extension headers in skb->network_header
Date: Tue,  5 Apr 2016 18:41:08 +0200
Message-ID: <4697d0324d0b4313cbc2053b49ac85ec955b81cb.1459872592.git.jkbs@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ji Jianwen <jiji@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57787 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757763AbcDEQlm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 12:41:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sending a UDPv6 message longer than MTU, account for the length
of fragmentable IPv6 extension headers in skb->network_header offset.
Same as we do in alloc_new_skb path in __ip6_append_data().

This ensures that later on __ip6_make_skb() will make space in
headroom for fragmentable extension headers:

	/* move skb->data to ip header from ext header */
	if (skb->data < skb_network_header(skb))
		__skb_pull(skb, skb_network_offset(skb));

Prevents a splat due to skb_under_panic:

skbuff: skb_under_panic: text:ffffffff8143397b len:2126 put:14 \
head:ffff880005bacf50 data:ffff880005bacf4a tail:0x48 end:0xc0 dev:lo
------------[ cut here ]------------
kernel BUG at net/core/skbuff.c:104!
invalid opcode: 0000 [#1] KASAN
CPU: 0 PID: 160 Comm: reproducer Not tainted 4.6.0-rc2 #65
[...]
Call Trace:
 [<ffffffff813eb7b9>] skb_push+0x79/0x80
 [<ffffffff8143397b>] eth_header+0x2b/0x100
 [<ffffffff8141e0d0>] neigh_resolve_output+0x210/0x310
 [<ffffffff814eab77>] ip6_finish_output2+0x4a7/0x7c0
 [<ffffffff814efe3a>] ip6_output+0x16a/0x280
 [<ffffffff815440c1>] ip6_local_out+0xb1/0xf0
 [<ffffffff814f1115>] ip6_send_skb+0x45/0xd0
 [<ffffffff81518836>] udp_v6_send_skb+0x246/0x5d0
 [<ffffffff8151985e>] udpv6_sendmsg+0xa6e/0x1090
[...]

Reported-by: Ji Jianwen <jiji@redhat.com>
Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

Can be reproduced by sending a UDPv6 message longer than MTU when
Destination Options are present, as shown below.

Original reproducer has been developed by Ji Jianwen.  Cut down
version included.

# ip link set dev lo mtu 1500
# ./reproducer 0 1024		# works
# ./reproducer 8 1024		# works
# ./reproducer 64 1024		# works
# ./reproducer 0 2048		# works
# ./reproducer 8 2048		# crash
# ./reproducer 64 2048		# crash


/* reproducer.c */

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void set_dstopts(int s, int len)
{
	char *dstopts;
	int r;

	assert(len % 8 == 0);

	dstopts = calloc(len, 1);
	dstopts[1] = len / 8 - 1; /* Hdr Ext Len */
	dstopts[2] = 1;		  /* PadN Option */
	dstopts[3] = len - 4;	  /* Opt Data Len */

	r = setsockopt(s, IPPROTO_IPV6, IPV6_DSTOPTS, dstopts, len);
	if (r < 0) {
		perror("setsockopt");
		exit(1);
	}

	free(dstopts);
}

static void do_send(int s, const struct addrinfo *ai, int len)
{
	struct msghdr msg;
	struct iovec iov[1];
	char *data;
	int r;

	data = malloc(len);
	memset(data, 'A', len);
	memset(&msg, 0, sizeof(msg));
	iov[0].iov_base = data;
	iov[0].iov_len = len;

	msg.msg_name = ai->ai_addr;
	msg.msg_namelen = ai->ai_addrlen;
	msg.msg_iov = iov;
	msg.msg_iovlen = 1;
	msg.msg_control = 0;
	msg.msg_controllen = 0;

	r = sendmsg(s, &msg, 0);
	if (r < 0) {
		perror("sendmsg");
		exit(1);
	}

	free(data);
}

int main(int argc, char *argv[])
{
	struct addrinfo *ai = NULL;
	int dstopts_len, data_len;
	int r, s;

	if (argc != 3) {
		fprintf(stderr, "Usage: %s <dstopts-bytes> <data-bytes>\n", argv[0]);
		return 1;
	}

	dstopts_len = atoi(argv[1]);
	data_len = atoi(argv[2]);

	r = getaddrinfo("::1", "12345", NULL, &ai);
	assert(r == 0);

	s = socket(ai->ai_family, SOCK_DGRAM, IPPROTO_UDP);
	assert(s != -1);

	if (dstopts_len > 0)
		set_dstopts(s, dstopts_len);
	do_send(s, ai, data_len);

	freeaddrinfo(ai);

	return 0;
}


 net/ipv6/ip6_output.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9428345..bc972e7 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1090,8 +1090,8 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 			int getfrag(void *from, char *to, int offset, int len,
 			int odd, struct sk_buff *skb),
 			void *from, int length, int hh_len, int fragheaderlen,
-			int transhdrlen, int mtu, unsigned int flags,
-			const struct flowi6 *fl6)
+			int exthdrlen, int transhdrlen, int mtu,
+			unsigned int flags, const struct flowi6 *fl6)
 
 {
 	struct sk_buff *skb;
@@ -1116,7 +1116,7 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 		skb_put(skb, fragheaderlen + transhdrlen);
 
 		/* initialize network header pointer */
-		skb_reset_network_header(skb);
+		skb_set_network_header(skb, exthdrlen);
 
 		/* initialize protocol header pointer */
 		skb->transport_header = skb->network_header + fragheaderlen;
@@ -1358,7 +1358,7 @@ emsgsize:
 	    (rt->dst.dev->features & NETIF_F_UFO) &&
 	    (sk->sk_type == SOCK_DGRAM) && !udp_get_no_check6_tx(sk)) {
 		err = ip6_ufo_append_data(sk, queue, getfrag, from, length,
-					  hh_len, fragheaderlen,
+					  hh_len, fragheaderlen, exthdrlen,
 					  transhdrlen, mtu, flags, fl6);
 		if (err)
 			goto error;
-- 
2.5.5
