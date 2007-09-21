From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 0/2] David Miller's rbtree patches for 2.6.22.6
Date: Fri, 21 Sep 2007 17:08:07 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0709211327420.9514@kivilampi-30.cs.helsinki.fi>
References: <46F1CF35.3030606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Tom Quetchenbach <virtualphtn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50531 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757014AbXIUOIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 10:08:10 -0400
In-Reply-To: <46F1CF35.3030606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2007, Tom Quetchenbach wrote:

> Here are a couple of patches against 2.6.22.6. The first one is just
> David's patches tweaked for 2.6.22.6, with a couple of minor bugfixes to
> get it to compile and not crash.

Why did you combine original patches to a single larger one, I think Dave 
made them separate on purpose.

> (I also changed
> __tcp_insert_write_queue_tail() to set the fack_count of the new packet
> to the fack_count of the tail plus the packet count of the tail, not the
> packet count of the new skb, because I think that's how it was intended
> to be. Right?

I think I noticed similar "off-by-pcount" error when I looked that long 
time ago, so I guess you're correct. We're only interested in delta 
of it anyway and add the current skb's pcount to it (which is not 
fixed until tcp_fragment in sacktag is past).

> In the second patch there are a couple of significant changes.  One is
> (as Baruch suggested) to modify the existing SACK fast path so that we
> don't tag packets we've already tagged when we advance by a packet.

This solution would still spend extensive amount of time in processing  
loop, whenever recv_sack_cache fast-path is not taken, that is, e.g. when 
cumulative ACK after retransmissions arrive or new hole becomes visible 
(which are not very exceptional events after all :-)). In the cumulative 
ACK case especially, this processing is very likely _fully_ wasted 
walking.

So there is still room for large improvements. I've made an improved 
version of the current sacktag walk couple of days ago (it's in a state 
where it didn't crash but likely very buggy still), I'll post it here 
soon... Idea is embed recv_sack_cache checking fully into the walking 
loop. By doing that an previously known work is not duplicated. The patch
is currently against non-rbtree stuff but incorporating rb-tree things on 
top of it should be very trivial and synergy benefits with rbtree should 
be considerable because non-rbtree has to do "fast walk" skipping for skbs 
that are under highest_sack which is prone to cache misses. 

> The other issue is that the cached fack_counts seem to be wrong, because
> they're set when we insert into the queue, but tcp_set_tso_segs() is
> called later, just before we send, so all the fack_counts are zero. My
> solution was to set the fack_count when we advance the send_head.

I think it's better solution anyway, since we might have to do 
reset_fack_counts() in between and there's no need to update past 
sk_send_head.

> Also I
> changed tcp_reset_fack_counts() so that it exits when it hits an skb
> whose tcp_skb_pcount() is zero

Do you mind to explain what's the purpose of that?

> or whose fack_count is already correct.
> (This really helps when TSO is on, since there's lots of inserting into
> the middle of the queue.)

Good point.

> Please let me know how I can help get this tested and debugged.

Most network development happens against latest net-2.6(.x) trees. 
In addition, there's experimental tcp-2.6 tree but it's currently a bit 
outdated already (and DaveM is very busy with the phenomenal merge 
they're doing for 2.6.24 :-) so it's not too likely to be updated very 
soon).

...Anyway, thanks for your interest in these things.


-- 
 i.
