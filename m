From: Andi Kleen <ak@suse.de>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Fri, 22 Sep 2006 17:43:40 +0200
Message-ID: <200609221743.40053.ak@suse.de>
References: <200609181850.22851.ak@suse.de> <20060919.124751.24100694.davem@davemloft.net> <20060922153517.GB24866@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, master@sectorb.msk.ru,
	hawk@diku.dk, harry@atmos.washington.edu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:25236 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S932456AbWIVPoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 11:44:12 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060922153517.GB24866@ms2.inr.ac.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 22 September 2006 17:35, Alexey Kuznetsov wrote:
> Hello!
> 
> > I can't even find a reference to SIOCGSTAMP in the
> > dhcp-2.0pl5 or dhcp3-3.0.3 sources shipped in Ubuntu.
> > 
> > But I will note that tpacket_rcv() expects to always get
> > valid timestamps in the SKB, it does a:
> 
> It is equally unlikely it uses mmapped packet socket (tpacket_rcv).
> 
> I even installed that dhcp on x86_64. And I do not see anything,
> netstamp_needed remains zero when running both server and client.
> It looks like dhcp was defamed without a guilt. :-)
>
> Seems, Andi saw some leakage in netstamp_needed (value of 7),
> but I do not see this too.

That came from named. It opens lots of sockets with SIOCGSTAMP.
No idea what it needs that many for.
 
I suspect  it was either dhcpd (server) or that ppp user space daemon
the original reporter was running.

Maybe it would be a good idea to add a printk by default?

> In any case, the issue is obviously more serious than just behaviour
> of some applications. On my notebook one gettimeofday() takes:
> 
> 	0.2 us with tsc
> 	4.6 us with pm  (AND THIS CRAP IS DEFAULT!!)

This is actually quite fast. I've seen much worse ratios.

Also on some i386 kernels the pmtimer reads the register three 
times to work around some buggy implementation that doesn't latch the counter
properly.

> 	9.4 us with pit (kinda expected)
> 
> It is ridiculous. Obviosuly, nobody (not only tcpdump, but everything
> else) does not need such clock. Taking timestamp takes time comparable
> with processing the whole tcp frame. :-) I have no idea what is possible
> to do without breaking everything, but it is not something to ignore.
> This timer must be shot. :-)

If it's a reasonably new notebook it might be actually possible to change.
The default choices are quite conservative there because in the past
there were lots of problems with notebooks changing frequency behind
the kernel's back etc. and screwing up TSC. But that shouldn't happen anymore.

If you had a 64bit laptop the kernel would likely do the right choice :)

Notebooks are easy because they are only single socket, so the only thing
needed is to keep track of the frequency (or not if you have a Core+) 

-Andi

