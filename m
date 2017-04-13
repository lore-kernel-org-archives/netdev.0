From: Wolfgang Bumiller <w.bumiller@proxmox.com>
Subject: Re: [PATCH linux 2/2] net sched actions: fix refcount decrement on
 error
Date: Thu, 13 Apr 2017 10:06:48 +0200
Message-ID: <20170413080648.bbiikladwevaribf@olga.proxmox.com>
References: <20170412142140.26649-1-w.bumiller@proxmox.com>
 <20170412142140.26649-3-w.bumiller@proxmox.com>
 <CAM_iQpUxgF2X9z+mNhBUtPJsFPy8pyiDDhqz726Qt_aeEeLpeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpUxgF2X9z+mNhBUtPJsFPy8pyiDDhqz726Qt_aeEeLpeA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2017 at 09:27:31PM -0700, Cong Wang wrote:
> On Wed, Apr 12, 2017 at 7:21 AM, Wolfgang Bumiller
> <w.bumiller@proxmox.com> wrote:
> > If memory allocation for nla_memdup_cookie() fails
> > module_put has to be guarded by the same condition as it was
> > before the TCA_ACT_COOKIE has been added as stated in the
> > comment afterwards:
> >
> > /* module count goes up only when brand new policy is created
> >  * if it exists and is only bound to in a_o->init() then
> >  * ACT_P_CREATED is not returned (a zero is).
> >  */
> 
> Yeah, this patch makes sense for me too. Just one comment below.
> 
> >
> > Signed-off-by: Wolfgang Bumiller <w.bumiller@proxmox.com>
> > ---
> >
> > Note that I'm unsure about this patch. The hangups weren't very reliable
> > and I couldn't actually reproduce them when building from git/master (as
> > I can only test a fraction of my usual workload with it as a lot of my
> > data (VMs & containers utilizing veths and tap devices) is on ZFS...).
> > In any case it can't harm to take another look at the error handling
> > here.
> >
> >  net/sched/act_api.c | 12 ++++++++----
> >  1 file changed, 8 insertions(+), 4 deletions(-)
> >
> > diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> > index 8cc883c063f0..795ac092b723 100644
> > --- a/net/sched/act_api.c
> > +++ b/net/sched/act_api.c
> > @@ -608,15 +608,19 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
> >                 int cklen = nla_len(tb[TCA_ACT_COOKIE]);
> >
> >                 if (cklen > TC_COOKIE_MAX_SIZE) {
> > -                       err = -EINVAL;
> >                         tcf_hash_release(a, bind);
> > -                       goto err_mod;
> > +                       if (err != ACT_P_CREATED)
> > +                               module_put(a_o->owner);
> > +                       err = -EINVAL;
> > +                       goto err_out;
> >                 }
> >
> >                 if (nla_memdup_cookie(a, tb) < 0) {
> > -                       err = -ENOMEM;
> >                         tcf_hash_release(a, bind);
> > -                       goto err_mod;
> > +                       if (err != ACT_P_CREATED)
> > +                               module_put(a_o->owner);
> > +                       err = -ENOMEM;
> > +                       goto err_out;
> 
> Instead of duplicating code, you can add the check
> to the module_put() next to err_mod label? I mean:

I just realized that with module_put() happening in both error and
success cases if `err != ACT_P_CREATED`, we could just move that code up
to above the TCA_ACT_COOKIE handling?
Btw., the comment confused me a little at first as I thought it's about
what happens in ->init(). But reading the code I then noticed the module
count is increased in tc_lookup_action_n() (which calls try_module_get)
in this functions and it's about how this function itself is supposed
to affect the count - if I'm not mistaken.
=> so I think it makes sense to deal with this earlier.

Otherwise I'd have to save `err != ACT_P_CREATED` in an additional
variable for the err_mod case since the cookie handling modifies `err`.

What about this? (Since it's a separate issue not directly related to
patch 1 of the series I can send it as separate mail based on master if
you prefer - the diff below is based on master+patch1 for now.)

-- 8< --
Subject: [PATCH net v2] net sched actions: decrement module refcount earlier

Whether the reference count has to be decremented depends
on whether the policy was created. If TCA_ACT_COOKIE is
passed and an error occurs there, the same condition still
has to be honored.

Signed-off-by: Wolfgang Bumiller <w.bumiller@proxmox.com>
---
 net/sched/act_api.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 8cc883c063f0..7d920ef83a07 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -604,28 +604,29 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 	if (err < 0)
 		goto err_mod;
 
+	/* module count goes up only when brand new policy is created
+	 * if it exists and is only bound to in a_o->init() then
+	 * ACT_P_CREATED is not returned (a zero is).
+	 */
+	if (err != ACT_P_CREATED)
+		module_put(a_o->owner);
+
 	if (name == NULL && tb[TCA_ACT_COOKIE]) {
 		int cklen = nla_len(tb[TCA_ACT_COOKIE]);
 
 		if (cklen > TC_COOKIE_MAX_SIZE) {
 			err = -EINVAL;
 			tcf_hash_release(a, bind);
-			goto err_mod;
+			goto err_out;
 		}
 
 		if (nla_memdup_cookie(a, tb) < 0) {
 			err = -ENOMEM;
 			tcf_hash_release(a, bind);
-			goto err_mod;
+			goto err_out;
 		}
 	}
 
-	/* module count goes up only when brand new policy is created
-	 * if it exists and is only bound to in a_o->init() then
-	 * ACT_P_CREATED is not returned (a zero is).
-	 */
-	if (err != ACT_P_CREATED)
-		module_put(a_o->owner);
 
 	return a;
 
-- 
2.11.0
