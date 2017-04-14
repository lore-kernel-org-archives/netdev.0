From: Wolfgang Bumiller <w.bumiller@proxmox.com>
Subject: Re: [PATCH linux 2/2] net sched actions: fix refcount decrement on
 error
Date: Fri, 14 Apr 2017 11:08:53 +0200
Message-ID: <20170414090853.oqqdsu6xufr4n2nv@olga.proxmox.com>
References: <20170412142140.26649-1-w.bumiller@proxmox.com>
 <20170412142140.26649-3-w.bumiller@proxmox.com>
 <CAM_iQpUxgF2X9z+mNhBUtPJsFPy8pyiDDhqz726Qt_aeEeLpeA@mail.gmail.com>
 <20170413080648.bbiikladwevaribf@olga.proxmox.com>
 <CAM_iQpUWASuFdzLc6j+EyCj68=BnT6-bKXr=e=858Zkf9f6dSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>,
        Roman Mashak <mrv@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxmox.maurer-it.com ([212.186.127.180]:56816 "EHLO
        proxmox.maurer-it.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751838AbdDNJI4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 05:08:56 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpUWASuFdzLc6j+EyCj68=BnT6-bKXr=e=858Zkf9f6dSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 11:03:37AM -0700, Cong Wang wrote:
> On Thu, Apr 13, 2017 at 1:06 AM, Wolfgang Bumiller
> <w.bumiller@proxmox.com> wrote:
> > On Wed, Apr 12, 2017 at 09:27:31PM -0700, Cong Wang wrote:
> >> Instead of duplicating code, you can add the check
> >> to the module_put() next to err_mod label? I mean:
> >
> > I just realized that with module_put() happening in both error and
> > success cases if `err != ACT_P_CREATED`, we could just move that code up
> > to above the TCA_ACT_COOKIE handling?
> 
> Yes, even better.
> 
> > Btw., the comment confused me a little at first as I thought it's about
> > what happens in ->init(). But reading the code I then noticed the module
> > count is increased in tc_lookup_action_n() (which calls try_module_get)
> > in this functions and it's about how this function itself is supposed
> > to affect the count - if I'm not mistaken.
> > => so I think it makes sense to deal with this earlier.
> 
> Yes, the module reference count is not increased inside ->init(),
> it is because of the semantic of ->init(), it could create a new action
> or modify existing one, for the cast latter we need to rollback the
> refcount. Please feel free to update that comment to make it more
> clear, since you are already on it. ;)

Will do.

> 
> >
> > Otherwise I'd have to save `err != ACT_P_CREATED` in an additional
> > variable for the err_mod case since the cookie handling modifies `err`.
> >
> > What about this? (Since it's a separate issue not directly related to
> > patch 1 of the series I can send it as separate mail based on master if
> > you prefer - the diff below is based on master+patch1 for now.)
> >
> 
> Looks good, this could also address Roman's comment. Please remove
> the RFC tag and resend the whole series.
> 
> You can also add my:
> 
> Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Before I do that - trying to wrap my head around the interdependencies
here better to be thorough - I noticed that tcf_hash_release() can
return ACT_P_DELETED. The ACT_P_CREATED case means tcf_hash_create()
was used, in the other case the tc_action's ref & bind count is bumped
by tcf_hash_check() and then also decremented by tcf_hash_release() if
it existed, iow. kept at 1, but not always: It does always happen in
act_police.c but in other files such as act_bpf.c or act_connmark.c if
eg. bind is set they return without decrementing, so both ref&bind count
are bumped when they return - the refcount logic isn't easy to follow
for a newcomer. Now there are two uses of __tcf_hash_release() in
act_api.c which check for a return value of ACT_P_DELETED, in which case
they call module_put().
So I'm not sure exactly how the module and tc_action counts are related
(and I usually like to understand my own patches ;-) ).
Maybe I'm missing something obvious but I'm currently a bit confused as
to whether the tcf_hash_release() call there is okay, or should have its
return value checked or should depend on ->init()'s ACT_P_CREATED value
as well?
