From: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>
Subject: [PATCH 2.6.23-rc1][NETFILTER] nf_conntrack_reasm: adding icmpv6_send
 code(TIME EXCEEDED).
Date: Wed, 01 Aug 2007 19:53:20 -0700
Message-ID: <46B14720.9090300@ncos.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org,
	Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from homer.mvista.com ([63.81.120.158]:13294 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbXHBCxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2007 22:53:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I ran the TAHI conformance test on a kernel, which CONFIG_NF_CONNTRACK_IPV6
is enabled. And then it showed a result including a couple of failure.
The all of failed items are related to TIME EXCEEDED.

The test procedure is here.
  Tester                      Target
    |                           |
    |-------------------------->|
    |       Echo Request        |
    |      (1st fragment)       |
    |                           |
    |      wait for 65 sec.     |
    |                           |
    |<--------------------------|
    |        ICMPv6 Error       |

(1) Tester sends a first fragment of ICMPv6 echo request to Target.
(2) Wait for over 60 sec.
(3) If target replies a ICMPv6 error message(Time Exceeded) to Tester,
    then this test is success, otherwise it's failure.

The reason of the failure is very simple, it's because icmpv6_send code are
missing in nf_ct_frag6_expire function(nf_conntrack_reasm.c).
The change is to add the missing code.

In RFC2460, the specification regarding Time Exceeded is described,
but it's defined as "should". So, there is no specification violation here.
Therefore I'm not sure whether this change is appropriate or not.

I will appreciate any comments. Thanks.

Signed-off-by: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>

Index: linux-2.6/net/ipv6/netfilter/nf_conntrack_reasm.c
===================================================================
--- linux-2.6.orig/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ linux-2.6/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -76,6 +76,7 @@ struct nf_ct_frag6_queue
 	struct sk_buff		*fragments;
 	int			len;
 	int			meat;
+	int			iif;
 	ktime_t			stamp;
 	unsigned int		csum;
 	__u8			last_in;	/* has first/last segment arrived? */
@@ -279,6 +280,7 @@ static void nf_ct_frag6_evictor(void)
 static void nf_ct_frag6_expire(unsigned long data)
 {
 	struct nf_ct_frag6_queue *fq = (struct nf_ct_frag6_queue *) data;
+	struct net_device *dev = NULL;

 	spin_lock(&fq->lock);

@@ -287,7 +289,26 @@ static void nf_ct_frag6_expire(unsigned

 	fq_kill(fq);

+	dev = dev_get_by_index(fq->iif);
+	if (!dev)
+		goto out;
+
+	/* Don't send error if the first segment did not arrive. */
+	if (!(fq->last_in&FIRST_IN) || !fq->fragments)
+		goto out;
+
+	/*
+	   But use as source device on which LAST ARRIVED
+	   segment was received. And do not use fq->dev
+	   pointer directly, device might already disappeared.
+	 */
+	fq->fragments->dev = dev;
+	icmpv6_send(fq->fragments, ICMPV6_TIME_EXCEED, ICMPV6_EXC_FRAGTIME, 0, dev);
+
 out:
+	if (dev)
+		dev_put(dev);
+
 	spin_unlock(&fq->lock);
 	fq_put(fq, NULL);
 }
@@ -534,6 +555,9 @@ static int nf_ct_frag6_queue(struct nf_c
 	else
 		fq->fragments = skb;

+	if (skb->dev)
+		fq->iif = skb->dev->ifindex;
+
 	skb->dev = NULL;
 	fq->stamp = skb->tstamp;
 	fq->meat += skb->len;
