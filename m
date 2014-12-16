From: "Hubert Sokolowski" <h.sokolowski@wit.edu.pl>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Tue, 16 Dec 2014 14:35:38 -0000
Message-ID: <26730f986d80f6d06917682a9dec43e6.squirrel@poczta.wsisiz.edu.pl>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>
    <54894850.5000603@cumulusnetworks.com>
    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>
    <5489D53E.5010603@cumulusnetworks.com>
    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>
    <548AD781.5020004@mojatatu.com>
    <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl>
    <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com>
    <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com>
    <54902E5E.2070405@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF8
Content-Transfer-Encoding: 8bit
Cc: "John Fastabend" <john.fastabend@gmail.com>,
	"Roopa Prabhu" <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Vlad Yasevich" <vyasevic@redhat.com>
To: "Jamal Hadi Salim" <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dervish.wsisiz.edu.pl ([213.135.44.54]:59155 "EHLO
	dervish.wsisiz.edu.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbaLPOfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 09:35:42 -0500
In-Reply-To: <54902E5E.2070405@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>
> I am glad this happened ;-> Otherwise we wouldnt be having this
> discussion. When Vlad was asking me I was in a rush to get the patch
> out and didnt question because i thought this was something some crazy
> virtualization people needed.
> If Vlad's use case goes away, then Hubert's little restoration is fine.
>

I'm afraid there might be a little more to fix in here. I just tested
my patch after I moved the dflt_fdb_dump unconditional call inside br_fdb_dump,
so the "self" is returned again for the bridge and saw that br_fdb_dump is called
twice in some cases. As a result I saw duplicate "self" entries.
I think the problem is in rtnl_fdb_dump how it invokes ndo_fdb_dump.
In 3.16 the algorithm was very simple, now it is a little bit more complicated.

I tested on 3.18 without my changes only added pr_info inside br_fdb_dump:
pr_info("br fdb dump called dev %s filter dev %s.\n", dev->name,
			filter_dev->name);

I loaded dummy module, created bridge br0 with brctl and then attached dummy0
to that bridge:
    brctl  addif  br0 dummy0
Then when trying to filter by brport only:
./bridge fdb show brport dummy0
5e:e2:a0:21:0c:f5 vlan 1 master br0 permanent
5e:e2:a0:21:0c:f5 master br0 permanent
33:33:00:00:00:01 self permanent

Even though the output looks OK, I see in the journalctl logs the callback
was called twice with same attributes:
Dec 16 09:15:39 localhost.localdomain kernel: br fdb dump called dev br0 filter dev dummy0.
Dec 16 09:15:39 localhost.localdomain kernel: br fdb dump called dev br0 filter dev dummy0.

Do you have any idea why this is happening? I hope this test makes sense :).

Thanks,
Hubert

--
Hubert Sokolowski           Intel Corporation
