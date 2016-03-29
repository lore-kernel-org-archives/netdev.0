From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: net/netfilter: KASAN: stack-out-of-bounds in tcp_packet
Date: Mon, 28 Mar 2016 18:17:02 -0700
Message-ID: <1459214222.6473.144.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LSU.2.20.1603282214130.16241@nerf40.vanv.qr>
	 <1459197963.6473.125.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1459198306.6473.126.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160328.195457.1407210954449940457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jengelh@inai.de, kadlec@blackhole.kfki.hu, sploving1@gmail.com,
	pablo@netfilter.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32768 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbcC2BRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 21:17:06 -0400
In-Reply-To: <20160328.195457.1407210954449940457.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-28 at 19:54 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 28 Mar 2016 13:51:46 -0700
> 
> > On Mon, 2016-03-28 at 13:46 -0700, Eric Dumazet wrote:
> > 
> >> We have at least 384 bytes of padding in skb->head (this is struct
> >> skb_shared_info).
> >> 
> >> Whatever garbage we might read, current code is fine.
> >> 
> >> We have to deal with a false positive here.
> > 
> > Very similar to the one fixed in 
> > https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=10ec9472f05b45c94db3c854d22581a20b97db41
> 
> I don't see them as similar.
> 
> The current options code we are talking about here never references
> past legitimate parts of the packet data.  We always check 'length',
> and we never access past the boundary it describes.
> 
> This was the entire point of my posting.
> 
> Talking about padding, rather than the logical correctness of the
> code, is therefore a distraction I think :-)

Not really, we do read one out of bound byte David.

length = 1;
...
while (length > 0) {
	int opcode = *ptr++; // Note that length is still 1
        switch (opcode) {
        ...
        default:
            opsize = *ptr++; // Note that length is still 1


        ...
        length -= opsize;
}

So we do read 2 bytes, while length was 1.

opsize definitely can read garbage.
Call it padding or redzone or whatever ;)
