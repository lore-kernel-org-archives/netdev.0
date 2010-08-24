From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
	skb_copy_and_csum_dev
Date: Tue, 24 Aug 2010 06:18:22 +0000
Message-ID: <20100824061822.GA7639@ff.dom.local>
References: <20100821080735.GA2409@del.dom.local> <4C725FCB.2000304@fs.uni-ruse.bg> <20100823124736.GA16966@ff.dom.local> <1282568443.2486.34.camel@edumazet-laptop> <20100823131056.GA19160@ff.dom.local> <4C727B06.2060002@fs.uni-ruse.bg> <4C72802D.8090405@fs.uni-ruse.bg> <20100823141437.GA2282@del.dom.local> <4C734FB5.1090702@fs.uni-ruse.bg> <4C735669.6050708@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DocE+STaALJfprDB"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51613 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283Ab0HXGSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 02:18:30 -0400
Received: by fxm13 with SMTP id 13so3575179fxm.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 23:18:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4C735669.6050708@fs.uni-ruse.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 24, 2010 at 08:19:37AM +0300, Plamen Petrov wrote:
...
> And here is what I've got:
>
> [picture 7]
> http://picpaste.com/31d6a54fec9e87de0d1550ee02d9c336.jpg
>
> [picture 8]
> http://picpaste.com/02db6ad8abec6281065328fb52d328cf.jpg
>
> [picture 9]
> http://picpaste.com/9fbaaa14c679f57c82e96884d3274090.jpg
>
> Sorry for the really bad quality, even for a phone, but the problem
> is that I don't know when its going to happen, so... you see
> the results.
>
>  because contrary to what you suggest,
>> Jarek, there are no messages in the system logs.

I'm extremely sorry: I missed 1 place. Anyway, it's very helpful too.

>>
>> Plamen
>
> Ideas?

Try Eric's patch, and later maybe this one.

Thanks,
Jarek P.

--DocE+STaALJfprDB
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="dev.c.csum.2.diff"

diff --git a/net/core/dev.c b/net/core/dev.c
index 3721fbb..01241fc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1935,6 +1935,23 @@ static inline int skb_needs_linearize(struct sk_buff *skb,
 					      illegal_highdma(dev, skb))));
 }
 
+static int skb_csum_start_bug(struct sk_buff *skb, int pos)
+{
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		long csstart;
+
+		csstart = skb->csum_start - skb_headroom(skb);
+		if (WARN_ON(csstart > skb_headlen(skb))) {
+			pr_warning("%d: csum_start %d, headroom %d, headlen %d\n",
+				   pos, skb->csum_start, skb_headroom(skb),
+				   skb_headlen(skb));
+			return 1;
+		}
+	}
+	return 0;
+}
+
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
 {
@@ -1959,11 +1976,15 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				goto out_kfree_skb;
 			if (skb->next)
 				goto gso;
+			if (skb_csum_start_bug(skb, 10))
+				goto out_kfree_skb;
 		} else {
 			if (skb_needs_linearize(skb, dev) &&
 			    __skb_linearize(skb))
 				goto out_kfree_skb;
 
+			if (skb_csum_start_bug(skb, 20))
+				goto out_kfree_skb;
 			/* If packet is not checksummed and device does not
 			 * support checksumming for this protocol, complete
 			 * checksumming here.
@@ -1974,10 +1995,16 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				if (!dev_can_checksum(dev, skb) &&
 				     skb_checksum_help(skb))
 					goto out_kfree_skb;
+				if (skb_csum_start_bug(skb, 30))
+					goto out_kfree_skb;
 			}
 		}
 
-		rc = ops->ndo_start_xmit(skb, dev);
+		if (skb_csum_start_bug(skb, 40)) {
+			kfree_skb(skb);
+			rc = NETDEV_TX_OK;
+		} else
+			rc = ops->ndo_start_xmit(skb, dev);
 		if (rc == NETDEV_TX_OK)
 			txq_trans_update(txq);
 		return rc;
@@ -1997,7 +2024,12 @@ gso:
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(nskb);
 
-		rc = ops->ndo_start_xmit(nskb, dev);
+		if (skb_csum_start_bug(skb, 50)) {
+			kfree_skb(skb);
+			rc = NETDEV_TX_OK;
+		} else
+			rc = ops->ndo_start_xmit(nskb, dev);
+
 		if (unlikely(rc != NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)
 				goto out_kfree_gso_skb;

--DocE+STaALJfprDB--
