From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: NULL pointer dereference in rt6_get_cookie()
Date: Tue, 13 Oct 2015 23:14:21 -0700
Message-ID: <20151014061421.GD68583@kafai-mba.local>
References: <20151010132437.GB25926@orbit.nwl.cc>
 <20151013181443.GB68583@kafai-mba.local>
 <20151013191039.GA3070@base.sg13b.nwl.cc>
 <20151013192543.06B5021398@mail.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Julian Anastasov <ja@ssi.bg>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:65487 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750759AbbJNGOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 02:14:53 -0400
Content-Disposition: inline
In-Reply-To: <20151013192543.06B5021398@mail.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 13, 2015 at 09:26:41PM +0200, Phil Sutter wrote:
> I have backed up the rt pointer at top of the function and restored it
> before pr_err, this is the output:
>
> | rt6i_dst:2001:4dd0:ff3b:13::/64 rt6i_gateway::: rt6i_flags:40000001 dst.flags:00000000
Hi Phil, Can you try the following patch and report the pr_err?

Thanks,
Martin

--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -262,7 +262,7 @@ static struct dst_ops ip6_dst_blackhole_ops = {
 	.default_advmss		=	ip6_default_advmss,
 	.update_pmtu		=	ip6_rt_blackhole_update_pmtu,
 	.redirect		=	ip6_rt_blackhole_redirect,
-	.cow_metrics		=	ip6_rt_blackhole_cow_metrics,
+	.cow_metrics		=	dst_cow_metrics_generic,
 	.neigh_lookup		=	ip6_neigh_lookup,
 };

@@ -1201,21 +1201,20 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 		new = &rt->dst;

 		memset(new + 1, 0, sizeof(*rt) - sizeof(*new));
+		INIT_LIST_HEAD(&rt->rt6i_siblings);
+		INIT_LIST_HEAD(&rt->rt6i_uncached);

 		new->__use = 1;
 		new->input = dst_discard;
 		new->output = dst_discard_out;

-		if (dst_metrics_read_only(&ort->dst))
-			new->_metrics = ort->dst._metrics;
-		else
-			dst_copy_metrics(new, &ort->dst);
+		dst_copy_metrics(new, &ort->dst);
 		rt->rt6i_idev = ort->rt6i_idev;
 		if (rt->rt6i_idev)
 			in6_dev_hold(rt->rt6i_idev);

 		rt->rt6i_gateway = ort->rt6i_gateway;
-		rt->rt6i_flags = ort->rt6i_flags;
+		rt->rt6i_flags = ort->rt6i_flags & (~RTF_PCPU);
 		rt->rt6i_metric = 0;

 		memcpy(&rt->rt6i_dst, &ort->rt6i_dst, sizeof(struct rt6key));
@@ -1223,6 +1222,19 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 		memcpy(&rt->rt6i_src, &ort->rt6i_src, sizeof(struct rt6key));
 #endif

+		pr_err("ort:%p rt6i_dst:[%pI6c]/%d rt6i_gateway:[%pI6c] "
+		       "rt6i_flags:%08X dst.flags:%08X\n",
+		       ort,
+		       &ort->rt6i_dst.addr, ort->rt6i_dst.plen,
+		       &ort->rt6i_gateway, ort->rt6i_flags,
+		       ort->dst.flags);
+		pr_err(" rt:%p rt6i_dst:[%pI6c]/%d rt6i_gateway:[%pI6c] "
+		       "rt6i_flags:%08X dst.flags:%08X\n",
+		       rt,
+		       &rt->rt6i_dst.addr, rt->rt6i_dst.plen,
+		       &rt->rt6i_gateway, rt->rt6i_flags,
+		       rt->dst.flags);
+
 		dst_free(new);
 	}
