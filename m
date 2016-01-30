From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 16:47:46 -0800
Message-ID: <CALx6S37KgEPorPp4T4gh8xatsPUTOe=wuhG4fzqx8U35a9O3KA@mail.gmail.com>
References: <20160129180651.GA17127@oracle.com>
	<1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	<1454093642.7627.57.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34+od6o69rHQzotJFXf7kziEuQUj=xH5VUWw+YpH4FjNg@mail.gmail.com>
	<20160129210900.GD17127@oracle.com>
	<CALx6S35V47scFFQab7ZsQyh6CktS17w4hSKZSVAnOB0Ppa7brg@mail.gmail.com>
	<20160129230424.GG17127@oracle.com>
	<CALx6S34KtC4kkjzchY5Xs4QapD7FMqxShwEDST0Q_bZgDRicmQ@mail.gmail.com>
	<20160129235800.GH17127@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Michael Dalton <mwdalton@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36286 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754786AbcA3Arr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 19:47:47 -0500
Received: by mail-io0-f179.google.com with SMTP id g73so107570752ioe.3
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 16:47:46 -0800 (PST)
In-Reply-To: <20160129235800.GH17127@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2016 at 3:58 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (01/29/16 15:31), Tom Herbert wrote:
>> But even within flow dissector, to be completely correct, we need to
>> replace all 32-bit accesses with the mempy (flow_label, mpls label,
>> keyid) and be vigilant about new ones coming in. For that matter, ..
>
> well, one question that came to my mind when I was looking at this is:
> why does eth_get_headlen try to compute the flow hash even before the
> driver has had a chance to pull things into an aligned buffer? Isn't
> that just risking even more unaligned accesses?
>
Hmm, thanks for pointing that out. It looks like this is called by a
couple drivers as part of pulling up the data to get alignment. I am
actually surprised they are doing this. Flow dissector is not the
cheapest function in the world and it seems like a shame to be calling
it this early and not even getting a hash for the skb. Also, this is
another instance of touching the data so if we do get to the point of
trying steering packets without cache miss (another thread); this
undermines that. Seems like it might be just as well to pull up a
fixed number of bytes (ixgbe want min of 60 bytes), or don't pull up
anything avoid the cache miss here and let the stack pull up as
needed.

Anyway, I think you do have a point that flow_dissector does not
assume alignment or pull up data like the rest of the stack. Seems
like we need a utility function like align_access (maybe there is one
already) to get 32-bit fields and probably do need the sanity check
for odd alignment.

Tom
