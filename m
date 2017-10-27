From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [Patch net 01/16] net_sched: introduce a workqueue for RCU
 callbacks of tc filter
Date: Fri, 27 Oct 2017 04:55:50 -0700
Message-ID: <20171027115550.GG3659@linux.vnet.ibm.com>
References: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
 <20171027012443.3306-2-xiyou.wangcong@gmail.com>
 <1509077103.11887.23.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUB_y5=Pa9z5Vq+Ves9GhT5COXvRbDtRZo2xqxjo__vmw@mail.gmail.com>
 <1509079166.11887.33.camel@edumazet-glaptop3.roam.corp.google.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Chris Mi <chrism@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:33200 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752190AbdJ0L4O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 07:56:14 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9RBu4Mr030712
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 07:56:14 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dv37039te-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 07:56:08 -0400
Received: from localhost
        by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Fri, 27 Oct 2017 07:55:53 -0400
Content-Disposition: inline
In-Reply-To: <1509079166.11887.33.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 09:39:26PM -0700, Eric Dumazet wrote:
> On Thu, 2017-10-26 at 21:28 -0700, Cong Wang wrote:
> > On Thu, Oct 26, 2017 at 9:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > On Thu, 2017-10-26 at 18:24 -0700, Cong Wang wrote:
> > >> ...
> > >
> > >> On the other hand, this makes tcf_block_put() ugly and
> > >> harder to understand. Since David and Eric strongly dislike
> > >> adding synchronize_rcu(), this is probably the only
> > >> solution that could make everyone happy.
> > >
> > >
> > > ...
> > >
> > >> +static void tcf_block_put_deferred(struct work_struct *work)
> > >> +{
> > >> +     struct tcf_block *block = container_of(work, struct tcf_block, work);
> > >> +     struct tcf_chain *chain;
> > >>
> > >> +     rtnl_lock();
> > >>       /* Hold a refcnt for all chains, except 0, in case they are gone. */
> > >>       list_for_each_entry(chain, &block->chain_list, list)
> > >>               if (chain->index)
> > >> @@ -292,13 +308,27 @@ void tcf_block_put(struct tcf_block *block)
> > >>       list_for_each_entry(chain, &block->chain_list, list)
> > >>               tcf_chain_flush(chain);
> > >>
> > >> -     /* Wait for RCU callbacks to release the reference count. */
> > >> +     INIT_WORK(&block->work, tcf_block_put_final);
> > >> +     /* Wait for RCU callbacks to release the reference count and make
> > >> +      * sure their works have been queued before this.
> > >> +      */
> > >>       rcu_barrier();
> > >> +     tcf_queue_work(&block->work);
> > >> +     rtnl_unlock();
> > >> +}
> > >
> > >
> > > On a loaded server, rcu_barrier() typically takes 4 ms.
> > >
> > > Way better than synchronize_rcu() (about 90 ms) but still an issue when
> > > holding RTNL.
> > >
> > > We have thousands of filters, and management daemon restarts and rebuild
> > > TC hierarchy from scratch.
> > >
> > > Simply getting rid of 1000 old filters might block RTNL for a while, or
> > > maybe I misunderstood your patches.
> > >
> > 
> > Paul pointed out the same.
> > 
> > As I replied, this rcu_barrier() is NOT added by this patchset, it is already
> > there in current master branch.
> 
> You added the rtnl_lock()  rtnl_unlock()...
> 
> I really do not care if hundreds of tasks (not owning rtnl) call
> rcu_barrier()...
> 
> Also we are still using a 4.3 based kernel, and no rcu_barrier() is used
> in filters dismantle ( unregister_tcf_proto_ops() is not used in our
> workloads )
> 
> Somehow something went very wrong in net/sched in recent kernels.

Would this be a good time for me to repeat my suggestion that timers
be used to aggregate the work done in the workqueue handlers, thus
decreasing the number of rcu_barrier() calls done under RTNL?

							Thanx, Paul
