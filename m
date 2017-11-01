From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 08/20] net: sched: cls_bpf: call block
 callbacks for offload
Date: Wed, 1 Nov 2017 09:33:59 +0100
Message-ID: <20171101083359.GD1977@nanopsycho.orion>
References: <20171019135048.4306-1-jiri@resnulli.us>
 <20171019135048.4306-9-jiri@resnulli.us>
 <20171031174409.7b803613@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        ast@kernel.org, daniel@iogearbox.net, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:50868 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751721AbdKAIeB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 04:34:01 -0400
Received: by mail-wr0-f193.google.com with SMTP id p96so1284591wrb.7
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 01:34:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171031174409.7b803613@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 01, 2017 at 01:44:09AM CET, jakub.kicinski@netronome.com wrote:
>On Thu, 19 Oct 2017 15:50:36 +0200, Jiri Pirko wrote:
>> @@ -159,17 +162,38 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
>>  	cls_bpf.exts_integrated = prog->exts_integrated;
>>  	cls_bpf.gen_flags = prog->gen_flags;
>>  
>> -	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSBPF, &cls_bpf);
>> -	if (!err && (cmd == TC_CLSBPF_ADD || cmd == TC_CLSBPF_REPLACE))
>> -		prog->gen_flags |= TCA_CLS_FLAGS_IN_HW;
>> +	if (tc_can_offload(dev)) {
>> +		err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSBPF,
>> +						    &cls_bpf);
>> +		if (addorrep) {
>> +			if (err) {
>> +				if (skip_sw)
>> +					return err;
>> +			} else {
>> +				prog->gen_flags |= TCA_CLS_FLAGS_IN_HW;
>> +			}
>> +		}
>> +	}
>> +
>> +	err = tc_setup_cb_call(block, NULL, TC_SETUP_CLSBPF, &cls_bpf, skip_sw);
>> +	if (addorrep) {
>> +		if (err < 0) {
>> +			cls_bpf_offload_cmd(tp, prog, TC_CLSBPF_DESTROY);
>
>It seems counter intuitive that the appropriate action for a failed
>REPLACE is DESTROY.  One would expect a bad REPLACE X -> Y to be 
>followed by a REPLACE Y -> X (i.e. go back to X).

That makes sense.

>
>At least my reading of cls_bpf is that if replace fails software path
>will keep using the old prog.  Is this maybe something that's different
>in flower?  Or am I reading the code wrong?

In flower, there is not possible to do replace. First, the new one is
added and then the old one is removed.
