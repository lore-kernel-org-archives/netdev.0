From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Thu, 21 Feb 2008 12:08:29 +0000
Message-ID: <20080221120829.GB12944@ff.dom.local>
References: <20080211.213048.192442721.davem@davemloft.net> <47B17BCD.2070903@katalix.com> <20080214130016.GA2583@ff.dom.local> <47BA0214.40703@katalix.com> <20080219230640.GA2755@ami.dom.local> <47BC4F2C.4000802@katalix.com> <20080220183837.GA2881@ami.dom.local> <47BCABC5.9080204@katalix.com> <20080221085959.GA12944@ff.dom.local> <47BD4A34.7070606@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:36233 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752390AbYBUMHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 07:07:36 -0500
Received: by an-out-0708.google.com with SMTP id d31so740260and.103
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2008 04:07:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47BD4A34.7070606@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2008 at 09:53:56AM +0000, James Chapman wrote:
> Jarek Poplawski wrote:
...
> The _bh locking fixes in pppol2tp combined with your ppp_generic change  
> solved that problem. So I then added data traffic into the mix (since  
> this will happen in a real network) and found that lockups still happen.  
> But the lockdep trace in this case is different, as you noted.

I'm not sure what do you mean by "solved that problem": lack of lockups
or lack of this kind of lockdep reports. This lockdep report shows a
real danger in this case, probably very little probable, unless a lot
of tries. So if you think just this kind of lockup happend there, this
is would be nice. But there could be something less nice too: we are
"fighting" with lockdep in one place but the lockup happens somewhere
else for some totally different reason...

> Does PPPoE stress the PPP setup code as much as this scenario? I guess  
> in theory it could if lots of PPPoE clients connected at the same time,  
> but there is no aggregate tunnel like there is with L2TP to cause all  
> sessions to connect simultaneously. Perhaps PPTP also suffers from these  
> issues? Perhaps not because it tends to be used only in VPN setups where  
> there is only 1 session per tunnel.

I don't know this code enough, but it seems it should be easier to
maintain or debug if there are similar solutions where possible.

>>>> 3) I send here another testing patch with this second way to do this:
>>>>    on the write side, but it's even more "experimental" and only a
>>>>    proof of concept (should be applied on vanilla ppp_generic).
>>> I'll look over it. I think I need to take a step back and look at 
>>> what's  happening in more detail though.
>>
>> This is something completely new and changes all the picture: the xmit
>> path wasn't expected (at least by me) to be called in softirq context
>> at all, and there were no traces of this on previous reports. But,
>> since lockdep always stops after the first warning, there could be
>> even more surprises like this in the future. I'll check this report.
>
> Doesn't the TX softirq do transmits if they've been queued up?

I've probably too much looked at these reports, and should've expected
this could happen. Probably queueing could be separated, but since
there could be no queue at all and it's done like this, then this
current proof of concept seems to be dead end, and we have to go back
to fixing sk_dst_lock handling and my patches could be dumped...

So if I don't miss something again (and I need more time for this new
report) you should try to fix the problem not reported originally by
lockdep, but forseen by David(!): we need to avoid any path like:
ppp_generic -> pppol2tp -> something, which could take sk_dst_lock
while holding any ppp_generic writing lock:  they all are softirq
"safe" (i.e. endangered). David gave some example, but I'm not sure
you did your patch like this (sk_dst_set()). Probably ip_queue_xmit()
can't work with this too.

Another, probably simpler way would be to move almost all pppol2tp_xmit
code to a workqueue: this should let to break most of dependencies with
ppp_generic locks, but I don't know how much it would affect other
things (e.g. performance). So you should really rethink these things.

Jarek P.
