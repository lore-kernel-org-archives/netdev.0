From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: Add low-latency/polling support for
 UDP multicast
Date: Thu, 08 Aug 2013 16:55:14 -0700
Message-ID: <1376006114.4004.141.camel@edumazet-glaptop>
References: <5200A203.2090306@linux.intel.com>
	  <1375818663-12318-1-git-send-email-sbohrer@rgmadvisors.com>
	 <1375906946.4004.45.camel@edumazet-glaptop>
	 <52035AD9.30703@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	tomk@rgmadvisors.com
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:59648 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966520Ab3HHXzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 19:55:23 -0400
Received: by mail-pa0-f45.google.com with SMTP id bg4so4252698pad.4
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 16:55:22 -0700 (PDT)
In-Reply-To: <52035AD9.30703@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-08 at 11:46 +0300, Eliezer Tamir wrote:
> On 07/08/2013 23:22, Eric Dumazet wrote:
> > On Tue, 2013-08-06 at 14:51 -0500, Shawn Bohrer wrote:
> >> Set the napi id for each socket in the multicast path to enable
> >> low-latency/polling support.
> >>
> >> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> >> ---
> >> v2 include ipv6 support
> > 
> > This might help your workload, but I doubt it is generic enough.
> > 
> > One UDP socket is supposed to receive traffic from many endpoints,
> > so we have no guarantee all the received traffic will end on a single RX
> > queue on the NIC.
> > 
> > That's the same logic than RFS here.
> > 
> > sk_mark_napi_id() in UDP are wrong IMHO.
> > 
> > It should be guarded by the following test in  
> > __udp_queue_rcv_skb()
> > 
> > if (inet_sk(sk)->inet_daddr) {
> >     sock_rps_save_rxhash(sk, skb);
> >     sk_mark_napi_id(sk, skb);
> > }
> > 
> > (To occur only for connected UDP sockets, where we are 100% sure all
> > packets will use this same rxhash/rx queue)
> 
> This would also be safe if there is only one NIC and said NIC was
> programmed to always place this socket's data on the same queue.
> 
> I don't have a good suggestion on how to detect this.

Well, this stuff relies on flows being correctly steered.

TCP stack performs much better if we avoid reorders ;)
