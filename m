From: Marc Aurele La France <tsi@ualberta.ca>
Subject: RFC:  MTU for serving NFS on Infiniband
Date: Mon, 23 Aug 2010 08:44:37 -0600 (MDT)
Message-ID: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My apologies for the multiple post.  I got bit the first time around by my 
MUA's configuration.

----

Greetings.

For some time now, the kernel and I have been having an argument over what 
the MTU should be for serving NFS over Infiniband.  I say 65520, the 
documented maximum for connected mode.  But, so far, I've been unable to have 
anything over 32192 remain stable.

Back in the 2.6.14 -> .15 period, sunrpc's sk_buff allocations were changed 
from GFP_KERNEL to GFP_ATOMIC (b079fa7baa86b47579f3f60f86d03d21c76159b8 
mainstream commit).  Understandably, this was to prevent recursion through 
the NFS and sunrpc code.  This is fine for the most common MTU out there, as 
the kernel is almost certain to find a free page.  But, as one increases the 
MTU, memory fragmentation starts to play a role in nixing these allocations.

These allocation failures ultimately result in sparse files being written 
through NFS.  Granted, many of my users' application are oblivious to 
this because they don't check for such errors.  But it would be nice if the 
kernel were more resilient in this regard.

For a few months now, I've been running with sunrpc sk_buff allocations using 
GFP_NOFS instead, which allows for dirty data to be flushed out and still 
avoids recursion through sunrpc.  With this, I've been able to increase the 
stable MTU to 32192.  But no further, as eventually there is no dirty data 
left and memory fragmentation becomes mostly due to yet-to-be-sync'ed 
filesystem data.  There's also the matter that using GFP_NOFS for this can 
slow down NFS quite a bit.

In regrouping for my next tack at this, I noticed that all stack traces go 
through ip_append_data().  This would be ipv6_append_data() in the IPv6 case.
A _very_ rough draft that would have ip_append_data() temporarily drop down 
to a smaller fake MTU follows ...

diff -adNpru linux-2.6.35.2/net/ipv4/ip_output.c devel-2.6.35.2/net/ipv4/ip_output.c
--- linux-2.6.35.2/net/ipv4/ip_output.c	2010-08-13 14:44:56.000000000 -0600
+++ devel-2.6.35.2/net/ipv4/ip_output.c	2010-08-14 17:09:46.000000000 -0600
@@ -801,10 +801,10 @@ int ip_append_data(struct sock *sk,
 	int exthdrlen;
 	int mtu;
 	int copy;
-	int err;
+	int err = 0;
 	int offset = 0;
 	unsigned int maxfraglen, fragheaderlen;
-	int csummode = CHECKSUM_NONE;
+	int csummode;
 	struct rtable *rt;

 	if (flags&MSG_PROBE)
@@ -852,10 +852,9 @@ int ip_append_data(struct sock *sk,
 		exthdrlen = 0;
 		mtu = inet->cork.fragsize;
 	}
-	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);

+	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
-	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;

 	if (inet->cork.length + length > 0xFFFF - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->inet_dport,
@@ -863,6 +862,12 @@ int ip_append_data(struct sock *sk,
 		return -EMSGSIZE;
 	}

+	inet->cork.length += length;
+
+retry_with_smaller_mtu_data:
+	csummode = CHECKSUM_NONE;
+	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
+
 	/*
 	 * transhdrlen > 0 means that this is the first fragment and we wish
 	 * it won't be fragmented in the future.
@@ -875,15 +880,19 @@ int ip_append_data(struct sock *sk,

 	skb = skb_peek_tail(&sk->sk_write_queue);

-	inet->cork.length += length;
-	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
+	if ((err == 0) && ((length > mtu) || (skb && skb_is_gso(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->u.dst.dev->features & NETIF_F_UFO)) {
 		err = ip_ufo_append_data(sk, getfrag, from, length, hh_len,
 					 fragheaderlen, transhdrlen, mtu,
 					 flags);
-		if (err)
-			goto error;
+		if (err) {
+			if (mtu == ETH_DATA_LEN || err != -ENOBUFS)
+				goto error;
+			mtu = ETH_DATA_LEN;
+			goto retry_with_smaller_mtu_data;
+		}
+
 		return 0;
 	}

@@ -957,8 +966,12 @@ alloc_new_skb:
 					   time stamped */
 					ipc->shtx.flags = 0;
 			}
-			if (skb == NULL)
-				goto error;
+			if (skb == NULL) {
+				if (mtu == ETH_DATA_LEN || err != -ENOBUFS)
+					goto error;
+				mtu = ETH_DATA_LEN;
+				goto retry_with_smaller_mtu_data;
+			}

 			/*
 			 *	Fill in the control structures
@@ -1112,7 +1125,6 @@ ssize_t	ip_append_page(struct sock *sk,
 	mtu = inet->cork.fragsize;

 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
-	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;

 	if (inet->cork.length + size > 0xFFFF - fragheaderlen) {
 		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->inet_dport, mtu);
@@ -1123,6 +1135,7 @@ ssize_t	ip_append_page(struct sock *sk,
 		return -EINVAL;

 	inet->cork.length += size;
+
 	if ((size + skb->len > mtu) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->u.dst.dev->features & NETIF_F_UFO)) {
@@ -1130,6 +1143,8 @@ ssize_t	ip_append_page(struct sock *sk,
 		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 	}

+retry_with_smaller_mtu_page:
+	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;

 	while (size > 0) {
 		int i;
@@ -1153,8 +1168,13 @@ ssize_t	ip_append_page(struct sock *sk,
 			alloclen = fragheaderlen + hh_len + fraggap + 15;
 			skb = sock_wmalloc(sk, alloclen, 1, sk->sk_allocation);
 			if (unlikely(!skb)) {
-				err = -ENOBUFS;
-				goto error;
+				if (mtu == ETH_DATA_LEN) {
+					err = -ENOBUFS;
+					goto error;
+				}
+
+				mtu = ETH_DATA_LEN;
+				goto retry_with_smaller_mtu_page;
 			}

 			/*

Now, I don't have this working quite right yet, but in the meantime, I'd 
appreciate some comments over whether this is an appropriate path to follow 
and/or ideas on other avenues I should be exploring instead.

Thanks.

Marc.

+----------------------------------+----------------------------------+
|  Marc Aurele La France           |  work:   1-780-492-9310          |
|  Academic Information and        |  fax:    1-780-492-1729          |
|    Communications Technologies   |  email:  tsi@ualberta.ca         |
|  352 General Services Building   +----------------------------------+
|  University of Alberta           |                                  |
|  Edmonton, Alberta               |    Standard disclaimers apply    |
|  T6G 2H1                         |                                  |
|  CANADA                          |                                  |
+----------------------------------+----------------------------------+
