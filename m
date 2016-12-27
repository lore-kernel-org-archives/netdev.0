From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH 4.10 3/6] bpf: Use SHA256 instead of SHA1 for bpf
 digests
Date: Mon, 26 Dec 2016 17:36:46 -0800
Message-ID: <20161227013644.GA96815@ast-mbp.thefacebook.com>
References: <cover.1482545792.git.luto@kernel.org>
 <bbfd69226fd74391045bafc695bba9a46cacca85.1482545792.git.luto@kernel.org>
 <585ED3B9.6020407@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@kernel.org>, Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35245 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751022AbcL0Bgw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2016 20:36:52 -0500
Content-Disposition: inline
In-Reply-To: <585ED3B9.6020407@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 24, 2016 at 08:59:53PM +0100, Daniel Borkmann wrote:
> On 12/24/2016 03:22 AM, Andy Lutomirski wrote:
> >BPF digests are intended to be used to avoid reloading programs that
> >are already loaded.  For use cases (CRIU?) where untrusted programs
> >are involved, intentional hash collisions could cause the wrong BPF
> >program to execute.  Additionally, if BPF digests are ever used
> >in-kernel to skip verification, a hash collision could give privilege
> >escalation directly.
> 
> Just for the record, digests will never ever be used to skip the
> verification step, so I don't know why this idea even comes up
> here (?) or is part of the changelog? As this will never be done
> anyway, rather drop that part so we can avoid confusion on this?

+1 to what Daniel said above.

For the others let me explain what this patch set is actually
trying to accomplish.
Andy had an idea that sha256 of the program can somehow be used
to bypass kernel verifier during program loading. Furthemore
he thinks that such 'bypass' would be useful for criu of bpf programs,
hence see vigorously attacking existing prog_digest (sha1) because
it's not as secure as sha256 and hence cannot be used for such 'bypass'.

The problem with criu of bpf programs is same as criu of kernel modules.
For the main tracing and networking use cases, we cannot stop the kernel,
so criu is out of question already.
Even if we could stop all the events that trigger bpf program execution,
the sha256 or memcmp() of the full program is not enough to guarantee
that two programs are the same.
Ex. bpf_map_lookup() may be safe for one program and not for another
depending on how map was created. Two programs of different types
are not comparable either. Etc, etc.
Therefore the idea of using sha256 for such purpose is bogus,
and I have an obvious NACK for bpf related patches 3,4,5,6.

For the questions raised in other threads:
I'm not ok with making BPF depend on CRYPTO, since it's the same as
requiring CRYPTO to select BPF for no good reason.

And 0/6 commit log:
> Since there are plenty of uses for the new-in-4.10 BPF digest feature
> that would be problematic if malicious users could produce collisions,
> the BPF digest should be collision-resistant. 

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
