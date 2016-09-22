From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Thu, 22 Sep 2016 01:52:42 -0400 (EDT)
Message-ID: <20160922.015242.735026657310158125.davem@davemloft.net>
References: <20160920163108.GP8920@oracle.com>
        <20160920184333.17444823@griffin>
        <20160920190929.57ddaeb0@griffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org,
        hannes@stressinduktion.org, aduyck@mirantis.com,
        daniel@iogearbox.net, pabeni@redhat.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54922 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932966AbcIVFwq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 01:52:46 -0400
In-Reply-To: <20160920190929.57ddaeb0@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue, 20 Sep 2016 19:09:29 +0200

> But the point stands, we have much greater problems here than VXLAN.
> And I don't think that wrapping all IP address accesses into
> get/put_unaligned all around the stack is the solution.

Right, and I don't like marking things as packed either.

We need something that really solves the problem.  We can't
change the existing protocols, but we can perhaps change the
geometry of the SKB when we deal with such protocols.

For example, we can memmove() to align the headers at skb->data and
then for the skb->data portion past the headers we insert a frag
pointing to it at the front of the frag list.

So we "memmove" down, creating a gap, and then past the gap
is the post-header area which gets inserted into the head of
the SKB's fraglist.

That will align all of the subsequent headers and avoid the
unaligned accesses after the vxlan header.

Alternatively we can do Alexander Duyck's trick, by pushing
the headers into the frag list, forcing a pull and realignment
by the next protocol layer.

This is so much better than the little hacks sprinkled all
over the problem and tackles the fundamental issue.

Thanks.
