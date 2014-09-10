From: Konstantinos Kolelis <k.kolelis@sirrix.com>
Subject: [BUG REPORT]  Unencrypted packets after SNAT, allthough IPSEC-Policies
 are present
Date: Wed, 10 Sep 2014 19:26:53 +0200
Message-ID: <541089DD.6060307@sirrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.sirrix.com ([176.9.214.66]:33063 "EHLO mx.sirrix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074AbaIJRqx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 13:46:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

i' ve observed a problem with xfrm lookups, SNAT, blackhole route and
missing SAs.
The problem occures with all Kernels above 3.6.x and might has to do
with the changes in
ip4_blackhole_route() function in net/route.c.

Let say you have two network interfaces:
eth0 with ip 172.16.0.10/24
and
eth1 with ip 192.168.0.1/24

and you have done the following configuration:

iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j SNAT --to-source
172.16.0.10

and

ip xfrm policy add dir out  src 172.16.0.10 dst 0.0.0.0/0 tmpl proto esp
src 172.16.0.10 dst 172.31.0.10 mode tunnel

with the following routes:
default via 172.16.0.1 dev eth0  proto static
172.16.0.0/24 dev eth0  proto kernel  scope link  src 172.16.0.10
192.168.0.0/24 dev eth1  proto kernel  scope link  src 192.168.0.1

If for what ever reason IPSEC-SAs can not be established, maybe because
172.31.0.10 is down,
the traffic comming from 192.168.0.0/24 will leave unencrypted the
external (eth0) interface.

I can see that the traffic is source-Nated correctly and
xfrm_me_harder() is called.
Also i can see that a xfrm_bundle can not be created so
make_blackhole_route()
and ip4_blackhole_route() is called. But the callback for dst_output()
is never called afterwards.

The following Patch is workaround which restores the expected behavior.
It should work for Kernel 3.6.x and higher.


diff -rupN a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c    2014-09-06 01:37:11.000000000 +0200
+++ b/net/ipv4/ip_output.c    2014-09-10 16:27:12.287893706 +0200
@@ -260,6 +260,9 @@ static int ip_finish_output(struct sk_bu
     if (skb_dst(skb)->xfrm != NULL) {
         IPCB(skb)->flags |= IPSKB_REROUTED;
         return dst_output(skb);
+    } else if (skb_dst(skb)->error == -EINVAL) {
+        IPCB(skb)->flags |= IPSKB_REROUTED;
+        return dst_output(skb);
     }
 #endif
     if (skb_is_gso(skb))
diff -rupN a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c    2014-09-06 01:37:11.000000000 +0200
+++ b/net/ipv4/route.c    2014-09-10 16:13:07.179847637 +0200
@@ -2231,6 +2231,7 @@ struct dst_entry *ipv4_blackhole_route(s
         struct dst_entry *new = &rt->dst;
 
         new->__use = 1;
+        new->error = -EINVAL;
         new->input = dst_discard;
         new->output = dst_discard_sk;
 


Please let me know if you need more details.

Best regards,

   Kosta
