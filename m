From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Network namespace and bonding WARNING at fs/proc/generic.c remove_proc_entry
Date: Thu, 05 Jul 2012 17:41:54 -0700
Message-ID: <87ehopu3e5.fsf@xmission.com>
References: <1340900320.3441.88.camel@pro6455b.example.com>
	<20120705220749.GA11255@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dilip Daya <dilip.daya@hp.com>, linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org, <netdev@vger.kernel.org>
To: "Serge E. Hallyn" <serge@hallyn.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120705220749.GA11255@mail.hallyn.com> (Serge E. Hallyn's
	message of "Thu, 5 Jul 2012 22:07:49 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Serge E. Hallyn" <serge@hallyn.com> writes:

> Quoting Dilip Daya (dilip.daya@hp.com):
>> Hi,
>> 
>> I'd discussed the following with Serge Hallyn.
>> 
>> => Environment based on 3.2.18 / x86_64 kernel.
>> => WARNING: at fs/proc/generic.c:808 remove_proc_entry+0xdb/0x21f()
>> => WARNING: at fs/proc/generic.c:849 remove_proc_entry+0x208/0x21f()
>
> Hi,
>
> thanks much for sending this.  I'm still getting this error on
> 3.5.0-2-generic (today's ubuntu quantal kernel)
>
>> network namespace and bonding
>> -----------------------------
>> 
>> * Migrate two phy nics from host to netns (netns0).
>>   - ip link set ethX netns netns0
>> 
>> * In host environment:
>>   - load bonding module, /sbin/modprobe -v bonding mode=1 miimon=100
>>   - /sys/class/net/bond0 exists.
>>   - /proc/net/bonding/bond0 exists.
>>   - /sys/class/net/bonding_masters has bond0.
>> 
>> * Migrate bond0 to netns (netns0):
>>   - ip link set bond0 netns netns0.
>> 
>> * Within netns (netns0):
>>   - /sys/class/net/bonding_masters is empty.
>>   - /sys/class/net/bond0 exist.
>>   - configure bond0 and ifenslave with two phy nics.
>>   - /proc/net/bonding/bond0 does not exist within netns0, but does
>>     exist in the host environment.
>>   - /sys/class/net/bonding_masters is empty.
>
> mine is not empty, fwiw.  However
>
>>   - ping to remote end of bond0 works.
>> 
>> * Within netns (netns0), flushing ethX and bondY:
>>   - down bond0 and its phy nic interfaces:
>>   - ip link set ... down
>>   - ip addr flush dev [bond0 | eth#]
>>   - deleting bond0, /sbin/ip link del dev bond0
>
> Yup I still get a remove_proc_entry WARNING at fs/proc/generic.c:808,
> which is the warning when (!de)

It looks like Dilip is running an old kernel.  There should have been
some version of /sys/class/net/bonding_masters in every network
namespace since sometime in 2009.

>From the warning it looks like the proc files are being added/removed
to the wrong network namespace.  So in one namespace we get an error
when we delete the moved device and in the other network namespace
we get an error when we remove the /proc/directory.

An old kernel without proper network namespace support is the only
reason I can imagine someone would be moving an existing bond device
between network namespaces.

If there are other reasons for wanting to move a bonding device between
network namespaces it is possible to catch the NETDEV_UNREGISTER and
NETDEV_REGISTER events to remove/add the per device proc files at the
appropriate time.

However since moving bonding devices appears to be an unneded operation
let's just do things simply and forbid moving bonding devices between
network namespaces.  Serge, Dilip can you two test the patch below
and see if it fixes the warnings.

Eric


diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2ee8cf9..818ed64 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4345,6 +4345,9 @@ static void bond_setup(struct net_device *bond_dev)
        bond_dev->priv_flags |= IFF_BONDING;
        bond_dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
 
+       /* Don't allow bond devices to change network namespaces. */
+       bond_dev->features |= NETIF_F_LOCAL;
+
        /* At first, we block adding VLANs. That's the only way to
         * prevent problems that occur when adding VLANs over an
         * empty bond. The block will be removed once non-challenged
