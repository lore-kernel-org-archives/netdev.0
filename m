From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Mon, 13 Sep 2010 07:49:41 +0000
Message-ID: <20100913074941.GA7259@ff.dom.local>
References: <20100912.150854.193715637.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43538 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434Ab0IMHtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 03:49:50 -0400
Received: by bwz11 with SMTP id 11so4258507bwz.19
        for <netdev@vger.kernel.org>; Mon, 13 Sep 2010 00:49:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100912.150854.193715637.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-09-13 00:08, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sun, 12 Sep 2010 22:57:22 +0200
> 
>> On Sun, Sep 12, 2010 at 09:13:53AM -0700, David Miller wrote:
>>>
>>> BTW, Jarek, as to your idea to store a tail pointer in the shinfo, how
>>> will you sync that tail pointer in all of the shinfo instances
>>> referencing the frag list?
>>>
>>> It simply can't work, we have to copy.
>>
>> The question is if we need to sync at all? This is shared data at the
>> moment, so I can't imagine how the list (especialy doubly linked)
>> could be changed without locking? And even if it's possible, I doubt
>> copying e.g. like in your current patch can help when an skb is added
>> at the tail later.
> 
> That's the fundamental issue.
> 
> If you look, everywhere we curently do that trick of "use the
> skb->prev pointer to remmeber the frag_list tail" the code knows
> it has exclusive access to both the skb metadata and the
> underlying data.
> 
> But for modifications of the frag list during the SKBs lifetime
> that's another issue, entirely.  All of these functions trimming
> the head or tail of the SKB data which can modify the frag
> list elements, they can be called from all kinds of contexts.
> Look for Alexey Kuznetsov's comments in skbuff.c that read
> "mincing fragments" and similar.

OK, I've found the skb_cow_data() comments, but I can see there only
a modification of copied data.

> 
> The real win with my work is complete unification of all list
> handling, and making our packet handling code much more "hackable"
> by non-networking kernel hackers.
> 
> Really we have the last major core datastructures that do not
> use standard lists, and I'm going to convert it so we can
> be sane like the rest of the kernel. :-)

I guess we can stay with different opinions, no problem, at least to
me. IMHO, considering the need for additional copying or even only
cloning data where it's not currently done, doubly linked list is
too costly for the frag_list. It would affect pskb_expand_head(),
pskb_copy() but probably also skb_segment(), and maybe more. So, with
GROwing(!) importance of fragmented packets, I doubt this copying will
be as unlikely as presumed.

Jarek P.
