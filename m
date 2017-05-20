From: Ivan Vecera <cera@cera.cz>
Subject: Re: [PATCH net-next v2] bridge: fix hello and hold timers
	starting/stopping
Date: Sat, 20 May 2017 09:06:16 +0200
Message-ID: <CA+Nub0aY6hjWeg8h2Qgx_c+yazh5WnA1u0D8bDtxChjWXsEHSw@mail.gmail.com>
References: <20170519173043.10201-1-cera@cera.cz>
	<20170520055720.GA12974@leo.usersys.redhat.com>
Reply-To: ivan.vecera@cera.cz
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Xin Long <lucien.xin@gmail.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	network dev <netdev@vger.kernel.org>, bridge@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170520055720.GA12974@leo.usersys.redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

2017-05-20 7:57 GMT+02:00 Hangbin Liu <liuhangbin@gmail.com>:
> On Fri, May 19, 2017 at 07:30:43PM +0200, Ivan Vecera wrote:
>> Current bridge code incorrectly handles starting/stopping of hello and
>> hold timers during STP enable/disable.
>>
>> 1. Timers are stopped in br_stp_start() during NO_STP->USER_STP
>>    transition. The timers are already stopped in NO_STP state so
>>    this is confusing no-op.
>
> Hi Ivan,
>
> Shouldn't we start hello timer in br_stp_start when NO_STP -> BR_KERNEL_STP ?

As Nikolay mentioned, this is fixed by
https://patchwork.ozlabs.org/patch/764685/

>>
>> 2. During USER_STP->NO_STP transition the timers are started. This
>>    does not make sense and is confusion because the timer should not be
>>    active in NO_STP state.
>
> Yes, but what about BR_KERNEL_STP -> NO_STP in function br_stp_stop() ?

The timer is lazily stopped by itself in its handler... or not rearmed
respectively.

>> Cc: davem@davemloft.net
>> Cc: sashok@cumulusnetworks.com
>> Cc: stephen@networkplumber.org
>> Cc: bridge@lists.linux-foundation.org
>> Cc: lucien.xin@gmail.com
>> Cc: nikolay@cumulusnetworks.com
>> Signed-off-by: Ivan Vecera <cera@cera.cz>
>> ---
>>  net/bridge/br_stp_if.c | 11 -----------
>>  1 file changed, 11 deletions(-)
>>
>> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
>> index 08341d2aa9c9..a05027027513 100644
>> --- a/net/bridge/br_stp_if.c
>> +++ b/net/bridge/br_stp_if.c
>> @@ -150,7 +150,6 @@ static int br_stp_call_user(struct net_bridge *br, char *arg)
>>
>>  static void br_stp_start(struct net_bridge *br)
>>  {
>> -     struct net_bridge_port *p;
>>       int err = -ENOENT;
>>
>>       if (net_eq(dev_net(br->dev), &init_net))
>> @@ -169,11 +168,6 @@ static void br_stp_start(struct net_bridge *br)
>>       if (!err) {
>>               br->stp_enabled = BR_USER_STP;
>>               br_debug(br, "userspace STP started\n");
>> -
>> -             /* Stop hello and hold timers */
>> -             del_timer(&br->hello_timer);
>> -             list_for_each_entry(p, &br->port_list, list)
>> -                     del_timer(&p->hold_timer);
>
> I'm not sure if user space daemon will send bpdu or not? In comment
> 76b91c32dd86 ("bridge: stp: when using userspace stp stop kernel hello and
> hold timers"). Nikolay said we should not handle it with BR_USER_STP.
>
>>       } else {
>>               br->stp_enabled = BR_KERNEL_STP;
>>               br_debug(br, "using kernel STP\n");
>> @@ -187,7 +181,6 @@ static void br_stp_start(struct net_bridge *br)
>>
>>  static void br_stp_stop(struct net_bridge *br)
>>  {
>> -     struct net_bridge_port *p;
>>       int err;
>>
>>       if (br->stp_enabled == BR_USER_STP) {
>> @@ -196,10 +189,6 @@ static void br_stp_stop(struct net_bridge *br)
>>                       br_err(br, "failed to stop userspace STP (%d)\n", err);
>>
>>               /* To start timers on any ports left in blocking */
>> -             mod_timer(&br->hello_timer, jiffies + br->hello_time);
>> -             list_for_each_entry(p, &br->port_list, list)
>> -                     mod_timer(&p->hold_timer,
>> -                               round_jiffies(jiffies + BR_HOLD_TIME));
>
> If we do not del hello_timer. after it expired in br_hello_timer_expired(),
> Our state is br->dev->flags & IFF_UP and br->stp_enabled == NO_STP, it will
> call mod_timer(&br->hello_timer, round_jiffies(jiffies + br->hello_time))
> and we will keep sending bpdu message even after stp stoped.
>
>>               spin_lock_bh(&br->lock);
>>               br_port_state_selection(br);
>>               spin_unlock_bh(&br->lock);
>> --
>
> So how about just like
>
> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
> index d8ad73b..0198f62 100644
> --- a/net/bridge/br_stp_if.c
> +++ b/net/bridge/br_stp_if.c
> @@ -183,6 +183,7 @@ static void br_stp_start(struct net_bridge *br)
>         } else {
>                 br->stp_enabled = BR_KERNEL_STP;
>                 br_debug(br, "using kernel STP\n");
> +               mod_timer(&br->hello_timer, jiffies + br->hello_time);
>
>                 /* To start timers on any ports left in blocking */
>                 br_port_state_selection(br);
> @@ -202,7 +203,6 @@ static void br_stp_stop(struct net_bridge *br)
>                         br_err(br, "failed to stop userspace STP (%d)\n", err);
>
>                 /* To start timers on any ports left in blocking */
> -               mod_timer(&br->hello_timer, jiffies + br->hello_time);
>                 list_for_each_entry(p, &br->port_list, list)
>                         mod_timer(&p->hold_timer,
>                                   round_jiffies(jiffies + BR_HOLD_TIME));
> @@ -211,6 +211,7 @@ static void br_stp_stop(struct net_bridge *br)
>                 spin_unlock_bh(&br->lock);
>         }
>
> +       del_timer_sync(&br->hello_timer);
>         br->stp_enabled = BR_NO_STP;
>  }
>
> Thanks
> Hangbin
