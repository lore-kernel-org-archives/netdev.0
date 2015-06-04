From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH net-next v2] rocker: move netevent neigh update to processes
 context
Date: Fri, 05 Jun 2015 00:34:50 +0900
Message-ID: <5570701A.5010903@gmail.com>
References: <1433303008-32656-1-git-send-email-sfeldma@gmail.com> <20150603.233829.1362177764562847830.davem@davemloft.net> <20150604082045.GA7709@vergenet.net> <20150604.013409.228829580818256337.davem@davemloft.net> <20150604090749.GA18460@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, jiri@resnulli.us,
	makita.toshiaki@lab.ntt.co.jp
To: Simon Horman <horms@verge.net.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34542 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbbFDPey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 11:34:54 -0400
Received: by payr10 with SMTP id r10so31962261pay.1
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 08:34:54 -0700 (PDT)
In-Reply-To: <20150604090749.GA18460@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/06/04 (=E6=9C=A8) 18:07, Simon Horman wrote:
> Hi Dave,
>
> On Thu, Jun 04, 2015 at 01:34:09AM -0700, David Miller wrote:
>> From: Simon Horman <simon.horman@netronome.com>
>> Date: Thu, 4 Jun 2015 17:20:48 +0900
>>
>>> What I was seeing is as follows:
>>>
>>> 1. rocker_port_ipv4_nh() is called via switchdev_port_obj_add()
>>>     with trans =3D SWITCHDEV_TRANS_PREPARE
>>>
>>> 2. rocker_port_ipv4_neigh() is called by rocker_neigh_update()
>>>     with trans =3D SWITCHDEV_TRANS_NONE.
>>>
>>>     The call chain goes up to arp_process() via neigh_update().
>>>
>>> 3. rocker_port_ipv4_nh() is called via switchdev_port_obj_add()
>>>     with trans =3D SWITCHDEV_TRANS_COMMIT
>>>
>>> #1 and #2 are guarded by rtl across those calls but
>>> #2 is not guarded by rtnl.
>>>
>>> Inside both rocker_port_ipv4_nh() and rocker_port_ipv4_neigh()
>>> neigh_tbl_lock lock is taken but it is not held across the
>>> two calls to rocker_port_ipv4_nh within a single prepare->commit tr=
ansaction.
>>>
>>> I can double check that the above still occurs, but I'm not aware o=
f any
>>> recent changes that would cause it not to occur any more.
>>
>> Ok, thanks for explaining.
>>
>> I still don't want this to be moved asynchronosly from the ARP neigh
>> update event code path.
>>
>> And therefore I'd like folks to look into another mechanism to fix
>> this.
>>
>> If that means the prepare/commit engine is given a spinlock by the
>> driver to be held across the two calls, so be it.
>
> I'm not opposed to such a scheme. But I'd like to note that it seems =
to me
> that for it to resolve the problem above the lock would be need be he=
ld
> both for "none" and "prepare->commit" transactions.  I think the form=
er may
> be a little tricky as it may occur in IRQ context but perhaps I am mi=
ssing
> something obvious.

I'm thinking IRQ context does not match the prepare-commit model, and=20
Scott's fix is needed. There are more critical problems Scott's patch f=
ixes.
(I shortly explained it before, although it is not clearly stated in th=
e=20
commitlog. http://marc.info/?l=3Dlinux-netdev&m=3D143219842420093&w=3D2=
)

1. Operations from IRQ context could change the state of rocker, like=20
hash tables. This could cause inconsistent states between prepare-commi=
t=20
(for example, prepare phase cannot find an entry but commit phase can=20
find it), and leads to memory corruption (unreserved memory could be=20
used or reserved memory could not be used in commit phase).

2. rocker_wait_event_timeout() can sleep, but it can be called from IRQ=
=20
context.

   rocker_event_neigh_update()
    rocker_port_ipv4_neigh()
     rocker_group_l3_unicast()
      rocker_group_tbl_do()
       rocker_group_tbl_add()
        rocker_cmd_exec()
         rocker_wait_event_timeout()
          wait_event_timeout()
           might_sleep()

3. Currently memory allocation is always done with GFP_KERNEL in=20
__rocker_port_mem_alloc(), but it can be called from IRQ context.

   rocker_event_neigh_update()
    rocker_port_ipv4_neigh()
     rocker_port_kzalloc()
      __rocker_port_mem_alloc()

Toshiaki Makita
