From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] RxRPC: use copy_to_user() instead of memcpy()
Date: Wed, 20 Mar 2013 01:51:02 +0300
Message-ID: <20130319225101.GZ9189@mwanda>
References: <20130319.094240.1315516663563952557.davem@davemloft.net>
 <20130318105503.GA17102@longonot.mountain>
 <30707.1363701570@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="W/nzBZO5zC0uMSeA"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20657 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934117Ab3CSWvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 18:51:20 -0400
Content-Disposition: inline
In-Reply-To: <30707.1363701570@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Thanks for the explanation.  I misread the code and then managed to
trigger an unrelated locking bug and got confused.

I think there is a spin_unlock(call->lock) missing somewhere on an
error path.  I have attached a reproducer file.

regards,
dan carpenter


--W/nzBZO5zC0uMSeA
Content-Type: text/x-csrc; charset=utf-8
Content-Disposition: attachment; filename="test_rxrpc.c"
Content-Transfer-Encoding: 8bit

/* klog.c: description
 *
 * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
 * Written by David Howells (dhowells@redhat.com)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version
 * 2 of the License, or (at your option) any later version.
 *
 * Based on code:
 *
 * Copyright (c) 1995 - 2000 Kungliga Tekniska Högskolan
 * (Royal Institute of Technology, Stockholm, Sweden).
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the Institute nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE INSTITUTE AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE INSTITUTE OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#define _XOPEN_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <ctype.h>
#include <time.h>
#include <signal.h>
#include <errno.h>
#include <termios.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <keyutils.h>
//#include <rpc/xdr.h>

#define KA_SERVICE 731
#define KA_TICKET_GRANTING_SERVICE 732

#define OSERROR(X, Y) do { if ((long)(X) == -1) { perror(Y); exit(1); } } while(0)

struct sockaddr_rxrpc {
	sa_family_t	srx_family;	/* address family */
	unsigned short	srx_service;	/* service desired */
	unsigned short	transport_type;	/* type of transport socket (SOCK_DGRAM) */
	unsigned short	transport_len;	/* length of transport address */
	union {
		sa_family_t family;		/* transport address family */
		struct sockaddr_in sin;		/* IPv4 transport address */
		struct sockaddr_in6 sin6;	/* IPv6 transport address */
	} transport;
};

#define SOL_RXRPC		272
#define RXRPC_USER_CALL_ID	1	/* User call ID specifier */
#define RXRPC_ABORT		2	/* Abort request / notification */
#define RXRPC_ACK		3	/* [Server] RPC op final ACK received */
#define RXRPC_RESPONSE		4	/* [Server] security response received */
#define RXRPC_NET_ERROR		5	/* network error received */
#define RXRPC_BUSY		6	/* server busy received */
#define RXRPC_LOCAL_ERROR	7	/* local error generated */
#define RXRPC_PREPARE_CALL_SLOT	8	/* Propose user call ID specifier for next call */
#define RXRPC_SECURITY_KEY		1	/* [clnt] set client security key */
#define RXRPC_SECURITY_KEYRING		2	/* [srvr] set ring of server security keys */
#define RXRPC_EXCLUSIVE_CONNECTION	3	/* [clnt] use exclusive RxRPC connection */
#define RXRPC_MIN_SECURITY_LEVEL	4	/* minimum security level */

#define OSERROR(X, Y) do { if ((long)(X) == -1) { perror(Y); exit(1); } } while(0)

static const unsigned char local_addr[4] = { 0, 0, 0, 0 };
static const unsigned char remote_addr[4] = { 127, 0, 0, 1 };

#define RXRPC_ADD_CALLID(control, ctrllen, id)				\
do {									\
	struct cmsghdr *__cmsg;						\
	__cmsg = (void *)(control) + (ctrllen);				\
	__cmsg->cmsg_len	= CMSG_LEN(sizeof(unsigned long));	\
	__cmsg->cmsg_level	= SOL_RXRPC;				\
	__cmsg->cmsg_type	= RXRPC_USER_CALL_ID;			\
	*(unsigned long *)CMSG_DATA(__cmsg) = (id);			\
	(ctrllen) += __cmsg->cmsg_len;					\
									\
} while (0)

int main(int argc, char *argv[])
{
	struct sockaddr_rxrpc srx;
	struct msghdr send;
	struct msghdr msg;
	struct iovec iov[1];
	size_t ctrllen, replen;
	unsigned char control[4096];
	void *preply;
	int client, ret;
	int service = KA_SERVICE;
	char buffer[16384] __attribute__((aligned(4)));
	void *request = buffer;
	size_t reqlen = sizeof(buffer);
	void *reply = buffer;
	size_t replen_tmp = sizeof(buffer);
	size_t *_replen = &replen_tmp;
	void *p = NULL;
	int i;

	client = socket(AF_RXRPC, SOCK_DGRAM, PF_INET);
	OSERROR(client, "socket");

	/* the authentication is associated with the virtual
	 * connection, so we need to open an exclusive channel */
	ret = setsockopt(client, SOL_RXRPC, RXRPC_EXCLUSIVE_CONNECTION,
			 NULL, 0);
	OSERROR(ret, "setsockopt");

	/* bind an address to the local endpoint */
	srx.srx_family = AF_RXRPC;
	srx.srx_service = 0; /* it's a client */
	srx.transport_type = SOCK_DGRAM;
	srx.transport_len = sizeof(srx.transport.sin);
	srx.transport.sin.sin_family = AF_INET;
	srx.transport.sin.sin_port = htons(7001);
	memcpy(&srx.transport.sin.sin_addr, &local_addr, 4);

	ret = bind(client, (struct sockaddr *) &srx, sizeof(srx));
	OSERROR(ret, "bind");

	/* connect to the remote server */
	srx.srx_family = AF_RXRPC;
	srx.srx_service = service;
	srx.transport_type = SOCK_DGRAM;
	srx.transport_len = sizeof(srx.transport.sin);
	srx.transport.sin.sin_family = AF_INET;
	srx.transport.sin.sin_port = htons(7004);
	memcpy(&srx.transport.sin.sin_addr, &remote_addr, 4);

	ret = connect(client, (struct sockaddr *) &srx, sizeof(srx));
	OSERROR(ret, "connect");

	/* request an operation */
	ctrllen = 0;
	RXRPC_ADD_CALLID(control, ctrllen, 0x12345);

	iov[0].iov_base = (void *) request;
	iov[0].iov_len = reqlen;

	send.msg_name		= NULL;
	send.msg_namelen	= 0;
	send.msg_iov		= iov;
	send.msg_iovlen		= 1;
	send.msg_control	= control;
	send.msg_controllen	= ctrllen;
	send.msg_flags		= 0;


	/* wait for a reply */
	preply = reply;
	replen = 0;
	for (i = 0; i < 2; i++) {

		iov[0].iov_base = preply;
		iov[0].iov_len = *_replen - replen;

		ret = sendmsg(client, &send, 0);
		if (ret == -1 && (errno == ENOANO || errno == ECONNABORTED))
			perror("sendmsg/data");
		else
			OSERROR(ret, "sendmsg/data");


		p += 10000;
		msg.msg_name	= p;
		msg.msg_namelen	= sizeof(struct sockaddr_rxrpc);
		msg.msg_iov	= iov;
		msg.msg_iovlen	= 1;
		msg.msg_control	= control;
		msg.msg_controllen = sizeof(control);
		msg.msg_flags	= 0;

		ret = recvmsg(client, &msg, 0);
		if (ret < 0) {
			printf("%d %p recvmsg %s\n", i, p, strerror(errno));
			continue;
		}

		printf("RECV: %d [fl:%d]\n", ret, msg.msg_flags);
		printf("CMSG: %zu\n", msg.msg_controllen);
		printf("IOV: %zu [0]=%zu\n", msg.msg_iovlen, iov[0].iov_len);

		preply += ret;
		replen += ret;

		if (msg.msg_flags & MSG_EOR)
			break;
	}

	*_replen = replen;
	close(client);
	return 0;
}


--W/nzBZO5zC0uMSeA--
