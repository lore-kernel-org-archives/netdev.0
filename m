From: Cong Wang <amwang@redhat.com>
Subject: Re: [v2 Patch 3/3] bonding: make bonding support netpoll
Date: Tue, 06 Apr 2010 10:43:39 +0800
Message-ID: <4BBA9FDB.4040909@redhat.com>
References: <20100405091605.4890.31181.sendpatchset@localhost.localdomain> <20100405091628.4890.30541.sendpatchset@localhost.localdomain> <20100405194356.GA10488@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100405194356.GA10488@gospo.rdu.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek wrote:
> 
> I tried these patches on top of Linus' latest tree and still get
> deadlocks.  Your line numbers might differ a bit, but you should be
> seeing them too.
> 


Yeah, my local clone is some days behind Linus' latest tree. :)


> # echo 7 4 1 7 > /proc/sys/kernel/printk 
> # ifup bond0 
> bonding: bond0: setting mode to balance-rr (0).                                                 
> bonding: bond0: Setting MII monitoring interval to 1000.                                        
> ADDRCONF(NETDEV_UP): bond0: link is not ready                                                   
> bonding: bond0: Adding slave eth4.                                                              
> bnx2 0000:10:00.0: eth4: using MSIX                                                             
> bonding: bond0: enslaving eth4 as an active interface with a down link.                         
> bonding: bond0: Adding slave eth5.                                                              
> bnx2 0000:10:00.1: eth5: using MSIX                                                             
> bonding: bond0: enslaving eth5 as an active interface with a down link.                         
> bnx2 0000:10:00.0: eth4: NIC Copper Link is Up, 100 Mbps full duplex,
> receive & transmit flow control ON
> bonding: bond0: link status definitely up for interface eth4.                                   
> ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready                                              
> bnx2 0000:10:00.1: eth5: NIC Copper Link is Up, 100 Mbps full duplex,
> receive & transmit flow control ON
> bond0: IPv6 duplicate address fe80::210:18ff:fe36:ad4 detected!                                 
> bonding: bond0: link status definitely up for interface eth5.                                   
> # cat /proc/net/bonding/bond0                                                    
> Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)                                    
>                                                                                                 
> Bonding Mode: load balancing (round-robin)                                                      
> MII Status: up                                                                                  
> MII Polling Interval (ms): 1000                                                                 
> Up Delay (ms): 0                                                                                
> Down Delay (ms): 0                                                                              
>                                                                                                 
> Slave Interface: eth4                                                                           
> MII Status: up                                                                                  
> Link Failure Count: 0
> Permanent HW addr: 00:10:18:36:0a:d4
> 
> Slave Interface: eth5
> MII Status: up
> Link Failure Count: 0
> Permanent HW addr: 00:10:18:36:0a:d6
> # modprobe netconsole 
> netconsole: local port 1234
> netconsole: local IP 10.0.100.2
> netconsole: interface 'bond0'
> netconsole: remote port 6666
> netconsole: remote IP 10.0.100.1
> netconsole: remote ethernet address 00:e0:81:71:ee:aa
> console [netcon0] enabled
> netconsole: network logging started
> # echo -eth4 > /sys/class/net/bond0/bonding/slaves  
> bonding: bond0: Removing slave eth4
> 
> [ now the system is hung ]
> 
> My suspicion from dealing with this problem in the past is that there is
> contention over bond->lock.
> 
> Since there statements that will result in netconsole messages inside
> the write_lock_bh in bond_release:
> 
> 1882         write_lock_bh(&bond->lock);
> 1883 
> 1884         slave = bond_get_slave_by_dev(bond, slave_dev);
> 1885         if (!slave) {
> 1886                 /* not a slave of this bond */
> 1887                 pr_info("%s: %s not enslaved\n",
> 1888                         bond_dev->name, slave_dev->name);
> 1889                 write_unlock_bh(&bond->lock);
> 1890                 return -EINVAL;
> 1891         }
> 1892 
> 1893         if (!bond->params.fail_over_mac) {
> 1894                 if (!compare_ether_addr(bond_dev->dev_addr, slave->perm_hwaddr) &&
> 1895                     bond->slave_cnt > 1)
> 1896                         pr_warning("%s: Warning: the permanent HWaddr of %s - %pM - is still in use by %s.
> 
> we are getting stuck at 1986 since bond_xmit_roundrobin (in my case)
> will try and acquire bond->lock for reading.
> 
> One valuable aspect netpoll_start_xmit routine was that is could be used
> to check to be sure that bond->lock could be taken for writing.  This
> made us sure that we were not in a call stack that has already taken the
> lock and queuing the skb to be sent later would prevent the imminent
> deadlock.
> 
> A way to prevent this is needed and a first-pass might be to do
> something similar to what I below above for all the xmit routines.  I
> confirmed the following patch prevents that deadlock:
> 
> # git diff drivers/net/bonding/
> diff --git a/drivers/net/bonding/bond_main.c
> b/drivers/net/bonding/bond_main.c
> index 4a41886..53b39cc 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4232,7 +4232,8 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struc
>         int i, slave_no, res = 1;
>         struct iphdr *iph = ip_hdr(skb);
>  
> -       read_lock(&bond->lock);
> +       if (!read_trylock(&bond->lock))
> +               return NETDEV_TX_BUSY;
>  
>         if (!BOND_IS_OK(bond))
>                 goto out;
> 
> The kernel no longer hangs, but a new warning message shows up (over
> netconsole even!):
> 
> ------------[ cut here ]------------
> WARNING: at kernel/softirq.c:143 local_bh_enable+0x43/0xba()
> Hardware name: HP xw4400 Workstation
> Modules linked in: tg3 netconsole bonding ipt_REJECT bridge stp autofs4
> i2c_dev i2c_core hidp rfcomm l2cap crc16 bluetooth rfkill sunrpc 8021q
> iptable_filter ip_tables ip6t_REJECT xt_tcpudp ip6table_filter
> ip6_tables x_tables ipv6 cpufreq_ondemand acpi_cpufreq dm_multipath
> video output sbs sbshc battery acpi_memhotplug ac lp sg ide_cd_mod
> tpm_tis rtc_cmos rtc_core serio_raw cdrom libphy e1000e floppy
> parport_pc parport button tpm tpm_bios bnx2 rtc_lib tulip pcspkr shpchp
> dm_snapshot dm_zero dm_mirror dm_region_hash dm_log dm_mod ata_piix ahci
> libata sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last
> unloaded: tg3]
> Pid: 9, comm: events/0 Not tainted 2.6.34-rc3 #6
> Call Trace:
>  [<ffffffff81058754>] ? cpu_clock+0x2d/0x41
>  [<ffffffff810404d9>] ? local_bh_enable+0x43/0xba
>  [<ffffffff8103a350>] warn_slowpath_common+0x77/0x8f
>  [<ffffffff812a4659>] ? dev_queue_xmit+0x408/0x467
>  [<ffffffff8103a377>] warn_slowpath_null+0xf/0x11
>  [<ffffffff810404d9>] local_bh_enable+0x43/0xba
>  [<ffffffff812a4659>] dev_queue_xmit+0x408/0x467
>  [<ffffffff812a435e>] ? dev_queue_xmit+0x10d/0x467
>  [<ffffffffa04a3868>] bond_dev_queue_xmit+0x1cd/0x1f9 [bonding]
>  [<ffffffffa04a4217>] bond_start_xmit+0x139/0x3e9 [bonding]
>  [<ffffffff812b0e9a>] queue_process+0xa8/0x160
>  [<ffffffff812b0df2>] ? queue_process+0x0/0x160
>  [<ffffffff81003794>] kernel_thread_helper+0x4/0x10
>  [<ffffffff813362bc>] ? restore_args+0x0/0x30
>  [<ffffffff81053884>] ? kthread+0x0/0x85
> 
> to point out possible locking issues (probably in netpoll_send_skb) that
> I would suggest you investigate further.  It may point to why we cannot
> perform an:
> 
> # rmmod bonding
> 
> without the system deadlocking (even with my patch above).
> 

Thanks a lot for testing!

Before I try to reproduce it, could you please try to replace the 'read_lock()'
in slaves_support_netpoll() with 'read_lock_bh()'? (read_unlock() too) Try if this helps.

After I reproduce this, I will try it too.
