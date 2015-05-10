From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code
 where it belongs
Date: Mon, 11 May 2015 01:43:13 +0200
Message-ID: <20150510234313.GA3176@salvia>
References: <554F9DE8.3000507@plumgrid.com>
 <20150510182414.GA4198@salvia>
 <554FA7A5.5020400@plumgrid.com>
 <20150510190039.GA4938@salvia>
 <554FAC3A.40701@plumgrid.com>
 <20150510192044.GA7173@salvia>
 <554FB366.7080509@plumgrid.com>
 <20150510195018.GA7877@salvia>
 <554FCE24.8020904@iogearbox.net>
 <554FD12F.2020607@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org,
	davem@davemloft.net, jhs@mojatatu.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38539 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751709AbbEJXi3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 19:38:29 -0400
Content-Disposition: inline
In-Reply-To: <554FD12F.2020607@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 10, 2015 at 11:44:15PM +0200, Daniel Borkmann wrote:
> On 05/10/2015 11:31 PM, Daniel Borkmann wrote:
> >On 05/10/2015 09:50 PM, Pablo Neira Ayuso wrote:
> >...
> >>The numbers show that the existing approach and your approach results
> >>in less performance for everyone that don't need to filter from
> >>ingress. We have to move ingress to where it belongs.
> >
> >Your cleanup in patch 1 is okay, thanks for spotting it Pablo.
> >
> >I agree with you on the qdisc_enqueue_root(), it's not needed, which I
> >removed in my set as well. Please note that my set doesn't introduce a
> >regression, it improves ingress performance however.
> >
> >If there's no ingress user than that code path is simply *nop*'ed out.
> >If there's one ingress present on one device but not on others, it also
> >doesn't make anything slower to the current state. And you can also always
> >compile out CONFIG_NET_CLS_ACT (which we actually could make more fine
> >grained), if you really care.
> 
> But I am still wondering, does your machine have static_key support?

Yes:

CONFIG_JUMP_LABEL=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y

$ scripts/gcc-goto.sh gcc
y

> If nothing is enabled, the code runs through a straight-line code path,
> it's a nop that is there.

The noop is patched to an unconditional branch to skip that code, but
the code is still there in that path, even if it's dormant.

What the numbers show is rather simple: The more code is in the path,
the less performance you get, and the qdisc ingress specific code
embedded there is reducing performance for people that are not using
qdisc ingress, hence it should go where it belongs. The static key
cannot save you from that.
