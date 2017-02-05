From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Sat, 4 Feb 2017 20:37:18 -0800
Message-ID: <20170205043716.GI73775@ast-mbp.thefacebook.com>
References: <CALCETrXgdY_Kt8wn4uiATUnNJ3YXttCUREgEeQReG7u29Lc44g@mail.gmail.com>
 <588A4D3C.9070601@fb.com>
 <87r33fevva.fsf@xmission.com>
 <CALCETrWDxVHc4_hpjLQRj-XbvGX0+tbGZ8o388-xn6rNcQTySQ@mail.gmail.com>
 <20170203230830.GC26227@ast-mbp.thefacebook.com>
 <CALCETrUb1Rf-BdSTHdKSgwnftHjpmcDt1HX1KX-cpN=N7ev+eg@mail.gmail.com>
 <20170205031045.GC73775@ast-mbp.thefacebook.com>
 <CALCETrUhE_Ga4PeobPFvhtLPVGKskTUaXe9H0v=kBXe4ii7dLw@mail.gmail.com>
 <20170205034839.GG73775@ast-mbp.thefacebook.com>
 <CALCETrXgBrWmWFghWxtV92RDvqYBHsT-L37ujvexyA6v+3M8sQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Alexei Starovoitov <ast@fb.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36820 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751636AbdBEEhZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 23:37:25 -0500
Received: by mail-pf0-f195.google.com with SMTP id 19so4421841pfo.3
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 20:37:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALCETrXgBrWmWFghWxtV92RDvqYBHsT-L37ujvexyA6v+3M8sQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 04, 2017 at 07:54:20PM -0800, Andy Lutomirski wrote:
>
> I've repeatedly asked how you plan to make a "don't override" flag
> have sensible semantics when someone tries to add a new flag or change
> the behavior to "don't override but, rather then rejecting programs
> down the hierarchy, just run them all".  You haven't answered that
> question.

I explained already that I need to do combining on the bpf side instead
of running the list, since running several programs where 90% of
the logic is the same is the overhead that is not acceptable
for production server. It may be fine for desktop, but not
when every cycle matters. With one program per cgroup I can
combine multiple of them on bpf side. In networking the most of
the prep work like packet parsing and lookups are common,
but the actions are different, so for one part of the hieararchy
I can have program A monitoring tcp and in other
part I can have program B monitoring tcp and udp.
What you're saying that for tcp and udp monitoring
run two programs. One for udp and one for tcp.
That is not efficient. Hence the need to combine
the programs on bpf side and attach only one with override.

The "dont override flag" was also explained before. Here it is again:
Without breaking above "override" scenario we can add a flag
that when the program is attached with that flag to one part of
the hierarchy the override of it will not be allowed in the descendent.
This extension can be done at any time in the future.
The only question is what is the default when such flag
is not present. The current default is override allowed.
You insist on changing the default right now.
I don't mind, therefore I'm working on such "dont override flag",
since if we need to change the default it needs to be done now,
but if it doesn't happen for 4.10, it's absolutely fine too.
For security use cases the flag will be added later
and sandboxing use cases will use that flag too.
There are no expections that if cgroup is there the program
attach command must always succeed. That's why we have error codes
and we can dissallow attach based on this flag or any future
restrictions. All of it is root now anyway and sandboxing/security
use cases need to wait until bpf side can be made unprivileged.
I see current api to have a ton of room for future extensions.

> Given that we're doing API design and it's waaaaay past the merge
> window, I just don't see how any of this is ready for 4.10.

We are NOT doing design now. Design and implementation was
done back last summer. It took many interations and lots
of discussions on public lists with netdev and cgroup lists cc-ed.
