From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Mon, 19 Mar 2007 00:42:34 +0200
Message-ID: <20070318224234.GP11078@mellanox.co.il>
References: <20070318155532.GG7958@mellanox.co.il>
	<20070318191238.GA20518@ms2.inr.ac.ru>
	<20070318202559.GD11078@mellanox.co.il>
	<m3tzwi8a20.fsf@maxwell.lnxi.com>
	<20070318223653.GO11078@mellanox.co.il>
Reply-To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederman@lnxi.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	general@lists.openfabrics.org
To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:2722 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933222AbXCRWlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2007 18:41:53 -0400
Received: by ug-out-1314.google.com with SMTP id 44so1162765uga
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2007 15:41:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070318223653.GO11078@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Quoting Michael S. Tsirkin <mst@dev.mellanox.co.il>:
> Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
> 
> > Quoting Eric W. Biederman <ebiederman@lnxi.com>:
> > Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
> > 
> > "Michael S. Tsirkin" <mst@dev.mellanox.co.il> writes:
> > 
> > >> > Why is neighbour->dev changed here?
> > >> 
> > >> It holds reference to device and prevents its destruction.
> > >> If dst is held somewhere, we cannot destroy the device and deadlock
> > >> while unregister.
> > >
> > > BTW, can this ever happen for the loopback device itself?
> > > Is it ever unregistered?
> > 
> > Well I don't think the loopback device is currently but as soon
> > as we get network namespace support we will have multiple loopback
> > devices and they will get unregistered when we remove the network
> > namespace.
> 
> Hmm. Then the code moving dst->dev to point to the loopback
> device will have to be fixed too. I'll post a patch a bit later.

Does this look sane (untested)?

Signed-off-by: Michael S. Tsirkin <mst@dev.mellanox.co.il>


diff --git a/net/core/dst.c b/net/core/dst.c
index 764bccb..8283158 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -235,6 +236,8 @@ again:
 static inline void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 			      int unregister)
 {
+	struct neighbour *neigh;
+
 	if (dst->ops->ifdown)
 		dst->ops->ifdown(dst, dev, unregister);
 
@@ -245,14 +248,13 @@ static inline void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 		dst->input = dst_discard_in;
 		dst->output = dst_discard_out;
 	} else {
-		dst->dev = &loopback_dev;
-		dev_hold(&loopback_dev);
-		dev_put(dev);
-		if (dst->neighbour && dst->neighbour->dev == dev) {
-			dst->neighbour->dev = &loopback_dev;
-			dev_put(dev);
-			dev_hold(&loopback_dev);
+		neigh = dst->neighbour;
+		if (neigh && neigh->dev == dev) {
+			dst->neighbour = NULL;
+			neigh_release(neigh);
 		}
+		dst->dev = NULL;
+		dev_put(dev);
 	}
 }
 

-- 
MST
