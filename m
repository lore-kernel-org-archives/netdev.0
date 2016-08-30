From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next V3 4/4] net/sched: Introduce act_tunnel_key
Date: Tue, 30 Aug 2016 16:17:54 +0300
Message-ID: <20160830131754.GA11446@office.localdomain>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
 <1472141627-27339-5-git-send-email-hadarh@mellanox.com>
 <1472147334.14381.149.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXvS5KQ-3AaPjtHHRrexr48tTMSXpuJPFkOsz6caJP5EA@mail.gmail.com>
 <1472238975.14381.192.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpV=iCa_nyNRaTE=qkZvw+44mzN8sY01su0pLi2yqqpVmA@mail.gmail.com>
 <20160830110308.GA7141@office.localdomain>
 <bd4cb7ee-1f7e-eefe-760e-0fa53257390e@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36801 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751527AbcH3NSD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 09:18:03 -0400
Received: by mail-wm0-f68.google.com with SMTP id i138so3131441wmf.3
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 06:18:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <bd4cb7ee-1f7e-eefe-760e-0fa53257390e@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 30, 2016 at 08:05:03AM -0400, Jamal Hadi Salim wrote:
> On 16-08-30 07:03 AM, Amir Vadai wrote:
> > On Sun, Aug 28, 2016 at 10:04:21PM -0700, Cong Wang wrote:
> > > On Fri, Aug 26, 2016 at 12:16 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > > On Fri, 2016-08-26 at 11:26 -0700, Cong Wang wrote:
> 
> 
> > Regarding the specific action in this patchset, correct me if I'm wrong,
> > but I think that the lock could be removed safely.
> > 
> 
> From what Eric suggested (refer to my posting on skbmod),
> this becomes:
> 
> +struct tcf_tunnel_key_p {
> +	int			tcft_action;
> +	struct metadata_dst     *tcft_enc_metadata;
> +};
> 
> /* rcu protected */
> +struct tcf_tunnel_key {
> +	struct tc_action	common;
> +       struct tcf_tunnel_key_p *p;
> +};
> 
> At init() - always alloc struct tcf_tunnel_key_p, new
> 
> old = rtnl_dereference(mykey->p);
> if (ovr)
>     spin_lock_bh(&mykey->tcf_lock);
Thanks for the detailed example :)

what are we protecting with this spin lock here? isn't concurrent init()
calls are protected by the rtnl lock?


> ... update all params here ..
> rcu_assign_pointer(mykey->p, new);
> if (ovr) {
>      spin_unlock_bh(&mykey->tcf_lock);
>      synchronize_rcu();
> }
> 
> kfree(old);
> 
> at act():
> 
> rcu_read_lock();
> struct tcf_tunnel_key_p *p = rcu_dereference(mykey->p);
> ... use p here ...
> rcu_read_unlock();
> 
> Cong was looking to do something more generic for all actions.
> 
> cheers,
> jamal
