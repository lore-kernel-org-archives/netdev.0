From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [patch net-next V7] net: introduce ethernet teaming device
Date: Fri, 11 Nov 2011 17:58:45 -0200
Message-ID: <20111111175845.10c82c3c@asterix.rh>
References: <1320939698-1062-1-git-send-email-jpirko@redhat.com>
	<20111111160441.5ab366cc@asterix.rh>
	<20111111170509.581c4ca2@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com, jesse@nicira.com,
	benjamin.poirier@gmail.com, jzupka@redhat.com, ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689Ab1KKT7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Nov 2011 14:59:07 -0500
In-Reply-To: <20111111170509.581c4ca2@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Nov 2011 17:05:09 -0200
Flavio Leitner <fbl@redhat.com> wrote:

> On Fri, 11 Nov 2011 16:04:41 -0200
> Flavio Leitner <fbl@redhat.com> wrote:
> 
> > On Thu, 10 Nov 2011 16:41:38 +0100
> > Jiri Pirko <jpirko@redhat.com> wrote:
> > 
> > > This patch introduces new network device called team. It supposes to be
> > > very fast, simple, userspace-driven alternative to existing bonding
> > > driver.
> > > 
> > > Userspace library called libteam with couple of demo apps is available
> > > here:
> > > https://github.com/jpirko/libteam
> > > Note it's still in its dipers atm.
> > > 
> > > team<->libteam use generic netlink for communication. That and rtnl
> > > suppose to be the only way to configure team device, no sysfs etc.
> > > 
> > > Python binding of libteam was recently introduced.
> > > Daemon providing arpmon/miimon active-backup functionality will be
> > > introduced shortly. All what's necessary is already implemented in
> > > kernel team driver.
> > > 
> > > Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> > > 
> > > v6->v7:
> > > 	- transmit and receive functions are not checked in hot paths.
> > > 	  That also resolves memory leak on transmit when no port is
> > > 	  present
> > > 
> > 
> > You're right. No need to patch those function names if we use libnl
> > from git.
> > 
> > [...]
> > > +static void team_vlan_rx_add_vid(struct net_device *dev, uint16_t vid)
> > > +{
> > > +	struct team *team = netdev_priv(dev);
> > > +	struct team_port *port;
> > > +
> > > +	rcu_read_lock();
> > > +	list_for_each_entry_rcu(port, &team->port_list, list) {
> > > +		const struct net_device_ops *ops = port->dev->netdev_ops;
> > > +
> > > +		ops->ndo_vlan_rx_add_vid(port->dev, vid);
> > 
> > This causes a oops when enslaving a tg3 device because there is
> > no ndo_vlan_rx_add_vid().
> > 
> Sorry, I should have said when bring team0 up:
> 
> [root@f16i7 ~]# ip link set team0 up
> Killed
> 
> BUG: unable to handle kernel NULL pointer dereference at           (null)
> IP: [<          (null)>]           (null)
> PGD 18ee5b067 PUD 18d9cd067 PMD 0
> Oops: 0010 [#1] SMP
> d_timer snd soundcore snd_page_alloc pl2303 usbserial iTCO_wdt iTCO_vendor_support raid0 i2c_i801 pcspkr microcode serio_raw uinput floppy joydev ipv6 autofs4 ata_generic firewire_ohci pata_acpi firewire_core crc_itu_t pata_marvell nouveau ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core mxm_wmi wmi video [last unloaded: scsi_wait_scan]
> 
> Pid: 21877, comm: ip Not tainted 3.2.0-rc1-10901-g40709d7 #31                  /DX58SO
> RIP: 0010:[<0000000000000000>]  [<          (null)>]           (null)
> RSP: 0018:ffff88018eecd6a0  EFLAGS: 00010283
> RAX: ffffffffa02a4370 RBX: ffff8801a4d04500 RCX: 0000000000000e7f
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff880198356000
> RBP: ffff88018eecd6d8 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000000 R11: ffff880181d57600 R12: 0000000000000000
> R13: ffff8801a526f7d8 R14: ffffffffa032f0c0 R15: 0000000000000000
> FS:  00007f52ae475700(0000) GS:ffff8801afcc0000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000000 CR3: 00000001983ab000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process ip (pid: 21877, threadinfo ffff88018eecc000, task ffff88018db8aea0)
>

I patched the kernel to test if there is ops->ndo_vlan_rx_add_vid before
call it and works out, no more oopses.

Well, as there is no active-backup daemon yet (right?), only the link
notification is sent to team_monitor when I remove the cable from the
NIC, so I have to switch manually active and backup slaves.

ping -f, ssh, and a script to change active slave every second are 
running in parallel. 

I haven't noticed any other issue so far.
fbl
