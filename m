From: Imre Palik <imrep@amazon.de>
Subject: Re: [RFC PATCH v2] bridge: make it possible for packets to traverse
 the bridge without hitting netfilter
Date: Thu, 26 Feb 2015 11:19:25 +0100
Message-ID: <54EEF32D.2010202@amazon.de>
References: <1424705163-13428-1-git-send-email-imrep.amz@gmail.com> <20150223160619.GF24297@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <bridge@lists.linux-foundation.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Anthony Liguori <aliguori@amazon.com>
To: Florian Westphal <fw@strlen.de>, Imre Palik <imrep.amz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9101.amazon.com ([207.171.184.25]:40355 "EHLO
	smtp-fw-9101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbbBZKTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 05:19:33 -0500
In-Reply-To: <20150223160619.GF24297@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/15 17:06, Florian Westphal wrote:
> Imre Palik <imrep.amz@gmail.com> wrote:
>> The netfilter code is made with flexibility instead of performance in mind.
>> So when all we want is to pass packets between different interfaces, the
>> performance penalty of hitting netfilter code can be considerable, even when
>> all the firewalling is disabled for the bridge.
>>
>> This change makes it possible to disable netfilter on a per bridge basis.
>> In the case interesting to us, this can lead to more than 15% speedup
>> compared to the case when only bridge-iptables is disabled.
> 
> I wonder what the speed difference is between no-rules (i.e., we hit jump label
> in NF_HOOK), one single (ebtables) accept-all rule, and this patch, for
> the call_nf==false case.

ebtables is completely empty:

# ebtables -L
Bridge table: filter

Bridge chain: INPUT, entries: 0, policy: ACCEPT

Bridge chain: FORWARD, entries: 0, policy: ACCEPT

Bridge chain: OUTPUT, entries: 0, policy: ACCEPT


on some bridges I have iptables rules, but on the critical bridges I am running with iptables disabled.

> I guess your 15% speedup figure is coming from ebtables' O(n) rule
> evaluation overhead?  If yes, how many rules are we talking about?

If you are looking for peculiarities in my setup then here they are:
I am on 4k pages, and perf is not working :-(
(I am trying to fix those too, but that is far from being a low hanging fruit.)
So my guess would be that the packet pipeline doesn't fit in the cache/tlb

> Iff thats true, then the 'better' (I know, it won't help you) solution
> would be to use nftables bridgeport-based verdict maps...
> 
> If thats still too much overhead, then we clearly need to do *something*...
> 
> Thanks,
> Florian
> 
