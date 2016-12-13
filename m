From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [PATCH v2] audit: use proper refcount locking on audit_sock
Date: Tue, 13 Dec 2016 00:10:28 -0500
Message-ID: <20161213051028.GE1305@madcap2.tricolour.ca>
References: <20161212100215.GA1305@madcap2.tricolour.ca>
 <5714bd7468cfec225407a6c367e658478d590495.1481534171.git.rgb@redhat.com>
 <CAHC9VhSjU+-KDSUcjHZAPEwCDbyLYGvkmXYcUqSfSsa1+=DsRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-audit@redhat.com, edumazet@google.com,
        xiyou.wangcong@gmail.com, dvyukov@google.com
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37642 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750703AbcLMFKc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Dec 2016 00:10:32 -0500
Content-Disposition: inline
In-Reply-To: <CAHC9VhSjU+-KDSUcjHZAPEwCDbyLYGvkmXYcUqSfSsa1+=DsRw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-12-12 15:18, Paul Moore wrote:
> On Mon, Dec 12, 2016 at 5:03 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> > Resetting audit_sock appears to be racy.
> >
> > audit_sock was being copied and dereferenced without using a refcount on
> > the source sock.
> >
> > Bump the refcount on the underlying sock when we store a refrence in
> > audit_sock and release it when we reset audit_sock.  audit_sock
> > modification needs the audit_cmd_mutex.
> >
> > See: https://lkml.org/lkml/2016/11/26/232
> >
> > Thanks to Eric Dumazet <edumazet@google.com> and Cong Wang
> > <xiyou.wangcong@gmail.com> on ideas how to fix it.
> >
> > Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
> > ---
> > There has been a lot of change in the audit code that is about to go
> > upstream to address audit queue issues.  This patch is based on the
> > source tree: git://git.infradead.org/users/pcmoore/audit#next
> > ---
> >  kernel/audit.c |   34 ++++++++++++++++++++++++++++------
> >  1 files changed, 28 insertions(+), 6 deletions(-)
> > diff --git a/kernel/audit.c b/kernel/audit.c
> > index f20eee0..439f7f3 100644
> > --- a/kernel/audit.c
> > +++ b/kernel/audit.c
> > @@ -452,7 +452,9 @@ static void auditd_reset(void)
> >         struct sk_buff *skb;
> >
> >         /* break the connection */
> > +       sock_put(audit_sock);
> >         audit_pid = 0;
> > +       audit_nlk_portid = 0;
> >         audit_sock = NULL;
> >
> >         /* flush all of the retry queue to the hold queue */
> > @@ -478,6 +480,12 @@ static int kauditd_send_unicast_skb(struct sk_buff *skb)
> >         if (rc >= 0) {
> >                 consume_skb(skb);
> >                 rc = 0;
> > +       } else {
> > +               if (rc & (-ENOMEM|-EPERM|-ECONNREFUSED)) {
> 
> I dislike the way you wrote this because instead of simply looking at
> this to see if it correct I need to sort out all the bits and find out
> if there are other error codes that could run afoul of this check ...
> make it simple, e.g. (rc == -ENOMEM || rc == -EPERM || ...).
> Actually, since EPERM is 1, -EPERM (-1 in two's compliment is
> 0xffffffff) is going to cause this to be true for pretty much any
> value of rc, yes?

Yes, you are correct.  We need there a logical or on the results of each
comparison to the return code rather than bit-wise or-ing the result
codes together first to save a step.

> > +                       mutex_lock(&audit_cmd_mutex);
> > +                       auditd_reset();
> > +                       mutex_unlock(&audit_cmd_mutex);
> > +               }
> 
> The code in audit#next handles netlink_unicast() errors in
> kauditd_thread() and you are adding error handling code here in
> kauditd_send_unicast_skb() ... that's messy.  I don't care too much
> where the auditd_reset() call is made, but let's only do it in one
> function; FWIW, I originally put the error handling code in
> kauditd_thread() because there was other error handling code that
> needed to done in that scope so it resulted in cleaner code.

Hmmm, I seem to remember it not returning the return code and I thought
I had changed it to do so, but I see now that it was already there.
Agreed, I needlessly duplicated that error handling.

> Related, I see you are now considering ENOMEM to be a fatal condition,
> that differs from the AUDITD_BAD macro in kauditd_thread(); this
> difference needs to be reconciled.

Also correct about -EPERM now that I check back to the intent of commit
32a1dbaece7e ("audit: try harder to send to auditd upon netlink
failure")

> Finally, you should update the comment header block for auditd_reset()
> that it needs to be called with the audit_cmd_mutex held.

Yup.

> > @@ -1004,17 +1018,22 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
> >                                 return -EACCES;
> >                         }
> >                         if (audit_pid && new_pid &&
> > -                           audit_replace(requesting_pid) != -ECONNREFUSED) {
> > +                           (audit_replace(requesting_pid) & (-ECONNREFUSED|-EPERM|-ENOMEM))) {
> 
> Do we simply want to treat any error here as fatal, and not just
> ECONN/EPERM/ENOMEM?  If not, let's come up with a single macro to
> handle the fatal netlink_unicast() return codes so we have some chance
> to keep things consistent in the future.

I'll work through this before I post another patch...

> paul moore

- RGB
