From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 27/34] nfp: bpf: Convert ndo_setup_tc offloads
 to block callbacks
Date: Tue, 17 Oct 2017 20:16:47 +0200
Message-ID: <20171017181647.GI2112@nanopsycho>
References: <20171012171823.1431-1-jiri@resnulli.us>
 <20171012171823.1431-28-jiri@resnulli.us>
 <20171012180824.1e76eac1@cakuba.netronome.com>
 <20171017124812.GH2112@nanopsycho>
 <20171017073959.2b0553fd@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:53202 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937351AbdJQSQt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 14:16:49 -0400
Received: by mail-wm0-f65.google.com with SMTP id k4so5672378wmc.1
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 11:16:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171017073959.2b0553fd@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 17, 2017 at 04:39:59PM CEST, jakub.kicinski@netronome.com wrote:
>On Tue, 17 Oct 2017 14:48:12 +0200, Jiri Pirko wrote:
>> Fri, Oct 13, 2017 at 03:08:24AM CEST, jakub.kicinski@netronome.com wrote:
>> >On Thu, 12 Oct 2017 19:18:16 +0200, Jiri Pirko wrote:  
>> >> diff --git a/drivers/net/ethernet/netronome/nfp/bpf/offload.c b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
>> >> index a88bb5b..9e9af88 100644
>> >> --- a/drivers/net/ethernet/netronome/nfp/bpf/offload.c
>> >> +++ b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
>> >> @@ -246,6 +246,10 @@ int nfp_net_bpf_offload(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
>> >>  	void *code;
>> >>  	int err;
>> >>  
>> >> +	if (cls_bpf->common.protocol != htons(ETH_P_ALL) ||
>> >> +	    cls_bpf->common.chain_index)
>> >> +		return -EOPNOTSUPP;
>> >> +
>> >>  	max_instr = nn_readw(nn, NFP_NET_CFG_BPF_MAX_LEN);
>> >>  
>> >>  	switch (cls_bpf->command) {  
>> >
>> >It is certainly very ugly but I send a fake struct tc_cls_bpf_offload
>> >here for XDP.  Refactoring this mess is pretty high on my priority list
>> >but one way or the other this function will be called from XDP so TC
>> >checks must stay in the TC handler... :(  
>> 
>> Okay. But currently, why is it a problem? You don't need the checks for
>> xdp path.
>> 
>
>static int
>nfp_bpf_xdp_offload(struct nfp_app *app, struct nfp_net *nn,
>		    struct bpf_prog *prog)
>{
>	struct tc_cls_bpf_offload cmd = {
>		.prog = prog,
>	};
>	int ret;
>
>	if (!nfp_net_ebpf_capable(nn))
>		return -EINVAL;
>
>	if (nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF) {
>		if (!nn->dp.bpf_offload_xdp)
>			return prog ? -EBUSY : 0;
>		cmd.command = prog ? TC_CLSBPF_REPLACE : TC_CLSBPF_DESTROY;
>	} else {
>		if (!prog)
>			return 0;
>		cmd.command = TC_CLSBPF_ADD;
>	}
>
>	ret = nfp_net_bpf_offload(nn, &cmd);
>	/* Stop offload if replace not possible */
>	if (ret && cmd.command == TC_CLSBPF_REPLACE)
>		nfp_bpf_xdp_offload(app, nn, NULL);
>	nn->dp.bpf_offload_xdp = prog && !ret;
>	return ret;
>}
>
>The fake offload struct is at the top of this function.  Dereferencing
>cls_bpf->common in nfp_net_bpf_offload() will crash the kernel.  Or am
>I missing something?

We just have to init it. Should not be a problem. Will add it.
