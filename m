From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [net-next PATCH 06/10] bpf: sockmap with sk redirect support
Date: Thu, 17 Aug 2017 15:28:03 -0700
Message-ID: <a6dafa0a-9cb2-6d70-5db7-fe44108a6c2c@fb.com>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
 <20170816053247.15445.69312.stgit@john-Precision-Tower-5810>
 <fbc6e111-f610-2ef9-bb2a-6503d747124f@fb.com> <5995E738.9090803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <tgraf@suug.ch>, <netdev@vger.kernel.org>, <tom@herbertland.com>
To: John Fastabend <john.fastabend@gmail.com>, <davem@davemloft.net>,
        <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43597 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752632AbdHQW23 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 18:28:29 -0400
In-Reply-To: <5995E738.9090803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/17/17 11:58 AM, John Fastabend wrote:
>>> +    /* reserve BPF programs early so can abort easily on failures */
>>> +    if (map_flags & BPF_SOCKMAP_STRPARSER) {
>> why have two 'flags' arguments and new helper just for this?
>> can normal update() be used and extra bits of flag there?
>>
> The new helper is needed regardless to handle consuming the skops ctx
> pointer from programs attached to cgroups. This way we can attach sockets
> in cgroups when they enter specified TCP states.
>
> The map_flags arg was because I expect we may end up with a few more flags
> in sockmap and thought it was reasonable to keep separate namespaces for
> the two flag types, BPF_ and BPF_SOCKMAP_*. It does however have the one
> issue that when doing the update via syscall the flags are not available.
>
> If there is no objection to consuming some bits of the normal flags a small
> patch could do that. I think we will need at least two more bits going forward
> for additional features. I guess though the map flags is not pressed for
> bit space yet though.
>

hmm. looking at the patch further. I'm not excited with this new api.
Why this BPF_SOCKMAP_STRPARSER flag is needed at all?
The sample code doesn't use it. What could be the use case?
Some future proofing? but the code seems to work properly only in
strparser mode... like 'verdict' bpf prog is called only
from strparser callback... and no other way to call it...
and normal map_update_elem() implies BPF_SOCKMAP_STRPARSER too...
I don't see detach api either..

Why BPF_CGROUP_SMAP_INGRESS has 'cgroup' suffix in there?
It doesn't deal with cgroups. It attaches a pair of prog_fds to sockmap.
I guess it's ok-ish to use BPF_PROG_ATTACH syscall command for that,
but using BPF_CGROUP_SMAP_INGRESS as 'attach type' is very confusing.
Why couldn't you use multiple normal bpf_map_update() commands to
store two prog_fds into stockmap ?
You could have reserved two special numerical key values 0xdead and
0xbeef or -1/-2 for these two progs?
If I read it correctly this new prog_attach sub-command doesn't attach
to any event, it only stores two hidden bpf programs inside sockmap.

Later proper prog_attach to actual cgroup is done with normal cgroup_fd
and BPF_CGROUP_SOCK_OPS prog type which looks completely independent
of sockmap, no?
It seems right now there is psock <-> one sockmap restriction
which looks implementation related. If we ever want to remove that
restriction such uapi will prevent us from doing it, since it's
doing too much stuff under the cover.

i like the sock to sock redirect concept of the patch, but uapi needs
to be improved before it goes to released kernel.

How about we break it down into smaller chunks of work and
expose what's happening underneath as explicit user driven actions?
Like:
- map_fd = create_map(BPF_MAP_TYPE_SOCKMAP) will create an empty map
- add new explicit helper to create psock in given map_fd or
   use prog_attach() cmd to attach to socket instead of sockmap ?
- two map_udpate_elem(map_fd, -1, strparser_prog_fd)
   map_update_elem(map_fd, -2, verdict_prog_fd)
   will store the progs in there which are currently hidden.
   map_delete_elem(-1) and (-2) would clear them.
   Alternatively pass both FDs at once as 8-byte key into single
   map_update() cmd
   or create new psock object that will keep strpaser and verdict progs?
- keep prog_attach(BPF_CGROUP_SOCK_OPS) as-is for
   BPF_CGROUP_SOCK_OPS prog type which can call new helper
   bpf_foo(ctx, ...) that will convert ctx socket into strparser mode
   without making association to sockmap.

My main objection to the api is that hidden psock object makes
the api confusing to use and I'm struggling to see how it will
be extensible. Like what if we want more than two strparser+verdict
progs in sockmap? or multiple sockmaps out of the same verdict prog?
I'm also struggling to wrap my head how prog_attach cmd attaches
to a map and hidden creation of strparser in a socket.
It seems right now psock == one rx socket that works in strparser
mode while sockmap is secondary set of tx sockets to redirect to.
If so, psock and sockmap should be independent in uapi.
Like prog_attach would attach strpaser and verdict programs to
a socket switching it to strparser mode.
If SK_REDIRECT is not returned it would be dropping skbs (like now),
if redirect requested, the smap_do_verdict() will pick the next
socket from sockmap and there will be no rigid connection
between sockmap and psock and we can use multiple sockmaps
from the same verdict program. smap_do_verdict() only needs
to know peer socket to redirect to.
Thoughts?
