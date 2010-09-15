From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: Re: [PATCH] 3c59x: Remove atomic context inside vortex_{set|get}_wol
Date: Wed, 15 Sep 2010 14:58:46 +0400
Message-ID: <4C90A6E6.8040608@kernel.org>
References: <20100915062453.GA16772@hera.kernel.org>	 <1284532517.2271.8.camel@edumazet-laptop>  <4C909CAD.8010905@kernel.org> <1284547021.2495.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, ben@decadent.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:44505 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752009Ab0IOK6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 06:58:33 -0400
In-Reply-To: <1284547021.2495.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2010 02:37 PM, Eric Dumazet wrote:
> Le mercredi 15 septembre 2010 =C3=A0 14:15 +0400, Denis Kirjanov a =C3=
=A9crit :
>> On 09/15/2010 10:35 AM, Eric Dumazet wrote:
>>> Le mercredi 15 septembre 2010 =C3=A0 06:24 +0000, Denis Kirjanov a =
=C3=A9crit :
>>>> There is no need to use spinlocks in vortex_{set|get}_wol.
>>>> This also fixes a bug:
>>>> [  254.214993] 3c59x 0000:00:0d.0: PME# enabled
>>>> [  254.215021] BUG: sleeping function called from invalid context =
at kernel/mutex.c:94
>>>> [  254.215030] in_atomic(): 0, irqs_disabled(): 1, pid: 4875, name=
: ethtool
>>>> [  254.215042] Pid: 4875, comm: ethtool Tainted: G        W   2.6.=
36-rc3+ #7
>>>> [  254.215049] Call Trace:
>>>> [  254.215050]  [] __might_sleep+0xb1/0xb6
>>>> [  254.215050]  [] mutex_lock+0x17/0x30
>>>> [  254.215050]  [] acpi_enable_wakeup_device_power+0x2b/0xb1
>>>> [  254.215050]  [] acpi_pm_device_sleep_wake+0x42/0x7f
>>>> [  254.215050]  [] acpi_pci_sleep_wake+0x5d/0x63
>>>> [  254.215050]  [] platform_pci_sleep_wake+0x1d/0x20
>>>> [  254.215050]  [] __pci_enable_wake+0x90/0xd0
>>>> [  254.215050]  [] acpi_set_WOL+0x8e/0xf5 [3c59x]
>>>> [  254.215050]  [] vortex_set_wol+0x4e/0x5e [3c59x]
>>>> [  254.215050]  [] dev_ethtool+0x1cf/0xb61
>>>> [  254.215050]  [] ? debug_mutex_free_waiter+0x45/0x4a
>>>> [  254.215050]  [] ? __mutex_lock_common+0x204/0x20e
>>>> [  254.215050]  [] ? __mutex_lock_slowpath+0x12/0x15
>>>> [  254.215050]  [] ? mutex_lock+0x23/0x30
>>>> [  254.215050]  [] dev_ioctl+0x42c/0x533
>>>> [  254.215050]  [] ? _cond_resched+0x8/0x1c
>>>> [  254.215050]  [] ? lock_page+0x1c/0x30
>>>> [  254.215050]  [] ? page_address+0x15/0x7c
>>>> [  254.215050]  [] ? filemap_fault+0x187/0x2c4
>>>> [  254.215050]  [] sock_ioctl+0x1d4/0x1e0
>>>> [  254.215050]  [] ? sock_ioctl+0x0/0x1e0
>>>> [  254.215050]  [] vfs_ioctl+0x19/0x33
>>>> [  254.215050]  [] do_vfs_ioctl+0x424/0x46f
>>>> [  254.215050]  [] ? selinux_file_ioctl+0x3c/0x40
>>>> [  254.215050]  [] sys_ioctl+0x40/0x5a
>>>> [  254.215050]  [] sysenter_do_call+0x12/0x22
>>>>
>>>> vortex_set_wol protected with a spinlock, but nested  acpi_set_WOL=
 acquires a mutex inside atomic context.
>>>> Ethtool operations are already serialized by RTNL mutex, so it is =
safe to drop the locks.
>>>>
>>>> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
>>>> ---
>>>>  drivers/net/3c59x.c |    6 ++----
>>>>  1 files changed, 2 insertions(+), 4 deletions(-)
>>>>
>>>> diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
>>>> index 7a01588..a5c697b 100644
>>>> --- a/drivers/net/3c59x.c
>>>> +++ b/drivers/net/3c59x.c
>>>> @@ -634,6 +634,8 @@ struct vortex_private {
>>>>  		medialock:1,
>>>>  		must_free_region:1,				/* Flag: if zero, Cardbus owns the I/O r=
egion */
>>>>  		large_frames:1;			/* accept large frames */
>>>> +	/* {get|set}_wol operations are already serialized by rtnl.
>>>> +	 * no additional locking is required for the enable_wol and acpi=
_set_WOL() */
>>>
>>> Please format this comment like this :
>>>
>>> 	/* This is a fine ............................
>>> 	 * and long comment ..................................
>>> 	 */
>>>
>>>>  	int drv_flags;
>>>>  	u16 status_enable;
>>>>  	u16 intr_enable;
>>>> @@ -2922,13 +2924,11 @@ static void vortex_get_wol(struct net_devi=
ce *dev, struct ethtool_wolinfo *wol)
>>>>  {
>>>>  	struct vortex_private *vp =3D netdev_priv(dev);
>>>> =20
>>>> -	spin_lock_irq(&vp->lock);
>>>>  	wol->supported =3D WAKE_MAGIC;
>>>> =20
>>>>  	wol->wolopts =3D 0;
>>>>  	if (vp->enable_wol)
>>>>  		wol->wolopts |=3D WAKE_MAGIC;
>>>> -	spin_unlock_irq(&vp->lock);
>>>>  }
>>>> =20
>>>>  static int vortex_set_wol(struct net_device *dev, struct ethtool_=
wolinfo *wol)
>>>> @@ -2937,13 +2937,11 @@ static int vortex_set_wol(struct net_devic=
e *dev, struct ethtool_wolinfo *wol)
>>>>  	if (wol->wolopts & ~WAKE_MAGIC)
>>>>  		return -EINVAL;
>>>> =20
>>>> -	spin_lock_irq(&vp->lock);
>>>>  	if (wol->wolopts & WAKE_MAGIC)
>>>>  		vp->enable_wol =3D 1;
>>>>  	else
>>>>  		vp->enable_wol =3D 0;
>>>>  	acpi_set_WOL(dev);
>>>> -	spin_unlock_irq(&vp->lock);
>>>> =20
>>>>  	return 0;
>>>>  }
>>>
>>>
>> Comments fixed, thanks Eric
>>
>=20
> Yes, but you forgot to submit your patch completely, with changelog a=
nd
> your Signned-off-by ;)
>=20
>> ---
>>  drivers/net/3c59x.c |    7 +++----
>>  1 files changed, 3 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
>> index 7a01588..afcad74 100644
>> --- a/drivers/net/3c59x.c
>> +++ b/drivers/net/3c59x.c
>> @@ -634,6 +634,9 @@ struct vortex_private {
>>  		medialock:1,
>>  		must_free_region:1,				/* Flag: if zero, Cardbus owns the I/O reg=
ion */
>>  		large_frames:1;			/* accept large frames */
>> +	/* {get|set}_wol operations are already serialized by rtnl.
>> +	 * no additional locking is required for the enable_wol and acpi_s=
et_WOL()
>> +	 */
>>  	int drv_flags;
>>  	u16 status_enable;
>>  	u16 intr_enable;
>> @@ -2922,13 +2925,11 @@ static void vortex_get_wol(struct net_device=
 *dev, struct ethtool_wolinfo *wol)
>>  {
>>  	struct vortex_private *vp =3D netdev_priv(dev);
>> =20
>> -	spin_lock_irq(&vp->lock);
>>  	wol->supported =3D WAKE_MAGIC;
>> =20
>>  	wol->wolopts =3D 0;
>>  	if (vp->enable_wol)
>>  		wol->wolopts |=3D WAKE_MAGIC;
>> -	spin_unlock_irq(&vp->lock);
>>  }
>> =20
>>  static int vortex_set_wol(struct net_device *dev, struct ethtool_wo=
linfo *wol)
>> @@ -2937,13 +2938,11 @@ static int vortex_set_wol(struct net_device =
*dev, struct ethtool_wolinfo *wol)
>>  	if (wol->wolopts & ~WAKE_MAGIC)
>>  		return -EINVAL;
>> =20
>> -	spin_lock_irq(&vp->lock);
>>  	if (wol->wolopts & WAKE_MAGIC)
>>  		vp->enable_wol =3D 1;
>>  	else
>>  		vp->enable_wol =3D 0;
>>  	acpi_set_WOL(dev);
>> -	spin_unlock_irq(&vp->lock);
>> =20
>>  	return 0;
>>  }
>=20
>=20
Next attempt. With a changelog :)

Thanks.

[PATCH v2] 3c59x: Remove atomic context inside vortex_{set|get}_wol

There is no need to use spinlocks in vortex_{set|get}_wol.
This also fixes a bug:
[  254.214993] 3c59x 0000:00:0d.0: PME# enabled
[  254.215021] BUG: sleeping function called from invalid context at ke=
rnel/mutex.c:94
[  254.215030] in_atomic(): 0, irqs_disabled(): 1, pid: 4875, name: eth=
tool
[  254.215042] Pid: 4875, comm: ethtool Tainted: G        W   2.6.36-rc=
3+ #7
[  254.215049] Call Trace:
[  254.215050]  [] __might_sleep+0xb1/0xb6
[  254.215050]  [] mutex_lock+0x17/0x30
[  254.215050]  [] acpi_enable_wakeup_device_power+0x2b/0xb1
[  254.215050]  [] acpi_pm_device_sleep_wake+0x42/0x7f
[  254.215050]  [] acpi_pci_sleep_wake+0x5d/0x63
[  254.215050]  [] platform_pci_sleep_wake+0x1d/0x20
[  254.215050]  [] __pci_enable_wake+0x90/0xd0
[  254.215050]  [] acpi_set_WOL+0x8e/0xf5 [3c59x]
[  254.215050]  [] vortex_set_wol+0x4e/0x5e [3c59x]
[  254.215050]  [] dev_ethtool+0x1cf/0xb61
[  254.215050]  [] ? debug_mutex_free_waiter+0x45/0x4a
[  254.215050]  [] ? __mutex_lock_common+0x204/0x20e
[  254.215050]  [] ? __mutex_lock_slowpath+0x12/0x15
[  254.215050]  [] ? mutex_lock+0x23/0x30
[  254.215050]  [] dev_ioctl+0x42c/0x533
[  254.215050]  [] ? _cond_resched+0x8/0x1c
[  254.215050]  [] ? lock_page+0x1c/0x30
[  254.215050]  [] ? page_address+0x15/0x7c
[  254.215050]  [] ? filemap_fault+0x187/0x2c4
[  254.215050]  [] sock_ioctl+0x1d4/0x1e0
[  254.215050]  [] ? sock_ioctl+0x0/0x1e0
[  254.215050]  [] vfs_ioctl+0x19/0x33
[  254.215050]  [] do_vfs_ioctl+0x424/0x46f
[  254.215050]  [] ? selinux_file_ioctl+0x3c/0x40
[  254.215050]  [] sys_ioctl+0x40/0x5a
[  254.215050]  [] sysenter_do_call+0x12/0x22

vortex_set_wol protected with a spinlock, but nested  acpi_set_WOL acqu=
ires a mutex inside atomic context.
Ethtool operations are already serialized by RTNL mutex, so it is safe =
to drop the locks.

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
V2: fixed comments issue

 drivers/net/3c59x.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 7a01588..afcad74 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -634,6 +634,9 @@ struct vortex_private {
 		medialock:1,
 		must_free_region:1,				/* Flag: if zero, Cardbus owns the I/O region=
 */
 		large_frames:1;			/* accept large frames */
+	/* {get|set}_wol operations are already serialized by rtnl.
+	 * no additional locking is required for the enable_wol and acpi_set_=
WOL()
+	 */
 	int drv_flags;
 	u16 status_enable;
 	u16 intr_enable;
@@ -2922,13 +2925,11 @@ static void vortex_get_wol(struct net_device *d=
ev, struct ethtool_wolinfo *wol)
 {
 	struct vortex_private *vp =3D netdev_priv(dev);
=20
-	spin_lock_irq(&vp->lock);
 	wol->supported =3D WAKE_MAGIC;
=20
 	wol->wolopts =3D 0;
 	if (vp->enable_wol)
 		wol->wolopts |=3D WAKE_MAGIC;
-	spin_unlock_irq(&vp->lock);
 }
=20
 static int vortex_set_wol(struct net_device *dev, struct ethtool_wolin=
fo *wol)
@@ -2937,13 +2938,11 @@ static int vortex_set_wol(struct net_device *de=
v, struct ethtool_wolinfo *wol)
 	if (wol->wolopts & ~WAKE_MAGIC)
 		return -EINVAL;
=20
-	spin_lock_irq(&vp->lock);
 	if (wol->wolopts & WAKE_MAGIC)
 		vp->enable_wol =3D 1;
 	else
 		vp->enable_wol =3D 0;
 	acpi_set_WOL(dev);
-	spin_unlock_irq(&vp->lock);
=20
 	return 0;
 }
--=20
1.6.4.4
