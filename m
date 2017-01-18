From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: xennet_start_xmit assumptions
Date: Wed, 18 Jan 2017 10:31:32 -0500
Message-ID: <20170118153132.GB9258@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43374 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751413AbdARPbm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 10:31:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As I was playing around with pf_packet, I accidentally wrote
a buggy application program that bzero'ed the msghdr, then set
up the msg_name, msg_namelen correctly, and then did a sendmsg
on the pf_packet/SOCK_RAW fd.

This causes packet_snd to set up an skb with a lot of issues,
e.g., skb->len = 0, skb_headlen(skb) is 0, etc. I think we can/should
drop the packet in packet_snd if the skb->len is 0, but there
may be other driver bugs going on:

Turns out that ixgbe and sunvnet handle this problematic
skb correctly (they drop it and system remains stable), 
but it creates a panic in xen_netfront (xennet_start_xmit()
hits a null pointer deref when xennet_make_first_txreq() returns 
NULL)

I'm new to the xen driver code, so I'm hoping that
the experts can comment here: reading the code in xennet_start_xmit,
it seems like it mandatorily requires the skb_headlen() to be
non-zero in order to create the first_tx? That may not always be
true, how does the code recover for purely non-linear skbs?

--Sowmini
