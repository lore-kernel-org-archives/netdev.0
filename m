From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute uses too small of a receive buffer
Date: Wed, 28 Oct 2009 20:50:48 +0100
Message-ID: <4AE8A098.8040207@trash.net>
References: <4AE77F64.3090302@candelatech.com> <20091027162434.6dc31b2d@nehalam> <4AE7F859.7020105@gmail.com> <4AE895E8.60308@trash.net> <4AE89927.9090405@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020901070408040604090602"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64619 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754234AbZJ1Tuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 15:50:50 -0400
In-Reply-To: <4AE89927.9090405@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020901070408040604090602
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit

Ben Greear wrote:
> On 10/28/2009 12:05 PM, Patrick McHardy wrote:
>> Eric Dumazet wrote:
>>> Stephen Hemminger a écrit :
>>>> Just having larger buffer isn't guarantee of success. Allocating
>>>> a huge buffer is not going to work on embedded.
>>>>
>>>
>>> Please note we do not allocate a big buffer, only allow more small skbs
>>> to be queued on socket receive queue.
>>>
>>> If memory is not available, skb allocation will eventually fail
>>> and be reported as well, embedded or not.
>>>
>>> I vote for allowing 1024*1024 bytes instead of 32768,
>>> and eventually user should be warned that it is capped by
>>> /proc/sys/net/core/rmem_max
>>
>> How about this? It will double the receive queue limit on ENOBUFS
>> up to 1024 * 1024b, then bail out with the normal error message on
>> further ENOBUFS.
>>
>> Signed-off-by: Patrick McHardy<kaber@trash.net>
> 
> First:  This still pretty much guarantees that messages will be lost when
> the program starts (when messages are coming in too large of chunks for
> small buffers)
> If you are debugging something tricky, having lost messages will be
> very annoying!

Yeah, on second thought the probing also doesn't make too much sense
since the memory is only used when its really needed anyways. And its
capped by rmem_max.

> Second:  Why bail on ENOBUFS at all?  I don't see how it helps the user
> since they will probably just have to start it again, and will miss more
> messages than keeping going would have.

Agreed.

> And, even 1MB may not be enough for some scenarios.  So, probably best to
> let users over-ride the initial setting on cmd-line.  If not, then use
> a large value to start with.

How about this? It uses 1MB as receive buf limit by default (without
increasing /proc/sys/net/core/rmem_max it will be limited by less
however) and allows to specify the size manually using "-rcvbuf X"
(-r is already used, so you need to specify at least -rc).

Additionally rtnl_listen() continues on ENOBUFS after printing the
error message.

--------------020901070408040604090602
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 0e02468..61da15b 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -17,6 +17,8 @@ struct rtnl_handle
 	__u32			dump;
 };
 
+extern int rcvbuf;
+
 extern int rtnl_open(struct rtnl_handle *rth, unsigned subscriptions);
 extern int rtnl_open_byproto(struct rtnl_handle *rth, unsigned subscriptions, int protocol);
 extern void rtnl_close(struct rtnl_handle *rth);
diff --git a/ip/ip.c b/ip/ip.c
index 2bd54b2..b4c076a 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -50,7 +50,8 @@ static void usage(void)
 "                   tunnel | maddr | mroute | monitor | xfrm }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | link } |\n"
-"                    -o[neline] | -t[imestamp] | -b[atch] [filename] }\n");
+"                    -o[neline] | -t[imestamp] | -b[atch] [filename] |\n"
+"                    -rc[vbuf] [size]}\n");
 	exit(-1);
 }
 
@@ -213,6 +214,19 @@ int main(int argc, char **argv)
 			if (argc <= 1)
 				usage();
 			batch_file = argv[1];
+		} else if (matches(opt, "-rcvbuf") == 0) {
+			unsigned int size;
+
+			argc--;
+			argv++;
+			if (argc <= 1)
+				usage();
+			if (get_unsigned(&size, argv[1], 0)) {
+				fprintf(stderr, "Invalid rcvbuf size '%s'\n",
+					argv[1]);
+				exit(-1);
+			}
+			rcvbuf = size;
 		} else if (matches(opt, "-help") == 0) {
 			usage();
 		} else {
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index b68e2fd..5c716ab 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -25,6 +25,8 @@
 
 #include "libnetlink.h"
 
+int rcvbuf = 1024 * 1024;
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
 
@@ -409,6 +410,8 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 				continue;
 			fprintf(stderr, "netlink receive error %s (%d)\n",
 				strerror(errno), errno);
+			if (errno == ENOBUFS)
+				continue;
 			return -1;
 		}
 		if (status == 0) {

--------------020901070408040604090602--
