From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: AF_PACKET mmap() v4...
Date: Thu, 05 Nov 2015 23:56:37 +0100
Message-ID: <563BDEA5.9080907@iogearbox.net>
References: <20151105.000414.1682124328670738318.davem@davemloft.net>	 <4931220.z2MFa8LzkQ@wuerfel> <563B23C3.5070406@iogearbox.net>	 <1446723516.4184.33.camel@edumazet-glaptop2.roam.corp.google.com>	 <563B5202.1020207@iogearbox.net> <1446740279.4184.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, tklauser@distanz.ch
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57223 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756348AbbKEW4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 17:56:42 -0500
In-Reply-To: <1446740279.4184.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2015 05:17 PM, Eric Dumazet wrote:
> On Thu, 2015-11-05 at 13:56 +0100, Daniel Borkmann wrote:
>> On 11/05/2015 12:38 PM, Eric Dumazet wrote:
>
>>> If I am not mistaken, af_packet also lacks the ability to properly set
>>> skb->protocol
>>>
>>> I noticed this using trafgen on a bonding device, when I did my SYNFLOOD
>>> tests for TCP listener rewrite.
>>>
>>> The bonding hash function might uses flow dissector, but as this flow
>>> dissection depends on skb->protocol, all the traffic is directed on a
>>> single slave.
>>
>> Right, if I see this correctly, when you trigger the flushing of TX_RING
>> via sendmsg(), one can hand over a sockaddr_ll, where we infer sll_protocol
>> and tag every skb's skb->protocol with that in tpacket_fill_skb() for the
>> current flushing run. Otherwise, we use the po->num specified at socket
>> creation / bind time for everything (trafgen case).
>>
>> If needed on a per skb basis, perhaps we could map some tpacket_hdr{,2}
>> member that is not used from TX_RING side (perhaps union on tp_snaplen)?
>
> If po->num is 0 (as in trafgen case), we could also get the proto from
> Ethernet header provided by the user.
>
> The skb_probe_transport_header() call from tpacket_fill_skb() is useless
> in the current kernel.
>
> Let say an application wants to mix IPv6 and IPv4 packets, using a
> single TX ring....

Sorry for the late answer.

For the skb->protocol issue, perhaps something like this. Also noticed that
we should rather do the vlan check when we have the actual linear data from
the ring slot, the current way seems buggy if I see this correctly. Both
patches squashed below.

Thanks,
Daniel

  net/packet/af_packet.c | 27 ++++++++++++++-------------
  1 file changed, 14 insertions(+), 13 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 691660b..8415ebd 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2399,8 +2399,22 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
  	} else {
  		data = ph.raw + po->tp_hdrlen - sizeof(struct sockaddr_ll);
  	}
+
  	to_write = tp_len;

+	/* If skb->protocol is still 0, try to infer it. */
+	if (!skb->protocol && tp_len >= sizeof(struct ethhdr))
+		skb->protocol = ((struct ethhdr *)data)->h_proto;
+	if (tp_len > dev->mtu + dev->hard_header_len) {
+		/* Earlier code assumed this would be a VLAN pkt,
+		 * double-check this now that we have the actual
+		 * (linear) packet data at hand.
+		 */
+		if (unlikely(((struct ethhdr *)data)->h_proto !=
+			     htons(ETH_P_8021Q)))
+			return -EMSGSIZE;
+	}
+
  	if (sock->type == SOCK_DGRAM) {
  		err = dev_hard_header(skb, dev, ntohs(proto), addr,
  				NULL, tp_len);
@@ -2524,19 +2538,6 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
  		}
  		tp_len = tpacket_fill_skb(po, skb, ph, dev, size_max, proto,
  					  addr, hlen);
-		if (likely(tp_len >= 0) &&
-		    tp_len > dev->mtu + dev->hard_header_len) {
-			struct ethhdr *ehdr;
-			/* Earlier code assumed this would be a VLAN pkt,
-			 * double-check this now that we have the actual
-			 * packet in hand.
-			 */
-
-			skb_reset_mac_header(skb);
-			ehdr = eth_hdr(skb);
-			if (ehdr->h_proto != htons(ETH_P_8021Q))
-				tp_len = -EMSGSIZE;
-		}
  		if (unlikely(tp_len < 0)) {
  			if (po->tp_loss) {
  				__packet_set_status(po, ph,
-- 
1.9.3
