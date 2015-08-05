From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC] ipvlan: Problems with ipvlan and IPv6
Date: Wed, 5 Aug 2015 13:28:20 -0700
Message-ID: <1438806500-2384382-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:47457 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753204AbbHEU2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 16:28:25 -0400
Received: from pps.filterd (m0004347 [127.0.0.1])
	by m0004347.ppops.net (8.14.5/8.14.5) with SMTP id t75KRFlO004290
	for <netdev@vger.kernel.org>; Wed, 5 Aug 2015 13:28:24 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004347.ppops.net with ESMTP id 1w3s5f021e-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 13:28:24 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 849a0fb83bb011e58c8d0002c9521c9e-817f92b0 for <netdev@vger.kernel.org>;	Wed,
 05 Aug 2015 13:28:23 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just doing:

ip link add name ipvl0 link eth0 type ipvlan
ip -6 addr add 3333:0:0:1:5555:0:1:1/128 dev ipvl0
ip addr add 192.168.1.1/32 dev iplv0

Before patch:

  ping 3333:0:0:1:5555:0:1:1

   - No response, tcpdump on ipvl0 shows two copies of each ICMP echo
     request.

  ping 192.168.1.1

   - Works, tcpdump on ipvl0 shows nothing

With patch applied:

  ping 3333:0:0:1:5555:0:1:1

   - Works, tcpdump on ipvl0 shows nothing

  ping 192.168.1.1

   - Works, tcpdump on ipvl0 shows nothing

Some other problems I'm seeing
-  Occurrence of "Dead loop on virtual device ipvl0, fix it urgently!"

   Running following script several times seems to get to the error.
   Once in this state machine is pretty locked up:

     rmmod ipvlan

     for i  in `seq 0 199`;
     do
  	ip link add name ipvl$i link eth0 type ipvlan
        addr=`echo $i | awk '{printf("%04x", $1)}'`
	ip -6 addr add 3333:0:0:1:5555:0:1:$addr/128 dev ipvl$i
	ifconfig ipvl$i up
     done

- Seeing "Dropped {multi|broad}cast of type= [86dd]"

  Looks like this may be from ND messages. Might be innocuous I
  suppose, but it is annoying to see in logs.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 207f62e..0b68538 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -277,8 +277,8 @@ static int ipvlan_rcv_frame(struct ipvl_addr *addr, struct sk_buff *skb,
 	skb->pkt_type = PACKET_HOST;
 
 	if (local) {
-		if (dev_forward_skb(ipvlan->dev, skb) == NET_RX_SUCCESS)
-			success = true;
+		netif_receive_skb(skb);
+		success = true;
 	} else {
 		ret = RX_HANDLER_ANOTHER;
 		success = true;
@@ -384,7 +384,7 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
 	struct dst_entry *dst;
 	int err, ret = NET_XMIT_DROP;
 	struct flowi6 fl6 = {
-		.flowi6_iif = skb->dev->ifindex,
+		.flowi6_oif = dev_get_iflink(dev),
 		.daddr = ip6h->daddr,
 		.saddr = ip6h->saddr,
 		.flowi6_flags = FLOWI_FLAG_ANYSRC,
-- 
1.8.1
