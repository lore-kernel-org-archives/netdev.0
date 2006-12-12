From: Brian Haley <brian.haley@hp.com>
Subject: Re: Fw: [Bugme-new] [Bug 7665] New: getsockopt(IPV6_*CAST_HOPS) returns
 -1
Date: Tue, 12 Dec 2006 16:16:27 -0500
Message-ID: <457F1C2B.9000800@hp.com>
References: <20061211095623.09fb0c40.akpm@osdl.org> <457DD3EB.9030201@hp.com> <200612120908.19378@auguste.remlab.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020903050603070509070104"
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:40121 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932311AbWLLVQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Dec 2006 16:16:31 -0500
To: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
In-Reply-To: <200612120908.19378@auguste.remlab.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020903050603070509070104
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

>>> Where fd is a socket (datagram or raw) with IPv6 protocol family,
>>> getsockopt(fd, IPPROTO_IPV6, IPV6_UNICAST_HOPS, ...) succeeds, but
>>> the returned hop limit is -1. connect()'ing the socket first does
>>> not solve the problem.
>> An IPv6 socket's hoplimit value is not set at creation time, instead,
>> the hoplimit in an outgoing packet is set dynamically at transmit
>> time to one of the following (in this order):
>>
>> 1. Hoplimit route metric (if set)
>> 2. Outgoing interface value (/proc/sys/net/ipv6/conf/ethX/hop_limit)
>> 3. Global IPv6 value (/proc/sys/net/ipv6/conf/all/hop_limit)
>>
>> A setsockopt() value *will* override this.
> 
> Relevant standard (RFC 3493) notes:
> 
>    The IPV6_UNICAST_HOPS option may be used with getsockopt() to
>    determine the hop limit value that the system will use for subsequent
>    unicast packets sent via that socket.
> 
> I don't reckon -1 could be the hop limit value.

-1 means un-initialized.

> IMHO, the value from 
> case 1 (if socket is connected to some destination), otherwise case 2 
> (if bound to a scope interface) or ultimately the default hop limit 
> ought to be returned instead, as it will be most often correct, while 
> the current behavior is always wrong, unless setsockopt() has been used 
> first. I don't if some people may think doing a route lookup in 
> getsockopt might be overly expensive, but at least the two other cases 
> should be ok, particularly the last one.

The following patch seems to work for me, but this code has behaved this 
way for a while, so don't know if it will break any existing apps.

-Brian


Signed-off-by: Brian Haley <brian.haley@hp.com>


--------------020903050603070509070104
Content-Type: text/x-patch;
 name="ipv6hops.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipv6hops.patch"

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 1eafcfc..352690e 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -978,12 +978,27 @@ static int do_ipv6_getsockopt(struct soc
 		break;
 
 	case IPV6_UNICAST_HOPS:
-		val = np->hop_limit;
-		break;
-
 	case IPV6_MULTICAST_HOPS:
-		val = np->mcast_hops;
+	{
+		struct dst_entry *dst;
+
+		if (optname == IPV6_UNICAST_HOPS)
+			val = np->hop_limit;
+		else
+			val = np->mcast_hops;
+
+		dst = sk_dst_get(sk);
+		if (dst) {
+			if (val < 0)
+				val = dst_metric(dst, RTAX_HOPLIMIT);
+			if (val < 0)
+				val = ipv6_get_hoplimit(dst->dev);
+			dst_release(dst);
+		}
+		if (val < 0)
+			val = ipv6_devconf.hop_limit;
 		break;
+	}
 
 	case IPV6_MULTICAST_LOOP:
 		val = np->mc_loop;

--------------020903050603070509070104--
