From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/2] net sched act_vlan: VLAN action rewrite to
 use RCU lock/unlock and update
Date: Wed, 11 Oct 2017 22:41:00 +0200
Message-ID: <20171011204100.GB9297@nanopsycho>
References: <1507689219-22993-1-git-send-email-manish.kurup@verizon.com>
 <CAM_iQpUYGUzvvM3Weaw5ertgVpwn0p9j6B5xd5Ar5ysJwrdVvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Manish Kurup <kurup.manish@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexander Aring <aring@mojatatu.com>,
        Roman Mashak <mrv@mojatatu.com>, manish.kurup@verizon.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpUYGUzvvM3Weaw5ertgVpwn0p9j6B5xd5Ar5ysJwrdVvg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Oct 11, 2017 at 06:27:07PM CEST, xiyou.wangcong@gmail.com wrote:
>On Tue, Oct 10, 2017 at 7:33 PM, Manish Kurup <kurup.manish@gmail.com> wrote:

[...]


>> @@ -187,16 +196,33 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
>>
>>         v = to_vlan(*a);
>>
>> -       spin_lock_bh(&v->tcf_lock);
>> -
>> -       v->tcfv_action = action;
>> -       v->tcfv_push_vid = push_vid;
>> -       v->tcfv_push_prio = push_prio;
>> -       v->tcfv_push_proto = push_proto;
>> +       ASSERT_RTNL();
>> +       p = kzalloc(sizeof(*p), GFP_KERNEL);
>> +       if (unlikely(!p)) {
>> +               if (ovr)
>> +                       tcf_idr_release(*a, bind);
>> +               return -ENOMEM;
>> +       }
>>
>>         v->tcf_action = parm->action;
>>
>> -       spin_unlock_bh(&v->tcf_lock);
>> +       p_old = rtnl_dereference(v->vlan_p);
>> +
>> +       if (ovr)
>> +               spin_lock_bh(&v->tcf_lock);
>
>Why still take spinlock when you already have RTNL lock?
>What's the point?

Yeah, I believe this is copy&paste bug from act_skbmod
