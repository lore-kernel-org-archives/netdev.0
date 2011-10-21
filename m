From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net -v2] [BUGFIX] bonding: use flush_delayed_work_sync in bond_close
Date: Fri, 21 Oct 2011 13:45:32 +0800
Message-ID: <CAM_iQpV8089aU8gfeo8KotTNXQbx4ficMeBX69Nin_yXzqcEKg@mail.gmail.com>
References: <20111019081757.12455.24788.stgit@ltc219.sdl.hitachi.co.jp>
	<27007.1319047262@death>
	<20111019114129.162d895a@nehalam.linuxnetplumber.net>
	<29731.1319051397@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <29731.1319051397@death>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 20, 2011 at 3:09 AM, Jay Vosburgh <fubar@us.ibm.com> wrote:
> Stephen Hemminger <shemminger@vyatta.com> wrote:
>
>>On Wed, 19 Oct 2011 11:01:02 -0700
>>Jay Vosburgh <fubar@us.ibm.com> wrote:
>>
>>> Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com> wrote:
>>>
>>> >The bond_close() calls cancel_delayed_work() to cancel delayed wor=
ks.
>>> >It, however, cannot cancel works that were already queued in workq=
ueue.
>>> >The bond_open() initializes work->data, and proccess_one_work() re=
fers
>>> >get_work_cwq(work)->wq->flags. The get_work_cwq() returns NULL whe=
n
>>> >work->data has been initialized. Thus, a panic occurs.
>>> >
>>> >This patch uses flush_delayed_work_sync() instead of cancel_delaye=
d_work()
>>> >in bond_close(). It cancels delayed timer and waits for work to fi=
nish
>>> >execution. So, it can avoid the null pointer dereference due to th=
e
>>> >parallel executions of proccess_one_work() and initializing procce=
ss
>>> >of bond_open().
>>>
>>> =C2=A0 =C2=A0 =C2=A0I'm setting up to test this. =C2=A0I have a dim=
 recollection that we
>>> tried this some years ago, and there was a different deadlock that
>>> manifested through the flush path. =C2=A0Perhaps changes since then=
 have
>>> removed that problem.
>>>
>>> =C2=A0 =C2=A0 =C2=A0-J
>>
>>Won't this deadlock on RTNL. =C2=A0The problem is that:
>>
>> =C2=A0 CPU0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0CPU1
>> =C2=A0rtnl_lock
>> =C2=A0 =C2=A0 =C2=A0bond_close
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 delayed_work
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mii_work
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 read_lock(bond=
->lock);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 read_unlock(bo=
nd->lock);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rtnl_lock... w=
aiting for CPU0
>> =C2=A0 =C2=A0 =C2=A0flush_delayed_work_sync
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0waiting for delayed_work to finish=
=2E..
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Yah, that was it. =C2=A0We discussed this =
a couple of years ago in
> regards to a similar patch:
>
> http://lists.openwall.net/netdev/2009/12/17/3
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0The short version is that we could rework =
the rtnl_lock inside
> the montiors to be conditional and retry on failure (where "retry" me=
ans
> "reschedule the work and try again later," not "spin retrying on rtnl=
").
> That should permit the use of flush or cancel to terminate the work
> items.

Yes? Even if we use rtnl_trylock(), doesn't flush_delayed_work_sync()
still queue the pending delayed work and wait for it to be finished?

Maybe I am too blind, why do we need rtnl_lock for cancel_delayed_work(=
)
inside bond_close()?

Thanks.
