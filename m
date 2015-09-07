From: Eric Van Hensbergen <ericvh@gmail.com>
Subject: Re: [V9fs-developer] [PATCH] 9p: trans_fd, initialize recv fcall
 properly if not set
Date: Mon, 7 Sep 2015 09:09:34 -0500
Message-ID: <CAFkjPT=O_VJffFdoSq-iXwnSs+ewj6chWvGZ9yJ+MLWV4u=O2g@mail.gmail.com>
References: <1441273129-20185-1-git-send-email-dominique.martinet@cea.fr>
 <CAFkjPT=1TAq5S_TBgKa_UyGs2CfhDKOWEqc9HyhKHw89vO_ZOQ@mail.gmail.com> <20150906065540.GA2121@nautica>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Latchesar Ionkov <lucho@ionkov.net>,
	V9FS Developers <v9fs-developer@lists.sourceforge.net>,
	netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Ron Minnich <rminnich@sandia.gov>
To: Dominique Martinet <dominique.martinet@cea.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150906065540.GA2121@nautica>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I thought the nature of trans_fd would have prevented any sort of true
zero copy, but I suppose one less is always welcome :)

        -eric


On Sun, Sep 6, 2015 at 1:55 AM, Dominique Martinet
<dominique.martinet@cea.fr> wrote:
> Eric Van Hensbergen wrote on Sat, Sep 05, 2015:
>> On Thu, Sep 3, 2015 at 4:38 AM, Dominique Martinet
>> <dominique.martinet@cea.fr> wrote:
>> > To be honest, I think it might be better to just bail out if we get in
>> > this switch (m->req->rc == NULL after p9_tag_lookup) and not try to
>> > allocate more, because if we get there it's likely a race condition and
>> > silently re-allocating will end up in more troubles than trying to
>> > recover is worth.
>> > Thoughts ?
>> >
>>
>> Hmmm...trying to rattle my brain and remember why I put it in there
>> back in 2008.
>> It might have just been over-defensive programming -- or more likely it just
>> pre-dated all the zero copy infrastructure which pretty much guaranteed we had
>> an rc allocated and what is there is vestigial.  I'm happy to accept a
>> patch which
>> makes this an assert, or perhaps just resets the connection because something
>> has gone horribly wrong (similar to the ENOMEM path that is there now).
>
> Yeah, it looks like the safety comes from the zero-copy stuff that came
> much later.
> Let's go with resetting the connection then. Hmm. EIO is a bit too
> generic so would be good to avoid that if possible, but can't think of
> anything better...
>
>
> Speaking of zero-copy, I believe it should be fairly straight-forward to
> implement for trans_fd now I've actually looked at it, since we do the
> payload read after a p9_tag_lookup, would just need m->req to point to a
> zc buffer. Write is similar, if there's a zc buffer just send it after
> the header.
> The cost is a couple more pointers in req and an extra if in both
> workers, that seems pretty reasonable.
>
> Well, I'm not using trans_fd much here (and unfortunately zero-copy
> isn't possible at all given the transport protocol for RDMA, at least
> for recv), but if anyone cares it probably could be done without too
> much hassle for the fd workers.
>
> --
> Dominique
