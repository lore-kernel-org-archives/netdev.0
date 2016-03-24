From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 07:45:44 -0700
Message-ID: <1458830744.10868.72.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20151216161514.GA3476@1wt.eu>
	 <CAO5YkUSL=k3UxmuqkGN666YSvH-=UGKCZvRgqqBnnr1EPRqRtw@mail.gmail.com>
	 <20151218185812.GD4448@1wt.eu>
	 <1450492683.8474.123.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151219070009.GA4634@1wt.eu>
	 <CALx6S35248apbWqtG+g2U99O=4UJqyAG0bJeuxhZWtShrpDF+w@mail.gmail.com>
	 <20151221204127.GC8018@1wt.eu>
	 <CALmu+SwjG0GVocGufTbgX-WJfcsP85SvHB=xtW7qQX3kZwJCxg@mail.gmail.com>
	 <20160324061222.GA6807@1wt.eu>
	 <1458828813.10868.65.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160324142222.GB7237@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tolga Ceylan <tolga.ceylan@gmail.com>,
	Tom Herbert <tom@herbertland.com>, cgallek@google.com,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35172 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbcCXOpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 10:45:47 -0400
Received: by mail-pa0-f53.google.com with SMTP id td3so23691052pab.2
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 07:45:46 -0700 (PDT)
In-Reply-To: <20160324142222.GB7237@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-24 at 15:22 +0100, Willy Tarreau wrote:
> Hi Eric,

> But that means that any software making use of SO_REUSEPORT needs to
> also implement BPF on Linux to achieve the same as what it does on
> other OSes ? Also I found a case where a dying process would still
> cause trouble in the accept queue, maybe it's not redistributed, I
> don't remember, all I remember is that my traffic stopped after a
> segfault of only one of them :-/ I'll have to dig a bit regarding
> this.

Hi Willy

Problem is : If we add a SO_REUSEPORT_LISTEN_OFF, this wont work with
BPF. 

BPF makes a decision without knowing individual listeners states.

Or we would need to extend BPF to access these kind of states.
Doable certainly, but we need to be convinced it is necessary.

And yes, if a listener is closed while children are still in accept
queue, we drop all the children, we do not care of redistributing them
to another listeners. Really too complex to be worth it.

For example, we could probably revert
70da268b569d32a9fddeea85dc18043de9d89f89
("net: SO_INCOMING_CPU setsockopt() support") as this can be handled by
BPF as well, and would remove extra tests in fast path (when
SO_REUSEPORT is not used at all)
