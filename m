From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH 12/12 net-2.6.26] [ICMP6]: Consolidate fail path
	icmpv6_sk_init with icmpv6_sk_exit.
Date: Sat, 01 Mar 2008 01:05:41 +0300
Message-ID: <1204322741.7867.3.camel@iris.sw.ru>
References: <1204292360.10368.11.camel@iris.sw.ru>
	 <1204292458-11636-12-git-send-email-den@openvz.org>
	 <20080229.112342.76764059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ueqXyemMjqN+bnvv444e"
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:45618 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755609AbYB2WGm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 17:06:42 -0500
In-Reply-To: <20080229.112342.76764059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ueqXyemMjqN+bnvv444e
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2008-02-29 at 11:23 -0800, David Miller wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> Date: Fri, 29 Feb 2008 16:40:58 +0300
> 
> > +static void __net_exit icmpv6_sk_exit(struct net *net)
> > +{
> 
> Since you call this from __new_init code, won't this
> create a section conflict when ipv6 is built statically
> into the kernel?

Dave, you are perfectly correct :) Though, I have made a similar mistake
in the IPv4 code. Pls consider the patch attached.

--=-ueqXyemMjqN+bnvv444e
Content-Disposition: attachment; filename=diff-icmp-section.txt
Content-Type: text/plain; name=diff-icmp-section.txt; charset=KOI8-R
Content-Transfer-Encoding: 7bit

[ICMP]: Section conflict between icmp_sk_init/icmp_sk_exit.

Functions from __exit section should not be called from ones in __init
section. Fix this conflict.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index b51f4b0..cee77d6 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -1198,7 +1198,9 @@ int __net_init icmp_sk_init(struct net *net)
 	return 0;
 
 fail:
-	icmp_sk_exit(net);
+	for_each_possible_cpu(i)
+		sk_release_kernel(net->ipv4.icmp_sk[i]);
+	kfree(net->ipv4.icmp_sk);
 	return err;
 }
 

--=-ueqXyemMjqN+bnvv444e--

