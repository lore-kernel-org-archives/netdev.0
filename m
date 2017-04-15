From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH linux 2/2] net sched actions: fix refcount decrement on error
Date: Sat, 15 Apr 2017 11:20:54 -0700
Message-ID: <CAM_iQpWSszPtMSG+vb+sowDcBeerWwufYARXmaiU-D4KJsyq8w@mail.gmail.com>
References: <20170412142140.26649-1-w.bumiller@proxmox.com>
 <20170412142140.26649-3-w.bumiller@proxmox.com> <CAM_iQpUxgF2X9z+mNhBUtPJsFPy8pyiDDhqz726Qt_aeEeLpeA@mail.gmail.com>
 <20170413080648.bbiikladwevaribf@olga.proxmox.com> <CAM_iQpUWASuFdzLc6j+EyCj68=BnT6-bKXr=e=858Zkf9f6dSg@mail.gmail.com>
 <20170414090853.oqqdsu6xufr4n2nv@olga.proxmox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>,
        Roman Mashak <mrv@mojatatu.com>
To: Wolfgang Bumiller <w.bumiller@proxmox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170414090853.oqqdsu6xufr4n2nv@olga.proxmox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 14, 2017 at 2:08 AM, Wolfgang Bumiller
<w.bumiller@proxmox.com> wrote:
> Before I do that - trying to wrap my head around the interdependencies
> here better to be thorough - I noticed that tcf_hash_release() can
> return ACT_P_DELETED. The ACT_P_CREATED case means tcf_hash_create()
> was used, in the other case the tc_action's ref & bind count is bumped
> by tcf_hash_check() and then also decremented by tcf_hash_release() if
> it existed, iow. kept at 1, but not always: It does always happen in
> act_police.c but in other files such as act_bpf.c or act_connmark.c if
> eg. bind is set they return without decrementing, so both ref&bind count
> are bumped when they return - the refcount logic isn't easy to follow
> for a newcomer. Now there are two uses of __tcf_hash_release() in
> act_api.c which check for a return value of ACT_P_DELETED, in which case
> they call module_put().


That's the nasty part... IIRC, Jamal has fixed two bugs on action refcnt'ing.
We really need to clean up the code.

> So I'm not sure exactly how the module and tc_action counts are related
> (and I usually like to understand my own patches ;-) ).


Each action holds a refcnt to its module, each filter holds a refcnt to
its bound or referenced (unbound) action.


> Maybe I'm missing something obvious but I'm currently a bit confused as
> to whether the tcf_hash_release() call there is okay, or should have its
> return value checked or should depend on ->init()'s ACT_P_CREATED value
> as well?
>

I think it's the same? If we have ACT_P_CREATED here, tcf_hash_release()
will return ACT_P_DELETED for sure because the newly created action has
refcnt==1?

Thanks.
