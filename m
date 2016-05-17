From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 -next] ingress, clsact: don't add TCA_OPTIONS
 to nl msg
Date: Tue, 17 May 2016 15:10:42 +0200
Message-ID: <573B1852.4000703@iogearbox.net>
References: <192c686bb5e277b9552fe1e5c39b14bed520dddd.1463329895.git.daniel@iogearbox.net> <573B0676.30500@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37938 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbcEQNKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 09:10:48 -0400
In-Reply-To: <573B0676.30500@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/17/2016 01:54 PM, Jamal Hadi Salim wrote:
> On 16-05-15 12:36 PM, Daniel Borkmann wrote:
>> In ingress and clsact qdisc TCA_OPTIONS are ignored, since it's
>> parameterless. In tc, we add an empty addattr_l(... TCA_OPTIONS,
>> NULL, 0) to the netlink message nevertheless. This has the
>> side effect that when someone tries a 'tc qdisc replace' and
>> already an existing such qdisc is present, tc fails with
>> EINVAL here.
>>
>> Reason is that in the kernel, this invokes qdisc_change() when
>> such requested qdisc is already present. When TCA_OPTIONS are
>> passed to modify parameters, it looks whether qdisc implements
>> .change() callback, and if not present (like in both cases here)
>> it returns with error. Rather than adding an empty stub to the
>> kernel that ignores TCA_OPTIONS again, just don't add TCA_OPTIONS
>> to the netlink message in the first place.
>>
>> Before:
>>
>>    # tc qdisc replace dev foo clsact    # first try
>>    # tc qdisc replace dev foo clsact    # second one
>>    RTNETLINK answers: Invalid argument
>>
>> After:
>>
>>    # tc qdisc replace dev foo clsact
>>    # tc qdisc replace dev foo clsact
>>    # tc qdisc replace dev foo clsact
>>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
> I see need for correctness but was curious of use case
> that made you even look at this ;->

Sure, wanted to use this in a script that is called when some event
arrives and the error 'Invalid argument' looked quite weird to me
(... would have understood -ENOTSUPP ;)), which then led me looking
into whether clsact code is correct or not, but it eventually turned
out that the api code throws that error when TCA_OPTIONS are present,
but no .change() callback, so motivation was to make sure clsact is
fine and to improve usability there for the replace command.

Thanks,
Daniel
