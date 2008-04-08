From: Patrick McHardy <kaber@trash.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Wed, 09 Apr 2008 00:32:37 +0200
Message-ID: <47FBF285.4090201@trash.net>
References: <1203589042.17534.145.camel@johannes.berg>	 <1203616486.7181.269.camel@localhost>	<47BDBC23.5080007@trash.net>	 <20080223.200202.255773165.davem@davemloft.net>	 <47C2AAC8.8020202@trash.net> <1203969502.19319.279.camel@localhost>	 <47FBD30A.1010003@trash.net> <1207688549.1020.90.camel@localhost>	 <47FBE16E.6010504@trash.net> <1207692573.1020.134.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	harvey.harrison@gmail.com, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54772 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752176AbYDHWck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 18:32:40 -0400
In-Reply-To: <1207692573.1020.134.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> On Tue, 2008-04-08 at 23:19 +0200, Patrick McHardy wrote:
>> This might work (codiff should be able to tell). But I
>> just see that Dave also favours to use MAC_FMT directly,
>> so please just do this.
> 
> Precisely what are you objecting to Patrick?
> 
> Are you objecting to the existence of an additional
> function call in a printk or the unnecessary call to
> print_mac in functions like pr_debug that the compiler
> can not optimize away?
> 
> Your long list seems to be mostly a list of functions
> that are converted from direct use of MAC_FMT with
> 6 arguments on stack to a call to print_mac.
> 
> I think the only things that should be changed are those
> functions that add a useless call to print_mac because 
> pr_debug is optimized away.
> 
> I do _not_ think that merely because print_mac is used
> as a printk argument it should be reverted.


No, those cases probably don't matter, if there was a printk
before it can't matter that much. What should be removed is
cases like virtio_net:

static int start_xmit(struct sk_buff *skb, struct net_device *dev) 

{
...
         pr_debug("%s: xmit %p %s\n", dev->name, skb, print_mac(mac, dest));

which adds a unconditional and useless function call in a
performance critical path.

You could probably generate a better starting point than
my codiff somehow, I just redefined print_mac to
"00:00:00:00:00:00", which means it doesn't care whether
its in a printk or a pr_debug() call. Might be quicker
to go through the list manually though.

