From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH v2] ipv4: support for request type gratuitous ARP
Date: Sun, 17 Jan 2010 20:55:52 +0200
Message-ID: <201001172055.52953.opurdila@ixiacom.com>
References: <20100110.132105.179935794.davem@davemloft.net> <1263680334-1770-1-git-send-email-opurdila@ixiacom.com> <Pine.LNX.4.58.1001171310420.2769@u.domain.uli>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_401ULGz9OttGUg5"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Laurent Chavey <chavey@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:28157 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752422Ab0AQS7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 13:59:18 -0500
In-Reply-To: <Pine.LNX.4.58.1001171310420.2769@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_401ULGz9OttGUg5
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sunday 17 January 2010 15:45:45 you wrote:

> 	May be I'm missing something but the description and
> the changed code do not match. You claim this patch now supports
> dest mac ff:ff:ff:ff:ff:ff while without the patch the
> 'skb->pkt_type != PACKET_HOST' check usually updates the
> existing entry with state NUD_STALE (neigh_update). What
> exactly is not handled correctly?
> 
> 	I think, the existing entry should be updated
> properly even without the patch, when sip=tip. May be
> there is unwanted ARP reply? It is not clear from this email. Can
> you give example why we need to override ip_route_input? What is
> the case that there is existing entry for sip that we want
> to update but for some reason we do not like ip_route_input
> result and entry is not updated? I don't think, ip_route_input
> will do something different when sip=tip=unicast address.
> This is not much different from the case when tip is IP
> from the same subnet as sip. There are only 2 'goto out' but
> both places update the entry depending on some policy.
> 
> 	Also, you call neigh_event_ns which creates new entry while
> RFC talks about updating existing entry: "if the receiving node
> has an entry for that IP address already in its ARP cache".
> We don't want to create new entry. After neigh_event_ns you
> jump again to update (2nd unneeded update).
> 
> 	As for arp_accept, it only allows creating new ARP
> entries on received reply, but when disabled it does not
> prevent updates for existing entries.
> 

Hi Julian,

Thanks for looking at this patch ! You are indeed correct, we don't need to do anything special when we want to update an existing ARP entry.

But I also want to be able to create a new ARP entry not only update an existing one (and we can do that with Linux today, but only with response type grat arp).

How about this new version?

[PATCH] ipv4: allow warming up the ARP cache with request type gratuitous ARP

If the per device ARP_ACCEPT option is enabled, currently we only allow
creating new ARP cache entries for response type gratuitous ARP.

Allowing gratuitous ARP to create new ARP entries (not only to update
existing ones) is useful when we want to avoid unnecessary delays for
the first packet of a stream.

This patch allows request type gratuitous ARP to create new ARP cache
entries as well. This is useful when we want to warm-up the ARP cache
entries for a large number of hosts on the same LAN.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/ipv4/arp.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 0787092..1940b4d 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -907,7 +907,8 @@ static int arp_process(struct sk_buff *skb)
 		   devices (strip is candidate)
 		 */
 		if (n == NULL &&
-		    arp->ar_op == htons(ARPOP_REPLY) &&
+		    (arp->ar_op == htons(ARPOP_REPLY) ||
+		     (arp->ar_op == htons(ARPOP_REQUEST) && tip == sip)) &&
 		    inet_addr_type(net, sip) == RTN_UNICAST)
 			n = __neigh_lookup(&arp_tbl, &sip, dev, 1);
 	}
-- 
1.5.6.5


--Boundary-00=_401ULGz9OttGUg5
Content-Type: text/x-csrc;
  charset="UTF-8";
  name="gratarp.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="gratarp.c"

/*
 * Send gratuitous ARP, based on send_arp from the Linux fake package.
 */

/* send_arp.c

   This program sends out one ARP packet with source/target IP and Ethernet
   hardware addresses suuplied by the user.  It compiles and works on Linux
   and will probably work on any Unix that has SOCK_PACKET.

   The idea behind this program is a proof of a concept, nothing more.  It
   comes as is, no warranty.  However, you're allowed to use it under one
   condition: you must use your brain simultaneously.  If this condition is
   not met, you shall forget about this program and go RTFM immediately.

   yuri volobuev'97
   volobuev@t1.chem.umn.edu

*/

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <netdb.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <linux/if_ether.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <netinet/ether.h>
#include <sys/socket.h>
#include <netpacket/packet.h>
#include <net/ethernet.h> /* the L2 protocols */


#define ETH_HW_ADDR_LEN 6
#define IP_ADDR_LEN 4
#define ARP_FRAME_TYPE 0x0806
#define ETHER_HW_TYPE 1
#define IP_PROTO_TYPE 0x0800
#define OP_ARP_REQUEST 1
#define OP_ARP_REPLY 2

struct arp_packet {
        u_char targ_hw_addr[ETH_HW_ADDR_LEN];
        u_char src_hw_addr[ETH_HW_ADDR_LEN];
        u_short frame_type;
        u_short hw_type;
        u_short prot_type;
        u_char hw_addr_size;
        u_char prot_addr_size;
        u_short op;
        u_char sndr_hw_addr[ETH_HW_ADDR_LEN];
        u_char sndr_ip_addr[IP_ADDR_LEN];
        u_char rcpt_hw_addr[ETH_HW_ADDR_LEN];
        u_char rcpt_ip_addr[IP_ADDR_LEN];
        u_char padding[18];
};

int main(int argc,char** argv)
{
	struct arp_packet pkt = { { 0, }, };
	struct sockaddr_ll sa = {
		.sll_family = AF_PACKET,
	};
	struct ifreq ifr;
	int sock;

	if (argc != 2 && argc != 3) {
		fprintf(stderr, "usage: gratarp ifname [target_mac_address]\n");
		return 1;
	}

	sock = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_RARP));
	if (sock<0){
		perror("socket");
		exit(1);
        }

	pkt.frame_type = htons(ARP_FRAME_TYPE);
	pkt.hw_type = htons(ETHER_HW_TYPE);
	pkt.prot_type = htons(IP_PROTO_TYPE);
	pkt.hw_addr_size = ETH_HW_ADDR_LEN;
	pkt.prot_addr_size = IP_ADDR_LEN;

	memset (&ifr, 0, sizeof(ifr));
	memcpy (&ifr.ifr_name, argv[1], strlen(argv[1]));

	if (ioctl(sock, SIOCGIFINDEX, &ifr) < 0)
		perror("SIOCGIFINDEX");
	sa.sll_ifindex = ifr.ifr_ifindex;

	if (ioctl(sock, SIOCGIFHWADDR, &ifr) < 0) {
		perror("SIOCGIFHWADDR");
		return 2;
	}
	memcpy(pkt.src_hw_addr, ifr.ifr_hwaddr.sa_data, 6);
	memcpy(pkt.sndr_hw_addr, ifr.ifr_hwaddr.sa_data, 6);

	/* pickup the target mac address */
	if (argc > 2) {
		struct ether_addr *eth_addr = ether_aton(argv[2]);
		if (!eth_addr) {
			perror("ether_aton\n");
			return 4;
		}
		memcpy(pkt.targ_hw_addr, eth_addr, 6);
		memcpy(pkt.rcpt_hw_addr, eth_addr, 6);
		memcpy(sa.sll_addr, eth_addr, 6);
		pkt.op = htons(OP_ARP_REPLY);
	} else {
		pkt.op = htons(OP_ARP_REQUEST);
		memset(pkt.targ_hw_addr, 0xff, 6);
	}
	sa.sll_halen = 6;

	if (ioctl(sock, SIOCGIFADDR, &ifr) < 0) {
		perror("SIOCGIFADDR");
		return 5;
	}
	memcpy(pkt.sndr_ip_addr, &((struct sockaddr_in*)&ifr.ifr_addr)->sin_addr, 4);
	memcpy(pkt.rcpt_ip_addr, &((struct sockaddr_in*)&ifr.ifr_addr)->sin_addr, 4);

	if (sendto(sock, &pkt, sizeof(pkt), 0, (struct sockaddr*)&sa, sizeof(sa)) < 0){
		perror("sendto");
		return 4;
        }

	return 0;
}


--Boundary-00=_401ULGz9OttGUg5--
