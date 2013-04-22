From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 1/2] genl: Allow concurrent genl callbacks.
Date: Mon, 22 Apr 2013 13:41:41 -0700
Message-ID: <CALnjE+pwo5_j8ChPEHGXWT2kc1U3mVE99xc=XDtp6XtPOytKGA@mail.gmail.com>
References: <1366320646-16903-1-git-send-email-pshelar@nicira.com>
	<20130422.161812.1075030033926378895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:47704 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755140Ab3DVUlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 16:41:45 -0400
Received: by mail-qc0-f198.google.com with SMTP id v20so10652063qcm.1
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 13:41:41 -0700 (PDT)
In-Reply-To: <20130422.161812.1075030033926378895.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 22, 2013 at 1:18 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Thu, 18 Apr 2013 14:30:46 -0700
>
>> All genl callbacks are serialized by genl-mutex. This can become
>> bottleneck in multi threaded case.
>> Following patch adds an parameter to genl_family so that a
>> particular family can get concurrent netlink callback without
>> genl_lock held.
>> New rw-sem is used to protect genl callback from genl family unregister.
>> in case of lockless genl-family read-lock is taken for callbacks and
>> write lock is taken for register or unregistration for any family.
>> In case of locked genl family semaphore and gel-mutex is locked for
>> any openration.
>>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
> I don't think you can do this.
>
> Dumps happen in several passes, and the dumps keep track of where
> we are in the dump by using a scratchpad in the SKB.  That means
> we have state that must stay sane across several dump invocations.
>
Sorry for confusion, GENL still have netlink lock to protect dump operation
(nlk->cb_mutex). With this change that mutex is changed from global
genl_lock to per
socket lock by changing netlink_kernel_cfg in genl_pernet_init().
Therefore scatchpad in SKB is protected and parallel netlink dump operations
can go only on different netlink sockets.

> This means we have to keep out set operations while the dump is
> happening.
>
> That means we have to hold a mutex over all configurations changes.
>
right, Thats why I have introduced new rw-sem. Read lock is taken for all
callback and dump operations and all configuration changes
needs write lock on the semaphore. So that it is mutually exclusive.

Let me know if I am missing something.

> I do not like this change, and don't intend to apply it nor the
> openvswitch stuff.
>
> If you don't like my position, get one of the netlink experts to
> chime in since none of them have reviewed this stuff yet.
