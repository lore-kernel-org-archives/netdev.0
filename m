From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: NULL pointer dereference in rt6_get_cookie()
Date: Tue, 13 Oct 2015 11:14:43 -0700
Message-ID: <20151013181443.GB68583@kafai-mba.local>
References: <20151010132437.GB25926@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Julian Anastasov <ja@ssi.bg>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60795 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932794AbbJMSPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 14:15:08 -0400
Content-Disposition: inline
In-Reply-To: <20151010132437.GB25926@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 10, 2015 at 03:24:37PM +0200, Phil Sutter wrote:
> The conditional at the start of the function evaluates true, since
> 'rt->rt6i_flags & RTF_PCPU' is non-zero.
Hi Phil, can you try the following patch and capture the dmesg output
to confirm the value of rt->rt6i_flags and the rt->dst.flags.

Thanks,
Martin

--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -167,8 +167,15 @@ static inline void rt6_update_expires(struct rt6_info *rt0, int timeout)

 static inline u32 rt6_get_cookie(const struct rt6_info *rt)
 {
-	if (rt->rt6i_flags & RTF_PCPU || unlikely(rt->dst.flags & DST_NOCACHE))
+	if (rt->rt6i_flags & RTF_PCPU || unlikely(rt->dst.flags & DST_NOCACHE)) {
 		rt = (struct rt6_info *)(rt->dst.from);
+		if (!rt)
+			pr_err("rt6i_dst:%pI6c/%d rt6i_gateway:%pI6c "
+			       "rt6i_flags:%08X dst.flags:%08X\n",
+			       &rt->rt6i_dst.addr, rt->rt6i_dst.plen,
+			       &rt->rt6i_gateway, rt->rt6i_flags,
+			       rt->dst.flags);
+	}

 	return rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
 }
