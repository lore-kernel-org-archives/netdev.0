From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL net-next 01/17] ndisc: Fix size calculation for headers.
Date: Wed, 19 Dec 2012 12:08:22 +0900
Message-ID: <50D12FA6.6040901@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org> <50D04AD4.8010908@linux-ipv6.org> <20121218.162338.1594192050394527214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:57654 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754071Ab2LSDIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 22:08:23 -0500
In-Reply-To: <20121218.162338.1594192050394527214.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Tue, 18 Dec 2012 19:52:04 +0900
> 
>> We used to allocate MAX_HEADER bytes more than needed but
>> reserved hlen only (not MAX_HEADER + hlen) and the MAX_HEADER
>> was left behind.
>>
>> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> This change is wrong.
> 
> The MAX_HEADER is being used in order to accomodate any
> possible encapsulation that may occur.

As I tried to explain in the commit message, ndisc_build_skb() does tI would say his:

|        int hlen = LL_RESERVED_SPACE(dev);
:
|        skb = sock_alloc_send_skb(sk,
|                                  (MAX_HEADER + sizeof(struct ipv6hdr) +
|                                   len + hlen + tlen),
|                                  1, &err);
|        if (!skb) {
|                ND_PRINTK(0, err, "ND: %s failed to allocate an skb, err=%d\n",
|                          __func__, err);
|                return NULL;
|        }
|
|        skb_reserve(skb, hlen);

This means, MAX_HEADER has been placed at the TAIL of
the buffer, instead of the HEAD of the buffer, like this.

head        data                   tail                        end
+--------------------------------------------------------------+
+           |                      |          |                |
+--------------------------------------------------------------+
|<- hlen  ->|<---ipv6 packet------>|<--tlen-->|<--MAX_HEADER-->|
|  = LL_
     RESERVED_
     SPACE(dev)

MAX_HEADER will not be used at all and I would say it is waste of
memory.

Or do you expect something like this?

+--------------------------------------------------------------+
+                |           |                      |          |
+--------------------------------------------------------------+
|<--MAX_HEADER-->|<---hlen-->|<---ipv6 packet------>|<--tlen-->|
head                       data                   tail       end

or like this:

+--------------------------------------------------+
+                |                      |          |
+--------------------------------------------------+
|<--MAX_HEADER-->|<---ipv6 packet------>|<--tlen-->|
head           data                   tail       end

If so, we should (re)visit almost all users of
sock_alloc_send_skb() and friends, anyway, I think.

--yoshfuji
