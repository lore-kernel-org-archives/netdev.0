From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 04:21:30 -0700
Message-ID: <ada8xbvzjut.fsf@cisco.com>
References: <OFA0B8100C.1A34288C-ON652572D8.002808B3-652572D8.002945CB@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2-in.cisco.com ([171.71.176.71]:62719 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755759AbXEKLVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 07:21:31 -0400
In-Reply-To: <OFA0B8100C.1A34288C-ON652572D8.002808B3-652572D8.002945CB@in.ibm.com> (Krishna Kumar2's message of "Fri, 11 May 2007 13:00:48 +0530")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Sounds a good idea. I had a question on error handling. What happens if
 > the driver asynchronously returns an error for this WR (single WR
 > containing multiple skbs) ? Does it mean all the skbs failed to be sent ?
 > Requeuing all of them is a bad idea since it leads to infinitely doing the
 > same thing, so should every skb be free'd ? Isn't that harsh (if first skb
 > is bad and others are fine) and how do we avoid that ? Infact we don't
 > know which skb was transmitted and which failed. If we requeue skbs,
 > there will also be out-of-order skbs as the callback is asynchronous.

Each packet will still get a separate work request.  However if one
work request fails, then the QP will transition to the error state and
all later work requests will fail too.

But the completion handling doesn't change at all -- IPoIB already
queues work requests with the hardware and then collects completions
asynchronously.  If we get a failed completion then we free the skb
and bump tx errors -- there's nothing else really sensible to do.

However errors on UD QPs can never really happen except for driver
bugs or hardware failures, and for connected QPs (used in connected
mode), errors probably mean that a connection broke, so dropping
packets is quite sensible.
