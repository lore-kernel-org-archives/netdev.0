From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 06/12] nfp: add hardware cls_bpf offload
Date: Thu, 02 Jun 2016 14:30:10 +0200
Message-ID: <575026D2.7090009@iogearbox.net>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>	<1464799814-4453-7-git-send-email-jakub.kicinski@netronome.com>	<574F43A6.7000804@iogearbox.net>	<20160601205159.GB22759@ast-mbp.thefacebook.com>	<574F5570.2070107@gmail.com>	<20160602065748.GA1987@nanopsycho> <20160602131348.729ca2b6@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netdev@vger.kernel.org, ast@kernel.org,
	dinan.gunawardena@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57556 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125AbcFBMaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 08:30:14 -0400
In-Reply-To: <20160602131348.729ca2b6@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/2016 02:13 PM, Jakub Kicinski wrote:
> On Thu, 2 Jun 2016 08:57:48 +0200, Jiri Pirko wrote:
>> Wed, Jun 01, 2016 at 11:36:48PM CEST, john.fastabend@gmail.com wrote:
>>> On 16-06-01 01:52 PM, Alexei Starovoitov wrote:
>>>> On Wed, Jun 01, 2016 at 10:20:54PM +0200, Daniel Borkmann wrote:
>>>>> On 06/01/2016 06:50 PM, Jakub Kicinski wrote:
>>>>>> Add hardware cls_bpf offload on our smart NICs.  Detect if
>>>>>> capable firmware is loaded and use it to load the code JITed
>>>>>> with just added translator onto programmable engines.
>>>>>>
>>>>>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>>>>>> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
>>>>>> Reviewed-by: Simon Horman <simon.horman@netronome.com>
>>>>> [...]
>>>>>> +static int
>>>>>> +nfp_net_bpf_offload_prepare(struct nfp_net *nn,
>>>>>> +			    struct tc_cls_bpf_offload *cls_bpf,
>>>>>> +			    struct nfp_bpf_result *res,
>>>>>> +			    void **code, dma_addr_t *dma_addr, u16 max_instr)
>>>>>> +{
>>>>>> +	unsigned int code_sz = max_instr * sizeof(u64);
>>>>>> +	u16 start_off, tgt_out, tgt_abort;
>>>>>> +	const struct tc_action *a;
>>>>>> +	int err;
>>>>>> +
>>>>>> +	if (tc_no_actions(cls_bpf->exts))
>>>>>> +		return -EINVAL;
>>>>>> +
>>>>>> +	tc_for_each_action(a, cls_bpf->exts) {
>>>>>> +		if (!is_tcf_gact_shot(a))
>>>>>> +			return -EINVAL;
>>>>>> +	}
>>>>>> +
>>>>>> +	if (cls_bpf->exts_integrated)
>>>>>> +		return -EINVAL;
>>>>>
>>>>> So cls_bpf has two working modes as mentioned: da (direct-action) and non-da.
>>>>> Direct-action is I would say the most typical way to run cls_bpf as it allows
>>>>> you to more naturally and efficiently code programs in the sense that classification
>>>>> and action is already combined in a single program, so there's no additional
>>>>> overhead of a linear action chain required, and a single program can already
>>>>> have multiple action code outcomes (TC_ACT_OK, TC_ACT_SHOT, ...), so that it is
>>>>> usually enough to run a single cls_bpf instance, for example, on sch_clsact
>>>>> ingress or egress parent, nothing more than that to get the job done. I think
>>>>> the cls_bpf->exts_integrated test could probably come first and if it's false,
>>>>> we'd need to walk the actions?
>>>>
>>>> I think it makes sense to offload da mode only. Doing tc_for_each_action
>>>> walk like above is ok, but the number of bpf programs with only separate
>>>> gact is diminishingly small and we don't recommend to use it anymore.
>>>> That's the stuff we used when da wasn't available.
>>>
>>> +1 I've been using da mode only as well.
>>
>> I also think we should support offload for da mode only for cls_bpf
>
> First of all thanks everyone for the reviews and suggestions!
>
> I will definitely do da in the next revision, but I'm not sure we
> should do only da.  As far as I can tell there are no statistics when
> da mode is used.

Well, you still have (qdisc) drop counter, but other than that, you can implement
your own stats via BPF maps for whatever event the user is programming it to count
stats for. But I presume that would be for some step later on if you can in-fact
support that.

But at the same time there should also be nothing that prevents you from adding a
new netlink attribute for the cls_bpf dump part that could export generic hw stats
related to the offloaded program (like passes, drops, etc) to tc and if present and
da enabled, tc dumps them too?
