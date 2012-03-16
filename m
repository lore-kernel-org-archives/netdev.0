From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next] bonding: remove entries for master_ip and
 vlan_ip and query devices instead
Date: Fri, 16 Mar 2012 09:48:23 -0400
Message-ID: <CAHashqDhq20rqeOEdB0onOkV9yGF-dDKh22Ea4ra1KG21Uc9xQ@mail.gmail.com>
References: <1331742069-16602-1-git-send-email-andy@greyhouse.net>
	<29983.1331859800@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ralf Zeidler <ralf.zeidler@nsn.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44388 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761523Ab2CPNsZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 09:48:25 -0400
Received: by bkcik5 with SMTP id ik5so2915310bkc.19
        for <netdev@vger.kernel.org>; Fri, 16 Mar 2012 06:48:23 -0700 (PDT)
In-Reply-To: <29983.1331859800@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 15, 2012 at 9:03 PM, Jay Vosburgh <fubar@us.ibm.com> wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
>
>>The following patch aimed to resolve an issue where secondary, tertia=
ry,
>>etc. addresses added to bond interfaces could overwrite the
>>bond->master_ip and vlan_ip values.
>>
>> =A0 =A0 =A0 commit 917fbdb32f37e9a93b00bb12ee83532982982df3
>> =A0 =A0 =A0 Author: Henrik Saavedra Persson <henrik.e.persson@ericss=
on.com>
>> =A0 =A0 =A0 Date: =A0 Wed Nov 23 23:37:15 2011 +0000
>>
>> =A0 =A0 =A0 =A0 =A0 bonding: only use primary address for ARP
>>
>>That patch was good because it prevented bonds using ARP monitoring f=
rom
>>sending frames with an invalid source IP address. =A0Unfortunately, i=
t
>>didn't always work as expected.
>>
>>When using an ioctl (like ifconfig does) to set the IP address and
>>netmask, 2 separate ioctls are actually called to set the IP and netm=
ask
>>if the mask chosen doesn't match the standard mask for that class of
>>address. =A0The first ioctl did not have a mask that matched the one =
in
>>the primary address and would still cause the device address to be
>>overwritten. =A0The second ioctl that was called to set the mask woul=
d
>>then detect as secondary and ignored, but the damage was already done=
=2E
>>
>>This was not an issue when using an application that used netlink
>>sockets as the setting of IP and netmask came down at once. =A0The
>>inconsistent behavior between those two interfaces was something that
>>needed to be resolved.
>>
>>While I was thinking about how I wanted to resolve this, Ralf Zeidler
>>came with a patch that resolved this on a RHEL kernel by keeping a fu=
ll
>>shadow of the entries in dev->ifa_list for the bonding device and vla=
n
>>devices in the bonding driver. =A0I didn't like the duplication of th=
e
>>list as I want to see the 'bonding' struct and code shrink rather tha=
n
>>grow, but liked the general idea.
>>
>>As the Subject indicates this patch drops the master_ip and vlan_ip
>>elements from the 'bonding' and 'vlan_entry' structs, respectively.
>>This can be done because a device's address-list is now traversed to
>>determine the optimal source IP address for ARP requests and for chec=
ks
>>to see if the bonding device has a particular IP address. =A0This cod=
e
>>could have all be contained inside the bonding driver, but it made mo=
re
>>sense to me to EXPORT and call inet_confirm_addr since it did exactly
>>what was needed.
>>
>>I tested this and a backported patch and everything works as expected=
=2E
>>Ralf also helped with verification of the backported patch.
>>
>>Thanks to Ralf for all his help on this.
>
> =A0 =A0 =A0 =A0I did not test this, but it looks good to me from insp=
ection.
> I've got a couple of minor style questions, though, below.
>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>
>
>>Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>>CC: Ralf Zeidler <ralf.zeidler@nsn.com>
>>
>>---
>> drivers/net/bonding/bond_main.c | =A0 86 +++++++++------------------=
------------
>> drivers/net/bonding/bonding.h =A0 | =A0 17 +++++++-
>> net/ipv4/devinet.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
>> 3 files changed, 35 insertions(+), 69 deletions(-)
>>
>>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
>>index 435984a..67d58cd 100644
>>--- a/drivers/net/bonding/bond_main.c
>>+++ b/drivers/net/bonding/bond_main.c
>>@@ -2561,12 +2561,18 @@ re_arm:
>> static int bond_has_this_ip(struct bonding *bond, __be32 ip)
>> {
>> =A0 =A0 =A0 struct vlan_entry *vlan;
>>+ =A0 =A0 =A0struct net_device *vlan_dev;
>>
>>- =A0 =A0 =A0if (ip =3D=3D bond->master_ip)
>>+ =A0 =A0 =A0if (ip =3D=3D bond_confirm_addr(bond->dev, 0, ip))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>>
>> =A0 =A0 =A0 list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ip =3D=3D vlan->vlan_ip)
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_lock();
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0vlan_dev =3D __vlan_find_dev_deep(bond->=
dev,
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0vlan->vlan_id);
>
> =A0 =A0 =A0 =A0Can the function call arguments fit on one line?
>
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_unlock();
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0if (vlan_dev &&
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ip =3D=3D bond_confirm_addr(vlan=
_dev, 0, ip))
>
> =A0 =A0 =A0 =A0Similarly, can these be combined on to one line?
>

I could do that.  I only put the newline in there as I wanted to keep
the code under 72 chars wide (more of a personal preference than
anything else).  I'm happy to extend it if a limit of 80 would be fine
with you.

>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> =A0 =A0 =A0 }
>>
>>@@ -2608,7 +2614,7 @@ static void bond_arp_send_all(struct bonding *b=
ond, struct slave *slave)
>> =A0 =A0 =A0 int i, vlan_id;
>> =A0 =A0 =A0 __be32 *targets =3D bond->params.arp_targets;
>> =A0 =A0 =A0 struct vlan_entry *vlan;
>>- =A0 =A0 =A0struct net_device *vlan_dev;
>>+ =A0 =A0 =A0struct net_device *vlan_dev =3D NULL;
>> =A0 =A0 =A0 struct rtable *rt;
>>
>> =A0 =A0 =A0 for (i =3D 0; (i < BOND_MAX_ARP_TARGETS); i++) {
>>@@ -2618,7 +2624,9 @@ static void bond_arp_send_all(struct bonding *b=
ond, struct slave *slave)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!bond_vlan_used(bond)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("basa: empty vl=
an: arp_send\n");
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond_arp_send(slave->dev=
, ARPOP_REQUEST, targets[i],
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0bond->master_ip, 0);
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0bond_confirm_addr(bond->dev,
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0targets[i],
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00), 0);
>
> =A0 =A0 =A0 =A0Same comment here and for the later calls to bond_conf=
irm_addr,
> here putting "targets[i]" and perhaps the 0 on the previous line,
> although I'm less sure that it won't look funky.
>
> =A0 =A0 =A0 =A0-J
>

These we a bit tough to get looking great.  What I did really seemed
like the best I could do and keep it to a reasonable length.  If you
want me to just keep the length of these lines <100 characters wide, I
could combine them into the same line.  Either way is fine with me,
but I really just didn't want the code to get too wide and hard to
read when using a standard size terminal.

>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>>@@ -2644,7 +2652,9 @@ static void bond_arp_send_all(struct bonding *b=
ond, struct slave *slave)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ip_rt_put(rt);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("basa: rtdev =3D=
=3D bond->dev: arp_send\n");
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond_arp_send(slave->dev=
, ARPOP_REQUEST, targets[i],
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0bond->master_ip, 0);
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0bond_confirm_addr(bond->dev,
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0targets[i],
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00), 0);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>>@@ -2662,10 +2672,12 @@ static void bond_arp_send_all(struct bonding =
*bond, struct slave *slave)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0if (vlan_id) {
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0if (vlan_id && vlan_dev) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ip_rt_put(rt);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond_arp_send(slave->dev=
, ARPOP_REQUEST, targets[i],
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0vlan->vlan_ip, vlan_id);
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0bond_confirm_addr(vlan_dev,
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0targets[i],
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00), vlan_id);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>>@@ -3287,68 +3299,10 @@ static int bond_netdev_event(struct notifier_=
block *this,
>> =A0 =A0 =A0 return NOTIFY_DONE;
>> }
>>
>>-/*
>>- * bond_inetaddr_event: handle inetaddr notifier chain events.
>>- *
>>- * We keep track of device IPs primarily to use as source addresses =
in
>>- * ARP monitor probes (rather than spewing out broadcasts all the ti=
me).
>>- *
>>- * We track one IP for the main device (if it has one), plus one per=
 VLAN.
>>- */
>>-static int bond_inetaddr_event(struct notifier_block *this, unsigned=
 long event, void *ptr)
>>-{
>>- =A0 =A0 =A0struct in_ifaddr *ifa =3D ptr;
>>- =A0 =A0 =A0struct net_device *vlan_dev, *event_dev =3D ifa->ifa_dev=
->dev;
>>- =A0 =A0 =A0struct bond_net *bn =3D net_generic(dev_net(event_dev), =
bond_net_id);
>>- =A0 =A0 =A0struct bonding *bond;
>>- =A0 =A0 =A0struct vlan_entry *vlan;
>>-
>>- =A0 =A0 =A0/* we only care about primary address */
>>- =A0 =A0 =A0if(ifa->ifa_flags & IFA_F_SECONDARY)
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0return NOTIFY_DONE;
>>-
>>- =A0 =A0 =A0list_for_each_entry(bond, &bn->dev_list, bond_list) {
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0if (bond->dev =3D=3D event_dev) {
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (event) {
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case NETDEV_UP:
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bond->ma=
ster_ip =3D ifa->ifa_local;
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return N=
OTIFY_OK;
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case NETDEV_DOWN:
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bond->ma=
ster_ip =3D 0;
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return N=
OTIFY_OK;
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return N=
OTIFY_DONE;
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>-
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0list_for_each_entry(vlan, &bond->vlan_li=
st, vlan_list) {
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vlan_dev =3D __vlan_find=
_dev_deep(bond->dev,
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vlan->vlan_id);
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (vlan_dev =3D=3D even=
t_dev) {
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (=
event) {
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case NET=
DEV_UP:
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0vlan->vlan_ip =3D ifa->ifa_local;
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0return NOTIFY_OK;
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case NET=
DEV_DOWN:
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0vlan->vlan_ip =3D 0;
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0return NOTIFY_OK;
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0return NOTIFY_DONE;
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>- =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>- =A0 =A0 =A0}
>>- =A0 =A0 =A0return NOTIFY_DONE;
>>-}
>>-
>> static struct notifier_block bond_netdev_notifier =3D {
>> =A0 =A0 =A0 .notifier_call =3D bond_netdev_event,
>> };
>>
>>-static struct notifier_block bond_inetaddr_notifier =3D {
>>- =A0 =A0 =A0.notifier_call =3D bond_inetaddr_event,
>>-};
>>-
>> /*---------------------------- Hashing Policies --------------------=
---------*/
>>
>> /*
>>@@ -4917,7 +4871,6 @@ static int __init bonding_init(void)
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 register_netdevice_notifier(&bond_netdev_notifier);
>>- =A0 =A0 =A0register_inetaddr_notifier(&bond_inetaddr_notifier);
>> out:
>> =A0 =A0 =A0 return res;
>> err:
>>@@ -4931,7 +4884,6 @@ err_link:
>> static void __exit bonding_exit(void)
>> {
>> =A0 =A0 =A0 unregister_netdevice_notifier(&bond_netdev_notifier);
>>- =A0 =A0 =A0unregister_inetaddr_notifier(&bond_inetaddr_notifier);
>>
>> =A0 =A0 =A0 bond_destroy_debugfs();
>>
>>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bond=
ing.h
>>index 1aecc37..4fc9659 100644
>>--- a/drivers/net/bonding/bonding.h
>>+++ b/drivers/net/bonding/bonding.h
>>@@ -21,6 +21,7 @@
>> #include <linux/cpumask.h>
>> #include <linux/in6.h>
>> #include <linux/netpoll.h>
>>+#include <linux/inetdevice.h>
>> #include "bond_3ad.h"
>> #include "bond_alb.h"
>>
>>@@ -166,7 +167,6 @@ struct bond_parm_tbl {
>>
>> struct vlan_entry {
>> =A0 =A0 =A0 struct list_head vlan_list;
>>- =A0 =A0 =A0__be32 vlan_ip;
>> =A0 =A0 =A0 unsigned short vlan_id;
>> };
>>
>>@@ -232,7 +232,6 @@ struct bonding {
>> =A0 =A0 =A0 struct =A0 list_head bond_list;
>> =A0 =A0 =A0 struct =A0 netdev_hw_addr_list mc_list;
>> =A0 =A0 =A0 int =A0 =A0 =A0(*xmit_hash_policy)(struct sk_buff *, int=
);
>>- =A0 =A0 =A0__be32 =A0 master_ip;
>> =A0 =A0 =A0 u16 =A0 =A0 =A0rr_tx_counter;
>> =A0 =A0 =A0 struct =A0 ad_bond_info ad_info;
>> =A0 =A0 =A0 struct =A0 alb_bond_info alb_info;
>>@@ -378,6 +377,20 @@ static inline bool bond_is_slave_inactive(struct=
 slave *slave)
>> =A0 =A0 =A0 return slave->inactive;
>> }
>>
>>+static inline __be32 bond_confirm_addr(struct net_device *dev, __be3=
2 dst, __be32 local)
>>+{
>>+ =A0 =A0 =A0struct in_device *in_dev;
>>+ =A0 =A0 =A0__be32 addr =3D 0;
>>+
>>+ =A0 =A0 =A0rcu_read_lock();
>>+ =A0 =A0 =A0in_dev =3D __in_dev_get_rcu(dev);
>>+ =A0 =A0 =A0rcu_read_unlock();
>>+
>>+ =A0 =A0 =A0if (in_dev)
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0addr =3D inet_confirm_addr(in_dev, dst, =
local, RT_SCOPE_HOST);
>>+ =A0 =A0 =A0return addr;
>>+}
>>+
>> struct bond_net;
>>
>> struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_=
entry *curr);
>>diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
>>index e41c40f..d4fad5c 100644
>>--- a/net/ipv4/devinet.c
>>+++ b/net/ipv4/devinet.c
>>@@ -1079,6 +1079,7 @@ __be32 inet_confirm_addr(struct in_device *in_d=
ev,
>>
>> =A0 =A0 =A0 return addr;
>> }
>>+EXPORT_SYMBOL(inet_confirm_addr);
>>
>> /*
>> =A0* =A0 =A0Device notifier
>>--
>>1.7.4.4
>
> ---
> =A0 =A0 =A0 =A0-Jay Vosburgh, IBM Linux Technology Center, fubar@us.i=
bm.com
>
