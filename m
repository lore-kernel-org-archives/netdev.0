From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH linux 2/2] net sched actions: fix refcount decrement on error
Date: Mon, 17 Apr 2017 11:10:57 -0700
Message-ID: <CAM_iQpVfCO+QCUFhkz=933bk4-pry6tDo6HxfUcwoVcjM4S7yA@mail.gmail.com>
References: <20170412142140.26649-1-w.bumiller@proxmox.com>
 <20170412142140.26649-3-w.bumiller@proxmox.com> <CAM_iQpUxgF2X9z+mNhBUtPJsFPy8pyiDDhqz726Qt_aeEeLpeA@mail.gmail.com>
 <20170413080648.bbiikladwevaribf@olga.proxmox.com> <CAM_iQpUWASuFdzLc6j+EyCj68=BnT6-bKXr=e=858Zkf9f6dSg@mail.gmail.com>
 <20170414090853.oqqdsu6xufr4n2nv@olga.proxmox.com> <CAM_iQpWSszPtMSG+vb+sowDcBeerWwufYARXmaiU-D4KJsyq8w@mail.gmail.com>
 <1985738840.18.1492282135309@webmail.proxmox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Roman Mashak <mrv@mojatatu.com>
To: Wolfgang Bumiller <w.bumiller@proxmox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1985738840.18.1492282135309@webmail.proxmox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 15, 2017 at 11:48 AM, Wolfgang Bumiller
<w.bumiller@proxmox.com> wrote:
>
>> On April 15, 2017 at 8:20 PM Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>
>>
>> On Fri, Apr 14, 2017 at 2:08 AM, Wolfgang Bumiller
>> <w.bumiller@proxmox.com> wrote:
>> > Before I do that - trying to wrap my head around the interdependencies
>> > here better to be thorough - I noticed that tcf_hash_release() can
>> > return ACT_P_DELETED. The ACT_P_CREATED case means tcf_hash_create()
>> > was used, in the other case the tc_action's ref & bind count is bumped
>> > by tcf_hash_check() and then also decremented by tcf_hash_release() if
>> > it existed, iow. kept at 1, but not always: It does always happen in
>> > act_police.c but in other files such as act_bpf.c or act_connmark.c if
>> > eg. bind is set they return without decrementing, so both ref&bind count
>> > are bumped when they return - the refcount logic isn't easy to follow
>> > for a newcomer. Now there are two uses of __tcf_hash_release() in
>> > act_api.c which check for a return value of ACT_P_DELETED, in which case
>> > they call module_put().
>>
>>
>> That's the nasty part... IIRC, Jamal has fixed two bugs on action refcnt'ing.
>> We really need to clean up the code.
>>
>> > So I'm not sure exactly how the module and tc_action counts are related
>> > (and I usually like to understand my own patches ;-) ).
>>
>>
>> Each action holds a refcnt to its module, each filter holds a refcnt to
>> its bound or referenced (unbound) action.
>>
>>
>> > Maybe I'm missing something obvious but I'm currently a bit confused as
>> > to whether the tcf_hash_release() call there is okay, or should have its
>> > return value checked or should depend on ->init()'s ACT_P_CREATED value
>> > as well?
>> >
>>
>> I think it's the same? If we have ACT_P_CREATED here, tcf_hash_release()
>> will return ACT_P_DELETED for sure because the newly created action has
>> refcnt==1?
>
> Makes sense on the one hand, but for ACT_P_DELETED both ref and bind
> count need to reach 0, so I'm still concerned that the different behaviors

Bind refcnt is only used when it is bound to a filter and refcnt is always used,
so either bind refcnt is 0 or it is same with refcnt.

> I mentioned above might be problematic if we use ACT_P_CREATED only.
> (It also means my patches still leak a count - which is probably still
> better than the previous underflow, but ultimately doesn't satisfy me.)
> Should I still resend it this way for the record with the Acked-bys?
> (Since given the fact that with unprivileged containers it's possible to
> trigger this access and potentially crash the kernel I strongly feel that
> some version of this should end up in the 4.11 release.)

I think so.

Thanks.
