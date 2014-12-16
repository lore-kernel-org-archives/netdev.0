From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Mon, 15 Dec 2014 16:45:38 -0800
Message-ID: <548F80B2.80408@gmail.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com> <548EF05E.6050401@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hubert Sokolowski <h.sokolowski@wit.edu.pl>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:53503 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbaLPApw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 19:45:52 -0500
Received: by mail-ob0-f179.google.com with SMTP id va2so20753273obc.10
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 16:45:51 -0800 (PST)
In-Reply-To: <548EF05E.6050401@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/2014 06:29 AM, Jamal Hadi Salim wrote:
> On 12/12/14 15:05, John Fastabend wrote:
>> On 12/12/2014 06:35 AM, Jamal Hadi Salim wrote:
>
>
>> I'll wake up ;)
>
>
> Vlad made me go over those patches in a few iterations to make
> sure that the use cases covered in the test case work. It is
> holiday season, so he may be offline.
>

Yep.

>> First quick grep of code finds some strange uses of ndo_fdb_dump like
>> this in macvlan,
>>
>>    ./drivers/net/macvlan.c
>>          .ndo_fdb_dump           = ndo_dflt_fdb_dump,
>>
>> I'll be sending a patch once net-next opens up again to resolve it. Its
>> harmless though so not really a fix for net.
>>
>> There seem to be a few places that have the potential to return
>> different values then the uc/mc lists.
>>
>>      ./drivers/net/vxlan.c
>>      ./drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>>      ./drivers/net/ethernet/rocker/rocker.c
>>
>>      ./net/bridge/br_device.c
>>
>
> Yes, thats my observation as well.
> The question is: Are multi/unicast address unconditionally dumped?

hmm good question. When I implemented this on the host nics with SR-IOV,
VMDQ, etc. The multi/unicast addresses were propagated into the FDB by
the driver. My logic was if some netdev ethx has a set of MAC addresses
above it well then any virtual function or virtual device also behind
the hardware shouldn't be sending those addresses out the egress switch
facing port. Otherwise the switch will see packets it knows are behind
that port and drop them. Or flood them if it hasn't learned the address
yet. Either way they will never get to the right netdev.

Admittedly I wasn't thinking about switches with many ports at the time.

> Some of these drivers may be just doing the LinuxWay(aka cutnpaste what
> the other driver did).

My original thinking here was... if it didn't implement fdb_add, fdb_del
and fdb_dump then if you wanted to think of it as having forwarding
database that was fine but it was really just a two port mac relay. In
which case just dump all the mac addresses it knows about. In this case
if it was something more fancy it could do its own dump like vxlan or
macvlan.

> If you go over the original thread exchange with Vlad, you'll notice
> i was kind of unsure why dumping of unicast/multicast had anything to
> do with fdb dumping.
> It is still my view that we shouldnt be treating these addresses as if
> they were fdb entries. But: The problem is once you allow an API to
> user space you cant take it back even if people are depending on bugs.
>

For a host nic ucast/multicast and fdb are the same, I think? The
code we had was just short-hand to allow the common case a host nic
to work. Notice vxlan and bridge drivers didn't dump there addr lists 
from fdb_dump until your patch.

Perhaps my implementation of macvlan fdb_{add|del|dump} is buggy. And
I shouldn't overload the addr lists.

>
>> So I guess we can walk through the list and analyse them a bit.
>>
>> vxlan:
>>
>> Try stacking devices on top of the vxlan device this will call a uc_add
>> routine if you then change the mac addr on the vlan. This would get
>> reported by the dflt fdb dump handlers but not the drivers fdb dump
>> handlers. So removing the dflt dump handler from this patch at least
>> changes things. We should either explain why this is OK or accept that
>> the driver needs to be fixed. Or I guess that the patch is just wrong.
>> My guess is one of the latter options.
>>
>> Also Jamal, your original patch seems like it might of changed this
>> and Hubert's patch is reverting back to its original case. Was this
>> specific part of your patch intentional?
>>
>
> Yes.
> This is based on the view that unicast/multicast must be dumped
> *unconditionally*. If the view is that uni/mcast addresses are
> dumped conditionally based on what the driver thinks, then Hubert's
> one liner is good. But i really would like Vlad to comment. 80%
> of the effort on my part if you look at the thread was the refactoring
> of the code to meet the use case.

I'm interested to see what Vlad says as well. But the current situation
is previously some drivers dumped their addr lists others didn't.
Specifically, the more switch like devices (bridge, vxlan) didn't. Now
every device will dump the addr lists. I'm not entirely convinced that
is correct.

>
> I thought the abstraction which requires that your own MAC addresses
> are treated as fdb entries was broken - but it is too late to change
> that.
>

It works OK for host nics (NICS that can't forward between ports) and
seems at best confusing for real switch asics. On a related question do
you expect the switch asic to trap any packets with MAC addresses in
the multi/unicast address lists and send them to the correct netdev? Or
will the switch forward them using normal FDB tables?

Also I don't think its too late to fix it though. Maybe we had some
buggy drivers is all.

> cheers,
> jamal


-- 
John Fastabend         Intel Corporation
