From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Repeatable IPv6 crash in 3.19.0-1
Date: Fri, 27 Feb 2015 17:16:09 -0800
Message-ID: <1425086169.5130.57.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54F0E38C.5060203@vultr.com>
	 <1425084533.5130.54.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brian Rak <brak@vultr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35999 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbbB1BQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 20:16:11 -0500
Received: by igkb16 with SMTP id b16so4946706igk.1
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 17:16:11 -0800 (PST)
In-Reply-To: <1425084533.5130.54.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-27 at 16:48 -0800, Eric Dumazet wrote:
> On Fri, 2015-02-27 at 16:37 -0500, Brian Rak wrote:
> > I've been seeing a crash under 3.19.0 that seems to occur when I put 
> > heavy traffic across a macvtap/veth interface.
> > 
> > We have a KVM guest attached to a veth pair using macvtap.  We're 
> > routing IPv6 traffic into one end of the veth pair using some static 
> > routes.  We do *not* have proxy_ndp enabled (though, we are using some 
> > software to do neighbor proxying - http://priv.nu/projects/ndppd/ ).
> > 
> > I've been able to reproduce this pretty easily by downloading some large 
> > files from the guest.  We see two traces in a row when this occurs:
> 
> 
> Nice !
> 
> Crash is in neigh_hh_output()
> 
> -> memcpy(skb->data - HH_DATA_MOD, hh->hh_data, HH_DATA_MOD);
> 
> And there is only 14 bytes of headroom instead of 16.
> 
> Some layer did not align skb_headroom(skb) to HH_DATA_MOD for ethernet
> header.

Could you try following patch ?

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index e40fdfccc9c10df4ea8676a1dd59275d5d9c6b88..27ecc5c4fa2665cd42ac1ca81717255f85507113 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -654,11 +654,14 @@ static void macvtap_skb_to_vnet_hdr(struct macvtap_queue *q,
 	} /* else everything is zero */
 }
 
+/* Neighbour code has some assumptions on HH_DATA_MOD alignment */
+#define MACVTAP_RESERVE HH_DATA_OFF(ETH_HLEN)
+
 /* Get packet from user space buffer */
 static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 				struct iov_iter *from, int noblock)
 {
-	int good_linear = SKB_MAX_HEAD(NET_IP_ALIGN);
+	int good_linear = SKB_MAX_HEAD(MACVTAP_RESERVE);
 	struct sk_buff *skb;
 	struct macvlan_dev *vlan;
 	unsigned long total_len = iov_iter_count(from);
@@ -722,7 +725,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 			linear = macvtap16_to_cpu(q, vnet_hdr.hdr_len);
 	}
 
-	skb = macvtap_alloc_skb(&q->sk, NET_IP_ALIGN, copylen,
+	skb = macvtap_alloc_skb(&q->sk, MACVTAP_RESERVE, copylen,
 				linear, noblock, &err);
 	if (!skb)
 		goto err;
