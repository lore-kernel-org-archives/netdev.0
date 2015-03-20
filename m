From: Marcelo <marcelo.leitner@gmail.com>
Subject: Re: [PATCH v2] tipc: fix build issue when building without IPv6
Date: Fri, 20 Mar 2015 09:35:35 -0300
Message-ID: <9df97f7f63e5c844ede07f1e6ec45c4e@propriete.com.br>
References: <20150319.150433.850095478975909930.davem@davemloft.net> <1426794478-5469-1-git-send-email-marcelo.leitner@gmail.com> <20150319.160658.1294624225284354605.davem@davemloft.net> <550B8156.3020400@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, <richard.alpe@ericsson.com>,
	<jon.maloy@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>, <erik.hugne@ericsson.com>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:36692 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbbCTMfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 08:35:41 -0400
Received: by qgez102 with SMTP id z102so1765958qge.3
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 05:35:41 -0700 (PDT)
In-Reply-To: <550B8156.3020400@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Mar 2015 10:09:26 +0800, Ying Xue <ying.xue@windriver.com>
wrote:
> On 03/20/2015 04:06 AM, David Miller wrote:
>> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>> Date: Thu, 19 Mar 2015 16:47:58 -0300
>> 
>>> We can't directly call ipv6_sock_mc_join() but should use the stub
>>> instead and protect it around IS_ENABLED.
>>>
>>> Fixes: d0f91938bede ("tipc: add ip/udp media type")
>>> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>> 
> 
> Sorry, this patch doesn't work at all especially when IPV6=m and TIPC=y.
> For
> example, when we use the combination of the kernel config options, error
> appears
> like:
> 
> net/built-in.o: In function `tipc_udp_send_msg':
>
/home/ying/work/tipc/tipc2.0/net-next-2.6-debug/net/tipc/udp_media.c:196:
> undefined reference to `ip6_dst_lookup'
> make: *** [vmlinux] Error 1
> 
> Instead, I ever tried to fix the issue several days ago. Please refer to
> the thread:
> 
> https://patchwork.ozlabs.org/patch/448836/
> 
> According to the suggestion David gave lastly, we should separate the
UDP
> media
> as an independent module, make TIPC_MEDIA_UDP depend on (IPV6 ||
IPV6=n),
> and
> mark TIPC_MEDIA_UDP tristate. Now I am busy doing this following the
> proposal.

I missed your work on the issue, Ying, sorry, otherwise I would have
replied
to that thread instead of posting the patch.

I think David and Willem suggestion were more about the dependencies
than fixing the build issue itself. I mean, if some part of TIPC really
needs IPv6 in order to work or something like that.

So if all we want to do if fix the build issue, I have another suggestion.
When we have IPV6=m and TIPC=y, just have to use the stub too.

(cut & pasted)
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -193,7 +193,7 @@ static int tipc_udp_send_msg(struct net *net, struct
sk_buff *skb,
                        .saddr = src->ipv6,
                        .flowi6_proto = IPPROTO_UDP
                };
-               err = ip6_dst_lookup(ub->ubsock->sk, &ndst, &fl6);
+               err = ipv6_stub->ipv6_dst_lookup(ub->ubsock->sk, &ndst,
&fl6);
                if (err)
                        goto tx_error;
                ttl = ip6_dst_hoplimit(ndst);

then it builds fine here. That is, assuming that you can't reach this code
while
ipv6 module is unloaded.. (I didn't check that) what do you think?

Regards,
Marcelo
