From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Mon, 15 Dec 2014 09:29:50 -0500
Message-ID: <548EF05E.6050401@mojatatu.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hubert Sokolowski <h.sokolowski@wit.edu.pl>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:64027 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752586AbaLOO3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 09:29:55 -0500
Received: by mail-ie0-f179.google.com with SMTP id rp18so10817231iec.38
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 06:29:52 -0800 (PST)
In-Reply-To: <548B4AA4.1020804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/14 15:05, John Fastabend wrote:
> On 12/12/2014 06:35 AM, Jamal Hadi Salim wrote:


> I'll wake up ;)


Vlad made me go over those patches in a few iterations to make
sure that the use cases covered in the test case work. It is
holiday season, so he may be offline.

> First quick grep of code finds some strange uses of ndo_fdb_dump like
> this in macvlan,
>
>    ./drivers/net/macvlan.c
>          .ndo_fdb_dump           = ndo_dflt_fdb_dump,
>
> I'll be sending a patch once net-next opens up again to resolve it. Its
> harmless though so not really a fix for net.
>
> There seem to be a few places that have the potential to return
> different values then the uc/mc lists.
>
>      ./drivers/net/vxlan.c
>      ./drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>      ./drivers/net/ethernet/rocker/rocker.c
>
>      ./net/bridge/br_device.c
>

Yes, thats my observation as well.
The question is: Are multi/unicast address unconditionally dumped?
Some of these drivers may be just doing the LinuxWay(aka cutnpaste what
the other driver did).
If you go over the original thread exchange with Vlad, you'll notice
i was kind of unsure why dumping of unicast/multicast had anything to
do with fdb dumping.
It is still my view that we shouldnt be treating these addresses as if
they were fdb entries. But: The problem is once you allow an API to
user space you cant take it back even if people are depending on bugs.


> So I guess we can walk through the list and analyse them a bit.
>
> vxlan:
>
> Try stacking devices on top of the vxlan device this will call a uc_add
> routine if you then change the mac addr on the vlan. This would get
> reported by the dflt fdb dump handlers but not the drivers fdb dump
> handlers. So removing the dflt dump handler from this patch at least
> changes things. We should either explain why this is OK or accept that
> the driver needs to be fixed. Or I guess that the patch is just wrong.
> My guess is one of the latter options.
>
> Also Jamal, your original patch seems like it might of changed this
> and Hubert's patch is reverting back to its original case. Was this
> specific part of your patch intentional?
>

Yes.
This is based on the view that unicast/multicast must be dumped
*unconditionally*. If the view is that uni/mcast addresses are
dumped conditionally based on what the driver thinks, then Hubert's
one liner is good. But i really would like Vlad to comment. 80%
of the effort on my part if you look at the thread was the refactoring
of the code to meet the use case.

I thought the abstraction which requires that your own MAC addresses
are treated as fdb entries was broken - but it is too late to change
that.

cheers,
jamal
