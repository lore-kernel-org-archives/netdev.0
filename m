From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: add the sysfs interface to see RLB hash table
Date: Tue, 30 Nov 2010 10:37:58 -0800
Message-ID: <12804.1291142278@death>
References: <4CF4CB85.4010708@jp.fujitsu.com> <1291111829.2904.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:45564 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab0K3SiM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 13:38:12 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oAUIWVS7005718
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 11:32:31 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAUIc36p102328
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 11:38:06 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAUIc2Kh026016
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 11:38:03 -0700
In-reply-to: <1291111829.2904.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:

>Le mardi 30 novembre 2010 =C3=A0 19:01 +0900, Taku Izumi a =C3=A9crit =
:
>> This patch provides the sysfs interface to see RLB hash table
>> like the following:
>>=20
>> # cat /sys/class/net/bond0/bonding/rlb_hash_table
>>=20
>> SourceIP        DestinationIP   Destination MAC   DEV
>>  10.124.196.205  10.124.196. 81 00:19:99:XX:XX:XX eth3
>>  10.124.196.205  10.124.196.222 00:0a:79:XX:XX:XX eth0
>>  10.124.196.205  10.124.196. 75 00:15:17:XX:XX:XX eth4
>>  10.124.196.205  10.124.196.  1 00:21:d8:XX:XX:XX eth3
>>  10.124.196.205  10.124.196.205 ff:ff:ff:ff:ff:ff eth0

	I'm reasonably sure something like this isn't going to be
acceptable in sysfs (it's much too large).

	In the proc file that bonding already uses, this type of
information isn't unreasonable, but I don't think that is the best plac=
e
for this, for two reasons.

	First, the table may have up to 256 entries.  Therefore, a
sufficiently populated table will easily overrun the one page of space
available to a sysfs show function or a proc seq_printf (per iteration)=
,
so it will have to handle that.  The current code in bonding to do its
proc file already iterates over the slaves; adding another iteration
loop to handle this table seems overly complicated.  A well populated
table would also make the current proc file's output rather verbose,
particularly if the TLB table is added later.

	Second, it would have to hold the hash table spin lock, which
may provide an easy way to mess with bonding (user space doing "while 1
cat rlb_hash_table > /dev/null").

	Therefore, I'd suggest this go into debugfs somewhere, perhaps a
/sys/kernel/debug/bonding/rlb_hash_table (perhaps with a tlb_hash_table
as the logical pairing for the TX side), readable only by root.

	Alternatively, if there are objections to using debufs, a new
file in /proc/net/bonding could be used, although that seems cumbersome
(because it would have to be named to avoid conflicts, e.g.,
/proc/net/bonding/bond0_rlb_hash_table).

>why spaces in IP addresses ?
>
>>=20
>> This is helpful to check if the receive load balancing works as expe=
cted.
>>=20
>> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
>>=20
>> ---
>>  drivers/net/bonding/bond_sysfs.c |   56 +++++++++++++++++++++++++++=
++++++++++++
>>  1 file changed, 56 insertions(+)
>>=20
>> Index: net-next/drivers/net/bonding/bond_sysfs.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- net-next.orig/drivers/net/bonding/bond_sysfs.c
>> +++ net-next/drivers/net/bonding/bond_sysfs.c
>> @@ -43,6 +43,7 @@
>>  #include <linux/nsproxy.h>
>>=20
>>  #include "bonding.h"
>> +#include "bond_alb.h"
>>=20
>>  #define to_dev(obj)	container_of(obj, struct device, kobj)
>>  #define to_bond(cd)	((struct bonding *)(netdev_priv(to_net_dev(cd))=
))
>> @@ -1643,6 +1644,60 @@ out:
>>  static DEVICE_ATTR(resend_igmp, S_IRUGO | S_IWUSR,
>>  		   bonding_show_resend_igmp, bonding_store_resend_igmp);
>>=20
>> +/*
>> + *  Show RLB hash table
>> + */
>> +#define RLB_NULL_INDEX  0xffffffff

=09
>> +static ssize_t bonding_show_rlb_hashtable(struct device *d,
>> +					  struct device_attribute *attr,
>> +					  char *buf)
>> +{
>> +	int count =3D 0;
>> +	struct bonding *bond =3D to_bond(d);
>> +	struct alb_bond_info *bond_info =3D &(BOND_ALB_INFO(bond));
>> +	struct rlb_client_info *client_info;
>> +	u32 hash_index;
>> +
>> +	if (bond->params.mode !=3D BOND_MODE_ALB)
>> +		return count;
>> +
>> +	count +=3D sprintf(buf + count, "SourceIP        "
>> +		"DestinationIP   Destination MAC   DEV\n");
>> +
>> +	spin_lock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
>> +
>> +	hash_index =3D bond_info->rx_hashtbl_head;
>> +	for (; hash_index !=3D RLB_NULL_INDEX; hash_index =3D client_info-=
>next) {
>> +		client_info =3D &(bond_info->rx_hashtbl[hash_index]);
>> +
>> +		count +=3D sprintf(buf + count,
>> +			"%3d.%3d.%3d.%3d %3d.%3d.%3d.%3d "
>> +			"%02x:%02x:%02x:%02x:%02x:%02x %s\n",
>
>
>Oh well, I guess you dont read Joe patches on netdev ;)
>
>Please take a look at %pI4 and %pM

	Agreed.

	-J

>sprintf(buf + count, "%pI4 %pI4 %pM %s\n", ...)
>
>
>> +			client_info->ip_src & 0xff,
>> +			(client_info->ip_src >> 8) & 0xff,
>> +			(client_info->ip_src >> 16) & 0xff,
>> +			(client_info->ip_src >> 24) & 0xff,
>> +			client_info->ip_dst & 0xff,
>> +			(client_info->ip_dst >> 8) & 0xff,
>> +			(client_info->ip_dst >> 16) & 0xff,
>> +			(client_info->ip_dst >> 24) & 0xff,
>> +			client_info->mac_dst[0],
>> +			client_info->mac_dst[1],
>> +			client_info->mac_dst[2],
>> +			client_info->mac_dst[3],
>> +			client_info->mac_dst[4],
>> +			client_info->mac_dst[5],
>> +			client_info->slave->dev->name);
>> +	}
>> +
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
