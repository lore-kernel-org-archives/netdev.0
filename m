From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: packet: option to only pass skb protocol
Date: Wed, 6 Jan 2010 00:05:53 +0200
Message-ID: <20100105220553.GE30921@redhat.com>
References: <20100105185732.GA30346@redhat.com> <4B43AEF6.6050701@nortel.com> <20100105.134218.258781374.davem@davemloft.net> <20100105214524.GA31301@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cfriesen@nortel.com, eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932168Ab0AEWJB@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100105214524.GA31301@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 05, 2010 at 11:45:24PM +0200, Michael S. Tsirkin wrote:
> On Tue, Jan 05, 2010 at 01:42:18PM -0800, David Miller wrote:
> > From: "Chris Friesen" <cfriesen@nortel.com>
> > Date: Tue, 05 Jan 2010 15:28:22 -0600
> > 
> > > On 01/05/2010 12:57 PM, Michael S. Tsirkin wrote:
> > >> When sending packets with a packet socket it is often necessary to set
> > >> protocol in msg_name: otherwise the protocol field in the skb will not
> > >> be set correctly.
> > > 
> > > What about automatically detecting the protocol from the data being sent
> > > to avoid the necessity of specifying it in the first place?
> > 
> > This limits packet socket usage to only protocols the kernel is aware
> > of, defeating part of the usefulness of the packet socket facility.
> 
> We could do this if the protocol is ETH_P_ALL -  skbs end up with this
> protocol currently when sendmsg does not have msgname and when socket is
> set up to listen for all packets.  It's not a valid protocol value, is
> it?

Something like this (if we want to support this for all device types,
we would probably need to add get_proto callback to net_device_ops),
and call it instead of eth_hdr(skb)->h_proto.

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index a81dae8..a23d4b2 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -845,7 +845,6 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 
 	ph.raw = frame;
 
-	skb->protocol = proto;
 	skb->dev = dev;
 	skb->priority = po->sk.sk_priority;
 	skb->mark = po->sk.sk_mark;
@@ -924,6 +923,11 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		len = ((to_write > len_max) ? len_max : to_write);
 	}
 
+	if (proto == htons(ETH_P_ALL) && dev->type == ARPHRD_ETHER)
+		skb->protocol = eth_hdr(skb)->h_proto;
+	else
+		skb->protocol = proto;
+
 	return tp_len;
 }
 
@@ -1113,7 +1117,10 @@ static int packet_snd(struct socket *sock,
 	if (err)
 		goto out_free;
 
-	skb->protocol = proto;
+	if (proto == htons(ETH_P_ALL) && dev->type == ARPHRD_ETHER)
+		skb->protocol = eth_hdr(skb)->h_proto;
+	else
+		skb->protocol = proto;
 	skb->dev = dev;
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
