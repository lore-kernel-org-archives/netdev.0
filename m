From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: make sure -EBUSY won't escape from
 netlink_insert
Date: Mon, 28 Sep 2015 16:46:22 -0700 (PDT)
Message-ID: <20150928.164622.2054212909053636350.davem@davemloft.net>
References: <d466c48264ca677f0fc61ff76526780c32c37cb5.1438898409.git.daniel@iogearbox.net>
	<20150810.110015.1616067694505641781.davem@davemloft.net>
	<20150917054114.GN1983@Chimay.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, herbert@gondor.apana.org.au, tgraf@suug.ch,
	torvalds@linux-foundation.org, netdev@vger.kernel.org
To: christoph.paasch@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752984AbbI1XqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 19:46:25 -0400
In-Reply-To: <20150917054114.GN1983@Chimay.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@gmail.com>
Date: Wed, 16 Sep 2015 22:41:14 -0700

> Hello,
> 
> On 10/08/15 - 11:00:15, David Miller wrote:
>> From: Daniel Borkmann <daniel@iogearbox.net>
>> Date: Fri,  7 Aug 2015 00:26:41 +0200
>> > Linus reports the following deadlock on rtnl_mutex; triggered only
>> > once so far (extract):
>>  ...
>> > It seems so far plausible that the recursive call into rtnetlink_rcv()
>> > looks suspicious. One way, where this could trigger is that the senders
>> > NETLINK_CB(skb).portid was wrongly 0 (which is rtnetlink socket), so
>> > the rtnl_getlink() request's answer would be sent to the kernel instead
>> > to the actual user process, thus grabbing rtnl_mutex() twice.
>> > 
>> > One theory would be that netlink_autobind() triggered via netlink_sendmsg()
>> > internally overwrites the -EBUSY error to 0, but where it is wrongly
>> > originating from __netlink_insert() instead. That would reset the
>> > socket's portid to 0, which is then filled into NETLINK_CB(skb).portid
>> > later on. As commit d470e3b483dc ("[NETLINK]: Fix two socket hashing bugs.")
>> > also puts it, -EBUSY should not be propagated from netlink_insert().
>> > 
>> > It looks like it's very unlikely to reproduce. We need to trigger the
>> > rhashtable_insert_rehash() handler under a situation where rehashing
>> > currently occurs (one /rare/ way would be to hit ht->elasticity limits
>> > while not filled enough to expand the hashtable, but that would rather
>> > require a specifically crafted bind() sequence with knowledge about
>> > destination slots, seems unlikely). It probably makes sense to guard
>> > __netlink_insert() in any case and remap that error. It was suggested
>> > that EOVERFLOW might be better than an already overloaded ENOMEM.
>> > 
>> > Reference: http://thread.gmane.org/gmane.linux.network/372676
>> > Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
>> > Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>> 
>> Applied and queued up for -stable, thanks.
> 
> can this patch get queued up for 4.1 as well?
> It seems to fix a similar issue in 4.1.6.

Done.
