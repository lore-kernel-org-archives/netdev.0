From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: sched: shrink struct qdisc_skb_cb to 28 bytes
Date: Thu, 18 Sep 2014 11:00:27 -0700
Message-ID: <1411063227.7106.280.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1402338773-5996-1-git-send-email-_govind@gmx.com>
	 <1402338773-5996-2-git-send-email-_govind@gmx.com>
	 <CAE9FiQW+Rv4o9Pc1J9hyqgW1WrhEANKEXH6zYQc2NQqeMbAcvA@mail.gmail.com>
	 <alpine.LNX.2.03.1406261159071.1438@ws.cisco>
	 <CAJZOPZJ7+n0t1LCqaa3JCBByRw=f_Tp6rk8vm0ZnCzmtKFKX_g@mail.gmail.com>
	 <1411052525.7106.269.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140918092628.566eae2b@urahara>
	 <1411057934.7106.275.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Yinghai Lu <yinghai@kernel.org>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>, ssujith@cisco.com,
	gvaradar@cisco.com, "Christian Benvenuti (benve)" <benve@cisco.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:42226 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932117AbaIRSAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 14:00:32 -0400
Received: by mail-pa0-f53.google.com with SMTP id rd3so2013847pab.12
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 11:00:31 -0700 (PDT)
In-Reply-To: <1411057934.7106.275.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-18 at 09:32 -0700, Eric Dumazet wrote:
> On Thu, 2014-09-18 at 09:26 -0700, Stephen Hemminger wrote:
> > On Thu, 18 Sep 2014 08:02:05 -0700
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > 
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > We cannot make struct qdisc_skb_cb bigger without impacting IPoIB,
> > > or increasing skb->cb[] size.
> > > 
> > > Commit e0f31d849867 ("flow_keys: Record IP layer protocol in
> > > skb_flow_dissect()") broke IPoIB.
> > > 
> > > Only current offender is sch_choke, and this one do not need an
> > > absolutely precise flow key.
> > > 
> > > If we store 17 bytes of flow key, its more than enough. (Its the actual
> > > size of flow_keys if it was a packed structure, but we might add new
> > > fields at the end of it later)
> > > 
> > > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > 
> > Can we add BUILD_BUG to stop next time something smacks this.
> 
> I though we had.
> 
> Maybe IPoIB lacks one.
> 
> Or, do you have an idea ?

Seems straightforward ...

Or can you carry this fix for me ?

Thanks

[PATCH] ipoib: validate struct ipoib_cb size

To catch future errors sooner.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index 3edce617c31b..d7562beb5423 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -131,6 +131,12 @@ struct ipoib_cb {
 	u8			hwaddr[INFINIBAND_ALEN];
 };
 
+static inline struct ipoib_cb *ipoib_skb_cb(const struct sk_buff *skb)
+{
+	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct ipoib_cb));
+	return (struct ipoib_cb *)skb->cb;
+}
+
 /* Used for all multicast joins (broadcast, IPv4 mcast and IPv6 mcast) */
 struct ipoib_mcast {
 	struct ib_sa_mcmember_rec mcmember;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 1310acf6bf92..13e6e0431592 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -716,7 +716,7 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	struct ipoib_neigh *neigh;
-	struct ipoib_cb *cb = (struct ipoib_cb *) skb->cb;
+	struct ipoib_cb *cb = ipoib_skb_cb(skb);
 	struct ipoib_header *header;
 	unsigned long flags;
 
@@ -813,7 +813,7 @@ static int ipoib_hard_header(struct sk_buff *skb,
 			     const void *daddr, const void *saddr, unsigned len)
 {
 	struct ipoib_header *header;
-	struct ipoib_cb *cb = (struct ipoib_cb *) skb->cb;
+	struct ipoib_cb *cb = ipoib_skb_cb(skb);
 
 	header = (struct ipoib_header *) skb_push(skb, sizeof *header);
 
