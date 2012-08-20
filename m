From: Li Zefan <lizefan@huawei.com>
Subject: Re: [PATCH v1 3/5] cgroup: Protect access to task_cls_classid() when
 built as module
Date: Mon, 20 Aug 2012 08:59:37 +0800
Message-ID: <50318BF9.2080803@huawei.com>
References: <1345215494-9181-1-git-send-email-wagi@monom.org> <1345215494-9181-4-git-send-email-wagi@monom.org> <20120817182855.GA11607@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Wagner <wagi@monom.org>, <netdev@vger.kernel.org>,
	<cgroups@vger.kernel.org>,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Tejun Heo <tj@kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:46703 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217Ab2HTBAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 21:00:54 -0400
In-Reply-To: <20120817182855.GA11607@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012/8/18 2:28, Neil Horman =E5=86=99=E9=81=93:
> On Fri, Aug 17, 2012 at 04:58:12PM +0200, Daniel Wagner wrote:
>> From: Daniel Wagner <daniel.wagner@bmw-carit.de>
>>
>> The module version of task_cls_classid() checks if net_cls_sbusys_id
>> is valid to indentify when it is okay to access the controller.
>>
>> Instead relying on the subusys_id to be set, make it explicit
>> with a jump label.
>>
>> Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Gao feng <gaofeng@cn.fujitsu.com>
>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>> Cc: John Fastabend <john.r.fastabend@intel.com>
>> Cc: Li Zefan <lizefan@huawei.com>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
>> Cc: Tejun Heo <tj@kernel.org>
>> Cc: netdev@vger.kernel.org
>> Cc: cgroups@vger.kernel.org
>> ---
>>  include/net/cls_cgroup.h | 5 ++++-
>>  net/core/sock.c          | 5 +++++
>>  net/sched/cls_cgroup.c   | 9 +++++++++
>>  3 files changed, 18 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
>> index 401672c..bbbd957 100644
>> --- a/include/net/cls_cgroup.h
>> +++ b/include/net/cls_cgroup.h
>> @@ -16,6 +16,7 @@
>>  #include <linux/cgroup.h>
>>  #include <linux/hardirq.h>
>>  #include <linux/rcupdate.h>
>> +#include <linux/jump_label.h>
>> =20
>>  #ifdef CONFIG_CGROUPS
>>  struct cgroup_cls_state
>> @@ -44,6 +45,8 @@ static inline u32 task_cls_classid(struct task_str=
uct *p)
>>  }
>> =20
>>  #elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
>> +extern struct static_key cgroup_cls_enabled;
>> +#define clscg_enabled static_key_false(&cgroup_cls_enabled)
>> =20
>>  extern int net_cls_subsys_id;
>> =20
>> @@ -52,7 +55,7 @@ static inline u32 task_cls_classid(struct task_str=
uct *p)
>>  	int id;
>>  	u32 classid =3D 0;
>> =20
>> -	if (in_interrupt())
>> +	if (!clscg_enabled || in_interrupt())
>>  		return 0;
>> =20
>>  	rcu_read_lock();
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index 8f67ced..8106e77 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -327,6 +327,11 @@ int __sk_backlog_rcv(struct sock *sk, struct sk=
_buff *skb)
>>  EXPORT_SYMBOL(__sk_backlog_rcv);
>> =20
>>  #if defined(CONFIG_CGROUPS)
>> +#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
>> +struct static_key cgroup_cls_enabled =3D STATIC_KEY_INIT_FALSE;
>> +EXPORT_SYMBOL_GPL(cgroup_cls_enabled);
>> +#endif
>> +
>>  #if !defined(CONFIG_NET_CLS_CGROUP)
>>  int net_cls_subsys_id =3D -1;
>>  EXPORT_SYMBOL_GPL(net_cls_subsys_id);
>> diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
>> index 7743ea8..0635894 100644
>> --- a/net/sched/cls_cgroup.c
>> +++ b/net/sched/cls_cgroup.c
>> @@ -44,12 +44,21 @@ static struct cgroup_subsys_state *cgrp_create(s=
truct cgroup *cgrp)
>> =20
>>  	if (cgrp->parent)
>>  		cs->classid =3D cgrp_cls_state(cgrp->parent)->classid;
>> +#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
>> +	else if (!clscg_enabled)
>> +                static_key_slow_inc(&cgroup_cls_enabled);
> This is racy I think.  The read of the static key is atomic with othe=
r reads,
> but the entire conditional is not atomic.  If two cpus were creating =
cgroups in
> parallel, it would be possible for both to read the static key as bei=
ng zero
> (the second cpu would read the key before the first cpu could increme=
nt it).

static_key_slow_inc() is called only when we're creating the root cgrou=
p, and that's
module loading.

so it's safe.

>> +#endif
>> =20
>>  	return &cs->css;
>>  }
>> =20
>>  static void cgrp_destroy(struct cgroup *cgrp)
>>  {
>> +#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
>> +	if (!cgrp->parent && clscg_enabled)
>> +                static_key_slow_dec(&cgroup_cls_enabled);
> Ditto here with the race above.  I think what you want is one of:

and this is called only when we're destroying the root cgroup, and that=
's
module unload.
