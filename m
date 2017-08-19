From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 06/10] bpf: sockmap with sk redirect support
Date: Fri, 18 Aug 2017 20:30:13 -0700
Message-ID: <5997B0C5.703@gmail.com>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810> <20170816053247.15445.69312.stgit@john-Precision-Tower-5810> <fbc6e111-f610-2ef9-bb2a-6503d747124f@fb.com> <5995E738.9090803@gmail.com> <a6dafa0a-9cb2-6d70-5db7-fe44108a6c2c@fb.com> <599698D0.9040803@gmail.com> <653a9c34-c187-636d-40f4-eb74a819c3d5@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, tom@herbertland.com
To: Alexei Starovoitov <ast@fb.com>, davem@davemloft.net,
        daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:35700 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751076AbdHSDa1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 23:30:27 -0400
Received: by mail-pg0-f47.google.com with SMTP id u191so132969pgc.2
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 20:30:27 -0700 (PDT)
In-Reply-To: <653a9c34-c187-636d-40f4-eb74a819c3d5@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...] (trimmed email leaving proposal - 1 summary)

>>
>>  syscall:
>>
>>   bpf_create_map(BPF_MAP_TYPE_SOCKMAP, .... )
>>   bpf_prog_attach(verdict_prog, map_fd, BPF_SMAP_STREAM_VERDICT, 0);
>>   bpf_prog_attach(parse_prog, map_fd, BPF_SMAP_STREAM_PARSER, 0);
>>   bpf_map_update_elem(map_fd, key, sock_fd, BPF_ANY)
>>   bpf_map_delete_elem(map_fd, key)
>>
>>  helpers:
>>   to insert sock from sock ops progrm
>>       bpf_sock_map_update(skops, map, key, flags);
>>   to redirect skb to a sock in a sockmap
>>       bpf_sk_redirect_map(map, key, flags)
>>
>>  future work:
>>   bpf_prog_attach(verdict_prog, map_fd, BPF_SOCK_STREAM_VERDICT, 0)
>>   bpf_prog_attach(parse_prog, map_fd, BPF_SOCK_STREAM_PARSER, 0)
>>
>> How does this look? I think it will be both extensible and very usable
>> now.
> 
> Above sounds much better than the present situation.
> Can we take it even further and split psock from sockmap?

So psock data structure itself is almost entirely split at this
point anyways. The remaining two pieces are back pointers to the
map and a key so we can remove the entry when needed. The reason
is we need to remove the map entry when the socket is closed.

We use the sock insertion into the map as the trigger to create
the psock.

> My understanding that psock->key is there only because you tied
> psock with the map and using map as a storage for the rx socket

Almost. To clarify the psock only ever uses the key/map entries
to remove itself on a TCP state change that would close the sock.
.
> imo separating rx and tx sockets will make it cleaner.
> Like we can have new syscall cmd that creates psock that holds
> strpaser, verdict and potentially other programs.
> Later sock ops program will use a helper:
> bpf_psock_update(skops, psock_obj_handle, flags);
> to assign single skops socket into this psock object.
> The programs (strparser, verdict) will be applied to this skops socket,
> so your inheritance requirement is satisfied.
> And use sockmap only for TX sockets. Either user space via syscall
> will store them in there or sockops program will store them into the map
> via bpf_sock_map_update(skops, sockmap, key, flags); helper.
> Later the verdict program will use
> bpf_sk_redirect_map(sockmap, key, flags);
> and for the program author no need to worry about 'type' of socket
> in the sockmap. All sockets in there are TX sockets to redirect to.
> And the same verdict program can use multiple sockmaps.
> Similarly user space can create multiple psock objects with
> same strparser+verdict programs or different and sockops prog
> can pick and choose which psock to use to assign RX socket into.
> 

I prefer the alternative below it seems a bit cleaner to me. I think
a very similar programming flow to the above can be achieved using
the primitives below.

> Another alternative:
> Instead of new psock object to store single socket (like current
> implementation does), we can do two types of sockmap.
> One for a set of RX sockets. All of them will have the same
> strparser+verdict progs and psock with skbuff queue will be part
> of this sockmap type.
> And another sockmap type for TX sockets that don't have skbuff queues

Clarification the skbuff queue in the psock data structure,

	struct sk_buff_head rxqueue;

is attached to the TX socket actually and run through the workqueue.
The naming is perhaps unfortunate, it made sense to me because the
sending sock is receiving skbs from multiple socks.

> at all and can only be used to redirect the RX socket into.
> So bpf_rx_sock_map_update() helper will be used only on RX_SOCKMAP map
> and bpf_tx_sock_map_update() helper will be used only on TX_SOCKMAP,
> while bpf_sk_redirect_map() can only be used on TX_SOCKMAP.
> 

So this is really close to what I proposed above. For a TX_SOCKMAP
simply do not attach any programs,

   bpf_create_map(BPF_MAP_TYPE_SOCKMAP, .... )
   [...]

For an RX_SOCKMAP,

   bpf_create_map(BPF_MAP_TYPE_SOCKMAP, .... )
   bpf_prog_attach(verdict_prog, map_fd, BPF_SMAP_STREAM_VERDICT, 0);
   bpf_prog_attach(parse_prog, map_fd, BPF_SMAP_STREAM_PARSER, 0);   

With the new attach type (compared to the fd2 thing before) we can easily
extend maps to contain other program types as needed. So in the future
we might have TX_SOCKMAP, RX_SOCKMAP, FOO_SOCKMAP, ...

I don't see the need to have the API enforce the map type via update
specifiers bpf_{rx|tx}_sock_map_update. The programmer should "know"
the type by virtue of the programs attached. This is more flexible
as well because it allows a map to be TX only, RX only or TX/RX.

With this proposal we can relax the restriction where a sock can only
be in a single map and even allow a sock to be in the same map multiple
times. The limitation we do have to enforce is allowing a sock in the
a map with different BPF_SMAP_STREAM_* programs. But I think this
should be clear to the programmer (with good tracing functions and
error codes).

Slight aside: but by creating map size of 1 we have an object that
contains programs and later we can attach a sock to it, looks like
the following,

      create_map(BPF_MAP_TYPE_SOCKMAP,...)
      bpf_prog_attach(...) 
      [...]
      bpf_update_map_elem(fd, map, key, flags)

I think this is very close to your first approach where you suggested
a program container object.

> Or you have cases when two RX sockets need to redirect into each
> other and in both cases strparser+verdict need to run?

If we don't do rx, tx restrictions and use my suggestion here we
don't have this limitation. OR because we allow socks in multiple
maps now the user can simply put the sockets in different maps.

> In such case we need to allow bpf_sk_redirect_map() to use on
> RX_SOCKMAP map as well,
> but looking at current implementation you only allow one psock per map,
> so two sockets forwarding to each other cannot work due to only one queue.
> Am I missing anything from what you want to achieve?

I don't think so. But lets get rid of the one psock per map, I took a shot
at relaxing that today and was able to get it with a refcount on the psock
which seems to work OK.

Also reorganizing the psock structure into clear sections tx_psock, rx_psock,
general_psock will probably help readers.

> Thoughts?
> 

What do you think of my counter proposal I started coding it up and it
actually (other than pushing code snippets around) seems to work out
nicely with the existing code base. I think it is really a nice improvement.

Thanks,
John
