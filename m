From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Fix race condition about network device name allocation
Date: Wed, 13 Jun 2007 09:36:31 -0700
Message-ID: <20070613093631.42a45916@localhost>
References: <1178862045.3979.33.camel@kane-linux>
	<20070511092519.1f34ab34@freepuppy>
	<1179130660.3881.23.camel@kane-linux>
	<20070514085840.17a343f7@freepuppy>
	<20070613094521.GA8860@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Dan Aloni <da-x@monatomic.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37584 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752012AbXFMQhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 12:37:24 -0400
In-Reply-To: <20070613094521.GA8860@localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Jun 2007 12:45:21 +0300
Dan Aloni <da-x@monatomic.org> wrote:

> On Mon, May 14, 2007 at 08:58:40AM -0700, Stephen Hemminger wrote:
> > Kenji Kaneshige found this race between device removal and
> > registration.  On unregister it is possible for the old device to
> > exist, because sysfs file is still open.  A new device with 'eth%d'
> > will select the same name, but sysfs kobject register will fial.
> > 
> > The following changes the shutdown order slightly. It hold a removes the sysfs
> > entries earlier (on unregister_netdevice), but holds a kobject reference.
> > Then when todo runs the actual last put free happens.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> That patch breaks the bonding driver. After reverting it I avoid this crash:
> 
> <6>[1115260.637351] Ethernet Channel Bonding Driver: v3.1.2 (January 20, 2007)
> <6>[1115260.637358] bonding: MII link monitoring set to 100 ms
> <6>[1115260.637767] bonding: bond0 is being deleted...
> <1>[1115260.695812] Unable to handle kernel NULL pointer dereference at 0000000000000020 RIP: 
> <1>[1115260.701504]  [<ffffffff802805e2>] __lookup_hash+0x22/0x150
> <6>[1115260.709754] PGD 798bf067 PUD 798c4067 PMD 0 
> <0>[1115260.714394] Oops: 0000 [1] SMP 
> [1]kdb> 
> [1]kdb> btc
> btc: cpu status: Currently on cpu 1
> Available cpus: 0(I), 1
> Stack traceback for pid 0
> 0xffffffff80585420        0        0  1    0   I  0xffffffff80585710  swapper
> rsp                rip                Function (args)
> 0xffffffff8066feb0 0xffffffff8046783f thread_return+0x5e
> 0xffffffff8066fec0 0xffffffff80469df9 _spin_unlock_irq+0x9
> 0xffffffff8066ff28 0xffffffff80209176 mwait_idle+0x46
> 0xffffffff8066ff50 0xffffffff802088e2 enter_idle+0x22
> 0xffffffff8066ff60 0xffffffff802090bc cpu_idle+0x5c
> 0xffffffff8066ff80 0xffffffff80207146 rest_init+0x26
> 0xffffffff8066ff90 0xffffffff80678c1a start_kernel+0x2ea
> 0xffffffff8066ffc0 0xffffffff8067815f _sinittext+0x15f
> Stack traceback for pid 66
> 0xffff81006a411850       66        1  1    1   R  0xffff81006a411b40 *platform_node
> rsp                rip                Function (args)
> 0xffff81006a46dd98 0xffffffff802805e2 __lookup_hash+0x22
> 0xffff81006a46de00 0xffffffff80280cba lookup_one_len+0x9a
> 0xffff81006a46de20 0xffffffff802be671 sysfs_remove_group+0x31
> 0xffff81006a46de50 0xffffffff8800fe4a [bonding]bond_destroy_sysfs_entry+0x1a
> 0xffff81006a46de60 0xffffffff88011974 [bonding]bonding_store_bonds+0x214
> 0xffff81006a46deb0 0xffffffff8037c9d4 class_attr_store+0x24
> [1]more> 
> 0xffff81006a46dec0 0xffffffff802bbe30 sysfs_write_file+0x100
> 0xffff81006a46df10 0xffffffff80277d7e vfs_write+0xbe
> 0xffff81006a46df40 0xffffffff80278400 sys_write+0x50
> 0xffff81006a46df80 0xffffffff80209e6e system_call+0x7e
> 

I assume this happens when bonded slave device is removed?
Which kernel version?
