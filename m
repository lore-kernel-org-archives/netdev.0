From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: tun netns BUG()
Date: Fri, 05 Jun 2009 16:20:45 -0700
Message-ID: <m11vpy2roy.fsf@fess.ebiederm.org>
References: <1244142352.3751.14.camel@macbook.infradead.org>
	<m17hzr7a0o.fsf@fess.ebiederm.org>
	<1244191328.3751.111.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52847 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752106AbZFEXVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 19:21:01 -0400
In-Reply-To: <1244191328.3751.111.camel@macbook.infradead.org> (David Woodhouse's message of "Fri\, 05 Jun 2009 09\:42\:07 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> writes:

> On Thu, 2009-06-04 at 18:19 -0700, Eric W. Biederman wrote:
>> David Woodhouse <dwmw2@infradead.org> writes:
>> 
>> > Johannes and I have been playing with using network namespaces for VPNs:
>> > 	http://david.woodhou.se/vpnc-netns.sh
>> >
>> > The idea is that you set up a separate netns to be 'afflicted' by the
>> > VPN, while your normal programs have a normal view of the network.
>> >
>> > One option was to run a SOCKS server in the VPN's netns, so that normal
>> > programs could get to the VPN through that. That's not what I'm doing
>> > here though -- this one is using NAT-PT so a range of IPv6 space is
>> > mapped to the Legacy IP range on the VPN. Any connections to
>> > fec0:0:0:ffff:0:0:xxyy:zzww get mapped to xx.yy.zz.ww on the VPN.
>> >
>> > This is done by passing the VPN tundev (from vpnc or openconnect) into
>> > the new netns, and running ptrtd inside the netns. Then passing the
>> > tundev from ptrtd back _out_ from the netns to the normal namespace.
>> >
>> > First I noticed that when vpnc/openconnect closes, the tundev doesn't
>> > disappear from inside the netns -- that was unexpected.
>> 
>> Agreed.   If it doesn't ask for that handling it should not happen.
>> 
>> > So I made the
>> > script in there exit some other way, and then it oopses when
>> > vpnc/openconnect closes its tun fd.
>> >
>> > Looks like you can reproduce it by passing a tundev to a different
>> > netns, then closing that netns before you close tun fd which is attached
>> > to it.
>> >
>> > (This was actually tun.c from commit 1bded710a5 on 2.6.29.4, but I see
>> > no reason to believe that 2.6.30-rc is different).
>> 
>> This?
>> 
>> commit 1bded710a574f20d41bc9e7fb531301db282d623
>> 
>>     tun: Check supplemental groups in TUN/TAP driver.
>
> Yes. That's the latest version of tun.c from 2.6.30-rc which would build
> against my distro's 2.6.29 kernel without me having to think. It
> includes all your patches -- as you point out, the driver in 2.6.29
> still has NETIF_F_NETNS_LOCAL.

Hmm.  I think you have the wrong commit id.  But now I understand what
code you are running.

> There have been 6 patches to tun.c in 2.6.30-rc since that version -- 5
> of which are from Herbert. Are you suggesting that one of those patches
> fixes a bug which you introduced? At first glance, I didn't think that
> looked likely.

I think the pot was stirred very well with Herbert's patches, and I
think it just about anything is possible.  The reference counting
completely changed.  So I expect at this point stabilizing the code
without Herbert's patches is wasted work.

>> I haven't had a chance to go back and check it thoroughly.  The code
>> in 2.6.30-rc at least tries to do the right thing.
>
> This _is_ the tun.c code from 2.6.30-rc, basically.

>> I will be happy to look into any problems with the driver on
>> 2.6.30-rc.  The driver in 2.6.29 is enough different it isn't really
>> worth trying to debug.
>
> OK, here's one from 2.6.30-rc8. This one looks like it's the other way
> round -- my VPN script passes one tun device _into_ the netns, and one
> tun device _out_ of it. This time, it's oopsed on the one that was
> passed _out_.

Thanks.  Ugh I was afraid of that.

> I've been experimenting with a standalone test case but haven't yet
> managed to reproduce it -- I still had to use openconnect with the
> vpnc-script I gave before (with the 'sleep 1 # to avoid BUG()' commented
> out of course). Using that script with vpnc or anything similar should
> presumably have the same effect.

Ah the infamous poll path.  I will take a look. 

Eric
