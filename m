From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 0/2] sctp: Improve the tsn_map
Date: Wed,  8 Oct 2008 16:27:48 -0400
Message-ID: <1223497670-519-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:26970 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754839AbYJHU2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 16:28:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following two patches improve the TSN map implementation in sctp.
The TSN map is used to track which TSNs (transmission sequence numbers) we
received.  The way it's currently written, we have a 4K array of bytes
where each byte represents the TSN.  When we receive a TSN we mark the
corresponding byte and then run through an algorithm to update the
ack points.

This is grossely inefficient in both memory and code.  The only time it
makes sense to mark the TSN in the map is if it's out of order.  In-order
tsns can simply move the ack point and be done with it.  Also, since this
is a simple a 1 or 0 (we have the TSN or we do not), we can do all this
with bitmaps and shrink our map by a factor of 8.  Further more,
it is hightly unlikely that we are every going to see 2 out of order
number with a difference/gap of 4096.  So, we can start our map at
the optimum size of a long word (32 or 64 bits depending on architecure).
We can then grow the map in the unlikely event that we receive a gap
that will push us outside of the map.  On a low loss network, fast
retransmis will prevent that before the map grows to much.

Running netperf shows a tiny improvement, but it's very stable, ie.
it's the same 3% across 10.  It also shows about 1% reduction is
CPU utilization.

The second patch gets rid of the rather useless member of the tsn_map
and was done after the bulk of the work above.  It became more obvious
that the structure member was useless after all the clean up.

Please consider for 2.6.28.

Thanks
-vlad
