From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2 net-next 4/7] tcp: Make use of MSG_EOR flag in
 tcp_sendmsg
Date: Mon, 18 Apr 2016 17:06:57 -0700
Message-ID: <1461024417.10638.141.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com>
	 <1461019569-3037369-5-git-send-email-kafai@fb.com>
	 <1461021493.10638.131.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160418234202.GA27948@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:36099 "EHLO
	mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168AbcDSAHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 20:07:03 -0400
Received: by mail-vk0-f41.google.com with SMTP id n67so466227vkf.3
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 17:07:03 -0700 (PDT)
In-Reply-To: <20160418234202.GA27948@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-18 at 16:43 -0700, kafai@fb.com wrote:

> >
> > netperf could then get an option to set this MSG_EOR ;)
> Not sure how it is related.  Can you share how netperf can
> benefit from MSG_EOR in TCP tests without any of the
> SOF_TIMESTAMPING_TX_RECORD_MASK.

Simply setting MSG_EOR would be orthogonal to other timestamping stuff.

Maybe the application does not _want_ to be notified when skb is sent or
acknowledged, but would like some kind of "tcpdump awareness" or
something about burst control, who knows...

It should only be a request from user space to ask TCP to not aggregate
stuff on future sendpage()/sendmsg() on the skb carrying this new flag.

We already have other flags to ask for timestamping stuff, and they
could be used at the same time.

If the stack needs to be changed to properly fragment skb (or
aggregating them at retransmit), this is a separate concern.

Note that you do not need to automatically assert MSG_BOR (Begin of
Request) : MSG_EOR should really control the fact that last byte sent
marks the skb as being a non candidate for aggregation.

This would keep tcp_sendmsg() reasonnably fast.
Your tcp_sendmsg_noappend() is quite expensive :(
