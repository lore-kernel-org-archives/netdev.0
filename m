From: Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [kernel-hardening] Re: [RFC][PATCH] nfsd: add +1 to reference
 counting scheme for struct nfsd4_session
Date: Wed, 15 Feb 2017 11:45:05 -0500
Message-ID: <20170215164505.GA14912@fieldses.org>
References: <1486625901-10094-1-git-send-email-dwindsor@gmail.com>
 <CAEXv5_jUa8Av4JABoKSAueiLHSLzibMvaE-8DrVcxZHFceckMg@mail.gmail.com>
 <20170213105422.snaw65btejr3vsdi@ishxps>
 <CAEXv5_hP39k7HSLP-G_khx7MMQHnk=8Z5caa+U5n3bYvUTE1gQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org,
        Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        "Reshetova, Elena" <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAEXv5_hP39k7HSLP-G_khx7MMQHnk=8Z5caa+U5n3bYvUTE1gQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 13, 2017 at 06:46:19AM -0500, David Windsor wrote:
> On Mon, Feb 13, 2017 at 5:54 AM, Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > On Sat, Feb 11, 2017 at 01:42:53AM -0500, David Windsor wrote:
> >>
> >> <snip>
> >>
> >>> Signed-off-by: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >>> ---
> >>>  fs/nfsd/nfs4state.c | 6 +++---
> >>>  1 file changed, 3 insertions(+), 3 deletions(-)
> >>>
> >>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >>> index a0dee8a..b0f3010 100644
> >>> --- a/fs/nfsd/nfs4state.c
> >>> +++ b/fs/nfsd/nfs4state.c
> >>> @@ -196,7 +196,7 @@ static void nfsd4_put_session_locked(struct
> >>> nfsd4_session *ses)
> >>>
> >>>         lockdep_assert_held(&nn->client_lock);
> >>>
> >>> -       if (atomic_dec_and_test(&ses->se_ref) && is_session_dead(ses))
> >>> +       if (!atomic_add_unless(&ses->se_ref, -1, 1) &&
> >>> is_session_des(ses))
> >>
> >>
> >> This should read:
> >> if (!atomic_add_unless(&ses->se_ref, -1, 1) && is_session_dead(ses))
> >>
> >>>                 free_session(ses);
> >
> >
> > Hi,
> > I'm not sure if I have this correctly; But both before and after the patch
> > free_session gets called when se_ref count was 1, shouldn't this have
> > changed with the +1 scheme?
> >
> > Also, since the !atomic_add_unless doesn't actually decrement when at 1,
> > doesn't this leave the se_ref as 1 when it's destroyed? The function seems
> > to always be locked, so perhaps this doesn't matter, but still seems a bit
> > risky.
> >
> 
> Yes; I forgot the additional call to atomic_dec_and_test() before
> free_session().  Thanks!
> 
> I'll resubmit this after seeing how the rest of this discussion goes.
> We may end up abandoning this refcounting case.

I could live with it.

My knee jerk reaction is like Jeff's--it just seems more natural to me
for reference count 0 to mean "not in use, OK to free" in cases like
this--but maybe I just need to get used to the idea.

It'd be interesting to see what the final result looks like after
conversion to refcount_t.

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
