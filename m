From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 12:23:41 -0800
Message-ID: <20151124202340.GA78406@ast-mbp.thefacebook.com>
References: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
 <20151123.145433.1554000376541433305.davem@davemloft.net>
 <20151124152744.GB20972@breakpoint.cc>
 <20151124.105537.185897620062606312.davem@davemloft.net>
 <20151124162515.GA22266@breakpoint.cc>
 <1448389410.599529.449007361.7A816A14@webmail.messagingengine.com>
 <20151124185942.GA73070@ast-mbp.thefacebook.com>
 <1448392585.611746.449059097.46CE87C0@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>, tom@herbertland.com,
	netdev@vger.kernel.org, kernel-team@fb.com, davejwatson@fb.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35082 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520AbbKXUXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 15:23:46 -0500
Received: by pacej9 with SMTP id ej9so32387235pac.2
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 12:23:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1448392585.611746.449059097.46CE87C0@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2015 at 08:16:25PM +0100, Hannes Frederic Sowa wrote:
> Hello,
> 
> On Tue, Nov 24, 2015, at 19:59, Alexei Starovoitov wrote:
> > On Tue, Nov 24, 2015 at 07:23:30PM +0100, Hannes Frederic Sowa wrote:
> > > Hello,
> > > 
> > > On Tue, Nov 24, 2015, at 17:25, Florian Westphal wrote:
> > > > Its a well-written document, but I don't see how moving the burden of
> > > > locking a single logical tcp connection (to prevent threads from
> > > > reading a partial record) from userspace to kernel is an improvement.
> > > > 
> > > > If you really have 100 threads and must use a single tcp connection
> > > > to multiplex some arbitrarily complex record-format in atomic fashion,
> > > > then your requirements suck.
> > > 
> > > Right, if we are in a datacenter I would probably write a script and use
> > > all those IPv6 addresses to set up mappings a la:
> > > 
> > > for each $cpu; do
> > >   $ip address add 2000::$host:$cpu/64 dev if0 pref_cpu $cpu
> > > done
> > 
> > interesting idea, but then remote host will be influencing local cpu
> > selection?
> > how remote can figure out the number of local cpus?
> 
> Via rpc! :)
> 
> The configuration shouldn't change all the time and some get_info rpc
> call could provide info for the topology of the machine, or...

Configuration changes all the time. Machines crash, traffic redirected
because of load, etc, etc

> > Consider scenario where you have a ton of tcp sockets feeding into
> > bigger or smaller set of kcm sockets processed by threads or fibers.
> > Pinning sockets to cpu is not going to work.
> > 
> > Also note that opimizing byte copies between kernel and user space is
> > important,
> > but we lose a lot more in user space due to scheduling and re-scheduling
> > when demux-ing user space thread is feeding other worker threads.
> 
> ...also ipvs/netfilter could be used to only inspect the header and
> reroute the packet to some better fitting CPU. Complete hierarchies
> could be build with NUMA and addresses, packets could be rerouted into
> namespaces, etc.

or tc+bpf redirect...
but the reason it won't work is the same as af_packet+bpf fanout doesn't apply:
It's not packet based demuxing.
Kernel needs to deal with TCP stream first and different messages within single
TCP stream go to different workers.
