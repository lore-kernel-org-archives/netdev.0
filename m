From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: prevent deadlock on slave store with alb mode
Date: Tue, 24 May 2011 23:32:08 +0200
Message-ID: <4DDC23D8.80905@gmail.com>
References: <1306265765-8257-1-git-send-email-nhorman@tuxdriver.com> <20110524200047.GI21309@gospo.rdu.redhat.com> <4DDC116F.8020602@gmail.com> <20110524203714.GG28521@hmsreliant.think-freely.org> <4DDC1A4E.6080700@gmail.com> <12577.1306271574@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46355 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648Ab1EXVcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 17:32:10 -0400
Received: by wya21 with SMTP id 21so5330735wya.19
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 14:32:09 -0700 (PDT)
In-Reply-To: <12577.1306271574@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/05/2011 23:12, Jay Vosburgh a =C3=A9crit :
> Nicolas de Peslo=C3=BCan<nicolas.2p.debian@gmail.com>  wrote:
>
>> Le 24/05/2011 22:37, Neil Horman a =C3=A9crit :
>>
>>>>>> +		return -EINVAL;
>>>>
>>>> This will turn a warning into an error.
>>>>
>>> Yes, because it should have been an error all along.
>>>
>>>> This warning existed for long, but never caused the bonding setup =
to
>>>> fail. This patch cause some regression for user space. For example=
,
>>>> current ifenslave-2.6 package in Debian doesn't ensure bond is UP
>>>> before enslaving, because this was never required.
>>>>
>>> Thats not a regression, thats the kernel returning an error where i=
t should have
>>> done so all along.  Just because a utility got away with it for awh=
ile and it
>>> didn't always cause a lockup, doesn't grandfather that application =
in to a
>>> situation where the kernel has to support its broken behavior in pe=
rpituity.
>>>
>>> Besides, iirc, the ifsenslave utility still uses the ioctl path, wh=
ich this
>>> patch doesn't touch, so ifenslave is currently unaffected (although=
 I should
>>> look in the ioctl path to see if we have already added such a check=
, lest you be
>>> able to deadlock your system as previously indicated using that too=
l).
>>
>> Unfortunately, no. Recent versions of ifenslave-2.6 on Debian don't =
use
>> ioctl (ifenslave binary) anymore, but only sysfs.
>>
>> Documentation/bonding.txt should be updated to reflect this change.
>> pr_warning should be changed to pr_ err.
>> Bonding version should be bumped.
>>
>> Anyway, I will fix this package, but I suspect there exist many user
>> scripts that don't ensure bond is up before enslaving.
>
> 	I looked at sysconfig (as supplied with opensuse) and it uses
> sysfs, and does set the master device up first.  The other potential
> user that comes to mind is that OFED at one point had a script to set=
 up
> bonding for Infiniband devices.  I don't know if this is still the ca=
se,
> nor do I know if it set the bond device up before enslaving.
>
> 	Generally speaking, though, in the long run I think it should be
> permissible to change any bonding option when the bond is down (even =
to
> values that make no sense in context, e.g., setting the primary to a
> device not currently enslaved).  My rationale here is that some optio=
ns
> are very difficult to modify when the bond is up (e.g., changing the
> mode), and now some other set is precluded when the bond is down.  Th=
e
> init scripts already have repeat logic in them; this just makes thing=
s
> more complicated.
>
> 	There should be a state wherein any option can be changed (well,
> maybe not max_bonds), and that should be the down state.  A subset ca=
n
> also be changed while up.  I'd be happy to be able to change all opti=
ons
> while the bond is up, too, but that seems pretty hard to do.
>
> 	How much harder is it to fix the locking and permit the action
> in question here?

To add to the comment by Jay, here is an extract from the more up to da=
te version of the script that=20
setup bonding on Debian (/etc/network/if-pre-up.d/ifenslave, from ifens=
lave-2.6 package):

# early_setup_master is the place where we do master setup that need to=
 be done before enslavement.
early_setup_master()
{
         # Warning: the order in wich we write into the sysfs files is =
important.
         # Double check in drivers/net/bonding/bond_sysfs.c in linux ke=
rnel source tree
         # before changing anything here.

         # fail_over_mac must be set before enslavement of any slaves.
         sysfs fail_over_mac "$IF_BOND_FAIL_OVER_MAC"
}

setup_master()
{
         # Warning: the order in wich we write into the sysfs files is =
important.
         # Double check in drivers/net/bonding/bond_sysfs.c in linux ke=
rnel source tree
         # before changing anything here.

         # use_carrier can be set anytime.
         sysfs use_carrier "$IF_BOND_USE_CARRIER"
         # num_grat_arp can be set anytime.
         sysfs num_grat_arp "$IF_BOND_NUM_GRAT_ARP"
         # num_unsol_na can be set anytime.
         sysfs num_unsol_na "$IF_BOND_NUM_UNSOL_NA"

         # xmit_hash_policy can be set anytime.
         # Changing xmit_hash_policy requires $BOND_MASTER to be down.
         sysfs_change_down xmit_hash_policy "$IF_BOND_XMIT_HASH_POLICY"

         # arp_ip_target must be set before arp_interval.
         sysfs_add arp_ip_target "$IF_BOND_ARP_IP_TARGET"
         sysfs arp_interval "$IF_BOND_ARP_INTERVAL"

         # miimon must be set before updelay and downdelay.
         sysfs miimon "$IF_BOND_MIIMON"
         sysfs downdelay "$IF_BOND_DOWNDELAY"
         sysfs updelay "$IF_BOND_UPDELAY"

         # Changing ad_select requires $BOND_MASTER to be down.
         sysfs_change_down ad_select "$IF_BOND_AD_SELECT"

         # Changing mode requires $BOND_MASTER to be down.
         # Mode should be set after miimon or arp_interval, to avoid a =
warning in syslog.
         sysfs_change_down mode "$IF_BOND_MODE"

         # arp_validate must be after mode (because mode must be active=
-backup).
         sysfs arp_validate "$IF_BOND_ARP_VALIDATE"

         # lacp_rate must be set after mode (because mode must be 802.3=
ad).
         # Changing lacp_rate requires $BOND_MASTER to be down.
         sysfs_change_down lacp_rate "$IF_BOND_LACP_RATE"

         # primary must be set after mode (because only supported in so=
me modes) and after enslavement.
         # The first slave in bond-primary found in current slaves beco=
mes the primary.
         # If no slave in bond-primary is found, then primary does not =
change.
         for slave in $IF_BOND_PRIMARY ; do
                 if grep -sq "\\<$slave\\>" "/sys/class/net/$BOND_MASTE=
R/bonding/slaves" ; then
                         sysfs primary "$slave"
                         break
                 fi
         done

         # primary_reselect should be set after mode (because only supp=
orted in some modes), after=20
enslavement
         # and after primary. This is currently (2.6.35-rc1) not enforc=
ed by the bonding driver, but=20
it is
         # probably safer to do it in that order.
         sysfs primary_reselect "$IF_BOND_PRIMARY_RESELECT"

         # queue_id must be set after enslavement.
         for iface_queue_id in $IF_BOND_QUEUE_ID
         do
                 sysfs iface_queue_id $iface_queue_id
         done

         # active_slave must be set after mode and after enslavement.
         # The slave must be up and the underlying link must be up too.
         # FIXME: We should have a way to write an empty string to acti=
ve_slave, to set the=20
active_slave to none.
         if [ "$IF_BOND_ACTIVE_SLAVE" ] ; then
                 # Need to force interface up before. Bonding will refu=
se to activate a down interface.
                 ip link set "$IF_BOND_ACTIVE_SLAVE" up
                 sysfs active_slave "$IF_BOND_ACTIVE_SLAVE"
         fi

         # Force $BOND_MASTER to be up, if we are called from a slave s=
tanza.
         [ "$IFACE" !=3D "$BOND_MASTER" ] && ip link set dev "$BOND_MAS=
TER" up
}

In order to fix some of the reported problems with some previous versio=
ns of this script, I had to=20
conduct a detailed code review of bond_sysfs.c and eventually end up wi=
th this current version,=20
where I documented all the constraints I discovered.

bonding sysfs currently enforce many constraints on the exact order of =
the setup. As noted by Jay,=20
some setup need to be done while the master if down, some while the mas=
ter is up, some need to be=20
done before the first enslavement, some must be done after the referenc=
ed slave is enslaved, some=20
are only allowed if mode is properly set before, and so on...

I though for long about adding this into Documentation/networking/bondi=
ng.txt, but fail to find the=20
time to do so.

Arguably, it would be better to spend time to remove those constraints =
than to document them.

	Nicolas.
