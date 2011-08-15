From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Fw: [Bug 39132] Starting with 3.0.0-rc6, masquerading seems to
 be broken.
Date: Mon, 15 Aug 2011 18:27:13 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108151804580.1481@ja.ssi.bg>
References: <20110804193107.68d93727@schatten.dmk.lab> <alpine.LFD.2.00.1108042131040.1495@ja.ssi.bg> <8A188C9C23A54337A5A276BAE29DC6E0@delorimier>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Florian Mickler <florian@mickler.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	bugzilla-daemon@bugzilla.kernel.org
To: David Hill <hilld@binarystorm.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51824 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753020Ab1HOPWC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Aug 2011 11:22:02 -0400
In-Reply-To: <8A188C9C23A54337A5A276BAE29DC6E0@delorimier>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 5 Aug 2011, David Hill wrote:

> Hello Julian,
> 
>    I'm not using TPROXY and I've used a blank firewall with only masquerading
> and reproduced the issue.
> Nothing is in NAT/mangle nor OUTPUT  but the rules mentionned in the attached
> files to this bug.
> 
> Francis Whittle  (Comment #18) has the same issue.
> 
> > Hello,
> > 
> > On Thu, 4 Aug 2011, Florian Mickler wrote:
> > 
> > > Can someone take a look at this regression?
> > > 
> > > Begin forwarded message:
> > > 
> > > Date: Thu, 28 Jul 2011 04:51:12 GMT
> > > From: bugzilla-daemon@bugzilla.kernel.org
> > > To: florian@mickler.org
> > > Subject: [Bug 39132] Starting with 3.0.0-rc6, masquerading seems to be
> > > broken.
> > > 
> > > 
> > > https://bugzilla.kernel.org/show_bug.cgi?id=39132
> > 
> > So, problem points again to
> > "Fix ip_route_me_harder triggering ip_rt_bug" ? May be
> > David C. Hill or Florian can provide some information, eg. is
> > tproxy used, what NAT rules are used, any rules in OUTPUT
> > hooks (NAT/mangle) and which packets are dropped.

	May be it is a sequence of two problems. I now
checked the tcpdump log from Francis Whittle. The
"seq 352:1792" packet at 18:44:29.235154 that is not
SNAT-ed is long, can it be some PMTU event that triggers
ICMP response to the internal host? Because I see changes
in MSS. May be rc5 triggers ICMP FRAG NEEDED while rc6
does not. It can happen because:

1. ICMP uses non-local iph->saddr when XFRM is compiled,
reverse lookup fails with ENOENT but fl4->saddr is
already damaged with the original daddr (non-local).

	Fix is here: http://marc.info/?t=131118984300003&r=1&w=2

2. The patched ip_route_me_harder between 3.0-rc5 and
3.0-rc6 expects that sockets always provide local address.
This is wrong for some cases such as TCP (uses different
SOCK_RAW socket for some packets and can cause problem
for tproxy), RAW (can use spoofed sources) and now the
ICMP code that incorrectly provides non-local address.

	Fix is here: http://marc.info/?t=131274411600001&r=1&w=2

	I hope (any of) these two fixes should solve the
masquerading problems. If that is not true, tcpdump from rc5
would be helpful for comparison.

Regards

--
Julian Anastasov <ja@ssi.bg>
