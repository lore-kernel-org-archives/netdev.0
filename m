From: Jan Engelhardt <jengelh@medozas.de>
Subject: IPV6 raw socket denies bind(2)
Date: Thu, 28 Oct 2010 00:01:57 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1010280000260.7820@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:48475 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909Ab0J0WB7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Oct 2010 18:01:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Doublepost: linux-netdev does not exist. Sigh. "netdev" is totally 
nonstandard to all the other linux-* list names. :-?]

Hi,


I was trying out raw sockets and stumbled into a case whereby I cannot 
call bind(2) on a AF_INET6, SOCK_RAW socket. Apparently, I am triggering 
this particular code path that means absolutely nothing to me:

# ./rawtest

kernel pseudo callgraph:
static int rawv6_bind(struct sock *sk, struct sockaddr *uaddr, int 
addr_len)
addr >= SIN6_LEN_RFC2133
addr_type != IPV6_ADDR_MAPPED
sk->sk_state == TCP_CLOSED
addr_type != IPV6_ADDR_ANY
!(addr_type & IPV6_ADDR_LINKLOCAL)
!(addr_type & IPV6_ADDR_MULTICAST)
dev == NULL
ipv6_chk_addr does not have any addresses to loop through (wtf? checked 
with printk.)
=> going -EADDRNOTAVAIL

At this point I have no idea why ipv6_chk_addr does not run through 
its loop. No devices in the hash bucket or something. Happens in 
2.6.36. I hope somebody can shed some light here.

---Userspace testcase---
#include <sys/socket.h>
#include <stdio.h>
#include <string.h>
#include <netinet/udp.h>
#include <netinet/in.h>
#include <netinet/ip6.h>
#include <arpa/inet.h>
#include <stdlib.h>

int main(void)
{
	struct sockaddr_in6 src = {};
	int sk;

	sk = socket(AF_INET6, SOCK_RAW, IPPROTO_UDP);
	memset(&src, 0, sizeof(src));
	inet_pton(AF_INET6, "::1", &src);
	src.sin6_family = AF_INET6;

	if (bind(sk, (void *)&src, sizeof(src)) < 0) {
		perror("bind");
		abort();
	}
	return 0;
}
