From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Fwd: [Bug 447812] New: Netlink messages from "tc" to sch_netem module are not interpreted correctly
Date: Thu, 22 May 2008 13:18:35 +0200
Message-ID: <20080522111835.GQ20815@postel.suug.ch>
References: <20080521214523.GB22591@codemonkey.org.uk> <20080521151021.3d47a3d8@extreme> <20080522002155.GP20815@postel.suug.ch> <4834C4FE.4060502@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Dave Jones <davej@codemonkey.org.uk>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:36545 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751357AbYEVLSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 07:18:15 -0400
Content-Disposition: inline
In-Reply-To: <4834C4FE.4060502@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Rick Jones <rick.jones2@hp.com> 2008-05-21 17:57
> 
> >Could you try this patch?
> 
> I'm not sure what it does to the tc case, unless I botched applying the 
> patch, my rtnetlink case doesn't seem to change:
> 
> izzy:~/netperf2_trunk# ./testfoo 16.89.133.212
> destination address is 16.89.133.212
> egress interface 0x6000000000004010 eth6
> izzy:~/netperf2_trunk# ./testfoo 16.89.133.212 10.208.0.17
> netlink: 8 bytes leftover after parsing attributes.
> destination address is 16.89.133.212
> egress interface 0x6000000000004010 eth6
> izzy:~/netperf2_trunk# uname -a
> Linux izzy 2.6.26-rc1-netlink #1 SMP Wed May 21 17:36:53 PDT 2008 ia64 
> GNU/Linux

I looked at netrt_rtnetlink.c, the problem is unrelated. Look at
the code when adding the source attribtue:

  struct rtattr *rtap;

  if (source) {
    rtap +=  rtap->rta_len;

You want to increment rtap by rta_len bytes, not rta_len*sizeof(*rtap)
bytes.

Also, the code uses RTA_LENGTH() to calculate attributes sizes which
is wrong, it must use RTA_SPACE() as RTA_LENGTH() does not align the
actual data part and thus the next attribute is unaligned if the data
of the previous attribute is not aligned to 4 bytes.
