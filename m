From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch] mqueue: fix the retry logic for netlink_attachskb()
Date: Sun, 9 Jul 2017 12:57:21 -0700
Message-ID: <CAM_iQpXP0wtFdyuQ+Z6t0ftnqo6nbR_MoKFHNBOw5Yt4qZh8qA@mail.gmail.com>
References: <1499452335-3478-1-git-send-email-xiyou.wangcong@gmail.com>
 <CA+55aFxNtoGV=Ly5X-T2n9YzV31sm+i33b+wjs-Qrsybbe1Saw@mail.gmail.com>
 <CAM_iQpX2+sq9Czwk4qiwDH5JdvTjDxLtoCj56iSHgEpUPo=uzQ@mail.gmail.com> <CA+55aFzzUgWjQmP2hVD_ZWHuRDLXZFU8mf6W2jHPs+ysLOCOCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Gene Blue <geneblue.mail@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Manfred Spraul <manfred@colorfullife.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFzzUgWjQmP2hVD_ZWHuRDLXZFU8mf6W2jHPs+ysLOCOCQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 8, 2017 at 11:55 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Sat, Jul 8, 2017 at 11:04 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>
>>> Can you confirm that? I don't know where the original report is.
>>
>> Yes of course, setting 'sock' to NULL before 'goto retry' is sufficient
>> to fix it, that is in fact my initial thought. And I realized retry'ing
>> fdget() can't help anything in this situation but increases the
>> attack vector, so I decided to get rid of it from the retry loop
>> instead of just NULL'ing 'sock'.
>>
>> Or do you prefer the simpler fix? Or should I just resend it with
>> a improved changelog?
>
> It was just the combination of that nasty code, your patch, and the
> explanation that confused me.
>
> Reading the patch, I actually thought that one of the things you fixed
> was moving the "fdput()" later, to after the netlink_attachskb().
>
> And I thought you did that because netlink_attachskb() would need the
> file to be still around keeping a reference count to the socket, and
> without it the socket could have been dropped in the meantime.
>
> But reading the code more closely, I notice that
> netlink_getsockbyfilp() gets a reference to the sock, and it's that
> netlink_attachskb() will drop that reference on error or retry.
>
> So the fdput() makes sense after netlink_getsockbyfilp(), but that's
> also why the retry code currently includes repeating the fdget()...
> And the error handling for the fdget is that then triggers the real
> bug.
>
> So the reason you moved the fdput() later wasn't to protect the socket
> reference, it was just because of how the whole retry loop needs to
> have the file descriptor just to get a new reference to the socket.
>
> That's why I thought you fixed a bug even in the first iteration, but
> it turns out that was just me making assumptions based on mis-reading
> the patch without looking at all the context and the logic of the
> called functions.
>
> Now that I have checked deeper, I realize that your patch description
> was actually correct about this only being a retry problem - the first
> time around the reference count ends up moving correctly from file to
> socket, but then when it repeats and 'sock' may contain a stale
> pointer, we may end up doing the wrong thing when the fdget fails.
>
> Honestly, now I feel like either patch is fine, and your original
> commit message is fine too - but I just hate that code.
>
> And making it use some nice helper function to clean it up looks
> painful too, because the error handling is so odd (ie
> mq_netlink_attachskb() will free the skb on error, while the other
> error cases won't, so you'd have to have some special handling for the
> different errors that can happen).
>
> Honestly, this code is nasty, and right now my feeling is that it
> would be good to have a minimal patch that also backports cleanly.
> Maybe somebody can clean it up later, but that's a separate windmill
> to rail against.


Indeed, I spent a few hours to spot this bug, to be honest. ;) We can
always clean up things later.

>
> And due to the recent compat cleanups by Al, your bigger patch does
> not apply cleanly to current git - but the smaller patch to just
> setting 'sock' to NULL before that 'goto retry' should apply cleanly
> to all versions of this code.

Ah, understood, probably because I don't pull your branch so often
but now we are still in merge window...

>
> So purely because of that reason, I think I'd prefer to see that
> smaller patch instead. Would you mind re-sending the thing?

Sure, I will rebase and send the simpler fix.

>
> Sorry about the whole confusion.
>

No worries. Thanks for all the details!
