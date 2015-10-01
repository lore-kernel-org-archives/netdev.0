From: =?UTF-8?Q?Holger_Hoffst=c3=a4tte?=
	<holger.hoffstaette@googlemail.com>
Subject: Re: Soft lockup issue in Linux 4.1.9
Date: Thu, 1 Oct 2015 13:43:22 +0200
Message-ID: <560D1C5A.3050508@googlemail.com>
References: <1443650383.13282.10.camel@daevel.fr>
 <560D1223.3070606@googlemail.com>
 <CANn89i+B5T4Rhs8HnrC0+f+GhLvBFfpr4BVDvhkVOveSfy9B8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CANn89i+B5T4Rhs8HnrC0+f+GhLvBFfpr4BVDvhkVOveSfy9B8Q@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/01/15 13:29, Eric Dumazet wrote:
> On Thu, Oct 1, 2015 at 3:59 AM, Holger Hoffst=C3=A4tte
> <holger.hoffstaette@googlemail.com> wrote:
>>
>> On Thu, 01 Oct 2015 06:41:46 +0200, Andre Tomt wrote:
>>
>>> On 01. okt. 2015 00:37, Holger Hoffst=C3=A4tte wrote:
>>>> On Wed, 30 Sep 2015 23:59:43 +0200, Olivier Bonvalet wrote:
>>>>
>>>>> for information, I've just upgraded 6 servers from Linux 4.1.8 to=
 Linux
>>>>> 4.1.9, and have some random soft lockup. If this can help :
>>>>
>>>> Congratulations! You're not the first one to get hit by this, but
>>>> you are probably the first one to get a meaningful stacktrace! \o/
>>>>
>>>>> [  204.478380] Call Trace:
>>>>> [  204.478381]  <IRQ>
>>>>> [  204.478385]  [<ffffffff81076121>] ? try_to_del_timer_sync+0x43=
/0x4d
>>>>> [  204.478386]  [<ffffffff810760de>] ? del_timer+0x4d/0x4d
>>>>> [  204.478388]  [<ffffffff8107614b>] ? del_timer_sync+0x20/0x3d
>>>>
>>>> Can you try to revert
>>>>
>>>>     [PATCH 4.1 157/159] inet: fix races with reqsk timers
>>>>
>>>> and see how that works for you? I'll do the same on my end. So far=
 the
>>>> only thing I ever could gleam was an rcu stall after cpuidle_enter=
(),
>>>> but never anything regarding the timer - though it was definitely
>>>> related to NIC activity after idle.
>>>
>>> I'm running with this patch reverted now as well. 2 hours no issues=
 so
>>> far, but I can't conclude anything yet as I've seen it take up to 6=
+
>>> hours to explode here. As a result the bisect was going veeery slow=
ly.
>>
>> Now 12+ hours going without problems, never got this far with the pa=
tch
>> included, as it would usually freeze during idle periods.
>>
>> As far as I'm concerned this is the culprit and should be reverted i=
n
>> 4.1.x, unless Eric can suggest how to fix this. (cc'ed).
>>
>=20
> Looks an old and known problem...
>=20
> Following commit should be sent/added for 4.1 stable tree :
>=20
> commit 83fccfc3940c4a2db90fd7e7079f5b465cd8c6af
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Thu Aug 13 15:44:51 2015 -0700
>=20
>     inet: fix potential deadlock in reqsk_queue_unlink()
>=20
>     When replacing del_timer() with del_timer_sync(), I introduced
>     a deadlock condition :
>=20
>     reqsk_queue_unlink() is called from inet_csk_reqsk_queue_drop()
>=20
>     inet_csk_reqsk_queue_drop() can be called from many contexts,
>     one being the timer handler itself (reqsk_timer_handler()).
>=20
>     In this case, del_timer_sync() loops forever.
>=20
>     Simple fix is to test if timer is pending.
>=20
>     Fixes: 2235f2ac75fd ("inet: fix races with reqsk timers")
>     Signed-off-by: Eric Dumazet <edumazet@google.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

Whohoo! It applies/builds cleanly to 4.1.10-rc1 and is running as
we speak. Let's hope that this fixes the lockups.

Thanks for the quick reply!

Holger
