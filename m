From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: don't use CHECKSUM_PARTIAL on MSG_MORE/UDP_CORK
 sockets
Date: Wed, 21 Oct 2015 14:52:33 +0200
Message-ID: <1445431953.1205852.416263057.606CE717@webmail.messagingengine.com>
References: <1445351922-8463-1-git-send-email-hannes@stressinduktion.org>
 <5626B4A3.6080900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: sd@quesysnail.net, bcodding@redhat.com
To: Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:49889 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752971AbbJUMwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 08:52:34 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id A75A3204B9
	for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 08:52:33 -0400 (EDT)
In-Reply-To: <5626B4A3.6080900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 20, 2015, at 23:39, Vlad Yasevich wrote:
> I am now wondering if this might be UFO related instead and looking for a
> nic that
> has UFO support.

I doubt that.

We overallocate memory first time in ip6_append_data because we are in
MSG_MORE mode. Then, in my case the second write only copies data into
the first skb on the write queue, no skb is appended to frags_list. So
udp6_hwcsum_outgoing doesn't clean up the flags, either.

We can improve the check if we fragment an ipv6 skb in ip6_append_mode
in net-next, I agree. But I still see this fix suitable for 'net' tree.

We could also improve udp6_hwcsum_outgoing to check if our packets get
fragmented and fall back to the clean-up path. But I think this kind of
optimization should go into net-next, too.

Currently the check made sure we don't use PARTIAL on skbs which could
fragment. MSG_MORE somehow circumvented that check, so I think the fix
is good to go. We certainly can try to improve PARTIAL checksums for
fragmented packets.

What do you think?

Bye,
Hannes
