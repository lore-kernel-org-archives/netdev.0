From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: Re: [PATCH] net/packet: fix race condition between fanout_add and __unregister_prot_hook
Date: Tue, 19 Sep 2017 12:12:38 -0400
Message-ID: <CAF=yD-JN_NLxY-eB1oGZ-BeYgnPhhROBzSxj_CWRShY=SugW3Q@mail.gmail.com>
References: <E490CD805F7529488761C40FD9D26EF1299D0CAD@DGGEMA505-MBX.china.huawei.com>
 <CAF=yD-+kG8HHwtL55dRh+mayA+1W0iy7WRRK0uyHfkiX=woH_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "edumazet@google.com" <edumazet@google.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nixiaoming <nixiaoming@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAF=yD-+kG8HHwtL55dRh+mayA+1W0iy7WRRK0uyHfkiX=woH_A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 19, 2017 at 12:09 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> On Tue, Sep 19, 2017 at 3:21 AM, Nixiaoming <nixiaoming@huawei.com> wrote:
>> On Fri, Sep 15, 2017 at 10:46 AM, Willem de Bruijn
>>
>> <willemdebruijn.kernel@gmail.com> wrote:
>>
>>>
>>
>>> In case of failure we also need to unlink and free match. I
>>
>>> sent the following:
>>
>>>
>>
>>> http://patchwork.ozlabs.org/patch/813945/
>>
>>
>>
>> +       spin_lock(&po->bind_lock);
>>
>> +       if (po->running &&
>>
>> +           match->type == type &&
>>
>>            match->prot_hook.type == po->prot_hook.type &&
>>
>>            match->prot_hook.dev == po->prot_hook.dev) {
>>
>>                 err = -ENOSPC;
>>
>> @@ -1761,6 +1760,13 @@  static int fanout_add(struct sock *sk, u16 id, u16
>> type_flags)
>>
>>                           err = 0;
>>
>>                 }
>>
>>        }
>>
>> +       spin_unlock(&po->bind_lock);
>>
>> +
>>
>> +       if (err && !refcount_read(&match->sk_ref)) {
>>
>> +                list_del(&match->list);
>>
>> +                kfree(match);
>>
>> +       }
>>
>>
>>
>>
>>
>> In the function fanout_add add spin_lock to protect po-> running and po->
>> fanout,
>>
>> then whether it should be in the function fanout_release also add spin_lock
>> protection ?
>
> po->bind_lock is held when registering and unregistering the
> protocol hook. fanout_release does access po->running or
> prot_hook.

whoops. does *not* access.
