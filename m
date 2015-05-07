From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: xen-netfront sets partial checksum at wrong offset
Date: Thu, 7 May 2015 12:44:24 -0700 (PDT)
Message-ID: <ee74926e-deb3-4cbc-9798-42c19f4fe219@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31796 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbbEGTo2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 15:44:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello All,

When handle_incoming_queue (xen-netfront.c) calls checksum_setup()
the transport header didn't seem to be initialized yet.
skb_checksum_setup_ipv4 ends up initializing the checksum at incorrect offset. 
        if (recalculate)
                *csum = ~csum_tcpudp_magic(ip_hdr(skb)->saddr,
                                           ip_hdr(skb)->daddr,
                                           skb->len - off,
                                           ip_hdr(skb)->protocol, 0);

where csum is &tcp_hdr(skb)->check.

This problem got exposed when LRO was ON on the host.
It hits this case in checksum_setup().
        /*
         * A GSO SKB must be CHECKSUM_PARTIAL. However some buggy
         * peers can fail to set NETRXF_csum_blank when sending a GSO
         * frame. In this case force the SKB to CHECKSUM_PARTIAL and
         * recalculate the partial checksum.
         */

skb->ip_summed was CHECKSUM_UNNECESSARY. 
The guest was at 3.8.13 kernel.

I can send a patch if you think the problem exists in current releases too.

Thanks.

Venkat
