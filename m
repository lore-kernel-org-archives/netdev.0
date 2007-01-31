From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: (usagi-users 03789) Re: [Patch][IPv6] Fix wrong routing mechanism for Link Local IPv6
 packets
Date: Wed, 31 Jan 2007 14:42:50 +0900 (JST)
Message-ID: <20070131.144250.58478716.yoshfuji@linux-ipv6.org>
References: <1172119906.2658.4.camel@LINE>
	<20070131.140914.105443849.yoshfuji@linux-ipv6.org>
	<20070131.141408.22662891.yoshfuji@linux-ipv6.org>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-users@linux-ipv6.org,
        yoshfuji@linux-ipv6.org, weid@np.css.fujitsu.com
To: davem@davemloft.net
Return-path: <usagi-users-admin@linux-ipv6.org>
In-Reply-To: <20070131.141408.22662891.yoshfuji@linux-ipv6.org>
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

In article <20070131.141408.22662891.yoshfuji@linux-ipv6.org> (at Wed, 31 Jan 2007 14:14:08 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <20070131.140914.105443849.yoshfuji@linux-ipv6.org> (at Wed, 31 Jan 2007 14:09:14 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
> 
> > In article <1172119906.2658.4.camel@LINE> (at Wed, 21 Feb 2007 23:51:45 -0500), weidong <weid@np.css.fujitsu.com> says:
> > 
> > > 	Thanks for your patch. I think maybe we checking oif first is better,
> > > and WARN_ON in function rt6_score_route().
> > 
> > Please remove WARN_ON.  Otherwise, I'm fine with it.
> 
> Argh, no.... wrong.

Here's updated patch, intented for net-2.6.21.  Dave?

----
[IPV6] ROUTE: Do not route packets to link-local address on other device.

With help from Wei Dong <weid@np.css.fujitsu.com>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5f0043c..16111c4 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -311,12 +311,21 @@ static inline void rt6_probe(struct rt6_info *rt)
 static int inline rt6_check_dev(struct rt6_info *rt, int oif)
 {
 	struct net_device *dev = rt->rt6i_dev;
-	if (!oif || dev->ifindex == oif)
+	int ret = 0;
+
+	if (!oif)
 		return 2;
-	if ((dev->flags & IFF_LOOPBACK) &&
-	    rt->rt6i_idev && rt->rt6i_idev->dev->ifindex == oif)
-		return 1;
-	return 0;
+	if (dev->flags & IFF_LOOPBACK) {
+		if (!WARN_ON(rt->rt6i_idev == NULL) &&
+		    rt->rt6i_idev->dev->ifindex == oif)
+			ret = 1;
+		else
+			return 0;
+	}
+	if (dev->ifindex == oif)
+		return 2;
+
+	return ret;
 }
 
 static int inline rt6_check_neigh(struct rt6_info *rt)

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
