From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH 2.6.23-rc1][NETFILTER] nf_conntrack_reasm: adding
 icmpv6_send code(TIME EXCEEDED).
Date: Thu, 02 Aug 2007 13:43:12 +0900 (JST)
Message-ID: <200708020443.l724hDXg000916@toshiba.co.jp>
References: <46B14720.9090300@ncos.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org
To: nakagawa.msy@ncos.nec.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:33249 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754829AbXHBEvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 00:51:24 -0400
Received: from imx12.toshiba.co.jp (imx12 [61.202.160.132])
	by imx9.toshiba.co.jp  with ESMTP id l724pH1W004477
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 2 Aug 2007 13:51:17 +0900 (JST)
Received: from wall11.toshiba.co.jp (wall11 [133.199.90.149])
	by imx12.toshiba.co.jp  with ESMTP id l724hFMS006559
	for <netdev@vger.kernel.org>; Thu, 2 Aug 2007 13:43:15 +0900 (JST)
Received: (from root@localhost)
	by wall11.toshiba.co.jp  id l724hERt014132
	for netdev@vger.kernel.org; Thu, 2 Aug 2007 13:43:14 +0900 (JST)
Received: from mx.toshiba.co.jp (localhost [127.0.0.1])
	by ovp11.toshiba.co.jp  with ESMTP id l724hE39017426
	for <netdev@vger.kernel.org>; Thu, 2 Aug 2007 13:43:14 +0900 (JST)
In-Reply-To: <46B14720.9090300@ncos.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

From: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>
Date: Wed, 01 Aug 2007 19:53:20 -0700

> I ran the TAHI conformance test on a kernel, which CONFIG_NF_CONNTRACK_IPV6
> is enabled. And then it showed a result including a couple of failure.
> The all of failed items are related to TIME EXCEEDED.
> 
> The test procedure is here.
>   Tester                      Target
>     |                           |
>     |-------------------------->|
>     |       Echo Request        |
>     |      (1st fragment)       |
>     |                           |
>     |      wait for 65 sec.     |
>     |                           |
>     |<--------------------------|
>     |        ICMPv6 Error       |
> 
> (1) Tester sends a first fragment of ICMPv6 echo request to Target.
> (2) Wait for over 60 sec.
> (3) If target replies a ICMPv6 error message(Time Exceeded) to Tester,
>     then this test is success, otherwise it's failure.
> 
> The reason of the failure is very simple, it's because icmpv6_send code are
> missing in nf_ct_frag6_expire function(nf_conntrack_reasm.c).
> The change is to add the missing code.
> 
> In RFC2460, the specification regarding Time Exceeded is described,
> but it's defined as "should". So, there is no specification violation here.
> Therefore I'm not sure whether this change is appropriate or not.
> 
> I will appreciate any comments. Thanks.

Main usage of nf_conntrack_ipv6 is for firewall today. I think that silently
sending error is not preferable. Moreover, RFC2460 says

  4.5  Fragment Header

   The Fragment header is used by an IPv6 source to send a packet larger
   than would fit in the path MTU to its destination.  (Note: unlike
   IPv4, fragmentation in IPv6 is performed only by source nodes, not by
   routers along a packet's delivery path -- see section 5.)  

This means that IPv6 router doesn't send Too Big error for forwarded
packets.

At least it's better to be configurable if people want to do that.
Second idea is to pass such fragments to next network processing instead of
dropping them. But I'm not sure that it is possible.

-- Yasuyuki Kozakai
