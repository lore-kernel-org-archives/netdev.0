From: Tom Herbert <therbert@google.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Sat, 17 Apr 2010 01:43:39 -0700
Message-ID: <z2q65634d661004170143nb35ec784mbedd003565410cfb@mail.gmail.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi> <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <1271489739.16881.4586.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, Changli Gao <xiaosuo@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	robert@herjulf.net, andi@firstfloor.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:14104 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729Ab0DQInq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Apr 2010 04:43:46 -0400
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [10.3.21.6])
	by smtp-out.google.com with ESMTP id o3H8hgsH010698
	for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 10:43:43 +0200
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by hpaq6.eem.corp.google.com with ESMTP id o3H8heqG030975
	for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 10:43:41 +0200
Received: by pzk26 with SMTP id 26so2459388pzk.6
        for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 01:43:39 -0700 (PDT)
In-Reply-To: <1271489739.16881.4586.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So the cost of queing the packet into our own queue (netif_receive_sk=
b
> -> enqueue_to_backlog) is about 0.74 us =A0(74 ms / 100000)
>
> I personally think we should process packet instead of queeing it, bu=
t
> Tom disagree with me.
>
You could do that, but then the packet processing becomes HOL blocking
on all the packets that are being sent to other queues for
processing-- remember the IPIs is only sent at the end of the NAPI.
So unless the upper stack processing is <0.74us in your case, I think
processing packets directly on the local queue would improve best case
latency, but would increase average latency and even more likely worse
case latency on loads with multiple flows.

> RPS on, directed on cpu1 (other socket)
> (echo 02 > /sys/class/net/eth3/queues/rx-0/rps_cpus)
> 100000 packets transmitted, 100000 received, 0% packet loss, time 454=
2ms
>
> So extra cost to enqueue to a remote cpu queue, IPI, softirq handling=
=2E..
> is 3 us. Note this cost is in case we receive a single packet.
>
> I suspect IPI itself is in the 1.5 us range, not very far from the
> queing to ourself case.
>
> For me RPS use cases are :
>
> 1) Value added apps handling lot of TCP data, where the costs of cach=
e
> misses in tcp stack easily justify to spend 3 us to gain much more.
>
> 2) Network appliance, where a single cpu is filled 100% to handle one
> device hardware and software/RPS interrupts, delegating all higher le=
vel
> works to a pool of cpus.
>
> I'll try to do these tests on a Nehalem target.
>
>
>
>
