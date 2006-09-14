From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.18-rc6 memory mapped pcap truncates outgoing TCP packets,
  but not icmp
Date: Thu, 14 Sep 2006 12:02:26 +0200
Message-ID: <450928B2.4090003@trash.net>
References: <20060913112307.GA1374@outpost.ds9a.nl> <45085185.2060904@trash.net> <20060914085618.GA4623@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030808020009080306090908"
Cc: cpw@lanl.gov, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:16811 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750715AbWINKC2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 06:02:28 -0400
To: bert hubert <bert.hubert@netherlabs.nl>
In-Reply-To: <20060914085618.GA4623@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030808020009080306090908
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

bert hubert wrote:
> On Wed, Sep 13, 2006 at 08:44:21PM +0200, Patrick McHardy wrote:
> 
> 
>>Are you using TSO on the outgoing device? If so please try to log the
>>packet using iptables to see if it really is a TSO packet.
> 
> 
> Good catch! I turned off TSO and things are working fine again.
> 
> Is this a known problem, should it be documented or fixed? I'm more than
> willing to write up some warnings should this be a good idea.

It appears to be intentionally, but I don't see a reason for it.
Can you try if this patch makes it work as expected?


--------------030808020009080306090908
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[PACKET]: Don't truncate non-linear skbs with mmaped IO

Non-linear skbs are truncated to their linear part with mmaped IO.
Fix by using skb_copy_bits instead of memcpy.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 6e184976552a407c331f9b4e52b2c26fcae46ee7
tree 1bb4fc2b65179a51e795dc07908277b83cc0921a
parent 9f737633e6ee54fc174282d49b2559bd2208391d
author Patrick McHardy <kaber@trash.net> Thu, 14 Sep 2006 11:59:09 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 14 Sep 2006 11:59:09 +0200

 net/packet/af_packet.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index f9cef36..4172a52 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -626,8 +626,6 @@ static int tpacket_rcv(struct sk_buff *s
 		if ((int)snaplen < 0)
 			snaplen = 0;
 	}
-	if (snaplen > skb->len-skb->data_len)
-		snaplen = skb->len-skb->data_len;
 
 	spin_lock(&sk->sk_receive_queue.lock);
 	h = (struct tpacket_hdr *)packet_lookup_frame(po, po->head);
@@ -644,7 +642,7 @@ static int tpacket_rcv(struct sk_buff *s
 		status &= ~TP_STATUS_LOSING;
 	spin_unlock(&sk->sk_receive_queue.lock);
 
-	memcpy((u8*)h + macoff, skb->data, snaplen);
+	skb_copy_bits(skb, 0, (u8*)h + macoff, snaplen);
 
 	h->tp_len = skb->len;
 	h->tp_snaplen = snaplen;

--------------030808020009080306090908--
