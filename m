From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] tc: fix tc actions in case of shared skb
Date: Tue, 14 Jul 2015 07:57:34 -0400
Message-ID: <55A4F92E.1020908@mojatatu.com>
References: <1436573411-5021-1-git-send-email-ast@plumgrid.com>	<20150711.212917.1463596559900301434.davem@davemloft.net>	<55A415DE.8020806@plumgrid.com> <20150713.130438.1857789246357119116.davem@davemloft.net> <55A41CE9.8050907@plumgrid.com> <55A425C4.60301@iogearbox.net> <55A43B26.1010009@plumgrid.com> <55A4E479.8080101@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36952 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbbGNL5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 07:57:41 -0400
Received: by igbpg9 with SMTP id pg9so10164120igb.0
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 04:57:41 -0700 (PDT)
In-Reply-To: <55A4E479.8080101@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/14/15 06:29, Daniel Borkmann wrote:
> On 07/14/2015 12:26 AM, Alexei Starovoitov wrote:
>> On 7/13/15 1:55 PM, Daniel Borkmann wrote:
>>> On 07/13/2015 10:17 PM, Alexei Starovoitov wrote:
>>> ...
>>>> We cannot check tc actions from pktgen, since they can be added
>>>> dynamically.
>>>> So I see three options:
>>>> 1 get rid of burst hack for both RX and TX in pktgen (kills
>>>> performance)
>>>> 2 add unlikely(skb_shread) check to few tc actions
>>>> 3 do nothing
>> ...
>>> pktgen case. :/ With regards to option 2, you could hide that behind
>>> a static inline helper wrapped in IS_ENABLED(CONFIG_NET_PKTGEN), but
>>> that is a veeeery ugly workaround/hack as well (and distros might
>>> even ship it nevertheless).
>>
>> naming such helper is a headache as well.
>> static inline bool is_pktgen_shared_skb(struct sk_buff *skb)
>> {
>> #if IS_ENABLED(CONFIG_NET_PKTGEN)
>>      /* pktgen uses skb->users += burst trick to reuse skb */
>>      return skb_shared(skb);
>> #else
>>      return false;
>> #endif
>> }
>> and in actions:
>> if (unlikely(is_pktgen_shared_skb(skb))) goto drop;
>>
>> thoughts?
>
> As I mentioned above, so Fedora, for example, ships pktgen by default.
> That means, we'd run into the above test for shared skb in every case,
> meaning it won't help much and it's also a pretty nasty hack. ;)
>
> One other thing that comes to mind, not sure if it's worth it though,
> would be to split the skb->tc_verd's TC_NCLS itself into TC_NCLS/TC_NACT,
> so that you can go into the classifier, but skip the action part.
>
> Since in tcf_action_exec(), we already test for that, you might be able
> to add this with no extra cost. pktgen would then need to tag its skb
> with TC_NACT, so that you'll always return with TC_ACT_OK. And if you
> really would want to test tc actions, then w/o pktgen bursting ...
>

Would just a simple skb->mark not work? Drop if skb->mark = x
using skbedit. Or a brand new pktgen_burst_mode action that drops?

cheers,
jamal
