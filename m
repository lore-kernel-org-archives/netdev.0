From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC 06/12] nfp: add hardware cls_bpf offload
Date: Thu, 2 Jun 2016 08:57:48 +0200
Message-ID: <20160602065748.GA1987@nanopsycho>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
 <1464799814-4453-7-git-send-email-jakub.kicinski@netronome.com>
 <574F43A6.7000804@iogearbox.net>
 <20160601205159.GB22759@ast-mbp.thefacebook.com>
 <574F5570.2070107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org, ast@kernel.org,
	dinan.gunawardena@netronome.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35178 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbcFBG5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 02:57:52 -0400
Received: by mail-wm0-f68.google.com with SMTP id e3so12994908wme.2
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 23:57:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <574F5570.2070107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 01, 2016 at 11:36:48PM CEST, john.fastabend@gmail.com wrote:
>On 16-06-01 01:52 PM, Alexei Starovoitov wrote:
>> On Wed, Jun 01, 2016 at 10:20:54PM +0200, Daniel Borkmann wrote:
>>> On 06/01/2016 06:50 PM, Jakub Kicinski wrote:
>>>> Add hardware cls_bpf offload on our smart NICs.  Detect if
>>>> capable firmware is loaded and use it to load the code JITed
>>>> with just added translator onto programmable engines.
>>>>
>>>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>>>> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
>>>> Reviewed-by: Simon Horman <simon.horman@netronome.com>
>>> [...]
>>>> +static int
>>>> +nfp_net_bpf_offload_prepare(struct nfp_net *nn,
>>>> +			    struct tc_cls_bpf_offload *cls_bpf,
>>>> +			    struct nfp_bpf_result *res,
>>>> +			    void **code, dma_addr_t *dma_addr, u16 max_instr)
>>>> +{
>>>> +	unsigned int code_sz = max_instr * sizeof(u64);
>>>> +	u16 start_off, tgt_out, tgt_abort;
>>>> +	const struct tc_action *a;
>>>> +	int err;
>>>> +
>>>> +	if (tc_no_actions(cls_bpf->exts))
>>>> +		return -EINVAL;
>>>> +
>>>> +	tc_for_each_action(a, cls_bpf->exts) {
>>>> +		if (!is_tcf_gact_shot(a))
>>>> +			return -EINVAL;
>>>> +	}
>>>> +
>>>> +	if (cls_bpf->exts_integrated)
>>>> +		return -EINVAL;
>>>
>>> So cls_bpf has two working modes as mentioned: da (direct-action) and non-da.
>>> Direct-action is I would say the most typical way to run cls_bpf as it allows
>>> you to more naturally and efficiently code programs in the sense that classification
>>> and action is already combined in a single program, so there's no additional
>>> overhead of a linear action chain required, and a single program can already
>>> have multiple action code outcomes (TC_ACT_OK, TC_ACT_SHOT, ...), so that it is
>>> usually enough to run a single cls_bpf instance, for example, on sch_clsact
>>> ingress or egress parent, nothing more than that to get the job done. I think
>>> the cls_bpf->exts_integrated test could probably come first and if it's false,
>>> we'd need to walk the actions?
>> 
>> I think it makes sense to offload da mode only. Doing tc_for_each_action
>> walk like above is ok, but the number of bpf programs with only separate
>> gact is diminishingly small and we don't recommend to use it anymore.
>> That's the stuff we used when da wasn't available.
>> 
>
>+1 I've been using da mode only as well.

I also think we should support offload for da mode only for cls_bpf
