From: Michael Chan <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] cnic: don't take the rtnl_read_lock in
 cnic_rcv_netevent
Date: Fri, 30 May 2014 13:58:33 -0700
Message-ID: <1401483513.9728.158.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1401462019-7958-1-git-send-email-nhorman@tuxdriver.com>
 <1401472691.9728.145.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <20140530200311.GG3144@hmsreliant.think-freely.org>
 <1401480820.9728.148.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <20140530203823.GH3144@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <20140530203823.GH3144-B26myB8xz7F8NnZeBjwnZQMhkBWG/bsMQH7oEaQurus@public.gmane.org>
List-Unsubscribe: <http://lists.open-fcoe.org/mailman/options/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-fcoe.org/pipermail/fcoe-devel>
List-Post: <mailto:fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://lists.open-fcoe.org/mailman/listinfo/fcoe-devel>,
 <mailto:fcoe-devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Errors-To: fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Sender: fcoe-devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-05-30 at 16:38 -0400, Neil Horman wrote: 
> On Fri, May 30, 2014 at 01:13:40PM -0700, Michael Chan wrote:
> > On Fri, 2014-05-30 at 16:03 -0400, Neil Horman wrote: 
> > > On Fri, May 30, 2014 at 10:58:11AM -0700, Michael Chan wrote:
> > > > On Fri, 2014-05-30 at 11:00 -0400, Neil Horman wrote: 
> > > > > The Cnic driver handles lots of ulp operations in its netdevice event hanlder.
> > > > > To do this, it accesses the ulp_ops array, which is an rcu protected array.
> > > > > However, some ulp operations (like bnx2fc_indicate_netevent) try to lock
> > > > > mutexes, which might sleep (somthing that you can't do while holding rcu read
> > > > > side locks if you've configured non-preemptive rcu.
> > > > > 
> > > > > Fix this by changing the dereference method.  All accesses to the ulp_ops array
> > > > > for a cnic dev are modified under the protection of the rtnl lock, and so we can
> > > > > safely just use rcu_dereference_rtnl, and remove the rcu_read_lock here
> > > > 
> > > > Because the bnx2fc function can sleep, we need a more complete fix to
> > > > prevent the ulp_ops from going away when the device is unregistered.
> > > > synchronize_rcu() won't be able to protect it.  I'll post the patch
> > > > later today.  Thanks.
> > > > 
> > > The device can't be unregistered while we hold rtnl, can it?  Since we hold it
> > > in this path it seems safe to me, even if we sleep, or am I missing something?
> > > Neil
> > > 
> > The netdev cannot be unregistered of course, but I am talking about
> > bnx2fc unregistering the cnic device.  For example if someone does
> > fcoeadm -d or bnx2fc gets unloaded.
> 
> I don't think the latter can happen, as creating an fcoe transport places a hold
> on the bnx2fc module (see bnx2fc_create), and the former operation (fcoeadm -d)
> will block in bnx2fc_destroy as it requires holding the rtnl_lock, which will
> already be held by the netevent notifer, and confirmed by the
> rcu_dereference_rtnl in my patch.
> 
> I really think we're safe here 

Take a look at bnx2fc_mod_exit().  It doesn't look safe to me as it goes
through the adapter_list unregistering all cnic devices not under
rtnl_lock.
