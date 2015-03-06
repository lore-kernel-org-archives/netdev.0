From: sfeldma@gmail.com
Subject: [PATCH net-next v4 6/8] ipv4: add net bool fib_offload_disabled
Date: Thu,  5 Mar 2015 21:21:18 -0800
Message-ID: <1425619280-27492-7-git-send-email-sfeldma@gmail.com>
References: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	roopa@cumulusnetworks.com, alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35789 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754167AbbCFFUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 00:20:45 -0500
Received: by pdbfp1 with SMTP id fp1so21277489pdb.2
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 21:20:44 -0800 (PST)
In-Reply-To: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

If something goes wrong with IPv4 FIB offload, mark entire net offload
disabled.  This is brute force policy to basically shut down IPv4 FIB offload
permanently if there is a problem offloading any route to an external device.
We can refine the policy in the future, to handle failures on a per-device or
per-route basis, but for now, this policy is per-net.

What we're trying to avoid is an inconsistent split between the kernel's FIB
and the offload device's FIB.  We don't want the device to fwd a pkt
inconsitent with what the kernel would do.  An example of a split is if device
has 10.0.0.0/16 and kernel has 10.0.0.0/16 and 10.0.0.0/24, the device wouldn't
see the longest prefix 10.0.0.0/24 and potentially forward pkts incorrectly.

Limited capacity or limited capability are two ways a route may fail to install
to the offload device.  We'll not differentiate between failures at this time,
and treat any failure as fatal and mark the net as fib_offload_disabled.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/netns/ipv4.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index db1db15..1085e12f 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -47,6 +47,7 @@ struct netns_ipv4 {
 	int			fib_num_tclassid_users;
 #endif
 	struct hlist_head	*fib_table_hash;
+	bool			fib_offload_disabled;
 	struct sock		*fibnl;
 
 	struct sock  * __percpu	*icmp_sk;
-- 
1.7.10.4
