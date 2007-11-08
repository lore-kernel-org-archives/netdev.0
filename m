From: Karsten Keil <kkeil@suse.de>
Subject: Re: Why does a connect to IPv6 LLA address fail ?
Date: Thu, 8 Nov 2007 19:32:22 +0100
Message-ID: <20071108183221.GA17878@pingi.kke.suse.de>
References: <20071107094007.GA15575@pingi.kke.suse.de> <20071107112838.GA22180@dhcp79.suse.cz> <4732151B.70309@hp.com> <200711081901.59334.agruen@suse.de> <47335258.4000806@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Gruenbacher <agruen@suse.de>, Jiri Bohac <jbohac@suse.cz>,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, kkeil@suse.de
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:34227 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759423AbXKHScX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 13:32:23 -0500
Content-Disposition: inline
In-Reply-To: <47335258.4000806@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 08, 2007 at 01:15:52PM -0500, Vlad Yasevich wrote:
> Andreas Gruenbacher wrote:
> > On Wednesday 07 November 2007 20:42, Vlad Yasevich wrote:
> >> The reason is that 2 different hosts may have the same link-local
> >> address as long as they are on different links.  If the sender is
> >> connected to both links then it may send the packet to the wrong
> >> destination.
> > 
> > Good point.
> > 
> > What's confusing is that connect(2) fails even if the host itself has the 
> > specified address. This isn't necessary.
> 
> Yes and no.  Since linux doesn't have the concept of default zone, we have
> to fail, because from the perspective of the kernel, the address was not
> fully specified.  OTOH, since this is our address, we 'could' have all
> the info.
> 

> The problem is that this verification happens before we hit the routing logic.
> It's an explicit check the if the sin6_scope_id is not set and we are not bound
> to an interface, it's an error.
> 

OK I run into this issue while running the TAHI testsuite. The test is as
follows:

  Check 03:
    DNS Address: fec0::9
    Candidate Source Addresses: fec0::1(SS) or LLA(LS)
    Destination Address List: 3fff::2(GS) or fe80::2(LS)
    Result: fe80::2 (src LLA) then 3fff::2 (src fec0::1)

    Scope(fe80::2) = Scope(LLA) and Scope(3fff::2) <> Scope(fec0::1), then prefer fe80::2

the nameserver send following answer for the query:

| | | | DNS_Question                    (length:21)
| | | | | DNS_QuestionEntry               (length:21)
| | | | | | Name                             = server.tahi.org.
| | | | | | Type                             = 28 (AAAA)
| | | | | | Class                            = 1
| | | | DNS_Answer                      (length:86)
| | | | | DNS_RR_AAAA                     (length:43)
| | | | | | Name                             = server.tahi.org.
| | | | | | Type                             = 28
| | | | | | Class                            = 1
| | | | | | TTL                              = 0
| | | | | | Length                           = 16
| | | | | | Address                          = 3fff::2
| | | | | DNS_RR_AAAA                     (length:43)
| | | | | | Name                             = server.tahi.org.
| | | | | | Type                             = 28
| | | | | | Class                            = 1
| | | | | | TTL                              = 0
| | | | | | Length                           = 16
| | | | | | Address                          = fe80::2



So how we should handle this issue, claim that the test is wrong, the test
should not use LLA for this ?

-- 
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex, HRB 16746 (AG Nuernberg)
