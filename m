From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next V3 4/4] net/sched: Introduce act_tunnel_key
Date: Tue, 30 Aug 2016 08:05:03 -0400
Message-ID: <bd4cb7ee-1f7e-eefe-760e-0fa53257390e@mojatatu.com>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
 <1472141627-27339-5-git-send-email-hadarh@mellanox.com>
 <1472147334.14381.149.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXvS5KQ-3AaPjtHHRrexr48tTMSXpuJPFkOsz6caJP5EA@mail.gmail.com>
 <1472238975.14381.192.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpV=iCa_nyNRaTE=qkZvw+44mzN8sY01su0pLi2yqqpVmA@mail.gmail.com>
 <20160830110308.GA7141@office.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>
To: Amir Vadai <amir@vadai.me>, Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35016 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758578AbcH3MFG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 08:05:06 -0400
Received: by mail-it0-f66.google.com with SMTP id f128so1816522ith.2
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 05:05:06 -0700 (PDT)
In-Reply-To: <20160830110308.GA7141@office.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-30 07:03 AM, Amir Vadai wrote:
> On Sun, Aug 28, 2016 at 10:04:21PM -0700, Cong Wang wrote:
>> On Fri, Aug 26, 2016 at 12:16 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> On Fri, 2016-08-26 at 11:26 -0700, Cong Wang wrote:


> Regarding the specific action in this patchset, correct me if I'm wrong,
> but I think that the lock could be removed safely.
>

 From what Eric suggested (refer to my posting on skbmod),
this becomes:

+struct tcf_tunnel_key_p {
+	int			tcft_action;
+	struct metadata_dst     *tcft_enc_metadata;
+};

/* rcu protected */
+struct tcf_tunnel_key {
+	struct tc_action	common;
+       struct tcf_tunnel_key_p *p;
+};

At init() - always alloc struct tcf_tunnel_key_p, new

old = rtnl_dereference(mykey->p);
if (ovr)
     spin_lock_bh(&mykey->tcf_lock);
... update all params here ..
rcu_assign_pointer(mykey->p, new);
if (ovr) {
      spin_unlock_bh(&mykey->tcf_lock);
      synchronize_rcu();
}

kfree(old);

at act():

rcu_read_lock();
struct tcf_tunnel_key_p *p = rcu_dereference(mykey->p);
... use p here ...
rcu_read_unlock();

Cong was looking to do something more generic for all actions.

cheers,
jamal
