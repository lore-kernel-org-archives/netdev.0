From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V3 4/4] net/sched: Introduce act_tunnel_key
Date: Tue, 30 Aug 2016 05:27:52 -0700
Message-ID: <1472560072.14381.288.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
         <1472141627-27339-5-git-send-email-hadarh@mellanox.com>
         <1472147334.14381.149.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpXvS5KQ-3AaPjtHHRrexr48tTMSXpuJPFkOsz6caJP5EA@mail.gmail.com>
         <1472238975.14381.192.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpV=iCa_nyNRaTE=qkZvw+44mzN8sY01su0pLi2yqqpVmA@mail.gmail.com>
         <20160830110308.GA7141@office.localdomain>
         <20160830113956.GA10991@office.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35558 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758203AbcH3M1z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 08:27:55 -0400
Received: by mail-pf0-f196.google.com with SMTP id h186so1108860pfg.2
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 05:27:54 -0700 (PDT)
In-Reply-To: <20160830113956.GA10991@office.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-30 at 14:39 +0300, Amir Vadai wrote:
> On Tue, Aug 30, 2016 at 02:03:08PM +0300, Amir Vadai wrote:

> > Regarding the specific action in this patchset, correct me if I'm wrong,
> > but I think that the lock could be removed safely.

Sure ;)

> > 
> > When the action is modified during traffic, an existing tcf_enc_metadata
> > is not changed, but a new metadata is allocated and the pointer is
> > replaced to point to the new one.
> > I just need to make sure that when changing an action from 'release'
> > into 'set' - tcf_enc_metadata will be set before the action type is
> > changed - change the order of operations and add a memory barrier.
> > Here is a pseudo code to explain:
> > 
> > metadata_new = new allocated metadata
> > metadata_old = t->tcft_enc_metadata
> > 
> 
> Oh - I had a typo here:
> Need to set the metadata and only after that, set the action:
> 
> t->tcft_enc_metadata = metadata_new
> wmb()

rcu_assign_pointer() is your friend, it auto documents the thing.


Note that you probably need to store in the allocated object :

	dst,
	tcf_action (a copy of it, read in tunnel_key_act()
	tcft_action ( a copy of it, read in tunnel_key_act())
	rcu_head rcu for kfree_rcu()

> t->tcft_action = encapdecap
> 
> > t->tcft_action = encapdecap
> > 
> > /* make sure the compiler won't swap the setting of tcft_action with
> >  * tcft_enc_metadata
> >  */
> > wmb()
> > 
> > t->tcft_enc_metadata = metadata_new
> > release metadata_old
> > 
> > 
> > This way, no need for lock between the init() and act() operations.
> > 
> > Please let me know if you see a problem with this approach.
> > I will also change the stats to be percpu.

Right, check tcf_hash_create() last argument. (false -> true)

Thanks.
