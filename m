From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Fri, 12 Dec 2014 06:54:41 -0500
Message-ID: <548AD781.5020004@mojatatu.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com> <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: Hubert Sokolowski <h.sokolowski@wit.edu.pl>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:41586 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967353AbaLLLyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 06:54:44 -0500
Received: by mail-ig0-f176.google.com with SMTP id l13so1384443iga.15
        for <netdev@vger.kernel.org>; Fri, 12 Dec 2014 03:54:43 -0800 (PST)
In-Reply-To: <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/14 06:38, Hubert Sokolowski wrote:
>> On 12/11/14, 9:06 AM, Hubert Sokolowski wrote:

> Please see how the ndo_dflt_fdb_add and del are called:
> 		if (dev->netdev_ops->ndo_fdb_add)
> 			err = dev->netdev_ops->ndo_fdb_add(ndm, tb, dev, addr,
> 							   vid,
> 							   nlh->nlmsg_flags);
> 		else
> 			err = ndo_dflt_fdb_add(ndm, tb, dev, addr, vid,
> 					       nlh->nlmsg_flags);
>

Semantically add and dump are not the same.
Add adds a specific entry.
Dump not only dumps the fdb table but also the unicast and multicast
addresses.
the default dumper does the uni/multicast dumping.


> As it was suggested by Ronen I can modify the patch so the dflt callback
> is always called for bridge devices if this is desirable. Either by calling
> it when following expression is true:
>      (dev->priv_flags & IFF_BRIDGE_PORT)
> or by modifying br_fdb_dump to call ndo_dflt_fdb_dump.
>

Are you saying the above is going to work? You need to TEST please.

It seems to me drivers which do this:
---
.ndo_fdb_dump           = my_fdb_dump,

and then my_fdb_dump is:
return ndo_dflt_fdb_dump(skb, ncb, netdev, filter_dev, idx);

are broken because we always have to dump the uni/multicast
addresses *unconditionally* and these drivers claim to be
overriding the dumper but are in fact calling the default dumper.
They are not filtering anything as you had stated.
I wish Vlad (Cced) would show up and say something ;->

IOW, fix all the broken driver to not do that.

cheers,
jamal
