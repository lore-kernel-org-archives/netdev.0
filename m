From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 10:59:43 -0800
Message-ID: <20151124185942.GA73070@ast-mbp.thefacebook.com>
References: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
 <20151123.145433.1554000376541433305.davem@davemloft.net>
 <20151124152744.GB20972@breakpoint.cc>
 <20151124.105537.185897620062606312.davem@davemloft.net>
 <20151124162515.GA22266@breakpoint.cc>
 <1448389410.599529.449007361.7A816A14@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>, tom@herbertland.com,
	netdev@vger.kernel.org, kernel-team@fb.com, davejwatson@fb.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33537 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098AbbKXS7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 13:59:50 -0500
Received: by pabfh17 with SMTP id fh17so31422669pab.0
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 10:59:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1448389410.599529.449007361.7A816A14@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2015 at 07:23:30PM +0100, Hannes Frederic Sowa wrote:
> Hello,
> 
> On Tue, Nov 24, 2015, at 17:25, Florian Westphal wrote:
> > Its a well-written document, but I don't see how moving the burden of
> > locking a single logical tcp connection (to prevent threads from
> > reading a partial record) from userspace to kernel is an improvement.
> > 
> > If you really have 100 threads and must use a single tcp connection
> > to multiplex some arbitrarily complex record-format in atomic fashion,
> > then your requirements suck.
> 
> Right, if we are in a datacenter I would probably write a script and use
> all those IPv6 addresses to set up mappings a la:
> 
> for each $cpu; do
>   $ip address add 2000::$host:$cpu/64 dev if0 pref_cpu $cpu
> done

interesting idea, but then remote host will be influencing local cpu selection?
how remote can figure out the number of local cpus?

Consider scenario where you have a ton of tcp sockets feeding into
bigger or smaller set of kcm sockets processed by threads or fibers.
Pinning sockets to cpu is not going to work.

Also note that opimizing byte copies between kernel and user space is important,
but we lose a lot more in user space due to scheduling and re-scheduling
when demux-ing user space thread is feeding other worker threads.
