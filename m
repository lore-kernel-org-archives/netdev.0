From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH iproute2 1/3] vxlan: add support for collect metadata
 flag
Date: Wed, 16 Dec 2015 11:56:26 +0100
Message-ID: <20151216115626.7a35b4ff@griffin>
References: <cover.1450193891.git.pabeni@redhat.com>
	<c83d317f4849cbbb1b0551d450c3972c5bc73e2b.1450193891.git.pabeni@redhat.com>
	<20151216115054.47dca715@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemming@brocade.com, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49088 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751090AbbLPK43 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 05:56:29 -0500
In-Reply-To: <20151216115054.47dca715@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Dec 2015 11:50:53 +0100, Jiri Benc wrote:
> Also, as a related remark, please note that IFLA_VXLAN_COLLECT_METADATA
> is mutually exclusive with many other flags. It's currently not
> enforced correctly at the kernel level (instead, you get weird
> behavior). I'll fix this on the kernel side but we may want to enforce
> this on the iproute2 side, too, to get a better error message. This is
> not to be addressed by this patch, though.

Actually, there's one thing this patch must do. Currently, vxlan
enforces vni to be specified. This is not required for metadata based
tunneling. It's actually not permitted.

You'll need to add a hunk similar to this:

--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -215,7 +215,12 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		argc--, argv++;
 	}
 
-	if (!vni_set) {
+	if (metadata && vni_set) {
+		fprintf(stderr, "vxlan: both metadata and vni cannot be specified\n");
+		return -1;
+	}
+
+	if (!metadata && !vni_set) {
 		fprintf(stderr, "vxlan: missing virtual network identifier\n");
 		return -1;
 	}

-- 
Jiri Benc
