From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tc filter flow hash question
Date: Tue, 30 Jun 2009 11:09:08 +0000
Message-ID: <20090630110908.GC8592@ff.dom.local>
References: <20090630085706.GD5589@ff.dom.local> <4A49D872.5050403@bigtelecom.ru> <20090630092344.GA8592@ff.dom.local> <4A49DF97.6090608@bigtelecom.ru> <20090630095628.GB8592@ff.dom.local> <4A49E94E.40209@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:57689 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752908AbZF3LJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 07:09:11 -0400
Received: by bwz9 with SMTP id 9so48080bwz.37
        for <netdev@vger.kernel.org>; Tue, 30 Jun 2009 04:09:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A49E94E.40209@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 30, 2009 at 02:30:38PM +0400, Badalian Vyacheslav wrote:
> Jarek Poplawski ??????????:
> > On Tue, Jun 30, 2009 at 01:49:11PM +0400, Badalian Vyacheslav wrote:
> > ...
> >   
> >> This example not approach? 
> >>
> >> tc qdisc add dev eth0 root handle 1 htb default 7
> >> tc class add dev eth0 parent 1: classid 1:7 htb rate 500mbit ceil 1000mbit prio 3
> >> tc qdisc add dev eth0 parent 1:7 handle 10: sfq perturb 10
> >>
> >> # all traffic go to class 1-7.
> >>
> >> # Try group traffic by "src,dst" key
> >>
> >> tc filter add dev eth0 protocol ip parent 10: handle 2 flow hash keys src,dst
> >>
> >> # all traffic dropped
> >>     
> >
> > Try:
> > tc filter add dev eth0 protocol ip parent 10: handle 2 flow hash keys src,dst divisor 1024
> >
> >   
> Outh! Very thanks! I'm so stupid. its simple :(
> 
> Also i look in code and see in flow_classify function this lines:
> 
> if (f->divisor)
>         classid %= f->divisor;
> 
> classid generated in up.
> Also i see to SFQ code and see that SFQ create 1024 hashes.
> If we do not add divisor when added filter rule we get classid > 1024
> and its not go to hash of SFQ (my example).
> Also divisor must be > 0 because = NaN as i understand.
> I not sure that it must be <= 1024 because it may use not in SFQ and i
> don't know MAX size of other qdiscs but if it use only in in SFQ i think
> we need to check <= SFQ_HASH_DIVISOR also?
> 
> Maybe "if" code must be changed to
> 
> if (f->divisor && f->divisor > 0)
>         classid %= f->divisor;
> else
>         classid %= 1024;
> 
> 
> How you think?

I guess the author preferred to signal that something is misconfigured
with drops, but you could try to send a patch or ask him to make sure.

Btw., sfq isn't very useful with real 1024 or even much less flows, so
you should probably start looking for sch_drr with cls_flow examples
(there were a few of them on the list).

Best regards,
Jarek P.
