From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] rps: add flow director support
Date: Mon, 12 Apr 2010 11:58:55 +0800
Message-ID: <r2s412e6f7f1004112058uf90bee88ud93690368ea59051@mail.gmail.com>
References: <1271022140-3917-1-git-send-email-xiaosuo@gmail.com>
	<1271001939.2078.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:58464 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702Ab0DLEBJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 00:01:09 -0400
Received: by iwn35 with SMTP id 35so810236iwn.21
        for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 21:01:09 -0700 (PDT)
In-Reply-To: <1271001939.2078.61.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 12, 2010 at 12:05 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le lundi 12 avril 2010 =C3=A0 05:42 +0800, Changli Gao a =C3=A9crit :
>
> Changli
>
> I am a bit disappointed to find so many bugs in your patch.

:(. Thanks for your patiently review.

>
> I believe this is over engineering at this stage, we yet have to get
> some benches or real world results.

OK. Leave this patch here for testing. And I'll post benchmarking after=
 I do.

>
> Plus it conflicts with the much more interesting upcoming stuff (RFS)=
=2E
> You name this patch 'flow director', to get our attention, but it's a=
n
> old idea of you, to get different weights on cpus, that RPS is not ye=
t
> able to perform.
>

I don't think it conflicts with RFS. RFS is for applications, and RPS
flow director is for firewalls and routers. Because softirqs aren't
under scheduler control, in order to do softirq load balancing, we
have to scheduler flows internally. At the same time, RPS flow
director exposes more than the old design, and keeps the interface
rps_cpus there.

> Maybe this is the reason you forgot to CC Tom Herbert (and me) ?
>

Sorry for forgetting adding you and Tom to CC list.

> Consider now :
>
> 1) echo 65000 >/sys/class/net/eth0/queues/rx-0/rps_flow_0
> =C2=A0 possible crash, dereferencing a smaller cpumap.

Yea, I supposed cpu_online() would check cpu was valid or not. After
checking the code, I found that you were right. OK, I'll add this
sanity check.

if (cpu >=3D nr_cpumask_bits)
      return -EINVAL;

>
> 2) echo 3000000000 >/sys/class/net/eth0/queues/rx-0/rps_flow_0
> =C2=A0 probable crash, because of overflow in RPS_MAP_SIZE(flows)

did you mean rps_flows? Yea, RPS_MAP_SIZE may overflow. Maybe I need
check the upper boundary.

if (flows > USHORT_MAX)
     return -EINVAL;

>
> 3) How can rps_flow_attribute & rps_flow_attribute_size be static (on=
e
> instance for whole kernel), if your intent is to have a per rxqueue
> attributes ? (/sys/class/net/eth0/queues/rx-0/ ...). Or the first lin=
es
> of update_rps_flow_files() are completely wrong...
>
> echo 10 > /sys/class/net/eth0/queues/rx-0/rps_flows
> echo 2 > /sys/class/net/eth1/queues/rx-0/rps_flows
> cat /sys/class/net/eth0/queues/rx-0/rps_flow_9

Yea, each rxqueue has his own attributes. rps_flow_attribute is much
like rps_cpus_attribute. As sysfs_create_file() and
sysfs_remove_file() don't modify them, and only use them constantly,
we can make them static for all the rxqueues.

>
> 4) Lack of atomic changes of the RPS flows -> many packet reordering =
can
> occur.

Yea, if you do packet dispatching dynamically. I don't know how to
avoid packet reordering totally. If OOO doesn't occur frequently, it
isn't a real problem.

>
> 5) Many possible memory leaks in update_rps_flow_files(), you obvious=
ly
> were very lazy. We try to build a bug-free kernel, not only a 'cool
> kernel', and if you are lazy, your patches wont be accepted.
>

Yea, I was lazy, and didn't shrink the rps_flow_attribute. I'll add
reference counters for rps_flow_attributes to trace them usage, and
free them when they aren't needed.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
