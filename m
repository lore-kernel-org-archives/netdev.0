From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC 06/12] nfp: add hardware cls_bpf offload
Date: Wed, 01 Jun 2016 23:16:39 +0200
Message-ID: <574F50B7.10406@iogearbox.net>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com> <1464799814-4453-7-git-send-email-jakub.kicinski@netronome.com> <574F43A6.7000804@iogearbox.net> <20160601205159.GB22759@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org, ast@kernel.org,
	dinan.gunawardena@netronome.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34669 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbcFAVQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 17:16:42 -0400
In-Reply-To: <20160601205159.GB22759@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2016 10:52 PM, Alexei Starovoitov wrote:
> On Wed, Jun 01, 2016 at 10:20:54PM +0200, Daniel Borkmann wrote:
>> On 06/01/2016 06:50 PM, Jakub Kicinski wrote:
>>> Add hardware cls_bpf offload on our smart NICs.  Detect if
>>> capable firmware is loaded and use it to load the code JITed
>>> with just added translator onto programmable engines.
>>>
>>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>>> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
>>> Reviewed-by: Simon Horman <simon.horman@netronome.com>
>> [...]
>>> +static int
>>> +nfp_net_bpf_offload_prepare(struct nfp_net *nn,
>>> +			    struct tc_cls_bpf_offload *cls_bpf,
>>> +			    struct nfp_bpf_result *res,
>>> +			    void **code, dma_addr_t *dma_addr, u16 max_instr)
>>> +{
>>> +	unsigned int code_sz = max_instr * sizeof(u64);
>>> +	u16 start_off, tgt_out, tgt_abort;
>>> +	const struct tc_action *a;
>>> +	int err;
>>> +
>>> +	if (tc_no_actions(cls_bpf->exts))
>>> +		return -EINVAL;
>>> +
>>> +	tc_for_each_action(a, cls_bpf->exts) {
>>> +		if (!is_tcf_gact_shot(a))
>>> +			return -EINVAL;
>>> +	}
>>> +
>>> +	if (cls_bpf->exts_integrated)
>>> +		return -EINVAL;
>>
>> So cls_bpf has two working modes as mentioned: da (direct-action) and non-da.
>> Direct-action is I would say the most typical way to run cls_bpf as it allows
>> you to more naturally and efficiently code programs in the sense that classification
>> and action is already combined in a single program, so there's no additional
>> overhead of a linear action chain required, and a single program can already
>> have multiple action code outcomes (TC_ACT_OK, TC_ACT_SHOT, ...), so that it is
>> usually enough to run a single cls_bpf instance, for example, on sch_clsact
>> ingress or egress parent, nothing more than that to get the job done. I think
>> the cls_bpf->exts_integrated test could probably come first and if it's false,
>> we'd need to walk the actions?
>
> I think it makes sense to offload da mode only. Doing tc_for_each_action
> walk like above is ok, but the number of bpf programs with only separate
> gact is diminishingly small and we don't recommend to use it anymore.
> That's the stuff we used when da wasn't available.

Yeah, that makes sense to me, I presume that would also be easier to manage due
to all being self-contained.
