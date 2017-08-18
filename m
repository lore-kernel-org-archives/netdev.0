From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [net-next PATCH 06/10] bpf: sockmap with sk redirect support
Date: Fri, 18 Aug 2017 11:32:17 -0700
Message-ID: <653a9c34-c187-636d-40f4-eb74a819c3d5@fb.com>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
 <20170816053247.15445.69312.stgit@john-Precision-Tower-5810>
 <fbc6e111-f610-2ef9-bb2a-6503d747124f@fb.com> <5995E738.9090803@gmail.com>
 <a6dafa0a-9cb2-6d70-5db7-fe44108a6c2c@fb.com> <599698D0.9040803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <tgraf@suug.ch>, <netdev@vger.kernel.org>, <tom@herbertland.com>
To: John Fastabend <john.fastabend@gmail.com>, <davem@davemloft.net>,
        <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:56969 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750971AbdHRScp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 14:32:45 -0400
In-Reply-To: <599698D0.9040803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/17 12:35 AM, John Fastabend wrote:
> From an API perspective having all socks in a sockmap inherit the same
> BPF programs is useful when working with cgroups. It keeps things consistent
> and is pretty effective for applying policy to cgroup sockets.

agree. it's all clear, see modified proposal below.

> But,
> in some cases it breaks down a bit and that is where the map_flags
> and BPF_SOCKMAP_STRPARSER entered the picture. After this discussion
> I think we can clean this up. Here is my proposal, let me know what you
> think.
>
> First I would like to continue allowing socks to inherit BPF programs
> from sock map if users set this up. To clean it up and make it extensible
> though,
>
>   - instead of doing the attach_fd2 which would break quickly if we need
>     fd(3,4,...) use two separate attach types,
>
>          BPF_SMAP_STREAM_PARSER
>          BPF_SMAP_STREAM_VERDICT
>
>     the target fd is the map fd just as before.
>
>     This allows us to easily extend as needed by adding another type and
>     the map space is a u32 so we have plenty of room for extensions.
>
>  - implement the detach for the above to remove the programs
>
> Next lets just remove the map_flags BPF_SOCKMAP_STRPARSER. The UAPI is
> simplified this way and the inheritance rule is clear. If BPF programs
> are attached to the map they are inherited. If there is no BPF program
> attached the socks do not use strparser/verdict logic and are purely
> for redirect actions.
>
> A sock may be in multiple maps but can only inherit a single BPF
> stream/verdict program. Otherwise we would have no way to "know"
> which stream parser to run.
>
> Future extensions could provide an API for doing per sock attach operations
> and I see no reason they would not be compatible. By adding two more
> attach types,
>
>         BPF_SOCK_STREAM_PARSER
>         BPF_SOCK_STREAM_VERDICT
>
> we can provide specific sock BPF programs. With verifier work we could
> even make bpf helpers
>
>         bpf_sock_prog_attach(skops, prog, type, flags)
>         bpf_sock_map_attach(sockmap, key, prog, type, flags)
>
> I think both this and the above work together nicely also the code can
> support this with some additional work. To summarize the API then with
> above changes,
>
>  syscall:
>
>   bpf_create_map(BPF_MAP_TYPE_SOCKMAP, .... )
>   bpf_prog_attach(verdict_prog, map_fd, BPF_SMAP_STREAM_VERDICT, 0);
>   bpf_prog_attach(parse_prog, map_fd, BPF_SMAP_STREAM_PARSER, 0);
>   bpf_map_update_elem(map_fd, key, sock_fd, BPF_ANY)
>   bpf_map_delete_elem(map_fd, key)
>
>  helpers:
>   to insert sock from sock ops progrm
>       bpf_sock_map_update(skops, map, key, flags);
>   to redirect skb to a sock in a sockmap
>       bpf_sk_redirect_map(map, key, flags)
>
>  future work:
>   bpf_prog_attach(verdict_prog, map_fd, BPF_SOCK_STREAM_VERDICT, 0)
>   bpf_prog_attach(parse_prog, map_fd, BPF_SOCK_STREAM_PARSER, 0)
>
> How does this look? I think it will be both extensible and very usable
> now.

Above sounds much better than the present situation.
Can we take it even further and split psock from sockmap?
My understanding that psock->key is there only because you tied
psock with the map and using map as a storage for the rx socket.
imo separating rx and tx sockets will make it cleaner.
Like we can have new syscall cmd that creates psock that holds
strpaser, verdict and potentially other programs.
Later sock ops program will use a helper:
bpf_psock_update(skops, psock_obj_handle, flags);
to assign single skops socket into this psock object.
The programs (strparser, verdict) will be applied to this skops socket,
so your inheritance requirement is satisfied.
And use sockmap only for TX sockets. Either user space via syscall
will store them in there or sockops program will store them into the map
via bpf_sock_map_update(skops, sockmap, key, flags); helper.
Later the verdict program will use
bpf_sk_redirect_map(sockmap, key, flags);
and for the program author no need to worry about 'type' of socket
in the sockmap. All sockets in there are TX sockets to redirect to.
And the same verdict program can use multiple sockmaps.
Similarly user space can create multiple psock objects with
same strparser+verdict programs or different and sockops prog
can pick and choose which psock to use to assign RX socket into.

Another alternative:
Instead of new psock object to store single socket (like current
implementation does), we can do two types of sockmap.
One for a set of RX sockets. All of them will have the same
strparser+verdict progs and psock with skbuff queue will be part
of this sockmap type.
And another sockmap type for TX sockets that don't have skbuff queues
at all and can only be used to redirect the RX socket into.
So bpf_rx_sock_map_update() helper will be used only on RX_SOCKMAP map
and bpf_tx_sock_map_update() helper will be used only on TX_SOCKMAP,
while bpf_sk_redirect_map() can only be used on TX_SOCKMAP.

Or you have cases when two RX sockets need to redirect into each
other and in both cases strparser+verdict need to run?
In such case we need to allow bpf_sk_redirect_map() to use on
RX_SOCKMAP map as well,
but looking at current implementation you only allow one psock per map,
so two sockets forwarding to each other cannot work due to only one queue.
Am I missing anything from what you want to achieve?
Thoughts?
