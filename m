From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: tun netns BUG()
Date: Thu, 04 Jun 2009 18:19:03 -0700
Message-ID: <m17hzr7a0o.fsf@fess.ebiederm.org>
References: <1244142352.3751.14.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55970 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647AbZFEBTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 21:19:07 -0400
In-Reply-To: <1244142352.3751.14.camel@macbook.infradead.org> (David Woodhouse's message of "Thu\, 04 Jun 2009 20\:05\:52 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> writes:

> Johannes and I have been playing with using network namespaces for VPNs:
> 	http://david.woodhou.se/vpnc-netns.sh
>
> The idea is that you set up a separate netns to be 'afflicted' by the
> VPN, while your normal programs have a normal view of the network.
>
> One option was to run a SOCKS server in the VPN's netns, so that normal
> programs could get to the VPN through that. That's not what I'm doing
> here though -- this one is using NAT-PT so a range of IPv6 space is
> mapped to the Legacy IP range on the VPN. Any connections to
> fec0:0:0:ffff:0:0:xxyy:zzww get mapped to xx.yy.zz.ww on the VPN.
>
> This is done by passing the VPN tundev (from vpnc or openconnect) into
> the new netns, and running ptrtd inside the netns. Then passing the
> tundev from ptrtd back _out_ from the netns to the normal namespace.
>
> First I noticed that when vpnc/openconnect closes, the tundev doesn't
> disappear from inside the netns -- that was unexpected.

Agreed.   If it doesn't ask for that handling it should not happen.

> So I made the
> script in there exit some other way, and then it oopses when
> vpnc/openconnect closes its tun fd.
>
> Looks like you can reproduce it by passing a tundev to a different
> netns, then closing that netns before you close tun fd which is attached
> to it.
>
> (This was actually tun.c from commit 1bded710a5 on 2.6.29.4, but I see
> no reason to believe that 2.6.30-rc is different).

This?

commit 1bded710a574f20d41bc9e7fb531301db282d623
Author: Michael Tokarev <mjt@tls.msk.ru>
Date:   Mon Feb 2 23:34:56 2009 -0800

    tun: Check supplemental groups in TUN/TAP driver.
    
    Michael Tokarev wrote:
    []
    > 2, and this is the main one: How about supplementary groups?
    >
    > Here I have a valid usage case: a group of testers running various
    > versions of windows using KVM (kernel virtual machine), 1 at a time,
    > to test some software.  kvm is set up to use bridge with a tap device
    > (there should be a way to connect to the machine).  Anyone on that group
    > has to be able to start/stop the virtual machines.
    >
    > My first attempt - pretty obvious when I saw -g option of tunctl - is
    > to add group ownership for the tun device and add a supplementary group
    > to each user (their primary group should be different).  But that fails,
    > since kernel only checks for egid, not any other group ids.
    >
    > What's the reasoning to not allow supplementary groups and to only check
    > for egid?
    
    Signed-off-by: Michael Tokarev <mjt@tls.msk.ru>
    Signed-off-by: David S. Miller <davem@davemloft.net>


There has been a lot of work in this area, and definitely reason to believe
that 2.6.30-rc is different.

As I read it the driver in 2.6.29 has NETIF_F_NETNS_LOCAL set because
it doesn't even try to handle this case.

I had it very close to 100% in netdev and then I looked away and
Herber Xu merged a conflicting patch into it.  Most of the damage
has been fixed now and I expect it to be much more likely to work in
2.6.30-rc.

I haven't had a chance to go back and check it thoroughly.  The code
in 2.6.30-rc at least tries to do the right thing.

I will be happy to look into any problems with the driver on
2.6.30-rc.  The driver in 2.6.29 is enough different it isn't really
worth trying to debug.

Eric
