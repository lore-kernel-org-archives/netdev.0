From: "Hubert Sokolowski" <h.sokolowski@wit.edu.pl>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Fri, 12 Dec 2014 13:36:41 -0000
Message-ID: <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>
    <54894850.5000603@cumulusnetworks.com>
    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>
    <5489D53E.5010603@cumulusnetworks.com>
    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>
    <548AD781.5020004@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF8
Content-Transfer-Encoding: 8bit
Cc: "Hubert Sokolowski" <h.sokolowski@wit.edu.pl>,
	"Roopa Prabhu" <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Vlad Yasevich" <vyasevic@redhat.com>
To: "Jamal Hadi Salim" <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dervish.wsisiz.edu.pl ([213.135.44.54]:60830 "EHLO
	dervish.wsisiz.edu.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967589AbaLLNgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 08:36:44 -0500
In-Reply-To: <548AD781.5020004@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 12/12/14 06:38, Hubert Sokolowski wrote:
>>> On 12/11/14, 9:06 AM, Hubert Sokolowski wrote:
>
>> Please see how the ndo_dflt_fdb_add and del are called:
>> 		if (dev->netdev_ops->ndo_fdb_add)
>> 			err = dev->netdev_ops->ndo_fdb_add(ndm, tb, dev, addr,
>> 							   vid,
>> 							   nlh->nlmsg_flags);
>> 		else
>> 			err = ndo_dflt_fdb_add(ndm, tb, dev, addr, vid,
>> 					       nlh->nlmsg_flags);
>>
>
> Semantically add and dump are not the same.
> Add adds a specific entry.
> Dump not only dumps the fdb table but also the unicast and multicast
> addresses.
this is not true for 3.16 and before. Please see:
http://lxr.free-electrons.com/source/net/core/rtnetlink.c?v=3.16#L2545
It lets you fully manage the FDB table by overwriding fdb_add, del and dump
in the same way.


>
>
>> As it was suggested by Ronen I can modify the patch so the dflt callback
>> is always called for bridge devices if this is desirable. Either by calling
>> it when following expression is true:
>>      (dev->priv_flags & IFF_BRIDGE_PORT)
>> or by modifying br_fdb_dump to call ndo_dflt_fdb_dump.
>>
>
> Are you saying the above is going to work? You need to TEST please.
yes, it works and it is not a rocket science :). we just need to agree
on the approach to use.

>
> It seems to me drivers which do this:
> ---
> .ndo_fdb_dump           = my_fdb_dump,
>
> and then my_fdb_dump is:
> return ndo_dflt_fdb_dump(skb, ncb, netdev, filter_dev, idx);
>
> are broken because we always have to dump the uni/multicast
> addresses *unconditionally* and these drivers claim to be
> overriding the dumper but are in fact calling the default dumper.
> They are not filtering anything as you had stated.
> I wish Vlad (Cced) would show up and say something ;->
>
> IOW, fix all the broken driver to not do that.

These "broken" drivers were written before 3.17 when the unconditional call
to dflt_dump was introduced. Some drivers implement own dump and don't
call dflt_dump at all, some call dflt_dump depending on some condition.
You can also call dflt_dump inside, save the idx result and continue
with own dump resulting in both uc/mc and own entries returned to the user.

thanks,
Hubert
