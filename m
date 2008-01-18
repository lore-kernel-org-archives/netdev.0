From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [PATCH net-2.6.25][NET_NS][IPV6] fix ip6_frags.ctl oops
Date: Fri, 18 Jan 2008 15:19:36 +0100
Message-ID: <4790B578.10303@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080109080508030506020207"
Cc: Alexey Dobriyan <adobriyan@sw.ru>, "Denis V. Lunev" <den@sw.ru>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Pavel Emelianov <xemul@openvz.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:36281 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758982AbYAROVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 09:21:16 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0IELFst019268
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 14:21:15 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0IELFAB4710560
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 14:21:15 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0IELBG1003418
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 14:21:12 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080109080508030506020207
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------080109080508030506020207
Content-Type: text/x-patch;
 name="fix-ip6frag-sysctl-oops.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix-ip6frag-sysctl-oops.patch"

Subject: fix ip6_frag ctl
From: Daniel Lezcano <dlezcano@fr.ibm.com>

Alexey Dobriyan reported an oops when unsharing the network
indefinitely inside a loop. This is because the ip6_frag is not per
namespace while the ctls are.

That happens at the fragment timer expiration: inet_frag_secret_rebuild 
function is called and this one restarts the timer using the value stored
inside the sysctl field.

        "mod_timer(&f->secret_timer, now + f->ctl->secret_interval);"

When the network is unshared, ip6_frag.ctl is initialized with the new
sysctl instances, but ip6_frag has only one instance. A race in this case
will appear because f->ctl can be modified during the read access in the 
timer callback.

Until the ip6_frag is not per namespace, I discard the assignation to the 
ctl field of ip6_frags in ip6_frag_sysctl_init when the network namespace
is not the init net.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/reassembly.c |    3 +++
 1 file changed, 3 insertions(+)

Index: net-2.6.25-misc/net/ipv6/reassembly.c
===================================================================
--- net-2.6.25-misc.orig/net/ipv6/reassembly.c
+++ net-2.6.25-misc/net/ipv6/reassembly.c
@@ -627,6 +627,9 @@ static struct inet6_protocol frag_protoc
 
 void ipv6_frag_sysctl_init(struct net *net)
 {
+	if (net != &init_net)
+		return;
+
 	ip6_frags.ctl = &net->ipv6.sysctl.frags;
 }
 

--------------080109080508030506020207--
