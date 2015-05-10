From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code where
 it belongs
Date: Sun, 10 May 2015 12:37:10 -0700
Message-ID: <554FB366.7080509@plumgrid.com>
References: <1431277170-4618-1-git-send-email-pablo@netfilter.org> <1431277170-4618-3-git-send-email-pablo@netfilter.org> <554F9946.9040707@plumgrid.com> <20150510175934.GA3799@salvia> <554F9DE8.3000507@plumgrid.com> <20150510182414.GA4198@salvia> <554FA7A5.5020400@plumgrid.com> <20150510190039.GA4938@salvia> <554FAC3A.40701@plumgrid.com> <20150510192044.GA7173@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	daniel@iogearbox.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:33046 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbbEJThN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 15:37:13 -0400
Received: by igbpi8 with SMTP id pi8so60110303igb.0
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 12:37:12 -0700 (PDT)
In-Reply-To: <20150510192044.GA7173@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/10/15 12:20 PM, Pablo Neira Ayuso wrote:
> On Sun, May 10, 2015 at 12:06:34PM -0700, Alexei Starovoitov wrote:
>> On 5/10/15 12:00 PM, Pablo Neira Ayuso wrote:
>>>
>>> The inlined code into the ingress core path seems to have an impact to
>>> people that don't need this, even with the static key.
>>
>> two emails ago you've accused me of non-technical comments and
>> now I've posted real numbers that show no impact on users that don't
>> enable ingress and you still say 'seems to have an impact' ?!
>> I'm speechless.
>
> No. On the danger of repeating myself: The existing approach that
> inlines handle_ing() into __netif_receive_skb_core(), and your
> approach since it's persists on that, has an impact in performance on
> everyone in the earth.

Another non-technical 'guess' ?

baseline with Daniel's two patches:
    text	   data	    bss	    dec	    hex	filename
10605509	1885208	1400832	13891549	 d3f7dd	vmlinux

then with:
-static inline struct sk_buff *handle_ing(struct sk_buff *skb,
+static noinline struct sk_buff *handle_ing(struct sk_buff *skb,

    text	   data	    bss	    dec	    hex	filename
10605572	1885208	1400832	13891612	 d3f81c	vmlinux

so not inlining handle_ing() actually may have an impact on everyone,
because .text gets bigger. Though only marginally.

btw, after removing 'inline' keyword gcc still inlines it automatically
and looking at the above numbers gcc is doing the right call.
