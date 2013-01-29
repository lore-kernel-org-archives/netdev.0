From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: inaccurate packet scheduling
Date: Tue, 29 Jan 2013 13:23:57 +0100
Message-ID: <20130129122357.GC7571@minipsycho.orion>
References: <e2f71dc7-bee5-41ca-bd64-f4569fa953da@tahiti.vyatta.com>
 <1355849503.9380.37.camel@edumazet-glaptop>
 <20130102152601.GB1532@minipsycho.orion>
 <1357144482.21409.16876.camel@edumazet-glaptop>
 <20130108133038.GB1621@minipsycho.orion>
 <20130124080536.GA1598@minipsycho.orion>
 <1359036087.12374.2088.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edumazet@google.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jhs@mojatatu.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:53631 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165Ab3A2M3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 07:29:13 -0500
Received: by mail-we0-f171.google.com with SMTP id u54so263091wey.30
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 04:29:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1359036087.12374.2088.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 24, 2013 at 03:01:27PM CET, eric.dumazet@gmail.com wrote:
>On Thu, 2013-01-24 at 09:05 +0100, Jiri Pirko wrote:
>> Tue, Jan 08, 2013 at 02:30:38PM CET, jiri@resnulli.us wrote:
>> >Wed, Jan 02, 2013 at 05:34:42PM CET, eric.dumazet@gmail.com wrote:
>> >>On Wed, 2013-01-02 at 16:26 +0100, Jiri Pirko wrote:
>> >>> Tue, Dec 18, 2012 at 05:51:43PM CET, erdnetdev@gmail.com wrote:
>> >>> >On Tue, 2012-12-18 at 08:26 -0800, Stephen Hemminger wrote:
>> >>> >
>> >>> >> Check kernel log for messages about clock. It could be that on the
>> >>> >> machines with issues TSC is not usable for kernel clock.
>> >>> >> Also turn off TSO since it screws up any form of rate control.
>> >>> >
>> >>> >Yes, but we should fix it eventually. I'll take a look.
>> >>> 
>> >>> Hi Eric, did you have a chance to look at this? Or should I give it a try?
>> >>
>> >>I took a look, and TBF does :
>> >>
>> >>if (qdisc_pkt_len(skb) > q->max_size)
>> >>    return qdisc_reshape_fail(skb, sch);
>> >>
>> >>We have several choices :
>> >>
>> >>1) Add a one time warning
>> >>
>> >>2) cap dev->gso_max_size at Qdisc setup time
>> >>
>> >>3) Re-segment the packet instead of dropping it (if GSO packet), and
>> >>call the expensive qdisc_tree_decrease_qlen() function.
>> >>
>> >>4) remove max_size limitation 
>> >>
>> >
>> >To my untrained eye, 2) or 4) look like a way to go. Not sure though.
>> 
>> What do you think would be the best way Eric? Thanks.
>
>Capping gso_max_size is a bit difficult after commit
>1def9238d4aa2146924 (net_sched: more precise pkt_len computation)
>
>If MSS is really small, we can easily get a lot of overhead
>
>qdisc_skb_cb(skb)->pkt_len > 2 * skb->len
>
>It looks like we need 4), maybe using same mechanism
>than the one used in commit 56b765b79e9a78d
>(htb: improved accuracy at high rates)

part of the commit message says:
<quote>
The bits per second on the wire is still 5200Mb/s with new HTB
because qdisc accounts for packet length using skb->len, which
is smaller than total bytes on the wire if GSO is used.  But
that is for another patch regardless of how time is accounted.	
</quote>
I believe that is a similar problem like ours. But looks like this
"another patch" never got in.


>
>
>
>
