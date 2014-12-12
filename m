From: "Hubert Sokolowski" <h.sokolowski@wit.edu.pl>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Fri, 12 Dec 2014 11:38:11 -0000
Message-ID: <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>
    <54894850.5000603@cumulusnetworks.com>
    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>
    <5489D53E.5010603@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, "Jamal Hadi Salim" <hadi@mojatatu.com>
To: "Roopa Prabhu" <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dervish.wsisiz.edu.pl ([213.135.44.54]:50942 "EHLO
	dervish.wsisiz.edu.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965873AbaLLLiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 06:38:15 -0500
In-Reply-To: <5489D53E.5010603@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 12/11/14, 9:06 AM, Hubert Sokolowski wrote:
>> My apologies for sending again, I forgot to include a sample output you asked.
>>
>>> Also, if i hear your concern correctly, for bridge ports that implement
>>> ndo_fdb_dump, with commit 5e6d243587990a588143b9da3974833649595587, we
>>> will get two entries for each 'self' entry above.
>>> Can you also paste sample output for that ?.
>>>
>> [root@silpixa00378825 ~]# bridge fdb show brport mac0
>> 33:33:00:00:00:01 self permanent
>> 33:33:00:00:00:01 self permanent
>>
>>
> Thanks. yes, that is a problem. And, this mac0 is not a bridge port
> correct ?.
>
in that part of the code it does not matter whether it is a bridge
port or not. I can show all devices and the entry is duplicated.
I can still filter by dev and you will see same problem, because
for every network device the dflt callback is called without checking
if the ndo_fdb_dump was defined:
[root@silpixa00378825 ~]# bridge fdb show
33:33:00:00:00:01 dev em1 self permanent
01:00:5e:00:00:01 dev em1 self permanent
33:33:00:00:00:01 dev p4p1 self permanent
01:00:5e:00:00:01 dev p4p1 self permanent
33:33:ff:81:56:db dev p4p1 self permanent
01:00:5e:00:00:fb dev p4p1 self permanent
33:33:00:00:00:01 dev dummy0 self permanent
33:33:00:00:00:01 dev mac0 self permanent
33:33:00:00:00:01 dev mac0 self permanent
[root@silpixa00378825 ~]# bridge fdb show dev mac0
33:33:00:00:00:01 self permanent
33:33:00:00:00:01 self permanent

Please see how the ndo_dflt_fdb_add and del are called:
		if (dev->netdev_ops->ndo_fdb_add)
			err = dev->netdev_ops->ndo_fdb_add(ndm, tb, dev, addr,
							   vid,
							   nlh->nlmsg_flags);
		else
			err = ndo_dflt_fdb_add(ndm, tb, dev, addr, vid,
					       nlh->nlmsg_flags);


> But, for the same test case, when mac0 is a bridge port, does your patch
> under review make both the entries go away for a bridge port ?.
> (If i understand jamal correctly, this is his concern).
>
As it was suggested by Ronen I can modify the patch so the dflt callback
is always called for bridge devices if this is desirable. Either by calling
it when following expression is true:
    (dev->priv_flags & IFF_BRIDGE_PORT)
or by modifying br_fdb_dump to call ndo_dflt_fdb_dump.

thanks,
Hubert
