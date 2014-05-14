From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: bonding directly changes underlying device address
Date: Wed, 14 May 2014 10:01:14 +0200
Message-ID: <20140514080114.GA30960@mikrodark.usersys.redhat.com>
References: <5371FCD0.7050502@mellanox.com>
 <20140513115527.GC2910@minipsycho.orion>
 <20030.1399998641@localhost.localdomain>
 <CAJZOPZ+pOBw4M-ZFF2qsqNgGJcKcRRdhWFf4dy1FQ8Ngr-ZqRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Noa Osherovich <noaos@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:41641 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700AbaENIBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 04:01:37 -0400
Received: by mail-we0-f175.google.com with SMTP id t61so1502137wes.20
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 01:01:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJZOPZ+pOBw4M-ZFF2qsqNgGJcKcRRdhWFf4dy1FQ8Ngr-ZqRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 13, 2014 at 08:38:01PM +0300, Or Gerlitz wrote:
>On Tue, May 13, 2014 at 7:30 PM, Jay Vosburgh
><jay.vosburgh@canonical.com> wrote:
>>>Tue, May 13, 2014 at 01:06:56PM CEST, ogerlitz@mellanox.com wrote:
>
>[...]
>
>>>>I suspect this can lead to funny (or actually sad) bugs in networking
>>>>drivers, can we avoid that?
>
>>         Changing this would also remove support for the tlb mode from
>> any device that cannot change their MAC while open.  I don't know how
>> many devices that is (it's probably a small number nowadays), but if
>> it's not zero then an assessment on losing that support has to be made.
>
>Focusing on the last part of your reply, are you OK with a patch that
>branches on whether that device supports ndo_set_mac_address and if
>this is the case we will call dev_set_mac_address, else do the current
>practice of setting dev_addr directly?

I'd actually just drop support for non-ndo_set_mac_address NICs, as it'll
unify the RLB and TLB logic, and anyways dev_set_mac_address() is used in
SIOCSIFHWADDR and rtnl ops, and thus, if the NIC doesn't support it, it
can't change its mac address at all, and using it in *LB modes makes little
sense.

Other way of doing this would be to just move the dev_addr to the slave
struct, instead of using the net_device's dev_addr, cause in tlb we don't
usually need to set the NIC mac address (except when there's mac filtering,
I guess), but only need to set the packet's source mac. This way we'll omit
quite costy mac address setting (as, on some NICs, it resets the whole NIC
and takes seconds), still maintain compatibility with older NICs and won't
mess with NICs ->dev_addr.

Anyway, I'll let Jay decide.

>
>Or.
