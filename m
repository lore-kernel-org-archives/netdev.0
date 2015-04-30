From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Thu, 30 Apr 2015 12:12:04 +0200
Message-ID: <20150430101204.GA3167@salvia>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
 <1430333589-4940-7-git-send-email-pablo@netfilter.org>
 <55413E99.5000807@iogearbox.net>
 <20150429233205.GA3416@salvia>
 <55417545.30103@iogearbox.net>
 <20150430003019.GE7025@acer.localdomain>
 <55417A3A.50405@iogearbox.net>
 <20150430004839.GG7025@acer.localdomain>
 <20150430011633.GA12674@Alexeis-MBP.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54037 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750771AbbD3KHj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 06:07:39 -0400
Content-Disposition: inline
In-Reply-To: <20150430011633.GA12674@Alexeis-MBP.westell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2015 at 06:16:35PM -0700, Alexei Starovoitov wrote:
> On Thu, Apr 30, 2015 at 02:48:39AM +0200, Patrick McHardy wrote:
> > Netfilter is based on hook chains. The cost when only using a single hook
> > is minimal (as Pablo showed in his numbers), but even if only using
> > TC and a single netfilter classifier chain, there has to be some relative
> > ordering and the hooks provide this in a generic way.
>
> Unfortunately the numbers that Pablo shown are not measuring
> the right thing.

The numbers I've shown were measuring the critical ingress path. I
never posted numbers on generic hook infrastructure.

> > 840203pps 403Mb/sec
>
> this is 20 times less than what they should be.

It's ~10% less, because obviously we run more code in the generic hook
infrastructure, as they provide more features. So far it was only
possible to register one single chain at ingress. Eric Dumazet already
indicated that this benchmark only measures *one single CPU* and
icache is fully populated. The numbers with smp will go worse because
of the central lock contention.

These are the numbers I got banging *one single CPU*:

* Without patches + qdisc ingress:

Result: OK: 16298126(c16298125+d0) usec, 10000000 (60byte,0frags)
  613567pps 294Mb/sec (294512160bps) errors: 10000000

* With patches + qdisc ingress on top of hooks:

Result: OK: 18339281(c18339280+d0) usec, 10000000 (60byte,0frags)
  545277pps 261Mb/sec (261732960bps) errors: 10000000

* With patches + nftables ingress chain:

Result: OK: 17118167(c17118167+d0) usec, 10000000 (60byte,0frags)

  584174pps 280Mb/sec (280403520bps) errors: 10000000
