From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] RPS: Sparse connection optimizations - v2
Date: Mon, 07 May 2012 10:25:53 +0200
Message-ID: <1336379153.3752.2273.camel@edumazet-glaptop>
References: <1336035412-2161-1-git-send-email-dczhu@mips.com>
	 <CA+mtBx_J=fm3+k6_NzMH9KCdrYpZPwT2XBQe4r424eNDCKzazg@mail.gmail.com>
	 <4FA35A3D.8000205@mips.com>
	 <CA+mtBx-CErRU=3ewkAjVrGN3dGzjsTz8Q-E8J+Xa+529OVEvwA@mail.gmail.com>
	 <4FA77051.20804@mips.com> <1336376282.3752.2252.camel@edumazet-glaptop>
	 <4FA7815F.8030101@mips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Deng-Cheng Zhu <dczhu@mips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:41809 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755543Ab2EGIZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 04:25:59 -0400
Received: by bkcji2 with SMTP id ji2so3450073bkc.19
        for <netdev@vger.kernel.org>; Mon, 07 May 2012 01:25:58 -0700 (PDT)
In-Reply-To: <4FA7815F.8030101@mips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-05-07 at 16:01 +0800, Deng-Cheng Zhu wrote:

> Did you really read my patch and understand what I commented? When I was
> talking about using rps_sparse_flow (initially cpu_flow), neither
> rps_sock_flow_table nor rps_dev_flow_table is activated (number of
> entries: 0).

I read your patch and am concerned of performance issues when handling
typical workload. Say between 0.1 and 20 Mpps on current hardware.

The argument "oh its only selected when
CONFIG_RPS_SPARSE_FLOW_OPTIMIZATION is set" is wrong.

CONFIG_NR_RPS_MAP_LOOPS is wrong.

Your HZ timeout is yet another dark side of your patch. 

Your (flow->dev == skb->dev) test is wrong.

Your : flow->ts = now; is wrong (dirtying memory for each packet)

Really I dont like your patch.

You are kindly asked to find another way to solve your problem, a
generic mechanism that can help others, not only you.

We do think activating RFS is the way to go. Its the standard layer we
added below RPS, its configurable and scales. It can be expanded at will
with configurable plugins.

For example, using single queue NICS, it makes sense to select cpu on
the output device only, not on the rxhash by itself (a modulo or
something), to reduce false sharing and qdisc/device lock on tx path.

If your machine has 4 cpus, and 4 nics, you can instruct RFS table to
prefer cpu on the NIC that packet will use for output.
