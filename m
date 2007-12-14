From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [Bugme-new] [Bug 9543] New: RTNL: assertion failed at
 net/ipv6/addrconf.c (2164)/RTNL: assertion failed at net/ipv4/devinet.c
 (1055)
Date: Fri, 14 Dec 2007 23:11:15 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0712142304470.23504@bizon.gios.gov.pl>
References: <E1J2Rgs-0006mz-00@gondolin.me.apana.org.au> <28503.1197481615@death>
 <Pine.LNX.4.64.0712141707090.30334@bizon.gios.gov.pl>
 <20071214182638.GC25879@gospo.usersys.redhat.com>
 <Pine.LNX.4.64.0712141955080.12202@bizon.gios.gov.pl>
 <20071214220300.GA8515@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1324668736-1197670275=:23504"
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:55103 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223AbXLNWRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 17:17:12 -0500
In-Reply-To: <20071214220300.GA8515@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1324668736-1197670275=:23504
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Fri, 14 Dec 2007, Andy Gospodarek wrote:

> On Fri, Dec 14, 2007 at 07:57:42PM +0100, Krzysztof Oledzki wrote:
>>
>>
>> On Fri, 14 Dec 2007, Andy Gospodarek wrote:
>>
>>> On Fri, Dec 14, 2007 at 05:14:57PM +0100, Krzysztof Oledzki wrote:
>>>>
>>>>
>>>> On Wed, 12 Dec 2007, Jay Vosburgh wrote:
>>>>
>>>>> Herbert Xu <herbert@gondor.apana.org.au> wrote:
>>>>>
>>>>>>> diff -puN drivers/net/bonding/bond_sysfs.c~bonding-locking-fix
>>>>>>> drivers/net/bonding/bond_sysfs.c
>>>>>>> --- a/drivers/net/bonding/bond_sysfs.c~bonding-locking-fix
>>>>>>> +++ a/drivers/net/bonding/bond_sysfs.c
>>>>>>> @@ -1111,8 +1111,6 @@ static ssize_t bonding_store_primary(str
>>>>>>> out:
>>>>>>>      write_unlock_bh(&bond->lock);
>>>>>>>
>>>>>>> -       rtnl_unlock();
>>>>>>> -
>>>>>>
>>>>>> Looking at the changeset that added this perhaps the intention
>>>>>> is to hold the lock? If so we should add an rtnl_lock to the start
>>>>>> of the function.
>>>>>
>>>>> =09Yes, this function needs to hold locks, and more than just
>>>>> what's there now.  I believe the following should be correct; I haven=
't
>>>>> tested it, though (I'm supposedly on vacation right now).
>>>>>
>>>>> =09The following change should be correct for the
>>>>> bonding_store_primary case discussed in this thread, and also correct=
s
>>>>> the bonding_store_active case which performs similar functions.
>>>>>
>>>>> =09The bond_change_active_slave and bond_select_active_slave
>>>>> functions both require rtnl, bond->lock for read and curr_slave_lock =
for
>>>>> write_bh, and no other locks.  This is so that the lower level
>>>>> mode-specific functions can release locks down to just rtnl in order =
to
>>>>> call, e.g., dev_set_mac_address with the locks it expects (rtnl only)=
=2E
>>>>>
>>>>> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>>>>>
>>>>> diff --git a/drivers/net/bonding/bond_sysfs.c
>>>>> b/drivers/net/bonding/bond_sysfs.c
>>>>> index 11b76b3..28a2d80 100644
>>>>> --- a/drivers/net/bonding/bond_sysfs.c
>>>>> +++ b/drivers/net/bonding/bond_sysfs.c
>>>>> @@ -1075,7 +1075,10 @@ static ssize_t bonding_store_primary(struct de=
vice
>>>>> *d,
>>>>> =09struct slave *slave;
>>>>> =09struct bonding *bond =3D to_bond(d);
>>>>>
>>>>> -=09write_lock_bh(&bond->lock);
>>>>> +=09rtnl_lock();
>>>>> +=09read_lock(&bond->lock);
>>>>> +=09write_lock_bh(&bond->curr_slave_lock);
> F
>>>>> +
>>>>> =09if (!USES_PRIMARY(bond->params.mode)) {
>>>>> =09=09printk(KERN_INFO DRV_NAME
>>>>> =09=09       ": %s: Unable to set primary slave; %s is in mode
>>>>> =09=09       %d\n",
>>>>> @@ -1109,8 +1112,8 @@ static ssize_t bonding_store_primary(struct dev=
ice
>>>>> *d,
>>>>> =09=09}
>>>>> =09}
>>>>> out:
>>>>> -=09write_unlock_bh(&bond->lock);
>>>>> -
>>>>> +=09write_unlock_bh(&bond->curr_slave_lock);
>>>>> +=09read_unlock(&bond->lock);
>>>>> =09rtnl_unlock();
>>>>>
>>>>> =09return count;
>>>>> @@ -1190,7 +1193,8 @@ static ssize_t bonding_store_active_slave(struc=
t
>>>>> device *d,
>>>>> =09struct bonding *bond =3D to_bond(d);
>>>>>
>>>>> =09rtnl_lock();
>>>>> -=09write_lock_bh(&bond->lock);
>>>>> +=09read_lock(&bond->lock);
>>>>> +=09write_lock_bh(&bond->curr_slave_lock);
>>>>>
>>>>> =09if (!USES_PRIMARY(bond->params.mode)) {
>>>>> =09=09printk(KERN_INFO DRV_NAME
>>>>> @@ -1247,7 +1251,8 @@ static ssize_t bonding_store_active_slave(struc=
t
>>>>> device *d,
>>>>> =09=09}
>>>>> =09}
>>>>> out:
>>>>> -=09write_unlock_bh(&bond->lock);
>>>>> +=09write_unlock_bh(&bond->curr_slave_lock);
>>>>> +=09read_unlock(&bond->lock);
>>>>> =09rtnl_unlock();
>>>>>
>>>>> =09return count;
>>>>
>>>> Vanilla 2.6.24-rc5 plus this patch:
>>>>
>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>> [ INFO: possible irq lock inversion dependency detected ]
>>>> 2.6.24-rc5 #1
>>>> ---------------------------------------------------------
>>>> events/0/9 just changed the state of lock:
>>>> (&mc->mca_lock){-+..}, at: [<c0411c7a>] mld_ifc_timer_expire+0x130/0x1=
fb
>>>> but this lock took another, soft-read-irq-unsafe lock in the past:
>>>> (&bond->lock){-.--}
>>>>
>>>> and interrupts could create inverse lock ordering between them.
>>>>
>>>>
>>>
>>> Grrr, I should have seen that -- sorry.  Try your luck with this instea=
d:
>> <CUT>
>>
>> No luck.
>>
>> bonding: bond0: setting mode to active-backup (1).
>> bonding: bond0: Setting MII monitoring interval to 100.
>> ADDRCONF(NETDEV_UP): bond0: link is not ready
>> bonding: bond0: Adding slave eth0.
>> e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow
>> Control: RX/TX
>> bonding: bond0: making interface eth0 the new active one.
>> bonding: bond0: first active interface up!
>> bonding: bond0: enslaving eth0 as an active interface with an up link.
>> bonding: bond0: Adding slave eth1.
>> ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
>
> <SNIP>
>
>> bonding: bond0: enslaving eth1 as a backup interface with a down link.
>> bonding: bond0: Setting eth0 as primary slave.
>> bond0: no IPv6 routers present
>>
>
> Based on the console log, I'm guessing your initialization scripts use
> sysfs to set eth0 as the primary interface for bond0?  Can you confirm?

Yep, that's correct:

postup() {
         if [[ ${IFACE} =3D=3D "bond0" ]] ; then
                 echo -n +eth0 > /sys/class/net/${IFACE}/bonding/slaves
                 echo -n +eth1 > /sys/class/net/${IFACE}/bonding/slaves
                 echo -n  eth0 > /sys/class/net/${IFACE}/bonding/primary
         fi
}

> If you did somehow use sysfs to set the primary device as eth0, I'm
> guessing you never see this issue without that line or without this
> patch.  Please confirm this as well.

Without this patch I get another error, of course. Unfortunately checking=
=20
what happens without using sysfs to set the primary device as eth0, have=20
to wait, as I am not able to test it before Monday.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1324668736-1197670275=:23504--
