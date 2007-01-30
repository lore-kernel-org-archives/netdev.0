From: weidong <weid@np.css.fujitsu.com>
Subject: Re: [Patch][IPv6] Fix wrong routing mechanism for Link Local IPv6
	packets
Date: Tue, 30 Jan 2007 23:47:34 +0000 (UTC)
Message-ID: <1172070287.3394.0.camel@LINE>
References: <001501c7444d$ed731020$ccb1220a@ZhaoleiSOTEC>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:36137 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037AbXA3Xqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 18:46:34 -0500
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id l0UNkWpM003275
	for <netdev@vger.kernel.org> (envelope-from weid@np.css.fujitsu.com);
	Wed, 31 Jan 2007 08:46:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3898C2AC127
	for <netdev@vger.kernel.org>; Wed, 31 Jan 2007 08:46:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 107DD12C066
	for <netdev@vger.kernel.org>; Wed, 31 Jan 2007 08:46:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3 [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EA8F0161C007
	for <netdev@vger.kernel.org>; Wed, 31 Jan 2007 08:46:31 +0900 (JST)
Received: from ml9.s.css.fujitsu.com (ml9.s.css.fujitsu.com [10.23.4.199])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 88EB6161C008
	for <netdev@vger.kernel.org>; Wed, 31 Jan 2007 08:46:31 +0900 (JST)
Received: from ml9.css.fujitsu.com (ml9 [127.0.0.1])
	by ml9.s.css.fujitsu.com (Postfix) with ESMTP id 70510314032
	for <netdev@vger.kernel.org>; Wed, 31 Jan 2007 08:46:31 +0900 (JST)
Received: from 192.168.10.2 (dhcp177-204.sky.yk.fujitsu.co.jp [10.34.177.204])
	by ml9.s.css.fujitsu.com (Postfix) with ESMTP id 2C6BE31402D
	for <netdev@vger.kernel.org>; Wed, 31 Jan 2007 08:46:31 +0900 (JST)
In-Reply-To: <001501c7444d$ed731020$ccb1220a@ZhaoleiSOTEC>
Date: Wed, 21 Feb 2007 10:04:47 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Mr yoshfuji:
    Thanks for your reply.
The following is the figure.
|--------------------------------------------|
|                                            | 
|                 Router                     | 
|                                            |    |-------|
|   |------|                   |------|      |    | other |
|   | eth0 |---                | eth1 |------|----|network|
|   |------|  |                |------|      |    |-------|
|------|------|--------------------|---------|
       |      v                    | 
       | fe80::20c:29ff:fe24:fa0a  | 
       |                           | 
       |                           | 
       |                           | 
       |                           | 
       |                           | 
       |                           v 
       |               fe80::20c:29ff:fe24:fa14 
       |                           
       | 
|------|------| 
|  |------|   | 
|  | eth0 |---|--->fe80::200:ff:fe00:100 
|  |------|   | 
|             | 
|    Host     | 
|-------------| 

Host eth0: fe80::200:ff:fe00:100
Router eth0: fe80::20c:29ff:fe24:fa0a
Router eth1: fe80::20c:29ff:fe24:fa14

We ping6 from host's eth0 to Router's eth1. Echo Request's src addr =
fe80::200:ff:fe00:100, dst addr = fe80::20c:29ff:fe24:fa14. And Kernel
just send ICMPv6 redirect packet and then forward the Echo Request to
router's eth0. If we run tcpdump on Host eth0, we can receive the ICMPv6
Redirect packet. And if we send NA which advertises
fe80::20c:29ff:fe24:fa14 MAC address(this is very easy for v6eval tool),
we also can receive the forwarded Echo Request(src:fe80::200:ff:fe00:100
dst is fe80::20c:29ff:fe24:fa14). 

I dived into the kernel, and found that maybe function rt6_score_route()
has problems. In rt6_score_route(), if rt6_check_dev() return 0, and the
dst ipv6 addr is link local addr, rt6_socre_route() return -1 directly.
I think this is not correct, we should return -1 only if the entry is in
the route cache, and the dst addr is link local addr. Only entries in
cache may select wrong IPv6 Link Local NIC for a link local dst addr.
because they are copied from static IPv6 fib table entries.

> > Hello, Mr yoshfuji
> >     Take ping6 for example. Asumming there is a router which has 2 NICs.
> > eth0 on router has ipv6 addr fe80::20c:29ff:fe24:fa0a, eth1 on router has
> > ipv6 addr fe80::20c:29ff:fe24:fa14. Also there is a host connected to
> > router's eth0, and the host's ipv6 addr is fe80::200:ff:fe00:100. We ping6
> :
> 
> I still need more precise figure.
> 
> Please draw complete box for the 2-3 boxes (pinger, router (and the
> destination)), link(s) and interfaces.
> 
> +-------------+
> |    Router   |
> +---+-----+---+
> eth0|     |eth1
>     |     |
> eth0|
> +---+-+
> |Host1|
> +-----+
> 
> Host1  eth0: fe80:....
> Router eth0: fe80:....
> Router eth1: fe80:...
> 
> Or, something like that....
> 
> I think you may use other tool such as tgif etc.
> 
> --yoshfuji 
> 

