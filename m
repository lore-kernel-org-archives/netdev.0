From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net v5] bpf: add helper to compare network namespaces
Date: Fri, 17 Feb 2017 15:15:11 +0100
Message-ID: <58A7056F.7040206@iogearbox.net>
References: <1487208564-4666-1-git-send-email-dsa@cumulusnetworks.com> <58A57A13.9070906@iogearbox.net> <16fcf613-fc8d-e2a1-5f49-40ddbade65b5@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, tj@kernel.org, luto@amacapital.net,
        ebiederm@xmission.com
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52605 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934058AbdBQOPW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 09:15:22 -0500
In-Reply-To: <16fcf613-fc8d-e2a1-5f49-40ddbade65b5@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/17/2017 05:01 AM, David Ahern wrote:
> On 2/16/17 3:08 AM, Daniel Borkmann wrote:
>> Is there anything that speaks against doing the comparison itself
>> outside of the helper? Meaning, the helper would get a buffer
>> passed from stack f.e. struct foo { u64 ns_dev; u64 ns_ino; }
>> and fills both out with the netns info belonging to the sk/skb.
>
> How do you handle CONFIG_NET_NS not set?
>
> You call something like bpf_get_netns_id(sk, &foo), it has to exist
> regardless of the config. What should it return if netns is disabled?

In rough semi pseudo code, it could look like the below. In case we have
!CONFIG_NET_NS then that would be hidden behind the netns_get_kstat() (or
whatever function name it has) as a static inline that just returns an
error such as -ENOTSUPP.

If the entity installing the program is aware that CONFIG_NET_NS is set
and that the input is exactly of size struct bpf_netns, then it can also
skip the error test in the BPF program itself. Anyway, just a thought
so that the helper could be more flexible and used as a key for lookups
on maps, too ...

BPF_CALL_3(bpf_sk_netns_get, struct sock *, sk,  struct bpf_netns *, ns,
            u32, size)
{
         struct ns_kstat tmp;
         int ret;

         if (unlikely(size != sizeof(struct bpf_netns)))
                 return -EINVAL;

         ret = netns_get_kstat(sock_net(sk), &tmp);
         if (unlikely(ret))
                 return ret;

         ns->dev = tmp.dev;
         ns->ino = tmp.ino;

         return 0;
}

static const struct bpf_func_proto bpf_sk_netns_get_proto = {
         .func           = bpf_sk_netns_get,
         .gpl_only       = false,
         .ret_type       = RET_INTEGER,
         .arg1_type      = ARG_PTR_TO_CTX,
         .arg2_type      = ARG_PTR_TO_UNINIT_MEM,
         .arg3_type      = ARG_CONST_SIZE,
};

Thanks,
Daniel
