From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v3 net] bpf: add bpf_sk_netns_id() helper
Date: Mon, 6 Feb 2017 16:02:55 -0800
Message-ID: <58990EAF.6010205@fb.com>
References: <1486179240-3574802-1-git-send-email-ast@fb.com>
 <58990917.8000406@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsa@cumulusnetworks.com>, Tejun Heo <tj@kernel.org>,
        "Andy Lutomirski" <luto@amacapital.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33542 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751545AbdBGADX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 19:03:23 -0500
In-Reply-To: <58990917.8000406@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/6/17 3:39 PM, Daniel Borkmann wrote:
> On 02/04/2017 04:34 AM, Alexei Starovoitov wrote:
> [...]
>> +BPF_CALL_1(bpf_skb_netns_id, struct sk_buff *, skb)
>> +{
>> +    struct net_device *dev = skb->dev;
>> +
>> +    if (!dev)
>> +        return 0;
>> +    return proc_get_ns_devid_inum(&dev_net(dev)->ns);
>> +}
>> +
>> +static const struct bpf_func_proto bpf_skb_netns_id_proto = {
>> +    .func        = bpf_skb_netns_id,
>> +    .gpl_only    = false,
>> +    .ret_type    = RET_INTEGER,
>> +    .arg1_type    = ARG_PTR_TO_CTX,
>> +};
>> +
>>   static const struct bpf_func_proto *
>>   sk_filter_func_proto(enum bpf_func_id func_id)
>>   {
>> @@ -2620,6 +2649,8 @@ sk_filter_func_proto(enum bpf_func_id func_id)
>>       case BPF_FUNC_trace_printk:
>>           if (capable(CAP_SYS_ADMIN))
>>               return bpf_get_trace_printk_proto();
>> +    case BPF_FUNC_sk_netns_id:
>> +        return &bpf_skb_netns_id_proto;
>>       default:
>>           return NULL;
>>       }
>
> Btw, I think here's an oversight that would still need to be
> fixed. Above would mean that trace printk from unprivileged would
> fall through and use &bpf_skb_netns_id_proto as proto now instead
> of NULL. So BPF_FUNC_sk_netns_id needs to be placed above the
> BPF_FUNC_trace_printk case, not in its fall-through path. Looks
> like Chenbo in his get_socket_cookie missed this, too. Other than
> that BPF bits seem good to me.

Ahh, right. Good catch.
I'll add 'else return NULL;' otherwise somebody might step on it again.
Thanks Daniel!

Eric,
still waiting for your review of nsfs.c bits.
