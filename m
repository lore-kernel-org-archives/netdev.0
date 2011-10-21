From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net -v2] [BUGFIX] bonding: use flush_delayed_work_sync in bond_close
Date: Thu, 20 Oct 2011 23:26:36 -0700
Message-ID: <17144.1319178396@death>
References: <20111019081757.12455.24788.stgit@ltc219.sdl.hitachi.co.jp> <27007.1319047262@death> <20111019114129.162d895a@nehalam.linuxnetplumber.net> <29731.1319051397@death> <CAM_iQpV8089aU8gfeo8KotTNXQbx4ficMeBX69Nin_yXzqcEKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com
To: =?us-ascii?Q?=3D=3FUTF-8=3FQ=3FAm=3DC3=3DA9rico=5FWang=3F=3D?=
	<xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <CAM_iQpV8089aU8gfeo8KotTNXQbx4ficMeBX69Nin_yXzqcEKg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am=C3=A9rico Wang <xiyou.wangcong@gmail.com> wrote:

>On Thu, Oct 20, 2011 at 3:09 AM, Jay Vosburgh <fubar@us.ibm.com> wrote=
:
>> Stephen Hemminger <shemminger@vyatta.com> wrote:
>>
>>>On Wed, 19 Oct 2011 11:01:02 -0700
>>>Jay Vosburgh <fubar@us.ibm.com> wrote:
>>>
>>>> Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com> wrote:
>>>>
>>>> >The bond_close() calls cancel_delayed_work() to cancel delayed wo=
rks.
>>>> >It, however, cannot cancel works that were already queued in work=
queue.
>>>> >The bond_open() initializes work->data, and proccess_one_work() r=
efers
>>>> >get_work_cwq(work)->wq->flags. The get_work_cwq() returns NULL wh=
en
>>>> >work->data has been initialized. Thus, a panic occurs.
>>>> >
>>>> >This patch uses flush_delayed_work_sync() instead of cancel_delay=
ed_work()
>>>> >in bond_close(). It cancels delayed timer and waits for work to f=
inish
>>>> >execution. So, it can avoid the null pointer dereference due to t=
he
>>>> >parallel executions of proccess_one_work() and initializing procc=
ess
>>>> >of bond_open().
>>>>
>>>> =C2=A0 =C2=A0 =C2=A0I'm setting up to test this. =C2=A0I have a di=
m recollection that we
>>>> tried this some years ago, and there was a different deadlock that
>>>> manifested through the flush path. =C2=A0Perhaps changes since the=
n have
>>>> removed that problem.
>>>>
>>>> =C2=A0 =C2=A0 =C2=A0-J
>>>
>>>Won't this deadlock on RTNL. =C2=A0The problem is that:
>>>
>>> =C2=A0 CPU0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0CPU1
>>> =C2=A0rtnl_lock
>>> =C2=A0 =C2=A0 =C2=A0bond_close
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 delayed_work
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mii_work
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 read_lock(bond=
->lock);
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 read_unlock(bo=
nd->lock);
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rtnl_lock... w=
aiting for CPU0
>>> =C2=A0 =C2=A0 =C2=A0flush_delayed_work_sync
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0waiting for delayed_work to finis=
h...
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0Yah, that was it. =C2=A0We discussed this=
 a couple of years ago in
>> regards to a similar patch:
>>
>> http://lists.openwall.net/netdev/2009/12/17/3
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0The short version is that we could rework=
 the rtnl_lock inside
>> the montiors to be conditional and retry on failure (where "retry" m=
eans
>> "reschedule the work and try again later," not "spin retrying on rtn=
l").
>> That should permit the use of flush or cancel to terminate the work
>> items.
>
>Yes? Even if we use rtnl_trylock(), doesn't flush_delayed_work_sync()
>still queue the pending delayed work and wait for it to be finished?

	Yes, it does.  The original patch wants to use flush instead of
cancel to wait for the work to finish, because there's evidently a
possibility of getting back into bond_open before the work item
executes, and bond_open would reinitialize the work queue and corrupt
the queued work item.

	The original patch series, and recipe for destruction, is here:

	http://www.spinics.net/lists/netdev/msg176382.html

	I've been unable to reproduce the work queue panic locally,
although it sounds plausible.

	Mitsuo: can you provide the precise bonding configuration you're
using to induce the problem?  Driver options, number and type of slaves=
,
etc.

>Maybe I am too blind, why do we need rtnl_lock for cancel_delayed_work=
()
>inside bond_close()?

	We don't need RTNL for cancel/flush.  However, bond_close is an
ndo_stop operation, and is called in the dev_close path, which always
occurs under RTNL.  The mii / arp monitor work functions separately
acquire RTNL if they need to perform various failover related
operations.

	I'm working on a patch that should resolve the mii / arp monitor
RTNL problem as I described above (if rtnl_trylock fails, punt and
reschedule the work).  I need to rearrange the netdev_bonding_change
stuff a bit as well, since it acquires RTNL separately.

	Once these changes are made to mii / arp monitor, then
bond_close can call flush instead of cancel, which should eliminate the
original problem described at the top.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
