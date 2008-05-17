From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Fri, 16 May 2008 18:13:20 -0700
Message-ID: <d1c2719f0805161813kc0dca29y1feaf4d512a959e@mail.gmail.com>
References: <d1c2719f0805122056ib4c1af7pfa7f95f6e38c7e32@mail.gmail.com>
	 <20080512.205837.215391489.davem@davemloft.net>
	 <d1c2719f0805122100u7e550820xff6fcdbc1e538948@mail.gmail.com>
	 <20080512.210202.158182011.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:45026 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbYEQBN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 21:13:29 -0400
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m4H1DM1O000623
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 02:13:23 +0100
Received: from hs-out-0708.google.com (hscn78.prod.google.com [10.44.115.78])
	by zps37.corp.google.com with ESMTP id m4H1DL6X014863
	for <netdev@vger.kernel.org>; Fri, 16 May 2008 18:13:21 -0700
Received: by hs-out-0708.google.com with SMTP id n78so877303hsc.8
        for <netdev@vger.kernel.org>; Fri, 16 May 2008 18:13:20 -0700 (PDT)
In-Reply-To: <20080512.210202.158182011.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, now the code seems to work when TSO is disabled, i.e., cwnd
remains low (40-60pkts) and only grows slowly for extended period on
a back2back 1GbE link. It also works when tcpdump was running
after I fixed the code, per your suggestion, to only bump the in_flight
count for fast clones.

But it doesn't work when TSO is enabled. I've fixed tso_fragment() to
correctly set skb_shinfo(buff)->in_flight after the split. But cwnd still
grows rapidly to a few hundred pkts (although smaller than w/o
the fix). The host inflight accounting gets screwed up. It looks like
pskb_expand_head() called by tcp_tso_acked()->tcp_trim_head()
messes up the accounting but I don't know how to fix it (still trying
to understand this complex piece of code). There could be other
reason as well.

Jerry

On Mon, May 12, 2008 at 9:02 PM, David Miller <davem@davemloft.net> wrote:
> From: "Jerry Chu" <hkchu@google.com>
> Date: Mon, 12 May 2008 21:00:08 -0700
>
>> Does xchg() return the old value? (Can't find any comments on it.)
>
> Yes, otherwise it wouldn't be very useful.
>
