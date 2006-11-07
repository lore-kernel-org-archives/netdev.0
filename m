From: Chris Lalancette <clalance@redhat.com>
Subject: Re: Zero checksum in netconsole/netdump packets
Date: Tue, 07 Nov 2006 08:33:00 -0500
Message-ID: <45508B0C.5020109@redhat.com>
References: <454FC80B.9090001@redhat.com> <20061106.231603.15264009.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030308040008070608040609"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:13509 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1752717AbWKGNdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 08:33:06 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061106.231603.15264009.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030308040008070608040609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Chris Lalancette <clalance@redhat.com>
> Date: Mon, 06 Nov 2006 18:40:59 -0500
> 
>>      Assuming that this is just an oversight, attached is a simple
>>      patch to compute the UDP checksum in netpoll_send_udp.
> 
> If the resulting checksum is zero, you should set it to
> all 1's, like the real UDP code does.

David,
     Ah, thanks.  Forgot about that.  I re-spun the patch with the change (attached).  I also moved the UDP checksum calculation up to where the rest of the UDP header setup is, to make it more consistent.

Thanks again for the comments!

Signed-off-by: Chris Lalancette <clalance@redhat.com>

--------------030308040008070608040609
Content-Type: text/x-patch;
 name="linux-2.6.19-rc4-netpoll-udp-checksum.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.19-rc4-netpoll-udp-checksum.patch"

--- linux-2.6/net/core/netpoll.c.orig	2006-11-06 18:16:58.000000000 -0500
+++ linux-2.6/net/core/netpoll.c	2006-11-07 08:16:29.000000000 -0500
@@ -340,6 +340,12 @@ void netpoll_send_udp(struct netpoll *np
 	udph->dest = htons(np->remote_port);
 	udph->len = htons(udp_len);
 	udph->check = 0;
+	udph->check = csum_tcpudp_magic(htonl(np->local_ip),
+					htonl(np->remote_ip),
+					udp_len, IPPROTO_UDP,
+					csum_partial((unsigned char *)udph, udp_len, 0));
+	if (udph->check == 0)
+		udph->check = -1;
 
 	skb->nh.iph = iph = (struct iphdr *)skb_push(skb, sizeof(*iph));
 

--------------030308040008070608040609--
