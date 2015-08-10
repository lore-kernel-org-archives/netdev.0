From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: make sure -EBUSY won't escape from
 netlink_insert
Date: Mon, 10 Aug 2015 11:00:15 -0700 (PDT)
Message-ID: <20150810.110015.1616067694505641781.davem@davemloft.net>
References: <d466c48264ca677f0fc61ff76526780c32c37cb5.1438898409.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, tgraf@suug.ch,
	torvalds@linux-foundation.org, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932097AbbHJSAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 14:00:16 -0400
In-Reply-To: <d466c48264ca677f0fc61ff76526780c32c37cb5.1438898409.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri,  7 Aug 2015 00:26:41 +0200

> Linus reports the following deadlock on rtnl_mutex; triggered only
> once so far (extract):
 ...
> It seems so far plausible that the recursive call into rtnetlink_rcv()
> looks suspicious. One way, where this could trigger is that the senders
> NETLINK_CB(skb).portid was wrongly 0 (which is rtnetlink socket), so
> the rtnl_getlink() request's answer would be sent to the kernel instead
> to the actual user process, thus grabbing rtnl_mutex() twice.
> 
> One theory would be that netlink_autobind() triggered via netlink_sendmsg()
> internally overwrites the -EBUSY error to 0, but where it is wrongly
> originating from __netlink_insert() instead. That would reset the
> socket's portid to 0, which is then filled into NETLINK_CB(skb).portid
> later on. As commit d470e3b483dc ("[NETLINK]: Fix two socket hashing bugs.")
> also puts it, -EBUSY should not be propagated from netlink_insert().
> 
> It looks like it's very unlikely to reproduce. We need to trigger the
> rhashtable_insert_rehash() handler under a situation where rehashing
> currently occurs (one /rare/ way would be to hit ht->elasticity limits
> while not filled enough to expand the hashtable, but that would rather
> require a specifically crafted bind() sequence with knowledge about
> destination slots, seems unlikely). It probably makes sense to guard
> __netlink_insert() in any case and remap that error. It was suggested
> that EOVERFLOW might be better than an already overloaded ENOMEM.
> 
> Reference: http://thread.gmane.org/gmane.linux.network/372676
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied and queued up for -stable, thanks.
