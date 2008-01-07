From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [Bugme-new] [Bug 9543] New: RTNL: assertion failed at
 net/ipv6/addrconf.c (2164)/RTNL: assertion failed at net/ipv4/devinet.c
 (1055)
Date: Mon, 7 Jan 2008 18:57:25 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801071854140.6696@bizon.gios.gov.pl>
References: <E1J2Rgs-0006mz-00@gondolin.me.apana.org.au> <28503.1197481615@death>
 <Pine.LNX.4.64.0712141707090.30334@bizon.gios.gov.pl>
 <20071214182638.GC25879@gospo.usersys.redhat.com>
 <Pine.LNX.4.64.0712141955080.12202@bizon.gios.gov.pl>
 <20071214224722.GA8728@gospo.usersys.redhat.com>
 <Pine.LNX.4.64.0712182052490.24949@bizon.gios.gov.pl>
 <20071219144208.GB8728@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1970340390-1199728645=:6696"
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:60725 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339AbYAGSOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 13:14:43 -0500
In-Reply-To: <20071219144208.GB8728@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1970340390-1199728645=:6696
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Wed, 19 Dec 2007, Andy Gospodarek wrote:

> On Tue, Dec 18, 2007 at 08:53:39PM +0100, Krzysztof Oledzki wrote:
>>
>>
>> On Fri, 14 Dec 2007, Andy Gospodarek wrote:
>>
>>> On Fri, Dec 14, 2007 at 07:57:42PM +0100, Krzysztof Oledzki wrote:
>>>>
>>>>
>>>> On Fri, 14 Dec 2007, Andy Gospodarek wrote:
>>>>
>>>>> On Fri, Dec 14, 2007 at 05:14:57PM +0100, Krzysztof Oledzki wrote:
>>>>>>
>>>>>>
>>>>>> On Wed, 12 Dec 2007, Jay Vosburgh wrote:
>>>>>>
>>>>>>> Herbert Xu <herbert@gondor.apana.org.au> wrote:
>>>>>>>
>>>>>>>>> diff -puN drivers/net/bonding/bond_sysfs.c~bonding-locking-fix
>>>>>>>>> drivers/net/bonding/bond_sysfs.c
>>>>>>>>> --- a/drivers/net/bonding/bond_sysfs.c~bonding-locking-fix
>>>>>>>>> +++ a/drivers/net/bonding/bond_sysfs.c
>>>>>>>>> @@ -1111,8 +1111,6 @@ static ssize_t bonding_store_primary(str
>>>>>>>>> out:
>>>>>>>>>     write_unlock_bh(&bond->lock);
>>>>>>>>>
>>>>>>>>> -       rtnl_unlock();
>>>>>>>>> -
>>>>>>>>
>>>>>>>> Looking at the changeset that added this perhaps the intention
>>>>>>>> is to hold the lock? If so we should add an rtnl_lock to the start
>>>>>>>> of the function.
>>>>>>>
>>>>>>> =09Yes, this function needs to hold locks, and more than just
>>>>>>> what's there now.  I believe the following should be correct; I hav=
en't
>>>>>>> tested it, though (I'm supposedly on vacation right now).
>>>>>>>
>>>>>>> =09The following change should be correct for the
>>>>>>> bonding_store_primary case discussed in this thread, and also corre=
cts
>>>>>>> the bonding_store_active case which performs similar functions.
>>>>>>>
>>>>>>> =09The bond_change_active_slave and bond_select_active_slave
>>>>>>> functions both require rtnl, bond->lock for read and curr_slave_loc=
k
>>>>>>> for
>>>>>>> write_bh, and no other locks.  This is so that the lower level
>>>>>>> mode-specific functions can release locks down to just rtnl in orde=
r to
>>>>>>> call, e.g., dev_set_mac_address with the locks it expects (rtnl onl=
y).
>>>>>>>
>>>>>>> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>>>>>>>
>>>>>>> diff --git a/drivers/net/bonding/bond_sysfs.c
>>>>>>> b/drivers/net/bonding/bond_sysfs.c
>>>>>>> index 11b76b3..28a2d80 100644
>>>>>>> --- a/drivers/net/bonding/bond_sysfs.c
>>>>>>> +++ b/drivers/net/bonding/bond_sysfs.c
>>>>>>> @@ -1075,7 +1075,10 @@ static ssize_t bonding_store_primary(struct
>>>>>>> device
>>>>>>> *d,
>>>>>>> =09struct slave *slave;
>>>>>>> =09struct bonding *bond =3D to_bond(d);
>>>>>>>
>>>>>>> -=09write_lock_bh(&bond->lock);
>>>>>>> +=09rtnl_lock();
>>>>>>> +=09read_lock(&bond->lock);
>>>>>>> +=09write_lock_bh(&bond->curr_slave_lock);
>>>>>>> +
>>>>>>> =09if (!USES_PRIMARY(bond->params.mode)) {
>>>>>>> =09=09printk(KERN_INFO DRV_NAME
>>>>>>> =09=09       ": %s: Unable to set primary slave; %s is in mode
>>>>>>> =09=09       %d\n",
>>>>>>> @@ -1109,8 +1112,8 @@ static ssize_t bonding_store_primary(struct
>>>>>>> device
>>>>>>> *d,
>>>>>>> =09=09}
>>>>>>> =09}
>>>>>>> out:
>>>>>>> -=09write_unlock_bh(&bond->lock);
>>>>>>> -
>>>>>>> +=09write_unlock_bh(&bond->curr_slave_lock);
>>>>>>> +=09read_unlock(&bond->lock);
>>>>>>> =09rtnl_unlock();
>>>>>>>
>>>>>>> =09return count;
>>>>>>> @@ -1190,7 +1193,8 @@ static ssize_t bonding_store_active_slave(str=
uct
>>>>>>> device *d,
>>>>>>> =09struct bonding *bond =3D to_bond(d);
>>>>>>>
>>>>>>> =09rtnl_lock();
>>>>>>> -=09write_lock_bh(&bond->lock);
>>>>>>> +=09read_lock(&bond->lock);
>>>>>>> +=09write_lock_bh(&bond->curr_slave_lock);
>>>>>>>
>>>>>>> =09if (!USES_PRIMARY(bond->params.mode)) {
>>>>>>> =09=09printk(KERN_INFO DRV_NAME
>>>>>>> @@ -1247,7 +1251,8 @@ static ssize_t bonding_store_active_slave(str=
uct
>>>>>>> device *d,
>>>>>>> =09=09}
>>>>>>> =09}
>>>>>>> out:
>>>>>>> -=09write_unlock_bh(&bond->lock);
>>>>>>> +=09write_unlock_bh(&bond->curr_slave_lock);
>>>>>>> +=09read_unlock(&bond->lock);
>>>>>>> =09rtnl_unlock();
>>>>>>>
>>>>>>> =09return count;
>>>>>>
>>>>>> Vanilla 2.6.24-rc5 plus this patch:
>>>>>>
>>>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>>>> [ INFO: possible irq lock inversion dependency detected ]
>>>>>> 2.6.24-rc5 #1
>>>>>> ---------------------------------------------------------
>>>>>> events/0/9 just changed the state of lock:
>>>>>> (&mc->mca_lock){-+..}, at: [<c0411c7a>] mld_ifc_timer_expire+0x130/0=
x1fb
>>>>>> but this lock took another, soft-read-irq-unsafe lock in the past:
>>>>>> (&bond->lock){-.--}
>>>>>>
>>>>>> and interrupts could create inverse lock ordering between them.
>>>>>>
>>>>>>
>>>>>
>>>>> Grrr, I should have seen that -- sorry.  Try your luck with this inst=
ead:
>>>> <CUT>
>>>>
>>>> No luck.
>>>>
>>>
>>>
>>> I'm guessing if we go back to using a write-lock for bond->lock this
>>> will go back to working again, but I'm not totally convinced since ther=
e
>>> are plenty of places where we used a read-lock with it.
>>
>> Should I check this patch or rather, based on a future discussion, wait
>> for another version?
>>
>>>
>>> diff --git a/drivers/net/bonding/bond_sysfs.c
>>> b/drivers/net/bonding/bond_sysfs.c
>>> index 11b76b3..635b857 100644
>>> --- a/drivers/net/bonding/bond_sysfs.c
>>> +++ b/drivers/net/bonding/bond_sysfs.c
>>> @@ -1075,7 +1075,10 @@ static ssize_t bonding_store_primary(struct devi=
ce
>>> *d,
>>> =09struct slave *slave;
>>> =09struct bonding *bond =3D to_bond(d);
>>>
>>> +=09rtnl_lock();
>>> =09write_lock_bh(&bond->lock);
>>> +=09write_lock_bh(&bond->curr_slave_lock);
>>> +
>>> =09if (!USES_PRIMARY(bond->params.mode)) {
>>> =09=09printk(KERN_INFO DRV_NAME
>>> =09=09       ": %s: Unable to set primary slave; %s is in mode
>>> =09=09       %d\n",
>>> @@ -1109,8 +1112,8 @@ static ssize_t bonding_store_primary(struct devic=
e
>>> *d,
>>> =09=09}
>>> =09}
>>> out:
>>> +=09write_unlock_bh(&bond->curr_slave_lock);
>>> =09write_unlock_bh(&bond->lock);
>>> -
>>> =09rtnl_unlock();
>>>
>>> =09return count;
>>> @@ -1191,6 +1194,7 @@ static ssize_t bonding_store_active_slave(struct
>>> device *d,
>>>
>>> =09rtnl_lock();
>>> =09write_lock_bh(&bond->lock);
>>> +=09write_lock_bh(&bond->curr_slave_lock);
>>>
>>> =09if (!USES_PRIMARY(bond->params.mode)) {
>>> =09=09printk(KERN_INFO DRV_NAME
>>> @@ -1247,6 +1251,7 @@ static ssize_t bonding_store_active_slave(struct
>>> device *d,
>>> =09=09}
>>> =09}
>>> out:
>>> +=09write_unlock_bh(&bond->curr_slave_lock);
>>> =09write_unlock_bh(&bond->lock);
>>> =09rtnl_unlock();
>>>
>>
>>
>> Best regards,
>>
>> =09=09=09=09=09Krzysztof Ol=EAdzki
>
> For now, I prefer Jay's original patch -- with the read_locks (rather
> than read/write_lock_bh) and the added rtnl_lock.  There is still a
> lockdep issue that we need to sort-out, but this patch is needed first.

This bug has not been fixed yet as it still exists in 2.6.24-rc7. Any=20
chances to cure it before 2.6.24-final?

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1970340390-1199728645=:6696--
