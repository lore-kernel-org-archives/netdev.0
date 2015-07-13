From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] tc: fix tc actions in case of shared skb
Date: Mon, 13 Jul 2015 22:55:32 +0200
Message-ID: <55A425C4.60301@iogearbox.net>
References: <1436573411-5021-1-git-send-email-ast@plumgrid.com>	<20150711.212917.1463596559900301434.davem@davemloft.net>	<55A415DE.8020806@plumgrid.com> <20150713.130438.1857789246357119116.davem@davemloft.net> <55A41CE9.8050907@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jhs@mojatatu.com,
	jiri@resnulli.us, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47493 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbbGMUzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 16:55:40 -0400
In-Reply-To: <55A41CE9.8050907@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/13/2015 10:17 PM, Alexei Starovoitov wrote:
...
> We cannot check tc actions from pktgen, since they can be added
> dynamically.
> So I see three options:
> 1 get rid of burst hack for both RX and TX in pktgen (kills performance)
> 2 add unlikely(skb_shread) check to few tc actions
> 3 do nothing
>
> I think 2 isn't that bad after all if properly documented with
> "because pktgen is doing this hack for performance" ?
>
> I'm fine with 3 too, since the whole pktgen business is for root
> and for kernel hackers who suppose to know what they're doing.

Hmm, one thing for option 3 could be that we add a modinfo tag
"experimental", so that on loading of pktgen module, we trigger
(like in case of staging) ...

   add_taint_module(mod, TAINT_CRAP, LOCKDEP_STILL_OK);

... and add a pr_warn() to the user, it may be more visible/clear
than the "Packet Generator (USE WITH CAUTION)" Kconfig title? ;)

It'd be a pity that we'd need the extra atomic read only for the
pktgen case. :/ With regards to option 2, you could hide that behind
a static inline helper wrapped in IS_ENABLED(CONFIG_NET_PKTGEN), but
that is a veeeery ugly workaround/hack as well (and distros might
even ship it nevertheless). I wouldn't be surprised if there are
other usage combinations with pktgen that would crash your box. :/

Best,
Daniel
