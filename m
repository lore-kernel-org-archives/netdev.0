From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] tc: fix tc actions in case of shared skb
Date: Mon, 13 Jul 2015 15:26:46 -0700
Message-ID: <55A43B26.1010009@plumgrid.com>
References: <1436573411-5021-1-git-send-email-ast@plumgrid.com>	<20150711.212917.1463596559900301434.davem@davemloft.net>	<55A415DE.8020806@plumgrid.com> <20150713.130438.1857789246357119116.davem@davemloft.net> <55A41CE9.8050907@plumgrid.com> <55A425C4.60301@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jhs@mojatatu.com,
	jiri@resnulli.us, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:34723 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357AbbGMW0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 18:26:47 -0400
Received: by pdbep18 with SMTP id ep18so232698051pdb.1
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 15:26:47 -0700 (PDT)
In-Reply-To: <55A425C4.60301@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/13/15 1:55 PM, Daniel Borkmann wrote:
> On 07/13/2015 10:17 PM, Alexei Starovoitov wrote:
> ...
>> We cannot check tc actions from pktgen, since they can be added
>> dynamically.
>> So I see three options:
>> 1 get rid of burst hack for both RX and TX in pktgen (kills performance)
>> 2 add unlikely(skb_shread) check to few tc actions
>> 3 do nothing
...
> pktgen case. :/ With regards to option 2, you could hide that behind
> a static inline helper wrapped in IS_ENABLED(CONFIG_NET_PKTGEN), but
> that is a veeeery ugly workaround/hack as well (and distros might
> even ship it nevertheless).

naming such helper is a headache as well.
static inline bool is_pktgen_shared_skb(struct sk_buff *skb)
{
#if IS_ENABLED(CONFIG_NET_PKTGEN)
	/* pktgen uses skb->users += burst trick to reuse skb */
	return skb_shared(skb);
#else
	return false;
#endif
}
and in actions:
if (unlikely(is_pktgen_shared_skb(skb))) goto drop;

thoughts?
