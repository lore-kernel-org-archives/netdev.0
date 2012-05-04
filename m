From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] RPS: Sparse connection optimizations - v2
Date: Fri, 04 May 2012 22:53:27 +0200
Message-ID: <1336164807.3752.465.camel@edumazet-glaptop>
References: <1336035412-2161-1-git-send-email-dczhu@mips.com>
	 <CA+mtBx_J=fm3+k6_NzMH9KCdrYpZPwT2XBQe4r424eNDCKzazg@mail.gmail.com>
	 <4FA35A3D.8000205@mips.com>
	 <CA+mtBx-CErRU=3ewkAjVrGN3dGzjsTz8Q-E8J+Xa+529OVEvwA@mail.gmail.com>
	 <1336146448.3752.349.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Deng-Cheng Zhu <dczhu@mips.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35737 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759765Ab2EDUxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 16:53:31 -0400
Received: by wibhr7 with SMTP id hr7so1740286wib.1
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 13:53:30 -0700 (PDT)
In-Reply-To: <1336146448.3752.349.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-04 at 17:47 +0200, Eric Dumazet wrote:
> On Fri, 2012-05-04 at 08:31 -0700, Tom Herbert wrote:
> > > I think the mechanisms of rps_dev_flow_table and cpu_flow (in this
> > > patch) are different: The former works along with rps_sock_flow_table
> > > whose CPU info is based on recvmsg by the application. But for the tests
> > > like what I did, there's no application involved.
> > >
> > While rps_sock_flow_table is currently only managed by recvmsg, it
> > still is the general mechanism that maps flows to CPUs for steering.
> > There should be nothing preventing you from populating and managing
> > entries in other ways.
> 
> It might be done from a netfilter module, activated in FORWARD chain for
> example.
> 
> 

A good indicator of the network load of a cpu would be to gather
&per_cpu(softnet_data, cpu)->input_pkt_queue.qlen in an EWMA.


We could dynamically adjust active cpus in RPS set given the load of the
machine.

On low load, cpu handling NIC interrupt could also bypass RPS and avoid
IPI to other cpus for low overhead.

tcpu = map->cpus[((u64) skb->rxhash * map->len) >> 32];

->

	if (map->curlen) {
		tcpu = map->cpus[((u64) skb->rxhash * map->curlen) >> 32];
		if (cpu_online(tcpu)) 
			return tcpu;
	}	
	return -1;

Every second or so (to reduce Out Of Order impact), allow curlen to be
incremented/decremented in [0 .. map->len] if load is
increasing/lowering.
