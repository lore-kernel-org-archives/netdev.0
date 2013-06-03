From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCHv2 net-next] netlink: allow large data transfers from
 user-space
Date: Mon, 3 Jun 2013 19:29:26 +0200
Message-ID: <20130603172926.GA28297@localhost>
References: <1370277599-27072-1-git-send-email-pablo@netfilter.org>
 <20130603170136.GA23920@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55440 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759230Ab3FCR3b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 13:29:31 -0400
Content-Disposition: inline
In-Reply-To: <20130603170136.GA23920@macbook.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick!

On Mon, Jun 03, 2013 at 07:01:37PM +0200, Patrick McHardy wrote:
> On Mon, Jun 03, 2013 at 06:39:59PM +0200, Pablo Neira Ayuso wrote:
> > I can hit ENOBUFS in the sendmsg() path with a large batch that is
> > composed of many netlink messages. Here that limit is 8 MBytes of
> > skbuff data area as kmalloc does not manage to get more than that.
> > 
> > While discussing atomic rule-set for nftables with Patrick McHardy,
> > we decided to put all rule-set updates that need to be applied
> > atomically in one single batch to simplify the existing approach.
> > However, as explained above, the existing netlink code limits us
> > to a maximum of ~20000 rules that fit in one single batch without
> > hitting ENOBUFS. iptables does not have such limitation as it is
> > using vmalloc.
> > 
> > This patch adds netlink_alloc_large_skb() which is only used in
> > the netlink_sendmsg() path. It uses alloc_skb if the memory
> > requested is <= one memory page, that should be the common case
> > for most subsystems, else vmalloc for higher memory allocations.
> 
> I know I suggested to do this - just wondering right now, how will
> we indiciate to userspace that a change has been applied atomically
> when sending notifications? Not sure whether it matters unless
> userspace will be able to get a dump while we're in the middle of
> updating the ruleset. I guess that won't be possible, right?

Userspace gets dump messages with the NLM_F_DUMP_INTR flag set in case
of interference, so it knows it has to retry the dump to get a fresh
rule-set. The current nftables code does not work that way, it needs a
small patch I have here though.

Regards.
