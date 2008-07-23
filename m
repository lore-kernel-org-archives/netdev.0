From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC][PATCH 0/3] net: per skb control messages
Date: Thu, 24 Jul 2008 01:01:01 +0300
Message-ID: <1216850464-30000-1-git-send-email-opurdila@ixiacom.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1937 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750799AbYGWWD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 18:03:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everybody,

These patches are a follow up on two previous [rfc] threads: 
- new sk_buff member: hwstamp [1]
- support for IEEE 1588 [2]

[1] http://www.spinics.net/lists/netdev/msg68804.html
[2] http://www.spinics.net/lists/netdev/msg67799.html

The idea is to associate control messages with skbs - for both 
out-going and in-going traffic. 

The RX case seems pretty straight forward.  

For the TX case, I am queueing an empty (or a clone of the original)
skb (with control messages attached) to the error queue of the socket
the TX skb belongs to.

To make an idea about how would this be used from userspace, I've
added a simple userspace demo for getting TX hardware timestamps.

I still ended up adding a new skb member but since this is a bit more
generic maybe it can offset the cost?

Thanks,
tavi
---
#include <stdlib.h>
#include <string.h>
#include <error.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/poll.h>
#include <sys/uio.h>
#include <netinet/in.h>

typedef unsigned long long __u64;
typedef unsigned long long __u32;

#define SOL_SKB 275

#include "include/linux/skb_cmsg.h"

struct cmsg_tx_tstamp  {
	struct cmsghdr hdr;
	struct skb_tx_tstamp stt __attribute__ ((packed));
};


int main()
{
	char buffer[100];
	struct iovec iovec = {
		.iov_base = buffer,
		.iov_len = sizeof(buffer)
	};
	struct cmsg_tx_tstamp ctt = {
		.hdr = {
			.cmsg_len = sizeof(ctt),
			.cmsg_level = SOL_SKB,
			.cmsg_type = SKB_TX_GET_TSTAMP
		},
		.stt = {
			.cookie = 0x0bad0badbeefbeefULL,
		}
	};
	struct sockaddr_in daddr = {
		.sin_family = AF_INET,
		.sin_port = 8888,
		.sin_addr = { htonl(0x01010101) }
	};
	struct msghdr msg = {
		.msg_iov = &iovec,
		.msg_iovlen = 1,
		.msg_control = &ctt,
		.msg_controllen = sizeof(ctt),
		.msg_name = &daddr,
		.msg_namelen = sizeof(daddr)
	};
	int s=socket(PF_INET, SOCK_DGRAM, 0);
	struct pollfd pollfd = {
		.fd = s,
		.events = POLLERR,
	};

	printf("%d %d %d %llx %llx\n", ctt.hdr.cmsg_len, ctt.hdr.cmsg_level,
	       ctt.hdr.cmsg_type, ctt.stt.cookie, ctt.stt.tstamp);

	if (sendmsg(s, &msg, 0) < 0)
		perror("sendmsg");

	poll(&pollfd, 1, -1);

	if (recvmsg(s, &msg, MSG_ERRQUEUE) < 0)
		perror("recvmsg");

	return printf("%d %d %d %llx %llx\n", ctt.hdr.cmsg_len,
		      ctt.hdr.cmsg_level, ctt.hdr.cmsg_type, ctt.stt.tstamp,
		      ctt.stt.cookie);
}
---
