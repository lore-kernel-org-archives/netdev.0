From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V3] qdisc: validate frames going through the
 direct_xmit path
Date: Wed, 03 Sep 2014 09:08:27 -0700
Message-ID: <1409760507.26422.49.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140903114841.19969.22671.stgit@dragon>
	 <20140903155508.23813.75407.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:41985 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022AbaICQIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 12:08:32 -0400
Received: by mail-pa0-f51.google.com with SMTP id rd3so17794369pab.38
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 09:08:29 -0700 (PDT)
In-Reply-To: <20140903155508.23813.75407.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-03 at 17:56 +0200, Jesper Dangaard Brouer wrote:
> In commit 50cbe9ab5f8d ("net: Validate xmit SKBs right when we
> pull them out of the qdisc") the validation code was moved out of
> dev_hard_start_xmit and into dequeue_skb.
> 
> However this overlooked the fact that we do not always enqueue
> the skb onto a qdisc. First situation is if qdisc have flag
> TCQ_F_CAN_BYPASS and qdisc is empty.  Second situation is if
> there is no qdisc on the device, which is a common case for
> software devices.
> 
> Originally spotted and inital patch by Alexander Duyck.
> As a result Alex was seeing issues trying to connect to a
> vhost_net interface after commit 50cbe9ab5f8d was applied.
> 
> Added a call to validate_xmit_skb() in __dev_xmit_skb(), in the
> code path for qdiscs with TCQ_F_CAN_BYPASS flag, and in
> __dev_queue_xmit() when no qdisc.
> 
> Also handle the error situation where dev_hard_start_xmit() could
> return a skb list, and does not return dev_xmit_complete(rc) and
> falls through to the kfree_skb(), in that situation it should
> call kfree_skb_list().

It seems that in this situation, we will return rc = -ENETDOWN,
I do not think this is the right error code. Not sure if that matters...
