From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 06/10] bpf: sockmap with sk redirect support
Date: Fri, 18 Aug 2017 00:35:44 -0700
Message-ID: <599698D0.9040803@gmail.com>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810> <20170816053247.15445.69312.stgit@john-Precision-Tower-5810> <fbc6e111-f610-2ef9-bb2a-6503d747124f@fb.com> <5995E738.9090803@gmail.com> <a6dafa0a-9cb2-6d70-5db7-fe44108a6c2c@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, tom@herbertland.com
To: Alexei Starovoitov <ast@fb.com>, davem@davemloft.net,
        daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:36563 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750739AbdHRHgC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 03:36:02 -0400
Received: by mail-pg0-f52.google.com with SMTP id i12so59171959pgr.3
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 00:36:02 -0700 (PDT)
In-Reply-To: <a6dafa0a-9cb2-6d70-5db7-fe44108a6c2c@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2017 03:28 PM, Alexei Starovoitov wrote:
> On 8/17/17 11:58 AM, John Fastabend wrote:
>>>> +    /* reserve BPF programs early so can abort easily on failures */
>>>> +    if (map_flags & BPF_SOCKMAP_STRPARSER) {
>>> why have two 'flags' arguments and new helper just for this?
>>> can normal update() be used and extra bits of flag there?
>>>
>> The new helper is needed regardless to handle consuming the skops ctx
>> pointer from programs attached to cgroups. This way we can attach sockets
>> in cgroups when they enter specified TCP states.
>>
>> The map_flags arg was because I expect we may end up with a few more flags
>> in sockmap and thought it was reasonable to keep separate namespaces for
>> the two flag types, BPF_ and BPF_SOCKMAP_*. It does however have the one
>> issue that when doing the update via syscall the flags are not available.
>>
>> If there is no objection to consuming some bits of the normal flags a small
>> patch could do that. I think we will need at least two more bits going forward
>> for additional features. I guess though the map flags is not pressed for
>> bit space yet though.
>>
> 
> hmm. looking at the patch further. I'm not excited with this new api.

OK first thanks for looking it over.

> Why this BPF_SOCKMAP_STRPARSER flag is needed at all?
> The sample code doesn't use it. What could be the use case?

The use case is to allow 'redirect' to a socket but without having the
receive side use strparser/verdict programs. If the flags not set we
wont run the strparser.

> Some future proofing? but the code seems to work properly only in
> strparser mode... like 'verdict' bpf prog is called only
> from strparser callback... and no other way to call it...
> and normal map_update_elem() implies BPF_SOCKMAP_STRPARSER too...
> I don't see detach api either..
> .

The detach is not yet implemented, I'll add it shortly.

> Why BPF_CGROUP_SMAP_INGRESS has 'cgroup' suffix in there?
> It doesn't deal with cgroups. It attaches a pair of prog_fds to sockmap.
> I guess it's ok-ish to use BPF_PROG_ATTACH syscall command for that,
> but using BPF_CGROUP_SMAP_INGRESS as 'attach type' is very confusing.

Point taken, bad naming scheme but easy enough to fix.

> Why couldn't you use multiple normal bpf_map_update() commands to
> store two prog_fds into stockmap ?
> You could have reserved two special numerical key values 0xdead and
> 0xbeef or -1/-2 for these two progs?
> If I read it correctly this new prog_attach sub-command doesn't attach
> to any event, it only stores two hidden bpf programs inside sockmap.
> 

see proposal below.

> Later proper prog_attach to actual cgroup is done with normal cgroup_fd
> and BPF_CGROUP_SOCK_OPS prog type which looks completely independent
> of sockmap, no?

Yes agreed. Although I expect sockmap will primarily be used with
BPF_CGROUP_SOCK_OPS with population of a sock map done through the
SOCK_OPS helpers. But, I agree sockmap fundamentally can stand on its
own without cgroups.

> It seems right now there is psock <-> one sockmap restriction
> which looks implementation related. If we ever want to remove that
> restriction such uapi will prevent us from doing it, since it's
> doing too much stuff under the cover.

The psock <-> sockmap binding is a result of the programs being
attached to the sockmap and not to the sock object. I think the
proposal below resolves this.

> 
> i like the sock to sock redirect concept of the patch, but uapi needs
> to be improved before it goes to released kernel.
> 
> How about we break it down into smaller chunks of work and
> expose what's happening underneath as explicit user driven actions?
> Like:
> - map_fd = create_map(BPF_MAP_TYPE_SOCKMAP) will create an empty map
> - add new explicit helper to create psock in given map_fd or
>   use prog_attach() cmd to attach to socket instead of sockmap ?
> - two map_udpate_elem(map_fd, -1, strparser_prog_fd)
>   map_update_elem(map_fd, -2, verdict_prog_fd)
>   will store the progs in there which are currently hidden.
>   map_delete_elem(-1) and (-2) would clear them.
>   Alternatively pass both FDs at once as 8-byte key into single
>   map_update() cmd
>   or create new psock object that will keep strpaser and verdict progs?
> - keep prog_attach(BPF_CGROUP_SOCK_OPS) as-is for
>   BPF_CGROUP_SOCK_OPS prog type which can call new helper
>   bpf_foo(ctx, ...) that will convert ctx socket into strparser mode
>   without making association to sockmap.
> 
> My main objection to the api is that hidden psock object makes
> the api confusing to use and I'm struggling to see how it will
> be extensible. Like what if we want more than two strparser+verdict
> progs in sockmap? or multiple sockmaps out of the same verdict prog?
> I'm also struggling to wrap my head how prog_attach cmd attaches
> to a map and hidden creation of strparser in a socket.
> It seems right now psock == one rx socket that works in strparser
> mode while sockmap is secondary set of tx sockets to redirect to.
> If so, psock and sockmap should be independent in uapi.
> Like prog_attach would attach strpaser and verdict programs to
> a socket switching it to strparser mode.
> If SK_REDIRECT is not returned it would be dropping skbs (like now),
> if redirect requested, the smap_do_verdict() will pick the next
> socket from sockmap and there will be no rigid connection
> between sockmap and psock and we can use multiple sockmaps
> from the same verdict program. smap_do_verdict() only needs
> to know peer socket to redirect to.
> Thoughts?
> 

OK I think there are a couple things we can do here.

>From an API perspective having all socks in a sockmap inherit the same
BPF programs is useful when working with cgroups. It keeps things consistent
and is pretty effective for applying policy to cgroup sockets. But,
in some cases it breaks down a bit and that is where the map_flags
and BPF_SOCKMAP_STRPARSER entered the picture. After this discussion
I think we can clean this up. Here is my proposal, let me know what you
think.

First I would like to continue allowing socks to inherit BPF programs
from sock map if users set this up. To clean it up and make it extensible
though,

  - instead of doing the attach_fd2 which would break quickly if we need
    fd(3,4,...) use two separate attach types,

         BPF_SMAP_STREAM_PARSER
         BPF_SMAP_STREAM_VERDICT

    the target fd is the map fd just as before.

    This allows us to easily extend as needed by adding another type and
    the map space is a u32 so we have plenty of room for extensions.

 - implement the detach for the above to remove the programs

Next lets just remove the map_flags BPF_SOCKMAP_STRPARSER. The UAPI is
simplified this way and the inheritance rule is clear. If BPF programs
are attached to the map they are inherited. If there is no BPF program
attached the socks do not use strparser/verdict logic and are purely
for redirect actions.

A sock may be in multiple maps but can only inherit a single BPF
stream/verdict program. Otherwise we would have no way to "know"
which stream parser to run.

Future extensions could provide an API for doing per sock attach operations
and I see no reason they would not be compatible. By adding two more
attach types,

        BPF_SOCK_STREAM_PARSER
        BPF_SOCK_STREAM_VERDICT

we can provide specific sock BPF programs. With verifier work we could
even make bpf helpers

        bpf_sock_prog_attach(skops, prog, type, flags)
        bpf_sock_map_attach(sockmap, key, prog, type, flags)

I think both this and the above work together nicely also the code can
support this with some additional work. To summarize the API then with
above changes,

 syscall:

  bpf_create_map(BPF_MAP_TYPE_SOCKMAP, .... )
  bpf_prog_attach(verdict_prog, map_fd, BPF_SMAP_STREAM_VERDICT, 0);
  bpf_prog_attach(parse_prog, map_fd, BPF_SMAP_STREAM_PARSER, 0);
  bpf_map_update_elem(map_fd, key, sock_fd, BPF_ANY)
  bpf_map_delete_elem(map_fd, key)

 helpers:
  to insert sock from sock ops progrm
      bpf_sock_map_update(skops, map, key, flags);
  to redirect skb to a sock in a sockmap
      bpf_sk_redirect_map(map, key, flags)

 future work:
  bpf_prog_attach(verdict_prog, map_fd, BPF_SOCK_STREAM_VERDICT, 0)
  bpf_prog_attach(parse_prog, map_fd, BPF_SOCK_STREAM_PARSER, 0)

How does this look? I think it will be both extensible and very usable
now.

Thanks,
John
