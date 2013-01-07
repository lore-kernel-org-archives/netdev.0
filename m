From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [PATCH] xen/netfront: improve truesize tracking
Date: Mon, 7 Jan 2013 15:11:33 +0100
Message-ID: <606842712.20130107151133@eikelenboom.it>
References: <1355838711-5473-1-git-send-email-ian.campbell@citrix.com> <1355843525.9380.18.camel@edumazet-glaptop> <1355844398.14620.254.camel@zakaz.uk.xensource.com> <55633610.20121219123427@eikelenboom.it> <1355933869.21834.13.camel@edumazet-glaptop> <1797374383.20121220135139@eikelenboom.it> <1356017968.21834.2859.camel@edumazet-glaptop> <1609010645.20121221122100@eikelenboom.it> <50D4AB87.8050601@hp.com> <561084196.20130103214030@eikelenboom.it> <1357566063.7989.68.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	annie li <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.121.164.40.188.clients.your-server.de ([188.40.164.121]:56352
	"EHLO smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844Ab3AGOLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 09:11:39 -0500
In-Reply-To: <1357566063.7989.68.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Monday, January 7, 2013, 2:41:03 PM, you wrote:

> On Thu, 2013-01-03 at 20:40 +0000, Sander Eikelenboom wrote:
>> Friday, December 21, 2012, 7:33:43 PM, you wrote:
>> 
>> > I'm guessing that trusize checks matter more on the "inbound" path than 
>> > the outbound path?  If that is indeed the case, then instead of, or in 
>> > addition to using the -s option to set the local (netperf side) socket 
>> > buffer size, you should use a -S option to set the remote (netserver 
>> > side) socket buffer size.
>> 
>> > happy benchmarking,
>> 
>> > rick jones
>> 
>> 
>> OK, ran them with -S as well:

> Are these all from domU -> dom0 ? Did you try traffic going the other
> way?

Yes running netperf in domU and netserver in dom0, but i must say i'm far from a netperf expert.
So i don't even know for sure if the tests i ran give a good picture.

>> "current" is with netfront as is        (skb->truesize += skb->data_len - RX_COPY_THRESHOLD;)
>> "patched" is with IanC's latest patch   (skb->truesize += PAGE_SIZE * skb_shinfo(skb)->nr_frags;)

skb->>truesize += skb->data_len - NETFRONT_SKB_CB(skb)->pull_to; is
> probably more interesting to compare against since we know the current
> one is buggy.

Will see if i can run against that as well, although i thought Eric said to prefer the "skb->truesize += PAGE_SIZE * skb_shinfo(skb)->nr_frags;"


> These number generally look good, largely +/- 1%, often in favour of the
> updated code but these two stand out as worrying:

>> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
>>         Recv   Send    Send
>>         Socket Socket  Message  Elapsed
>>         Size   Size    Size     Time     Throughput
>>         bytes  bytes   bytes    secs.    KBytes/sec
>> 
>> current 18000  16384   1432    60.00    37559.94
>> patched 18000  16384   1432    60.00    40630.66
>> 
>> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
>>         Recv   Send    Send
>>         Socket Socket  Message  Elapsed
>>         Size   Size    Size     Time     Throughput
>>         bytes  bytes   bytes    secs.    KBytes/sec
>> 
>> current 28000  16384  16384    60.00    103766.68
>> patched 28000  16384  16384    60.00    93277.98

> That's at least a 10% slow down in both cases.

>> UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
>>         Socket  Message  Elapsed      Messages
>>         Size    Size     Time         Okay Errors   Throughput
>>         bytes   bytes    secs            #      #   KBytes/sec
>> 
>> current 212992   65507   60.00      252586      0    269305.73
>> current   2280           60.00      229371           244553.96
>> patched 212992   65507   60.00      256209      0    273168.32
>> patched   2280           60.00      201670           215019.54

> The recv numbers here aren't too pleasing either.

> However, given that this fixes a real issue which people are seeing I'd
> be inclined to go with it, at least for now.

> Ian.
