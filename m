From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Wed, 7 May 2008 18:37:01 -0700
Message-ID: <d1c2719f0805071837v5168cee0qa6a3d160e93adb48@mail.gmail.com>
References: <d1c2719f0805062057q62decefcg7c3de96271c4b26d@mail.gmail.com>
	 <20080506.212722.225900091.davem@davemloft.net>
	 <d1c2719f0805071136i3414755cv6e72e7bd5a0d41ad@mail.gmail.com>
	 <20080507.141835.229114942.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:13287 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbYEHBhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 21:37:09 -0400
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id m481b2Sc029755
	for <netdev@vger.kernel.org>; Thu, 8 May 2008 02:37:03 +0100
Received: from wx-out-0506.google.com (wxdh27.prod.google.com [10.70.134.27])
	by zps77.corp.google.com with ESMTP id m481aeIj022785
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 18:37:01 -0700
Received: by wx-out-0506.google.com with SMTP id h27so447731wxd.7
        for <netdev@vger.kernel.org>; Wed, 07 May 2008 18:37:01 -0700 (PDT)
In-Reply-To: <20080507.141835.229114942.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 7, 2008 at 2:18 PM, David Miller <davem@davemloft.net> wrote:
> From: "Jerry Chu" <hkchu@google.com>
>  Date: Wed, 7 May 2008 11:36:59 -0700
>
>
>  > No I haven't tested your patch. I tried to understand skb better before
>  > applying your patch. After I studied bunch of code, I come to the conclusion
>  > that your patch won't work for me. First it tracks # of clones, which is not
>  > what I need. E.g., tcpdump will cause host_inflight to be grossly wrong.
>
>  We can make sub-clones not count.
>
>  Also, we already can distinguish this case, because all SKB clones
>  made by TCP are fast-clones.  So we could only bump the counter for
>  fast clones.  If tcpdump clones it again, it won't be a fast clone and
>  therefore we can avoid bumping the counter in that case.  Similarly
>  for other features that want to clone.

Ok, just Google search "skb fast clone" and found some posting from you.
Will take a look.

>
>  Please try to get your idea working with my infrastructure.  We
>  can modify it to behave however you need it to, but at the core
>  it's the idea that tracks the state most directly and properly.
>

Ok, will give it a try. First i'll fix your patch to
atomic_add()/atomic_sub() by
skb_shinfo(skb)->gso_segs rather than always 1, in order for GSO/TSO to work.

One problem came up to my mind - it seems possible for __kfree_skb() to
access skb_shinfo(skb)->in_flight whose tp has been freed up since only the
original skb's on TCP's rexmit list have the owner set and socket
held. One solution
is for TCP to zap skb_shinfo(skb)->in_flight field when it's ready to
free up skb.
I can hack sock_wfree() to do this, but I don't know how to do it right.

Jerry
