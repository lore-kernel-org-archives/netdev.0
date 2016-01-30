From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 18:15:38 -0800
Message-ID: <1454120138.7627.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160129180651.GA17127@oracle.com>
	 <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1454093642.7627.57.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34+od6o69rHQzotJFXf7kziEuQUj=xH5VUWw+YpH4FjNg@mail.gmail.com>
	 <20160129210900.GD17127@oracle.com>
	 <CALx6S35V47scFFQab7ZsQyh6CktS17w4hSKZSVAnOB0Ppa7brg@mail.gmail.com>
	 <20160129230424.GG17127@oracle.com>
	 <CALx6S34KtC4kkjzchY5Xs4QapD7FMqxShwEDST0Q_bZgDRicmQ@mail.gmail.com>
	 <20160129235800.GH17127@oracle.com>
	 <CALx6S37KgEPorPp4T4gh8xatsPUTOe=wuhG4fzqx8U35a9O3KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Michael Dalton <mwdalton@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:32977 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753027AbcA3CPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 21:15:41 -0500
Received: by mail-pa0-f42.google.com with SMTP id cy9so50330913pac.0
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 18:15:40 -0800 (PST)
In-Reply-To: <CALx6S37KgEPorPp4T4gh8xatsPUTOe=wuhG4fzqx8U35a9O3KA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-29 at 16:47 -0800, Tom Herbert wrote:

> Hmm, thanks for pointing that out. It looks like this is called by a
> couple drivers as part of pulling up the data to get alignment. I am
> actually surprised they are doing this. Flow dissector is not the
> cheapest function in the world and it seems like a shame to be calling
> it this early and not even getting a hash for the skb. Also, this is
> another instance of touching the data so if we do get to the point of
> trying steering packets without cache miss (another thread); this
> undermines that. Seems like it might be just as well to pull up a
> fixed number of bytes (ixgbe want min of 60 bytes), or don't pull up
> anything avoid the cache miss here and let the stack pull up as
> needed.

Except that when for example mlx4 is able to pull only the headers
instead of a fixed amount of bytes, we increased the performance,
because GRO could cook packets twice as big for tunneled traffic.

( commit cfecec56ae7c7c40f23fbdac04acee027ca3bd66 )

1) Increasing performance by prefetching headers is a separate matter,
completely orthogonal to this.

2) Taking the opportunity to also give back the l4 hash as a bonus
has been considered, but tests showed no clear benefit.

  For typical cases where l4 hash is not used (RPS and RFS being not
enabled by default on linux), computing it brings nothing but added
complexity.
