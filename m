From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: xt_bpf: support ebpf
Date: Mon, 5 Dec 2016 18:51:44 -0500
Message-ID: <CAF=yD-J-vcQQ_-48xG8qhMuYvLvucCr7SG99rsfJA5-okvhHzA@mail.gmail.com>
References: <1480969684-74414-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <1480972006.18162.559.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161205213001.GA16819@breakpoint.cc> <20161205223415.GA14689@salvia>
 <20161205230055.GA15379@salvia> <CAF=yD-Jk4W+zU=tdixWe3LPGcFp-sANxXLLoQTRvrkN_3=a9uw@mail.gmail.com>
 <20161205232214.GA15825@salvia> <CA+FuTSfHryyqBhRyfQCChG2VPwpj1KYBk2Z7DZ-dcYL-FbbSeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel <netfilter-devel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CA+FuTSfHryyqBhRyfQCChG2VPwpj1KYBk2Z7DZ-dcYL-FbbSeA@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 5, 2016 at 6:29 PM, Willem de Bruijn <willemb@google.com> wrote:
> On Mon, Dec 5, 2016 at 6:22 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>> On Mon, Dec 05, 2016 at 06:06:05PM -0500, Willem de Bruijn wrote:
>> [...]
>>> Eric also suggests a private variable to avoid being subject to
>>> changes to PATH_MAX. Then we can indeed also choose an arbitrary lower
>>> length than current PATH_MAX.
>>
>> Good.
>>
>>> FWIW, there is a workaround for users with deeply nested paths: the
>>> path passed does not have to be absolute. It is literally what is
>>> passed on the command line to iptables right now, including relative
>>> addresses.
>>
>> If iptables userspace always expects to have the bpf file repository
>> in some given location (suggesting to have a directory that we specify
>> at ./configure time, similar to what we do with connlabel.conf), then
>> I think we can rely on relative paths. Would this be flexible enough
>> for your usecase?
>
> As long as it accepts relative paths, I think it will always work.
> Worst case, a user has to cd. No need for hardcoding the bpf mount
> point at compile time.
>
> I have the matching iptables patch for pinned objects, btw. Not for
> elf objects, which requires linking to libelf and parsing the object,
> which is more work (and perhaps best punted on by expanding libbpf in
> bcc to include this functionality. it already exists under samples/bpf
> and iproute2).

While we're discussing the patch, another question, about revisions: I
tested both modified and original iptables binaries on both standard
and modified kernels. It all works as expected, except for the case
where both binaries are used on a single kernel. For instance:

  iptables -A OUTPUT -m bpf --bytecode "`./nfbpf_compile RAW 'udp port
8000'`" -j LOG
  ./iptables.new -L

Here the new binary will interpret the object as xt_bpf_match_v1, but
iptables has inserted xt_bpf_match. The same problem happens the other
way around. A new binary can be made robust to detect old structs, but
not the other way around. Specific to bpf, the existing xt_bpf code
has an unfortunate bug that it always prints at least one line of
code, even if ->bpf_program_num_elems == 0.

I notice that other extensions also do not necessarily only extend
struct vN in vN+1. Is the above a known issue?
