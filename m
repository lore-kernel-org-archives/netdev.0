From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TSQ accounting skb->truesize degrades throughput for large
 packets
Date: Sat, 07 Sep 2013 10:21:34 -0700
Message-ID: <1378574494.26319.14.camel@edumazet-glaptop>
References: <20130906101635.GI14104@zion.uk.xensource.com>
	 <1378472268.31445.15.camel@edumazet-glaptop> <522A049A.7000105@citrix.com>
	 <1378486840.31445.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Jonathan Davies <Jonathan.Davies@eu.citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:40752 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059Ab3IGRVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 13:21:35 -0400
Received: by mail-pd0-f170.google.com with SMTP id x10so4514865pdj.29
        for <netdev@vger.kernel.org>; Sat, 07 Sep 2013 10:21:35 -0700 (PDT)
In-Reply-To: <1378486840.31445.36.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-06 at 10:00 -0700, Eric Dumazet wrote:
> On Fri, 2013-09-06 at 17:36 +0100, Zoltan Kiss wrote:
> 
> > So I guess it would be good to revisit the default value of this 
> > setting.
> 
> If ixgbe requires 3 TSO packets in TX ring to get line rate, you also
> can tweak dev->gso_max_size from 65535 to 64000.

Another idea would be to no longer use tcp_limit_output_bytes but

max(sk_pacing_rate / 1000, 2*MSS)

This means that number of packets in FQ would be limited to the
equivalent of 1ms, so TCP could have faster response to packet losses : 

Retransmitted packets would not have to wait for prior packets being
drained from FQ

For a 8Gbps flow, 1Gbyte/s, sk_pacing_rate would be 2Gbyte, this would
translate to ~2 Mbytes in Qdisc/TX ring.

sk_pacing_rate was introduced in linux-3.12, but could be backported
easily.
