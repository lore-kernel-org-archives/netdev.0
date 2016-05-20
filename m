From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next] net: sched: do not acquire qdisc spinlock in
 qdisc/class stats dump
Date: Fri, 20 May 2016 06:09:22 -0700
Message-ID: <1463749762.18194.288.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpUj9u4bgG+7Tc06z0_wSRhAWCVSz5KsydrhcmpoJf39tg@mail.gmail.com>
	 <1463712330.18194.261.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1463748265.18194.279.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1463749280.18194.281.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Kevin Athey <kda@google.com>,
	Xiaotian Pei <xiaotian@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35705 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769AbcETNJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 09:09:25 -0400
Received: by mail-pa0-f65.google.com with SMTP id rw9so10921125pab.2
        for <netdev@vger.kernel.org>; Fri, 20 May 2016 06:09:24 -0700 (PDT)
In-Reply-To: <1463749280.18194.281.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-05-20 at 06:01 -0700, Eric Dumazet wrote:

> Tricky, since sch_direct_xmit() releases the qdisc spinlock and grabs it
> again, while owning the ' running seqcount'
> 
> Needs more LOCKDEP tricks ;)
> 

That would be :

@@ -137,10 +137,10 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
                HARD_TX_UNLOCK(dev, txq);
        } else {
-               spin_lock(root_lock);
+               spin_lock_nested(root_lock, SINGLE_DEPTH_NESTING);
                return qdisc_qlen(q);
        }
-       spin_lock(root_lock);
+       spin_lock_nested(root_lock, SINGLE_DEPTH_NESTING);
 
        if (dev_xmit_complete(ret)) {
                /* Driver sent out skb successfully or skb was consumed */
