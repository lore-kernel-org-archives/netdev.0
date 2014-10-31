From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v2 1/2] syncookies: remove ecn_ok validation when
 decoding option timestamp
Date: Fri, 31 Oct 2014 06:32:13 -0700
Message-ID: <1414762333.499.16.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414757602-27637-1-git-send-email-fw@strlen.de>
	 <1414757602-27637-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34045 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757992AbaJaNcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 09:32:16 -0400
Received: by mail-ig0-f182.google.com with SMTP id hn18so923287igb.3
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2014 06:32:15 -0700 (PDT)
In-Reply-To: <1414757602-27637-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-31 at 13:13 +0100, Florian Westphal wrote:
> Won't work anymore when tcp_ecn=0 and RTAX_FEATURES route attribute did
> allow ecn.
> 
> Just turn on ecn if the client ts says so.
> 
> This means that while syn cookies are in use clients can turn on ecn
> even if it is off on the server.
> 
> However, there seems to be no harm in permitting this.
> 
> Alternatively one can extend the test to also perform route lookup and
> check RTAX_FEATURES, but it simply doesn't appear to be worth the effort.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Changes since v1:
>   - reword commit message

Sorry.

Google chose to disable ecn on their GFE, so we set sysctl_tcp_ecn to 0

If I understand your patch, if a synflood is going on, some innocent
connections could get ECN enabled, while we do not want this to ever
happen. ECN really hurts our customers, this is a known fact.

You cannot change this like that, it would force us (and maybe others)
to either revert this patch, or add a knob.

If sysctl_tcp_ecn = 0, there is no way a connection should have ECN
enabled. This was documented years ago.

For the record :

vi +247 Documentation/networking/ip-sysctl.txt

tcp_ecn - INTEGER
        Control use of Explicit Congestion Notification (ECN) by TCP.
        ECN is used only when both ends of the TCP connection indicate
        support for it.  This feature is useful in avoiding losses due
        to congestion by allowing supporting routers to signal
        congestion before having to drop packets.
        Possible values are:
                0 Disable ECN.  Neither initiate nor accept ECN.
                1 Enable ECN when requested by incoming connections and
                  also request ECN on outgoing connection attempts.
                2 Enable ECN when requested by incoming connections
                  but do not request ECN on outgoing connections.
        Default: 2
