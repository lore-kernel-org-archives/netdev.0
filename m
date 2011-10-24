From: HAYASAKA Mitsuo <mitsuo.hayasaka.hu@hitachi.com>
Subject: Re: [PATCH net -v2] [BUGFIX] bonding: use flush_delayed_work_sync
 in bond_close
Date: Mon, 24 Oct 2011 13:00:46 +0900
Message-ID: <4EA4E2EE.4050201@hitachi.com>
References: <20111019081757.12455.24788.stgit@ltc219.sdl.hitachi.co.jp> <27007.1319047262@death> <20111019114129.162d895a@nehalam.linuxnetplumber.net> <29731.1319051397@death> <CAM_iQpV8089aU8gfeo8KotTNXQbx4ficMeBX69Nin_yXzqcEKg@mail.gmail.com> <17144.1319178396@death> <14766.1319245142@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <14766.1319245142@death>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(2011/10/22 9:59), Jay Vosburgh wrote:
> Jay Vosburgh <fubar@us.ibm.com> wrote:
>=20
>> Am=C3=A9rico Wang <xiyou.wangcong@gmail.com> wrote:
>>
>>> On Thu, Oct 20, 2011 at 3:09 AM, Jay Vosburgh <fubar@us.ibm.com> wr=
ote:
>>>> Stephen Hemminger <shemminger@vyatta.com> wrote:
>>>>
>>>>> On Wed, 19 Oct 2011 11:01:02 -0700
>>>>> Jay Vosburgh <fubar@us.ibm.com> wrote:
>>>>>
>>>>>> Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com> wrote:
>>>>>>
>>>>>>> The bond_close() calls cancel_delayed_work() to cancel delayed =
works.
>>>>>>> It, however, cannot cancel works that were already queued in wo=
rkqueue.
>>>>>>> The bond_open() initializes work->data, and proccess_one_work()=
 refers
>>>>>>> get_work_cwq(work)->wq->flags. The get_work_cwq() returns NULL =
when
>>>>>>> work->data has been initialized. Thus, a panic occurs.
>>>>>>>
>>>>>>> This patch uses flush_delayed_work_sync() instead of cancel_del=
ayed_work()
>>>>>>> in bond_close(). It cancels delayed timer and waits for work to=
 finish
>>>>>>> execution. So, it can avoid the null pointer dereference due to=
 the
>>>>>>> parallel executions of proccess_one_work() and initializing pro=
ccess
>>>>>>> of bond_open().
>>>>>>
>>>>>>      I'm setting up to test this.  I have a dim recollection tha=
t we
>>>>>> tried this some years ago, and there was a different deadlock th=
at
>>>>>> manifested through the flush path.  Perhaps changes since then h=
ave
>>>>>> removed that problem.
>>>>>>
>>>>>>      -J
>>>>>
>>>>> Won't this deadlock on RTNL.  The problem is that:
>>>>>
>>>>>   CPU0                            CPU1
>>>>>  rtnl_lock
>>>>>      bond_close
>>>>>                                 delayed_work
>>>>>                                   mii_work
>>>>>                                     read_lock(bond->lock);
>>>>>                                     read_unlock(bond->lock);
>>>>>                                     rtnl_lock... waiting for CPU0
>>>>>      flush_delayed_work_sync
>>>>>          waiting for delayed_work to finish...
>>>>
>>>>        Yah, that was it.  We discussed this a couple of years ago =
in
>>>> regards to a similar patch:
>>>>
>>>> http://lists.openwall.net/netdev/2009/12/17/3
>>>>
>>>>        The short version is that we could rework the rtnl_lock ins=
ide
>>>> the montiors to be conditional and retry on failure (where "retry"=
 means
>>>> "reschedule the work and try again later," not "spin retrying on r=
tnl").
>>>> That should permit the use of flush or cancel to terminate the wor=
k
>>>> items.
>>>
>>> Yes? Even if we use rtnl_trylock(), doesn't flush_delayed_work_sync=
()
>>> still queue the pending delayed work and wait for it to be finished=
?
>>
>> 	Yes, it does.  The original patch wants to use flush instead of
>> cancel to wait for the work to finish, because there's evidently a
>> possibility of getting back into bond_open before the work item
>> executes, and bond_open would reinitialize the work queue and corrup=
t
>> the queued work item.
>>
>> 	The original patch series, and recipe for destruction, is here:
>>
>> 	http://www.spinics.net/lists/netdev/msg176382.html
>>
>> 	I've been unable to reproduce the work queue panic locally,
>> although it sounds plausible.
>>
>> 	Mitsuo: can you provide the precise bonding configuration you're
>> using to induce the problem?  Driver options, number and type of sla=
ves,
>> etc.
>>
>>> Maybe I am too blind, why do we need rtnl_lock for cancel_delayed_w=
ork()
>>> inside bond_close()?
>>
>> 	We don't need RTNL for cancel/flush.  However, bond_close is an
>> ndo_stop operation, and is called in the dev_close path, which alway=
s
>> occurs under RTNL.  The mii / arp monitor work functions separately
>> acquire RTNL if they need to perform various failover related
>> operations.
>>
>> 	I'm working on a patch that should resolve the mii / arp monitor
>> RTNL problem as I described above (if rtnl_trylock fails, punt and
>> reschedule the work).  I need to rearrange the netdev_bonding_change
>> stuff a bit as well, since it acquires RTNL separately.
>>
>> 	Once these changes are made to mii / arp monitor, then
>> bond_close can call flush instead of cancel, which should eliminate =
the
>> original problem described at the top.
>=20
> 	Just an update: there are three functions that may deadlock if
> the cancel work calls are changed to flush_sync.  There are two
> rtnl_lock calls in each of the bond_mii_monitor and
> bond_activebackup_arp_mon functions, and one more in the
> bond_alb_monitor.
>=20
> 	Still testing to make sure I haven't missed anything, and I
> still haven't been able to reproduce Mitsuo's original failure.


The interval of mii_mon was set to 1 to reproduce this bug easily and=20
the 802.3ad mode was used. Then, I executed the following command.

# while true; do ifconfig bond0 down; done &
# while true; do ifconfig bond0 up; done &

This bug rarely occurs since it is the severe timing problem.
I found that it is more easily to reproduce this bug when using guest O=
S.

=46or example, it took one to three days for me to reproduce it on host=
 OS,=20
but some hours on guest OS.

Thanks.


>=20
> 	-J
>=20
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>=20
>=20
