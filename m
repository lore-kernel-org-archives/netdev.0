From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: TX_RING and VLAN : (packet size is too long 1518 > 1514)
Date: Sun, 23 Feb 2014 14:58:13 +0100
Message-ID: <5309FE75.8030802@redhat.com>
References: <5309D59A.1020304@fokus.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jbrouer@redhat.com, netdev@vger.kernel.org
To: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36799 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751092AbaBWN6V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Feb 2014 08:58:21 -0500
In-Reply-To: <5309D59A.1020304@fokus.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/2014 12:03 PM, Mathias Kretschmer wrote:
> Hi Daniel, all
>
> we're running into the above error when sending full-sized VLAN-tagged frames via TX_RING (Kernel 3.10.31, but same code seems to be present in 3.14).
>
> For the regular send() calls, there seems to be code in place to handle VLAN-tagged frames, but in tpacket_fill_skb() there is no such check.
>
> I came up with fix for this, but can only verify this tomorrow.
> If it works, I'd send you a patch, but someone with more insights into the networking code should probably fix this properly ;-)

Looks like the logic was added only to packet_snd() path when there was no TX_RING
implementation available yet.

Does that patch work for you?

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 48a6a93..9deb991 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2257,8 +2257,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
  	if (unlikely(!(dev->flags & IFF_UP)))
  		goto out_put;

-	reserve = dev->hard_header_len;
-
+	reserve = dev->hard_header_len + VLAN_HLEN;
  	size_max = po->tx_ring.frame_size
  		- (po->tp_hdrlen - sizeof(struct sockaddr_ll));

@@ -2285,8 +2284,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
  			goto out_status;

  		tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
-				addr, hlen);
-
+					  addr, hlen);
  		if (unlikely(tp_len < 0)) {
  			if (po->tp_loss) {
  				__packet_set_status(po, ph,
@@ -2300,6 +2298,21 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
  				goto out_status;
  			}
  		}
+		if (tp_len > (dev->mtu + dev->hard_header_len)) {
+			struct ethhdr *ehdr;
+			/* Earlier code assumed this would be a VLAN pkt,
+			 * double-check this now that we have the actual
+			 * packet in hand.
+			 */
+
+			skb_reset_mac_header(skb);
+			ehdr = eth_hdr(skb);
+			if (ehdr->h_proto != htons(ETH_P_8021Q)) {
+				status = TP_STATUS_WRONG_FORMAT;
+				err = -EMSGSIZE;
+				goto out_status;
+			}
+		}

  		packet_pick_tx_queue(dev, skb);
