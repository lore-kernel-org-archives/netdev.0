From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 0/8] Switch BPF's digest to SHA256
Date: Tue, 10 Jan 2017 17:09:42 -0800
Message-ID: <20170111010940.GA74000@ast-mbp.thefacebook.com>
References: <cover.1484090585.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>
To: Andy Lutomirski <luto@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33363 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760354AbdAKBJx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 20:09:53 -0500
Content-Disposition: inline
In-Reply-To: <cover.1484090585.git.luto@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 03:24:38PM -0800, Andy Lutomirski wrote:
> I can imagine future uses for the new-in-4.10 BPF digest feature that
> would be problematic if malicious users could produce collisions, and
> SHA-1 is no longer consdiered to be collision-free.  Even without
> needing collision resistance, SHA-1 is no longer recommended for new
> applications.  Switch the BPF digest to SHA-256 instead.

Using this reasoning we must immediately change 'git' to use sha256
as well. malicious users are coming!
Seriously, NACK for bpf bits again, since you somehow missed
the reasons I gave earlier, here they are again:
.......
This statement is also bogus. The only reason we added prog_digest is
to improve debuggability and introspection of bpf programs.
As I said in the previous thread "collisions are ok" and we could have
used jhash here to avoid patches like this ever appearing
and wasting everyones time.

sha1 is 20 bytes which is already a bit long to print and copy paste by humans.
whereas 4 byte jhash is a bit too short, since collisions are not that rare
and may lead to incorrect assumptions from the users that develop the programs.
I would prefer something in 6-10 byte range that prevents collisions most of
the time and short to print as hex, but I don't know of anything like this
in the existing kernel and inventing bpf specific hash is not great.
Another requirement for debugging (and prog_digest) that user space
should be able to produce the same hash without asking kernel, so
sha1 fits that as well, since it's well known and easy to put into library.

sha256 doesn't fit either of these requirements. 32-bytes are too long to print
and when we use it as a substitue for the prog name for jited ksym, looking
at long function names will screw up all tools like perf, which we don't
want. sha256 is equally not easy for user space app like iproute2,
so not an acceptable choice from that pov either.
...........

tldr: I see only Cons for sha1->sha256 switch. Not a single Pro, hence
nack for bpf patches 4+
The patches 1-3 are nice and useful on their own.
