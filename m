From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Mon, 23 Jan 2017 21:05:13 -0700
Message-ID: <08f3f57e-8c51-c893-01ad-3ce23db8166d@cumulusnetworks.com>
References: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
 <20170124020950.GA72992@ast-mbp.thefacebook.com>
 <CALCETrUq_ZSso_252ixzjt+WbFOv_K57zbePUXneLv-Tgi5=jA@mail.gmail.com>
 <20170124031259.GA81720@ast-mbp.thefacebook.com>
 <CALCETrVZqqfMO+=HGgebbAJ0TY6c3XSyY1G-Ve+g3VQiEfGwyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Andy Lutomirski <luto@amacapital.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:33684 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAXEOE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 23:14:04 -0500
Received: by mail-pg0-f53.google.com with SMTP id 204so51080350pge.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 20:14:04 -0800 (PST)
In-Reply-To: <CALCETrVZqqfMO+=HGgebbAJ0TY6c3XSyY1G-Ve+g3VQiEfGwyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/17 8:37 PM, Andy Lutomirski wrote:
> Yes, it is a bug because cgroup+bpf causes unwitting programs to be
> subject to BPF code installed by a different, potentially unrelated
> process.  That's a new situation.  The failure can happen when a
> privileged supervisor (whoever runs ip vrf) runs a clueless or
> unprivileged program (the thing calling unshare()).

There are many, many ways to misconfigure networking and to run programs in a context or with an input argument that causes the program to not work at all, not work as expected or stop working. This situation is no different. 

For example, the only aspect of BPF_PROG_TYPE_CGROUP_SOCK filters that are namespace based is the ifindex. You brought up the example of changing namespaces where the ifindex is not defined. Alexei mentioned an example where interfaces can be moved to another namespace breaking any ifindex based programs. Another example is the interface can be deleted. Deleting an interface with sockets bound to it does not impact the program in any way - no notification, no wakeup, nothing. The sockets just don't work.

The point of using a management tool like ip is to handle the details to make things sane -- which is the consistent with the whole point of ip netns vs running unshare -n.

> 
> If the way cgroup+bpf worked was that a program did a prctl() or
> similar to opt in to being managed by a provided cgroup-aware BPF
> program, then I'd agree with everything you're saying.  But that's not
> at all how this code works.

I don't want an opt-in approach. The program does not need to know or even care that it has some restriction. Today, someone runs 'ip netns exec NAME COMMAND' the command does not need to know or care that the network namespace was changed on it. Same with 'ip vrf exec' -- it is a network policy that is forced on the program by the user.
