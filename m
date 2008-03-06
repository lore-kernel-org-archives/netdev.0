From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Fri, 7 Mar 2008 01:43:33 +0200
Message-ID: <20080306233151.M43262@visp.net.lb>
References: <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb> <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local> <20080306135625.M25627@visp.net.lb> <1204813634.4440.59.camel@localhost> <20080306143910.M91001@visp.net.lb> <20080306202551.GB2876@ami.dom.local> <1204837000.4457.108.camel@localhost> <20080306221253.GD2876@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>, Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:58978 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756229AbYCFXny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 18:43:54 -0500
In-Reply-To: <20080306221253.GD2876@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

About reproducing, I think .config matter
Mine is at http://www.nuclearcat.com/files/config.txt

About hardware, maybe it is important - it is Intel dual core machine (32-
bit). I test few more times, i can reproduce it for sure. It gives lockdep on 
first incoming packet.

More info about hardware:
CPU model name      : Intel(R) Core(TM)2 CPU          6600  @ 2.40GHz
Other machines where i get this lockdep also Core Duo CPU's. 
I test now on old 2xXeon,P4 with hyperthreading - also triggered.




Shortest script i use:
modprobe ifb
ifconfig ifb0 up
/sbin/tc qdisc del dev eth0 ingress 1>/dev/null 2>/dev/null
/sbin/tc qdisc add dev eth0 ingress
/sbin/tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
         match u32 0 0 flowid 1:1 \
         action mirred egress redirect dev ifb0




On Thu, 6 Mar 2008 23:12:53 +0100, Jarek Poplawski wrote
> On Thu, Mar 06, 2008 at 03:56:40PM -0500, jamal wrote:
> > On Thu, 2008-06-03 at 21:25 +0100, Jarek Poplawski wrote:
> > 
> > > It's really strange: I can't reproduce this, 
> > 
> > I couldnt either - are you using 2.6.25-rc4?
> 
> No, David's net-2.6 tree so 2.6.25-rc3 plus something...
> 
> > 
> > > and if it were so easy we
> > > would get really a lot of similar reports. It looks like you have
> > > something special. This lockdep report with this kind of problem
> > > usually looks different too. The good side is it's easy to reproduce.
> > > So, could you try the patch below? (It's only supposed to fix the 
lockdep
> > > warning, not lockups).
> > 
> > This is more out of ignorance: Why is ifb needing the extra teaching for
> > lockdep? It is a netdevice - shouldnt the two global lockdeps you
> > described earlier not be sufficient?
> 
> As I've written in the previous message, currently lockdep tracks
> dev->queue_lock and dev->ingress_lock as only two locks used by all
> net devices (unless they were annotated individually). So, it's like
> A and B lock, and it's really not right to them AB in one place, and
> BA in another. In reality each net_device's locks are independent,
> so ifb has C and D. And it's not AB vs. BA, but: AB (eth/lo-
> >queue_lock, eth/lo->ingress_lock), CD (the same for ifb) and BC 
> (eth/lo->ingress_lock, ifb->queue_lock) - all legal combinations,
>  and no inversion.
> 
> Cheers,
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

