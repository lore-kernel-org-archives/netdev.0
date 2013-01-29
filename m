From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: inaccurate packet scheduling
Date: Tue, 29 Jan 2013 08:13:03 -0800
Message-ID: <1359475983.30177.2.camel@edumazet-glaptop>
References: <e2f71dc7-bee5-41ca-bd64-f4569fa953da@tahiti.vyatta.com>
	 <1355849503.9380.37.camel@edumazet-glaptop>
	 <20130102152601.GB1532@minipsycho.orion>
	 <1357144482.21409.16876.camel@edumazet-glaptop>
	 <20130108133038.GB1621@minipsycho.orion>
	 <20130124080536.GA1598@minipsycho.orion>
	 <1359036087.12374.2088.camel@edumazet-glaptop>
	 <20130129122357.GC7571@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jhs@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:58035 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab3A2QNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 11:13:07 -0500
Received: by mail-da0-f42.google.com with SMTP id z17so292051dal.29
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 08:13:06 -0800 (PST)
In-Reply-To: <20130129122357.GC7571@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-29 at 13:23 +0100, Jiri Pirko wrote:

> part of the commit message says:
> <quote>
> The bits per second on the wire is still 5200Mb/s with new HTB
> because qdisc accounts for packet length using skb->len, which
> is smaller than total bytes on the wire if GSO is used.  But
> that is for another patch regardless of how time is accounted.	
> </quote>
> I believe that is a similar problem like ours. But looks like this
> "another patch" never got in.
> 

Hmm, I thought I addressed this in 

commit 1def9238d4aa2146924994aa4b7dc861f03b9362
Author: Eric Dumazet <edumazet@google.com>
Date:   Thu Jan 10 12:36:42 2013 +0000

    net_sched: more precise pkt_len computation
    
    One long standing problem with TSO/GSO/GRO packets is that skb->len
    doesn't represent a precise amount of bytes on wire.
    
    Headers are only accounted for the first segment.
    For TCP, thats typically 66 bytes per 1448 bytes segment missing,
    an error of 4.5 % for normal MSS value.
    
    As consequences :
    
    1) TBF/CBQ/HTB/NETEM/... can send more bytes than the assigned limits.
    2) Device stats are slightly under estimated as well.
    
    Fix this by taking account of headers in qdisc_skb_cb(skb)->pkt_len
    computation.
    
    Packet schedulers should use qdisc pkt_len instead of skb->len for their
    bandwidth limitations, and TSO enabled devices drivers could use pkt_len
    if their statistics are not hardware assisted, and if they don't scratch
    skb->cb[] first word.
    
    Both egress and ingress paths work, thanks to commit fda55eca5a
    (net: introduce skb_transport_header_was_set()) : If GRO built
    a GSO packet, it also set the transport header for us.
