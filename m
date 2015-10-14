From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] netlink: trim skb to exact size to avoid MSG_TRUNC
Date: Wed, 14 Oct 2015 09:44:36 +0200
Message-ID: <20151014074436.GE3266@pox.localdomain>
References: <1444698923-13992-1-git-send-email-ronen.arad@intel.com>
 <20151013085600.GA23077@pox.localdomain>
 <E4CD12F19ABA0C4D8729E087A761DC350F7AC0AA@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:32828 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752659AbbJNHoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 03:44:39 -0400
Received: by wicge5 with SMTP id ge5so88506765wic.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 00:44:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC350F7AC0AA@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/15 at 05:52pm, Arad, Ronen wrote:
> [@Ronen] My reader as I described above is providing a larger message
> which I'm trying to properly size. I'm aware that libnl shields
> applications from the need to know and provide properly sized buffer by
> peeking or/and re-allocating a buffer.
> My issue is with iproute2 "ip link show" and "bridge vlan show" commands.

>  
> >I'm just trying to understand which exact case you are solving here.
> Allocation is always performed by alloc_size which could be
> nlk->max_recvmsg_len (only when min_dump_alloc is sufficiently small) and
> upon failure falling back to alloc_min_size.
> The trimming of the skb space is common regardless of the allocation call.
> I tried to submit the minimal patch to address the issue. If you think the
> Re-organized code is better I can re-submit a V2.

I was about to suggest the same code change after initial discussion ;-)

So you are fixing the case where >2x messages fit the padded skb size.
This was not clear from the commit message. I would appreciate a note
in the commit message and updated code comment to reflect this.

The fix is definitely not incorrect and the penalty for readers which
peek first is less than I thought since nlk->max_recvmsg_len is at
least 16K in size. Since most peekers will double buffer sizes they
will most likely end up growing nlk->max_recvmsg_len after the first
read.

However, if alloc_size is > 16K, we would have typically ended up with a
giant skb which peeking users were able to take advantage of while
with this fix this is no longer the case.

However #2, I'll see if it makes sense to look at MSG_PEEK in recvmsg
and change nlk->max_recvmsg_len accordingly so we take advantage of
the full skb size on sockets which perform peeking. Given that both
reader behaviours can be preserved, I'm good with your proposed v2.
