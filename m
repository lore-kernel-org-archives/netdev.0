From: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH] nfsd: add +1 to reference counting scheme for struct nfsd4_session
Date: Sat, 11 Feb 2017 09:01:15 -0500
Message-ID: <CAEXv5_gd7F-eaazzU1BWPzH4huhEcO1Y-FWov5UP9T+6R+fv-A@mail.gmail.com>
References: <1486625901-10094-1-git-send-email-dwindsor@gmail.com>
 <CAEXv5_jUa8Av4JABoKSAueiLHSLzibMvaE-8DrVcxZHFceckMg@mail.gmail.com> <1486816302.4233.29.camel@poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org,
        Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        "Reshetova, Elena" <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1486816302.4233.29.camel-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 11, 2017 at 7:31 AM, Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org> wrote:
> On Sat, 2017-02-11 at 01:42 -0500, David Windsor wrote:
>> <snip>
>>
>> > Signed-off-by: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> > ---
>> >  fs/nfsd/nfs4state.c | 6 +++---
>> >  1 file changed, 3 insertions(+), 3 deletions(-)
>> >
>> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> > index a0dee8a..b0f3010 100644
>> > --- a/fs/nfsd/nfs4state.c
>> > +++ b/fs/nfsd/nfs4state.c
>> > @@ -196,7 +196,7 @@ static void nfsd4_put_session_locked(struct nfsd4_session *ses)
>> >
>> >         lockdep_assert_held(&nn->client_lock);
>> >
>> > -       if (atomic_dec_and_test(&ses->se_ref) && is_session_dead(ses))
>> > +       if (!atomic_add_unless(&ses->se_ref, -1, 1) && is_session_des(ses))
>>
>> This should read:
>> if (!atomic_add_unless(&ses->se_ref, -1, 1) && is_session_dead(ses))
>>
>> >                 free_session(ses);
>> >         put_client_renew_locked(clp);
>> >  }
>> > @@ -1645,7 +1645,7 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
>> >         new->se_flags = cses->flags;
>> >         new->se_cb_prog = cses->callback_prog;
>> >         new->se_cb_sec = cses->cb_sec;
>> > -       atomic_set(&new->se_ref, 0);
>> > +       atomic_set(&new->se_ref, 1);
>> >         idx = hash_sessionid(&new->se_sessionid);
>> >         list_add(&new->se_hash, &nn->sessionid_hashtbl[idx]);
>> >         spin_lock(&clp->cl_lock);
>> > @@ -1792,7 +1792,7 @@ free_client(struct nfs4_client *clp)
>> >                 ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
>> >                                 se_perclnt);
>> >                 list_del(&ses->se_perclnt);
>> > -               WARN_ON_ONCE(atomic_read(&ses->se_ref));
>> > +               WARN_ON_ONCE((atomic_read(&ses->se_ref) > 1));
>> >                 free_session(ses);
>> >         }
>> >         rpc_destroy_wait_queue(&clp->cl_cb_waitq);
>> > --
>> > 2.7.4
>> >
>
> The basic idea here is that nfsv4 sessions have a "resting state" of 0.
> We want to keep them around, but if they go "dead" then we we'll tear
> them down if they aren't actively in use at the time. So, we still free
> the thing when the refcount goes to zero, but we have an extra condition
> before we free it on the put -- that the session is also "dead" (meaning
> that the client asked us to destroy it).
>
> Your patch doesn't look like it'll break anything, but I personally find
>  it harder to follow that way. The freeable reference state will be 1
> instead of the normal 0.
>

I'm not sure there's another way to accomplish what we need
(initializing struct nfsd4_session objects with refcount=1) without
also modifying the freeable reference state.  After migrating to the
refcount_t API, if we leave init_session() as is, the first call to
nfsd4_get_session_locked() will fail:

static __be32 nfsd4_get_session_locked(struct nfsd4_session *ses)
{
         __be32 status;

         if (is_session_dead(ses))
                 return nfserr_badsession;
         status = get_client_locked(ses->se_client);
         if (status)
                 return status;
         refcount_inc(&ses->se_ref);    /* This fails and WARNS when
ses->se_ref is 0. */
         return nfs_ok;
}


The refcount_t API patches aren't yet merged, so this discussion is a
bit limited in that respect, but refcount_inc() WARNS when called with
a refcount_t object whose value is 0, as this may represent a
use-after-free attempt.

Given this, I'm unsure how it's possible to achieve initialization of
struct nfsd4_session objects with refcount=1 while still maintaining
these objects' "rest state" at refcount=0.

> --
> Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
