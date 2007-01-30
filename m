From: "Wei Dong" <weid@np.css.fujitsu.com>
Subject: Re: [Patch][IPv6] Fix wrong routing mechanism for Link Local IPv6 packets
Date: Tue, 30 Jan 2007 16:55:12 +0900
Message-ID: <024b01c74443$f882d590$ccb1220a@ZhaoleiSOTEC>
References: <1172042666.4512.8.camel@LINE> <20070130.162441.39376131.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <usagi-users@linux-ipv6.org>
To: "YOSHIFUJI Hideaki / ????" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:36136 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965434AbXA3HzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 02:55:18 -0500
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id l0U7tFAa014650
	for <netdev@vger.kernel.org> (envelope-from weid@np.css.fujitsu.com);
	Tue, 30 Jan 2007 16:55:15 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 445982AC08B
	for <netdev@vger.kernel.org>; Tue, 30 Jan 2007 16:55:15 +0900 (JST)
Received: from s11.gw.fujitsu.co.jp (s11.gw.fujitsu.co.jp [10.0.50.81])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1947F12C08F
	for <netdev@vger.kernel.org>; Tue, 30 Jan 2007 16:55:15 +0900 (JST)
Received: from s11.gw.fujitsu.co.jp (s11 [127.0.0.1])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A96C161C009
	for <netdev@vger.kernel.org>; Tue, 30 Jan 2007 16:55:15 +0900 (JST)
Received: from ml2.s.css.fujitsu.com (ml2.s.css.fujitsu.com [10.23.4.192])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id A3DB2161C007
	for <netdev@vger.kernel.org>; Tue, 30 Jan 2007 16:55:14 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Mr yoshfuji
    Take ping6 for example. Asumming there is a router which has 2 NICs. 
eth0 on router has ipv6 addr fe80::20c:29ff:fe24:fa0a, eth1 on router has 
ipv6 addr fe80::20c:29ff:fe24:fa14. Also there is a host connected to 
router's eth0, and the host's ipv6 addr is fe80::200:ff:fe00:100. We ping6 
to router's eth1(ipv6 addr fe80::20c:29ff:fe24:fa14). But now Linux kernel 
deals with this kind of packet incorrectly. Router forward the Echo request 
to eth0. And send ICMP redirect packet to the host. In ICMP redirect packt 
TargetAddress =fe80::20c:29ff:fe24:fa14, DestinationAddress = 
fe80::20c:29ff:fe24:fa14. So I think Linux  kernel considers that 
fe80::200:ff:fe00:100 and fe80::20c:29ff:fe24:fa14 are neighbors.

I dived into the kernel, and found that maybe function rt6_score_route() has 
problems. In rt6_score_route(), if rt6_check_dev() return 0, and the dst 
ipv6 addr is link local addr, rt6_socre_route() return -1 directly. I think 
this is not correct, we should return -1 only if the entry is in the route 
cache, and the dst addr is link local addr. Only entries in cache will 
select wrong IPv6 Link Local NIC for a link local addr, because they are 
copied from static IPv6 fib tables.

----- Original Message ----- 
> Hello.
>
> In article <1172042666.4512.8.camel@LINE> (at Wed, 21 Feb 2007 
> 02:24:26 -0500), weidong <weid@np.css.fujitsu.com> says:
>
>>          eth0: fe80::20c:29ff:fe24:fa0a
>>             |                     eth1: fe80::20c:29ff:fe24:fa14
>>             |                      |
>> ------------------------------------------------
>>             |                      |
>>             |                      |
>>             | LAN1                 |LAN2
>>             |                      |
>>           -----
>>             ^
>>             |
>>      Send Echo Request(src addr = fe80::200:ff:fe00:100)
>
> Sorry, I could not understand this figure....
> Would you elaborate this?
>
> --yoshfuji 

