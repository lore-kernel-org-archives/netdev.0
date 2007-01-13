From: Li Yewang <lyw@nanjing-fnst.com>
Subject: [patch]IPv6: fix BUG of ndisc_send_redirect()
Date: Sat, 13 Jan 2007 17:12:40 +0800
Message-ID: <1168679560.3639.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:45784 "EHLO proxy.fnst.com.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751011AbXAMJ0n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Jan 2007 04:26:43 -0500
Received: from 192.168.1.42 ([192.168.1.42])
	by proxy.fnst.com.cn (8.12.11/8.12.11) with ESMTP id l0D9QKG2011942
	for <netdev@vger.kernel.org>; Sat, 13 Jan 2007 17:26:22 +0800
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All
  When I tested IPv6 redirect function about kernel 2.6.19.1, and found
that the kernel can send redirect packets whose target address is global
address, and the target is not the actual endpoint of communication.

  But the criteria conform to RFC2461, the target address defines as
following:

  Target Address An IP address that is a better first hop to use for
                 he ICMP Destination Address.  When the target is
                 the actual endpoint of communication, i.e., the
                 destination is a neighbor, the Target Address field
                 MUST contain the same value as the ICMP Destination
                 Address field.  Otherwise the target is a better
                 first-hop router and the Target Address MUST be the
                 router's link-local address so that hosts can
                 uniquely identify routers.

According to this definition, when a router redirect to a host, the
target address either the better first-hop router's link-local address
or the same as the ICMP destination address field. But the function of
ndisc_send_redirect() in net/ipv6/ndisc.c, does not check the target
address correctly.

There is another definition about receive Redirect message in RFC2461:

8.1.  Validation of Redirect Messages

   A host MUST silently discard any received Redirect message that does
   not satisfy all of the following validity checks:
   ......
   - The ICMP Target Address is either a link-local address (when
     redirected to a router) or the same as the ICMP Destination
     Address (when redirected to the on-link destination).
   ......

And the receive redirect function of ndisc_redirect_rcv() implemented
this definition, checks the target address correctly.
    if (ipv6_addr_equal(dest, target)) {
        on_link = 1;
    } else if (!(ipv6_addr_type(target) & IPV6_ADDR_LINKLOCAL)) {
        ND_PRINTK2(KERN_WARNING
               "ICMPv6 Redirect: target address is not link-local.\n");
        return;
    }

So, I think the send redirect function must check the target address
also.

signed-off-by: Li Yewang <lyw@nanjing-fnst.com>

--- a/net/ipv6/ndisc.c	2007-01-13 16:59:50.050650888 +0800
+++ b/net/ipv6/ndisc.c	2007-01-13 17:02:02.362536424 +0800
@@ -1412,6 +1412,13 @@ void ndisc_send_redirect(struct sk_buff 
  		return;
  	}
 
+	if (!ipv6_addr_equal(&skb->nh.ipv6h->daddr, target) &&
+	    !(ipv6_addr_type(target) & IPV6_ADDR_LINKLOCAL)) {
+		ND_PRINTK2(KERN_WARNING
+			"ICMPv6 Redirect: target address is not link-local.\n");
+		return;
+	}
+
 	ndisc_flow_init(&fl, NDISC_REDIRECT, &saddr_buf, &skb->nh.ipv6h-
>saddr,
 			dev->ifindex);
 


