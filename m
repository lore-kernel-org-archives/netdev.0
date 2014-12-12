From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Fri, 12 Dec 2014 12:05:56 -0800
Message-ID: <548B4AA4.1020804@gmail.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hubert Sokolowski <h.sokolowski@wit.edu.pl>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:41551 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471AbaLLUGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 15:06:08 -0500
Received: by mail-ob0-f175.google.com with SMTP id wp4so9965660obc.6
        for <netdev@vger.kernel.org>; Fri, 12 Dec 2014 12:06:08 -0800 (PST)
In-Reply-To: <548AFD41.3010801@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2014 06:35 AM, Jamal Hadi Salim wrote:
> On 12/12/14 08:36, Hubert Sokolowski wrote:
>>> On 12/12/14 06:38, Hubert Sokolowski wrote:
>>>>> On 12/11/14, 9:06 AM, Hubert Sokolowski wrote:
>>>
>>>> Please see how the ndo_dflt_fdb_add and del are called:
>>>>         if (dev->netdev_ops->ndo_fdb_add)
>>>>             err = dev->netdev_ops->ndo_fdb_add(ndm, tb, dev, addr,
>>>>                                vid,
>>>>                                nlh->nlmsg_flags);
>>>>         else
>>>>             err = ndo_dflt_fdb_add(ndm, tb, dev, addr, vid,
>>>>                            nlh->nlmsg_flags);
>>>>
>>>
>>> Semantically add and dump are not the same.
>>> Add adds a specific entry.
>>> Dump not only dumps the fdb table but also the unicast and multicast
>>> addresses.
>> this is not true for 3.16 and before. Please see:
>> http://lxr.free-electrons.com/source/net/core/rtnetlink.c?v=3.16#L2545
>> It lets you fully manage the FDB table by overwriding fdb_add, del and
>> dump
>> in the same way.
>>
>  >
>>
>>>
>>>
>>>> As it was suggested by Ronen I can modify the patch so the dflt
>>>> callback
>>>> is always called for bridge devices if this is desirable. Either by
>>>> calling
>>>> it when following expression is true:
>>>>       (dev->priv_flags & IFF_BRIDGE_PORT)
>>>> or by modifying br_fdb_dump to call ndo_dflt_fdb_dump.
>>>>
>>>
>>> Are you saying the above is going to work? You need to TEST please.
>> yes, it works and it is not a rocket science :). we just need to agree
>> on the approach to use.
>>
>
> I am happy if this solves wont break
> any of the use cases Vlad made me test and make sure work.
> When i said "test" - I mean run the testcases outlined in the
> commit log; if those work i dont see what the issue is.
>

I'll wake up ;)

First quick grep of code finds some strange uses of ndo_fdb_dump like
this in macvlan,

   ./drivers/net/macvlan.c
         .ndo_fdb_dump           = ndo_dflt_fdb_dump,

I'll be sending a patch once net-next opens up again to resolve it. Its
harmless though so not really a fix for net.

There seem to be a few places that have the potential to return
different values then the uc/mc lists.

	./drivers/net/vxlan.c
	./drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
	./drivers/net/ethernet/rocker/rocker.c

	./net/bridge/br_device.c

So I guess we can walk through the list and analyse them a bit.

vxlan:

Try stacking devices on top of the vxlan device this will call a uc_add
routine if you then change the mac addr on the vlan. This would get
reported by the dflt fdb dump handlers but not the drivers fdb dump
handlers. So removing the dflt dump handler from this patch at least
changes things. We should either explain why this is OK or accept that
the driver needs to be fixed. Or I guess that the patch is just wrong.
My guess is one of the latter options.

Also Jamal, your original patch seems like it might of changed this
and Hubert's patch is reverting back to its original case. Was this
specific part of your patch intentional?

qlcnic:

hmm again this is changed a bit. In the case of !learning and no
eswitch or sriov (side-bar question how do you do SR-IOV without
some sort of embedded switch?) then we return idx? See qlcnic_fdb_dump.

So at least this is different after the patch as well. Same questions
as above, explain why this is OK, fix it, or solve the issue some other
way. Although again it was this way before Jamal's patch.

rocker.c:

rocker never calls dflt dump either. Should it or is it not necessary?

br_device:

same story.

Hubert, can you run the set of commands in Jamal's patch and repost
your patch for us with them in the commit msg and call out any
differences?

Note the above is just from reading the code I never really ran any
tests to sort it out completely.

Thanks!
John



> cheers,
> jamal
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
John Fastabend         Intel Corporation
