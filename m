From: Fan Du <fan.du@windriver.com>
Subject: Re: [RFC PATCHv2 1/3] hrtimer: Add notifer for clock_was_set
Date: Wed, 7 Aug 2013 17:31:30 +0800
Message-ID: <520213F2.5090401@windriver.com>
References: <1375866296-15079-1-git-send-email-fan.du@windriver.com> <1375866296-15079-2-git-send-email-fan.du@windriver.com> <52021177.6020306@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<herbert@gondor.hengli.com.au>, <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47076 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757383Ab3HGJaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 05:30:22 -0400
In-Reply-To: <52021177.6020306@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B408=E6=9C=8807=E6=97=A5 17:20, Daniel Borkmann wrote:
> On 08/07/2013 11:04 AM, Fan Du wrote:
>> When clock_was_set is called in case of system wall time change
>> or host resume from suspend state, use this notifier for places
>> where interested in this action.
>
> (Only minor commenting on this one ...)
>
>> Signed-off-by: Fan Du <fan.du@windriver.com>
>> ---
>> kernel/hrtimer.c | 4 ++++
>> 1 file changed, 4 insertions(+)
>>
>> diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
>> index 383319b..b7c62a9 100644
>> --- a/kernel/hrtimer.c
>> +++ b/kernel/hrtimer.c
>> @@ -755,6 +755,9 @@ static inline void retrigger_next_event(void *ar=
g) { }
>>
>> #endif /* CONFIG_HIGH_RES_TIMERS */
>>
>> +ATOMIC_NOTIFIER_HEAD(clock_change_notifier_list);
>> +EXPORT_SYMBOL(clock_change_notifier_list);
>
> This should be static and hidden from other modules, e.g. have a look=
 at
> netevent_notif_chain (net/core/netevent.c).
>
> Instead, this should be accessed via registration/un-registration han=
dlers
> for notifier blocks, and those can then be exported as EXPORT_SYMBOL_=
GPL
> as this is core area.
>
>> +
>> /*
>> * Clock realtime was set
>> *
>> @@ -773,6 +776,7 @@ void clock_was_set(void)
>> on_each_cpu(retrigger_next_event, NULL, 1);
>> #endif
>> timerfd_clock_was_set();
>> + atomic_notifier_call_chain(&clock_change_notifier_list, 0, 0);
>
> Also here a small one-line handler call_clock_change_notifiers() woul=
d be
> better.

Thanks for your attention.
After taking a look at netevent_notif_chain, you mean I should do it in=
 below style:

static ATOMIC_NOTIFIER_HEAD(clock_change_notifier_list);

int un/register_clock_change_notifier(struct notifier_block *nb)
{
         int err;

         err =3D atomic_notifier_chain_un/register(&clock_change_notifi=
er_list, nb);
         return err;
}
EXPORT_SYMBOL_GPL(clock_change_notifier_list);

int call_clock_change_notifiers(unsigned long val, void *v)
{
         return atomic_notifier_call_chain(&clock_change_notifier, val,=
 v);
}
EXPORT_SYMBOL_GPL(call_clock_change_notifiers);

Will do it in next version after others comment rest of patches.

Thanks Daniel.

>> }
>>
>> /*
>>
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
