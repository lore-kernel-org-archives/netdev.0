From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: IPV6 loopback bound socket succeeds connecting to remote host
Date: Wed, 01 Dec 2010 16:18:35 +0800
Message-ID: <4CF604DB.8000302@cn.fujitsu.com>
References: <328335.88387.qm@web29006.mail.ird.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"yoshfuji@linux-ipv6.org >> YOSHIFUJI Hideaki"
	<yoshfuji@linux-ipv6.org>, David Miller <davem@davemloft.net>,
	pekkas@netcore.fi, jmorris@namei.org
To: Albert Pretorius <albertpretorius@yahoo.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64517 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751971Ab0LAIUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 03:20:16 -0500
In-Reply-To: <328335.88387.qm@web29006.mail.ird.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Albert Pretorius wrote, at 11/29/2010 06:55 PM:
> Hi
> I found a problem with ipv6 when a UDP socket is bound to loopback (::1) and connecting to a remote address. The same applies to TCP.
> Any data sent ends up on the remote host with a source address of loopback. The expected result of the connect should be EINVAL just like it is for ipv4.
> Here is a possible patch that fixes this problem below. I tested it on 2.6.37-rc3 using a tool I put on http://www.gitorious.org/bindconnect

Indeed, there is  an guide in RFC4291 for us to use IPv6 loopback address.

See RFC4291 2.5.3 section:
   The loopback address must not be used as the source address in IPv6
   packets that are sent outside of a single node.  An IPv6 packet with
   a destination address of loopback must never be sent outside of a
   single node and must never be forwarded by an IPv6 router.  A packet
   received on an interface with a destination address of loopback must
   be dropped.

I think it make nonsense to translate data between loopback device and
other e.g. eth0 device in same machine. With your patch, also can't establish
a tcp connection from loopback device to other device in same host.  

=====
[PATCH] ipv6: forbid to send ipv6 packet from loopback to other device in same host

According to 2.5.3 section of RFC4291, commit f630e43 dropped the received packet with
loopback as destination address. Now forbid to send packet from loopback to other
device. Original patch is provided by Albert Pretorius.


Reported-by: Albert Pretorius <albertpretorius@yahoo.co.uk>
Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/ip6_output.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 99157b4..6b6cf84 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -927,6 +927,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 {
 	int err;
 	struct net *net = sock_net(sk);
+	struct net_device *dev_out;
 
 	if (*dst == NULL)
 		*dst = ip6_route_output(net, sk, fl);
@@ -934,6 +935,13 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	if ((err = (*dst)->error))
 		goto out_err_release;
 
+	dev_out = ip6_dst_idev(*dst)->dev;
+	if (dev_out && ipv6_addr_loopback(&fl->fl6_src) &&
+	    !(dev_out->flags & IFF_LOOPBACK)) {
+		err = -EINVAL;
+		goto out_err_release;
+	}
+
 	if (ipv6_addr_any(&fl->fl6_src)) {
 		err = ipv6_dev_get_saddr(net, ip6_dst_idev(*dst)->dev,
 					 &fl->fl6_dst,
-- 
1.6.3.3

