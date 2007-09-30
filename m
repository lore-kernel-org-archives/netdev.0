From: linux@horizon.com
Subject: Re: 2.6.23-rc8 network problem.  Mem leak?  ip1000a?
Date: 30 Sep 2007 07:40:24 -0400
Message-ID: <20070930114024.13626.qmail@science.horizon.com>
References: <20070930022347.37514be3.akpm@linux-foundation.org>
Cc: jesse@icplus.com.tw, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, romieu@fr.zoreil.com, s.l-h@gmx.de
To: akpm@linux-foundation.org, linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:15416 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755566AbXI3MKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2007 08:10:04 -0400
In-Reply-To: <20070930022347.37514be3.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> OK.  Did you try to reproduce it without the pps patch applied?

No.  But I've yanked the ip1000a driver (using old crufy vendor-supplied
out-of-kernel module) and the problems are GONE.

>> This machine receives more data than it sends, so I'd expect acks to
>> outnumber "real" packets.  Could the ip1000a driver's transmit path be
>> leaking skbs somehow?

> Absolutely.  Normally a driver's transmit completion interrupt handler will
> run dev_kfree_skb_irq() against the skbs which have been fully sent.
>
> However it'd be darned odd if the driver was leaking only tcp acks.

It's leaking lots of things... you can see ARP packets in there and
all sorts of stuff.  But the big traffic hog is BackupPC doing inbound
rsyncs all night long, which generates a lot of acks.  Those are the
packets it sends, so those are the packets that get leaked.

> I can find no occurrence of "dev_kfree_skb" in drivers/net/ipg.c, which is
> suspicious.

Look for "IPG_DEV_KFREE_SKB", which is a wrapper macro.  (Or just add
"-i" to your grep.)  It should probably be deleted (it just expands to
dev_kfree_skb), but was presumably useful to someone during development.

> Where did you get your ipg.c from, btw?  davem's tree?  rc8-mm1? rc8-mm2??

As I wrote originally, I got it from
http://marc.info/?l=linux-netdev&m=118980588419882
which was a reuqest for mainline submission.

If there are other patches floating around, I'm happy to try them.
Now that I know what to look for, it's easy to spot the leak before OOM.

> I assume that meminfo was not captured when the system was ooming?  There
> isn't much slab there.

Oops, sorry.  I captured slabinfo but not meminfo.


Thank you very much!  Sorry to jump the gun and post a lot before I had
all the data, but if it WAS a problem in -rc8, I wanted to mention it
before -final.

Now, the rush is to get the ip1000a driver fixed before the merge
window opens.  I've added all the ip1000a developers to the Cc: list in
an attempt to speed that up.
