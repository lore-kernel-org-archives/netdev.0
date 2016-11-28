From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 1/3] bpf: Refactor cgroups code in prep for
 new type
Date: Mon, 28 Nov 2016 13:31:43 -0700
Message-ID: <8c67174f-1f03-b0bb-08ea-ec07c40c4466@cumulusnetworks.com>
References: <1480348130-31354-1-git-send-email-dsa@cumulusnetworks.com>
 <1480348130-31354-2-git-send-email-dsa@cumulusnetworks.com>
 <20161128200641.GA7634@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33723 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752668AbcK1Ubp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:31:45 -0500
Received: by mail-pf0-f170.google.com with SMTP id d2so26696043pfd.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 12:31:45 -0800 (PST)
In-Reply-To: <20161128200641.GA7634@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/16 1:06 PM, Alexei Starovoitov wrote:
> On Mon, Nov 28, 2016 at 07:48:48AM -0800, David Ahern wrote:
>> Code move only; no functional change intended.
> 
> not quite...
> 
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ...
>>   * @sk: The socken sending or receiving traffic
>> @@ -153,11 +166,15 @@ int __cgroup_bpf_run_filter(struct sock *sk,
>>  
>>  	prog = rcu_dereference(cgrp->bpf.effective[type]);
>>  	if (prog) {
>> -		unsigned int offset = skb->data - skb_network_header(skb);
>> -
>> -		__skb_push(skb, offset);
>> -		ret = bpf_prog_run_save_cb(prog, skb) == 1 ? 0 : -EPERM;
>> -		__skb_pull(skb, offset);
>> +		switch (type) {
>> +		case BPF_CGROUP_INET_INGRESS:
>> +		case BPF_CGROUP_INET_EGRESS:
>> +			ret = __cgroup_bpf_run_filter_skb(skb, prog);
>> +			break;
> 
> hmm. what's a point of double jump table? It's only burning cycles
> in the fast path. We already have
> prog = rcu_dereference(cgrp->bpf.effective[type]); if (prog) {...}
> Could you do a variant of __cgroup_bpf_run_filter() instead ?
> That doesnt't take 'skb' as an argument.
> It will also solve scary looking NULL skb from patch 2:
> __cgroup_bpf_run_filter(sk, NULL, ...
> 
> and to avoid copy-pasting first dozen lines of current
> __cgroup_bpf_run_filter can be moved into a helper that
> __cgroup_bpf_run_filter_skb and
> __cgroup_bpf_run_filter_sk will call.
> Or some other way to rearrange that code.
> 

sure
1. rename the existing __cgroup_bpf_run_filter to __cgroup_bpf_run_filter_skb

2. create new __cgroup_bpf_run_filter_sk for this new program type. the new run_filter does not need the family or full sock checks for this use case so the common code is only the sock_cgroup_ptr and prog lookups.
