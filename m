From: "kalash nainwal" <kalash.nainwal@gmail.com>
Subject: inconsistency in dev->hard_header() arguments?
Date: Thu, 26 Jul 2007 15:25:20 +0530
Message-ID: <416aa1ad0707260255h650468f5m67cef596523f949e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:39263 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869AbXGZJzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 05:55:22 -0400
Received: by ug-out-1314.google.com with SMTP id j3so506234ugf
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 02:55:21 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function is called like this- dev->hard_header(skb, dev, ptype,
dest_hw, src_hw, skb->len); where "skb->protocol" is same as "ptype",
but the former is expected to be in network byte order before calling
hard_header, while latter in host byte order (eth_header internally
does its own conversion of ptype). Is this deliberate? or a bug?

We've a driver, which sends pkt over ethernet. Here's the sample send routine-

my_eth_send(struct sk_buff * mp, struct net_device *dev, int linkno)
{
<snip>
        mp->protocol = link->ln_sap;
        mp->nh.raw = mp->data;
        dev->hard_header(mp, mp->dev, ntohs(link->ln_sap),
                dest_node->n_linkinfo[linkno].n_addr,
                src_node->n_linkinfo[linkno].n_addr,
                mp->len);
         dev_queue_xmit(mp);
}

We store the type field (i.e., link->ln_sap) in our driver in network
byte order only (as skb->protocol is expected to be in network byte
order), but as eth_header internally does the conversion again, we've
to un-convert it (for every outgoing pkt!!) unnecessarily. We can get
away with this by using two different variables for ptype- one in n/w
order, other in host order; but unless there's some hidden magic
behind the current behavior, I'd like to send a patch to fix this in
kernel. Or if you think it would touch too many files, might break too
many things...we can let it be.

Regards,
-Kalash
