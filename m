From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 15:31:54 -0800
Message-ID: <CALx6S34KtC4kkjzchY5Xs4QapD7FMqxShwEDST0Q_bZgDRicmQ@mail.gmail.com>
References: <20160129180651.GA17127@oracle.com>
	<1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	<1454093642.7627.57.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34+od6o69rHQzotJFXf7kziEuQUj=xH5VUWw+YpH4FjNg@mail.gmail.com>
	<20160129210900.GD17127@oracle.com>
	<CALx6S35V47scFFQab7ZsQyh6CktS17w4hSKZSVAnOB0Ppa7brg@mail.gmail.com>
	<20160129230424.GG17127@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Michael Dalton <mwdalton@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38230 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753351AbcA2Xbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 18:31:55 -0500
Received: by mail-ig0-f178.google.com with SMTP id mw1so217008igb.1
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 15:31:54 -0800 (PST)
In-Reply-To: <20160129230424.GG17127@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2016 at 3:04 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (01/29/16 15:00), Tom Herbert wrote:
>
>> The sparc documentation is pretty clear
>> http://docs.oracle.com/cd/E19253-01/816-4854/hwovr-2/index.html, seems
>> like unaligned accesses are not allowed in the architecture.
>
> yes, but looks like you  can paper over some of this with
> memcpy (as was happening with the saddr ref in skb_flow_dissect
> that puzzled me and Eric because it did not generate any traps).
>
Well, I am more worried about what happens when an unaligned
encapsulated TPC/IP packet gets into the stack. It seems unlikely we'd
want to replace a bunch of address, seq numbers, etc. with memcpy all
over the stack. ;-)

But even within flow dissector, to be completely correct, we need to
replace all 32-bit accesses with the mempy (flow_label, mpls label,
keyid) and be vigilant about new ones coming in. For that matter, if
we really want to be pedantic, nothing prevents a driver from giving
us a packet with 1 byte alignment in which case we need to consider
access to 16-bit values also! Considering that this is a very narrow
use case (requires encapsulated Ethernet and architecture that is
alignment sensitive), I wonder if we should just punt on flow
dissection when we see non 4-byte alignment and
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is not set.

Tom
