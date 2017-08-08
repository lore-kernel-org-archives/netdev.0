From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next 0/1] netvsc: another VF datapath fix
Date: Tue, 08 Aug 2017 17:42:10 +0200
Message-ID: <87mv7a9ict.fsf@vitty.brq.redhat.com>
References: <20170807183000.10827-1-sthemmin@microsoft.com>
 <87ziba9mwj.fsf@vitty.brq.redhat.com>
 <20170808081506.38bea86c@xeon-e3>
 <87shh29j70.fsf@vitty.brq.redhat.com>
 <20170808082927.128362aa@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, haiyangz@microsoft.com,
 sthemmin@microsoft.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170808082927.128362aa@xeon-e3> (Stephen Hemminger's message of
 "Tue, 8 Aug 2017 08:29:27 -0700")
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Stephen Hemminger <stephen@networkplumber.org> writes:

> On Tue, 08 Aug 2017 17:24:03 +0200
> Vitaly Kuznetsov <vkuznets@redhat.com> wrote:
>
>> Stephen Hemminger <stephen@networkplumber.org> writes:
>> 
>> > On Tue, 08 Aug 2017 16:03:56 +0200
>> > Vitaly Kuznetsov <vkuznets@redhat.com> wrote:
>> >  
>> >> Stephen Hemminger <stephen@networkplumber.org> writes:
>> >>   
>> >> > Previous fix was incomplete.
>> >> >    
>> >> 
>> >> Not really related to this patch series (which btw fixes my issue,
>> >> thanks!), but I found one addition issue. Systemd fails to rename VF
>> >> interface:
>> >> 
>> >>  kernel: mlx4_core 0002:00:02.0 eth2: joined to eth1
>> >>  kernel: hv_netvsc 33b7a6f9-6736-451f-8fce-b382eaa50bee eth1: VF registering: eth2
>> >>  kernel: hv_netvsc 33b7a6f9-6736-451f-8fce-b382eaa50bee eth1: Data path switched to VF: eth2
>> >>  kernel: mlx4_en: eth2: Link Up
>> >>  NetworkManager[750]: <info>  [1502200557.0821] device (eth2): link connected
>> >>  NetworkManager[750]: <info>  [1502200557.1004] manager: (eth2): new Ethernet device (/org/freedesktop/NetworkManager/Devices/6)
>> >>  systemd-udevd[6942]: Error changing net interface name 'eth2' to 'enP2p0s2': Device or resource busy
>> >>  systemd-udevd[6942]: could not rename interface '6' from 'eth2' to 'enP2p0s2': Device or resource busy
>> >> 
>> >> With some debug added I figured out what's wrong: __netvsc_vf_setup()
>> >> does dev_open() which sets IFF_UP flag on the interface. When systemd
>> >> tries to rename the interface we get into dev_change_name() and this
>> >> fails with -EBUSY when (dev->flags & IFF_UP).
>> >> 
>> >> The issue is of less importance as we're not supposed to configure VF
>> >> interface now. However, we may still want to get a stable name for it.
>> >> 
>> >> Any idea how this can be fixed?  
>> >
>> > The problem is Network Manager should ignore the VF device. I don't run NM on these
>> > interfaces because it causes more issues than it helps (dueling userspace).
>> >
>> > The driver needs to have slave track the master interface. Relying on userspace
>> > to bring interface up leads to all the issues the bonding script had.
>> >
>> > One option would be to delay the work of bringing up the slave device to allow
>> > small window for renaming to run.  
>> 
>> Actually, I tried removing 'if (dev->flags & IFF_UP)' check from
>> dev_change_name() and everything seems to work fine. The history of this
>> code predates git so I have no idea why it's forbiden to change names of
>> IFF_UP interfaces... I can send an RFC removing the check to figure out
>> the truth :-)
>
> That only works because NM by default brings everything up.
> Many users don't use NM on servers.

I'm not sure NetworkManager is related here: renaming is done by
systemd/udev according to the "predictable interface names" scheme:
https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/

Basically, systemd/udev tries to rename all new interfaces in the system
according to this scheme. And systemd/udev is ubiquitous nowdays.

I tried disabling NetworkManager in my VM and the behavior is not any
different:

 kernel: mlx4_core 0002:00:02.0 eth2: joined to eth1
 kernel: hv_netvsc 33b7a6f9-6736-451f-8fce-b382eaa50bee eth1: VF registering: eth2
 kernel: mlx4_en: eth2: Link Up
 kernel: hv_netvsc 33b7a6f9-6736-451f-8fce-b382eaa50bee eth1: Data path switched to VF: eth2
 systemd-udevd[1785]: Error changing net interface name 'eth2' to 'enP2p0s2': Device or resource busy
 systemd-udevd[1785]: could not rename interface '5' from 'eth2' to 'enP2p0s2': Device or resource busy

The 'if (dev->flags & IFF_UP)' check in dev_change_name() function
I mentioned prevents renaming interfaces which are already up but I
don't know an obvious reason for it to exist.

-- 
  Vitaly
