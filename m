From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: net/netfilter: KASAN: stack-out-of-bounds in tcp_packet
Date: Mon, 28 Mar 2016 14:29:57 -0700
Message-ID: <1459200597.6473.138.camel@edumazet-glaptop3.roam.corp.google.com>
References: <56F8987B.5030501@gmail.com> <56F92E21.30509@gmail.com>
	  <alpine.DEB.2.10.1603281844200.23985@blackhole.kfki.hu>
	  <20160328.152959.1109841569654352040.davem@davemloft.net>
	  <alpine.LSU.2.20.1603282214130.16241@nerf40.vanv.qr>
	 <1459197963.6473.125.camel@edumazet-glaptop3.roam.corp.google.com>
	 <alpine.DEB.2.10.1603282256120.25443@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@inai.de>,
	David Miller <davem@davemloft.net>, sploving1@gmail.com,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34000 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbcC1VaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 17:30:00 -0400
In-Reply-To: <alpine.DEB.2.10.1603282256120.25443@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-28 at 23:11 +0200, Jozsef Kadlecsik wrote:

> In net/netfilter/nf_conntrack_proto_tcp.c we copy the options into a 
> buffer with skb_header_pointer(), so it's not a false positive there and 
> the KASAN report referred to that part.
> 

Although the out of bound could be one extra byte,
if skb_header_bpointer() had to copy something (since it also might
return a pointer inside skb->head)

No arch would possibly fault here.

So reading one byte on the stack is fooling KASAN, but no ill effect
would actually happen.

If the read byte is < 2, the function would return because of

	 if (opsize < 2)
		return;

If the read byte is >= 2, the function would return because of
	if (opsize > length)
		return; /* don't parse partial options */


(Since we care here of the case where length == 1)

No big deal, it is probably better to 'fix' the code so that it pleases
dynamic checkers.
