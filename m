From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sunvnet: don't change gso data on clones
Date: Wed, 11 Feb 2015 18:52:50 -0800
Message-ID: <1423709570.4847.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54DB5711.3040705@oracle.com>
	 <1423662993.4847.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54DB92CD.1070309@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:34894 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753030AbbBLCww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 21:52:52 -0500
Received: by mail-qg0-f44.google.com with SMTP id j5so6018868qga.3
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 18:52:52 -0800 (PST)
In-Reply-To: <54DB92CD.1070309@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-11 at 12:35 -0500, David L Stevens wrote:

> I don't think I understand your concern. This problem can result in a
> panic using sunvnet because the sunvnet driver is changing the original
> skb, which is always, or at least almost always, a clone. TCP uses gso_segs
> to track packet counts, so changing it in the driver can result in bad math--
> TCP assumes its copy of the clone's data shouldn't change (of course).
> 
> A driver that doesn't change the segmentation or original data doesn't
> need to care whether it's a clone or not-- it'll free it and drop a
> reference. Since sunvnet is changing the gso_size and gso_segs, it needs
> to unclone first.

Well, we had a very hard to find bug in TCP stack, I want to make sure
we fixed all relevant points.

commit c52e2421f7368fd36cbe330d2cf41b10452e39a9
Author: Eric Dumazet <edumazet@google.com>
Date:   Tue Oct 15 11:54:30 2013 -0700

    tcp: must unclone packets before mangling them
    
    TCP stack should make sure it owns skbs before mangling them.
    
    We had various crashes using bnx2x, and it turned out gso_size
    was cleared right before bnx2x driver was populating TC descriptor
    of the _previous_ packet send. TCP stack can sometime retransmit
    packets that are still in Qdisc.
    
    Of course we could make bnx2x driver more robust (using
    ACCESS_ONCE(shinfo->gso_size) for example), but the bug is TCP stack.
    
    We have identified two points where skb_unclone() was needed.
    
    This patch adds a WARN_ON_ONCE() to warn us if we missed another
    fix of this kind.
    
    Kudos to Neal for finding the root cause of this bug. Its visible
    using small MSS.
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: Neal Cardwell <ncardwell@google.com>
    Cc: Yuchung Cheng <ycheng@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
