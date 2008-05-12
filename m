From: "Jerry Chu" <hkchu@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Mon, 12 May 2008 15:22:55 -0700
Message-ID: <d1c2719f0805121522g4767f585h4b33790318f44264@mail.gmail.com>
References: <d1c2719f0805071136i3414755cv6e72e7bd5a0d41ad@mail.gmail.com>
	 <20080507.141835.229114942.davem@davemloft.net>
	 <d1c2719f0805071837v5168cee0qa6a3d160e93adb48@mail.gmail.com>
	 <20080507.184311.196815718.davem@davemloft.net>
	 <d1c2719f0805072033u38dfffaes71aed3efbc8035c0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:22978 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbYELWXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 18:23:06 -0400
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m4CMMuZO013205
	for <netdev@vger.kernel.org>; Mon, 12 May 2008 23:22:57 +0100
Received: from hs-out-0708.google.com (hsl4.prod.google.com [10.44.12.4])
	by zps78.corp.google.com with ESMTP id m4CMM9ni023452
	for <netdev@vger.kernel.org>; Mon, 12 May 2008 15:22:55 -0700
Received: by hs-out-0708.google.com with SMTP id 4so1997146hsl.5
        for <netdev@vger.kernel.org>; Mon, 12 May 2008 15:22:55 -0700 (PDT)
In-Reply-To: <d1c2719f0805072033u38dfffaes71aed3efbc8035c0@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did a quick prototype based on your idea of adding an "in_flight"
field to skb_shared_info to track how many in-flight clones in the
host. I tested
it quickly and it doesn't work. After some thought it was obvious why it
won't work. It's because what the TCP stack needs is to track how
many in-flight pkts are in the host, but your proposed patch increments
"in_flight" once on the 1st __skb_clone() to be sent to the driver, but
decrements "in_flight" TWICE, one for each of the clones to be freed.
I did a quick hack to make it work for my limited test case but I haven't
figured out an acceptable (non-hack) solution.

Continued testing, I discovered the problem I described below where
"in_flight" may point to a tp that has already been freed can not be
addressed by zapping skb_shinfo(skb)->in_flight in sock_wfree(). The
reason is that pkts may be acked and freed by TCP before driver freeing
up its clone copy (e.g., due to driver lazy reclaim...) When that happens
the "host_inflight" accounting will get messed up.

Jerry

On Wed, May 7, 2008 at 8:33 PM, Jerry Chu <hkchu@google.com> wrote:
> There seems to be quite a bit of complexity plus one additional pointer
>  field per skb_shared_info to make skb better track when a pkt leaves
>  the host. Now I wonder if it's really a better solution than my original,
>  simply checking dataref==1 approach which, although not bullet proof,
>  may be "good enough" for all practical purposes?
>
>  Jerry
>
>
>
>  On Wed, May 7, 2008 at 6:43 PM, David Miller <davem@davemloft.net> wrote:
>  > From: "Jerry Chu" <hkchu@google.com>
>  >  Date: Wed, 7 May 2008 18:37:01 -0700
>  >
>  >
>  >  > Ok, will give it a try. First i'll fix your patch to
>  >  > atomic_add()/atomic_sub() by
>  >  > skb_shinfo(skb)->gso_segs rather than always 1, in order for GSO/TSO to work.
>  >
>  >  That might not work.  gso_segs can change over time as retransmit
>  >  packets get split up due to SACKs etc.  it needs to be audited,
>  >  at the very least.
>  >
>  >
>  >  > One problem came up to my mind - it seems possible for __kfree_skb() to
>  >  > access skb_shinfo(skb)->in_flight whose tp has been freed up since only the
>  >  > original skb's on TCP's rexmit list have the owner set and socket
>  >  > held. One solution
>  >  > is for TCP to zap skb_shinfo(skb)->in_flight field when it's ready to
>  >  > free up skb.
>  >  > I can hack sock_wfree() to do this, but I don't know how to do it right.
>  >
>  >  There will be references to the socket, so this should be ok.
>  >
>  >  If it isn't we can adjust the count and zap the pointer in
>  >  skb_orphan().
>  >
>
