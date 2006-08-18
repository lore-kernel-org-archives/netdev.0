From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: lockdep: adding bonding device triggers warning
Date: Fri, 18 Aug 2006 14:46:28 +0200
Message-ID: <1155905188.4494.177.camel@laptopd505.fenrus.org>
References: <20060815181103.GA9690@nostromo.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:15341 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1030194AbWHRMqu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 08:46:50 -0400
To: Bill Nottingham <notting@redhat.com>
In-Reply-To: <20060815181103.GA9690@nostromo.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-15 at 14:11 -0400, Bill Nottingham wrote:
> 2.6.17-1.2564.fc6 is 2.6.18rc4+.
> 
> Happened with 'echo "+bond0" > /sys/class/net/bonding_masters'
> 
> bonding: bond0 is being created...
> 
> =======================================================
> [ INFO: possible circular locking dependency detected ]
> 2.6.17-1.2564.fc6 #1
> -------------------------------------------------------
> bash/9497 is trying to acquire lock:
>  (rtnl_mutex){--..}, at: [<c0612860>] mutex_lock+0x21/0x24
> 
> but task is already holding lock:
>  (&bonding_rwsem){----}, at: [<f8c332e0>] bonding_store_bonds+0x28/0x1c6 [bonding]
> 
> which lock already depends on the new lock.


looks like a real deadlock:

SIOCSIFNAME ioctl takes  rtnl_lock() then calls dev_ifsioc which calls
dev_change_name which calls the netdev_chain notifier... which ends up
calling bond_event_changename() which does:
        down_write(&(bonding_rwsem));


on the other hand, bonding_store_bonds() does 
        down_write(&(bonding_rwsem));
then calls bond_create() which does:
int bond_create(char *name, struct bond_params *params, struct bonding
**newbond)
{
        struct net_device *bond_dev;
        int res;

        rtnl_lock();

since these both are global locks and not per device locks, this really
does look like an AB-BA deadlock to me....


-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com

