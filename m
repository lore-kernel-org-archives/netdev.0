From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Wed, 7 May 2008 20:33:06 -0700
Message-ID: <d1c2719f0805072033u38dfffaes71aed3efbc8035c0@mail.gmail.com>
References: <d1c2719f0805071136i3414755cv6e72e7bd5a0d41ad@mail.gmail.com>
	 <20080507.141835.229114942.davem@davemloft.net>
	 <d1c2719f0805071837v5168cee0qa6a3d160e93adb48@mail.gmail.com>
	 <20080507.184311.196815718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:22467 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752871AbYEHDdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 23:33:20 -0400
Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id m483X71g015541
	for <netdev@vger.kernel.org>; Thu, 8 May 2008 04:33:08 +0100
Received: from wx-out-0506.google.com (wxdi27.prod.google.com [10.70.135.27])
	by zps18.corp.google.com with ESMTP id m483WfIR025598
	for <netdev@vger.kernel.org>; Wed, 7 May 2008 20:33:07 -0700
Received: by wx-out-0506.google.com with SMTP id i27so522434wxd.6
        for <netdev@vger.kernel.org>; Wed, 07 May 2008 20:33:06 -0700 (PDT)
In-Reply-To: <20080507.184311.196815718.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There seems to be quite a bit of complexity plus one additional pointer
field per skb_shared_info to make skb better track when a pkt leaves
the host. Now I wonder if it's really a better solution than my original,
simply checking dataref==1 approach which, although not bullet proof,
may be "good enough" for all practical purposes?

Jerry

On Wed, May 7, 2008 at 6:43 PM, David Miller <davem@davemloft.net> wrote:
> From: "Jerry Chu" <hkchu@google.com>
>  Date: Wed, 7 May 2008 18:37:01 -0700
>
>
>  > Ok, will give it a try. First i'll fix your patch to
>  > atomic_add()/atomic_sub() by
>  > skb_shinfo(skb)->gso_segs rather than always 1, in order for GSO/TSO to work.
>
>  That might not work.  gso_segs can change over time as retransmit
>  packets get split up due to SACKs etc.  it needs to be audited,
>  at the very least.
>
>
>  > One problem came up to my mind - it seems possible for __kfree_skb() to
>  > access skb_shinfo(skb)->in_flight whose tp has been freed up since only the
>  > original skb's on TCP's rexmit list have the owner set and socket
>  > held. One solution
>  > is for TCP to zap skb_shinfo(skb)->in_flight field when it's ready to
>  > free up skb.
>  > I can hack sock_wfree() to do this, but I don't know how to do it right.
>
>  There will be references to the socket, so this should be ok.
>
>  If it isn't we can adjust the count and zap the pointer in
>  skb_orphan().
>
