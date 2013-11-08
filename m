From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] inet: fix a UFO regression
Date: Thu, 07 Nov 2013 18:32:06 -0800
Message-ID: <1383877926.9412.145.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMEtUuzswOVA6UkPRjS-O=gOe9BLLJ5qaAG_eAd_fTqDJo8ofA@mail.gmail.com>
	 <1382674000.7572.75.camel@edumazet-glaptop.roam.corp.google.com>
	 <1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131025.181809.348808013109842304.davem@davemloft.net>
	 <CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
	 <1382923096.13037.10.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383863586.9412.101.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMEtUuwqmUhTgeKyodGKmOxhxe23=umnfc7nouhdVrqVNnk6zQ@mail.gmail.com>
	 <1383871465.9412.118.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:52794 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932391Ab3KHCcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 21:32:14 -0500
Received: by mail-pd0-f172.google.com with SMTP id w10so1475012pde.31
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 18:32:13 -0800 (PST)
In-Reply-To: <1383871465.9412.118.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While testing virtio_net and skb_segment() changes, Hannes reported
that UFO was sending wrong frames.

It appears this was introduced by a recent commit :
8c3a897bfab1 ("inet: restore gso for vxlan")

The old condition to perform IP frag was :

tunnel = !!skb->encapsulation;
...
        if (!tunnel && proto == IPPROTO_UDP) {

So the new one should be :

udpfrag = !skb->encapsulation && proto == IPPROTO_UDP;
...
        if (udpfrag) {

Initialization of udpfrag must be done before call
to ops->callbacks.gso_segment(skb, features), as
skb_udp_tunnel_segment() clears skb->encapsulation

(We want udpfrag to be true for UFO, false for VXLAN)

With help from Alexei Starovoitov

Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
---
v2: move the udpfrag init, as spotted by Alexei.

 net/ipv4/af_inet.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 09d78d4a3cff..68af9aac91d0 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1299,6 +1299,9 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 
 	segs = ERR_PTR(-EPROTONOSUPPORT);
 
+	/* Note : following gso_segment() might change skb->encapsulation */
+	udpfrag = !skb->encapsulation && proto == IPPROTO_UDP;
+
 	ops = rcu_dereference(inet_offloads[proto]);
 	if (likely(ops && ops->callbacks.gso_segment))
 		segs = ops->callbacks.gso_segment(skb, features);
@@ -1306,7 +1309,6 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	if (IS_ERR_OR_NULL(segs))
 		goto out;
 
-	udpfrag = !!skb->encapsulation && proto == IPPROTO_UDP;
 	skb = segs;
 	do {
 		iph = (struct iphdr *)(skb_mac_header(skb) + nhoff);
