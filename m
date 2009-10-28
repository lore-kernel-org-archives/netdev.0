From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute uses too small of a receive buffer
Date: Wed, 28 Oct 2009 20:05:12 +0100
Message-ID: <4AE895E8.60308@trash.net>
References: <4AE77F64.3090302@candelatech.com> <20091027162434.6dc31b2d@nehalam> <4AE7F859.7020105@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070301080807020604040406"
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63866 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbZJ1TFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 15:05:14 -0400
In-Reply-To: <4AE7F859.7020105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070301080807020604040406
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit

Eric Dumazet wrote:
> Stephen Hemminger a écrit :
>> Just having larger buffer isn't guarantee of success. Allocating
>> a huge buffer is not going to work on embedded.
>>
> 
> Please note we do not allocate a big buffer, only allow more small skbs
> to be queued on socket receive queue.
> 
> If memory is not available, skb allocation will eventually fail
> and be reported as well, embedded or not.
> 
> I vote for allowing 1024*1024 bytes instead of 32768,
> and eventually user should be warned that it is capped by 
> /proc/sys/net/core/rmem_max

How about this? It will double the receive queue limit on ENOBUFS
up to 1024 * 1024b, then bail out with the normal error message on
further ENOBUFS.

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------070301080807020604040406
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index b68e2fd..e4fda40 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -25,6 +25,8 @@
 
 #include "libnetlink.h"
 
+static int rcvbuf = 32768;
+
 void rtnl_close(struct rtnl_handle *rth)
 {
 	if (rth->fd >= 0) {
@@ -38,7 +40,6 @@ int rtnl_open_byproto(struct rtnl_handle *rth, unsigned subscriptions,
 {
 	socklen_t addr_len;
 	int sndbuf = 32768;
-	int rcvbuf = 32768;
 
 	memset(rth, 0, sizeof(*rth));
 
@@ -407,6 +409,12 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 		if (status < 0) {
 			if (errno == EINTR || errno == EAGAIN)
 				continue;
+			if (errno == ENOBUFS && rcvbuf < 1024 * 1024) {
+				rcvbuf *= 2;
+				if (setsockopt(rtnl->fd, SOL_SOCKET, SO_RCVBUF,
+					       &rcvbuf, sizeof(rcvbuf)) == 0)
+					continue;
+			}
 			fprintf(stderr, "netlink receive error %s (%d)\n",
 				strerror(errno), errno);
 			return -1;

--------------070301080807020604040406--
