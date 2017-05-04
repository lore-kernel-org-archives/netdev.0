From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH net-next 9/9] ipvlan: introduce individual MAC addresses
Date: Thu, 4 May 2017 15:09:50 -0700
Message-ID: <CAF2d9jjzxmgqvxTB7ytDydMmf16SRfTQMQ74-SV5S=o7B2OR7Q@mail.gmail.com>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
 <20170427145142.15830-10-marco.chiappero@intel.com> <1493310033.27948.3.camel@redhat.com>
 <1493310219.27948.5.camel@redhat.com> <695CDAEB5A6CE2498DE413F2A9AA82960915DF0C@IRSMSX101.ger.corp.intel.com>
 <1493741366.32411.7.camel@redhat.com> <695CDAEB5A6CE2498DE413F2A9AA82960915EF08@IRSMSX101.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dan Williams <dcbw@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "Grandhi, Sainath" <sainath.grandhi@intel.com>
To: "Chiappero, Marco" <marco.chiappero@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:33026 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751864AbdEDWKM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 18:10:12 -0400
Received: by mail-io0-f169.google.com with SMTP id p24so40153661ioi.0
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 15:10:12 -0700 (PDT)
In-Reply-To: <695CDAEB5A6CE2498DE413F2A9AA82960915EF08@IRSMSX101.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 4, 2017 at 2:37 AM, Chiappero, Marco
<marco.chiappero@intel.com> wrote:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>> On Behalf Of Dan Williams
>> Sent: Tuesday, May 2, 2017 5:09 PM
>> To: Chiappero, Marco <marco.chiappero@intel.com>; netdev@vger.kernel.org
>> Cc: David S . Miller <davem@davemloft.net>; Kirsher, Jeffrey T
>> <jeffrey.t.kirsher@intel.com>; Duyck, Alexander H
>> <alexander.h.duyck@intel.com>; Grandhi, Sainath
>> <sainath.grandhi@intel.com>; Mahesh Bandewar <maheshb@google.com>
>> Subject: Re: [PATCH net-next 9/9] ipvlan: introduce individual MAC addresses
>>
>> On Tue, 2017-05-02 at 15:08 +0000, Chiappero, Marco wrote:
>> > > -----Original Message-----
>> > > From: Dan Williams [mailto:dcbw@redhat.com] On Thu, 2017-04-27 at
>> > > 11:20 -0500, Dan Williams wrote:
>> > > > On Thu, 2017-04-27 at 15:51 +0100, Marco Chiappero wrote:
>> > > > > Currently all the slave devices belonging to the same port
>> > > > > inherit their MAC address from its master device. This patch
>> > > > > removes this limitation and allows every slave device to obtain
>> > > > > a unique MAC address, by default randomly generated at creation
>> > > > > time.
>> > > > >
>> > > > > Moreover it is now possible to correctly modify the MAC address
>> > > > > at any time, fixing an existing bug as MAC address changes on
>> > > > > the master were not reflected on the slaves. It also avoids
>> > > > > multiple interfaces sharing the same IPv6 link-local address.
>> > > >
>> > > > How is this different than macvlan now?
>> >
>> > The same way it was before. The purpose of the patch is to make
>> > possible to change the MAC address on slaves, not to change the
>> > external behavior of ipvlan: ipvlan will still behave as ipvlan,
>> > macvlan will still behave as macvlan.
>>
>> Ok, it was completely unclear from the commit message that the "internal" MAC
>> addresses of the ipvlan interfaces were not reflected "on the wire", but that this
>> was essentially (as you say below) MAC NAT.
>
> Sorry about that, I'll fix it in V2.
>
>> I think everyone agrees that being able to change the MAC is useful and was a
>> bug.
>>
>> What I'm still not clear on is, if IPv6 is already solved, why is it useful to have
>> assign ipvlan interface a unique MAC address?  Is it only to make interface
>> lookups via MAC easier?
>
> The main motivation is that some higher level management software expect interfaces on the same L2 broadcast domain to obviously have different MAC addresses, either out-of-the-box or via address change - or both.  Instead with ipvlan:
> - there is no real/formal segmentation between slaves
segmentation between slaves is at L3. If you want segmentation at L2
then use Macvlan

> - slaves share the same L2 address
Yes, that's by design!

> This looks conceptually wrong.
Why is it hard to view a device that does mux/demux using L3 while
keeping L2 same. Namespaces within physical box have different L3 and
have different routing needs too while all this enclosed inside one
host exposing one external L2. If some mgmt software doesn't like it
then either IPvlan is not the best fit for that solution or that
software needs an update.

>Yes, ipvlan works at L3 (which is an implementation detail anyway), but slaves are Ethernet interfaces and should behave as much as possible as such regardless, with an individual MAC address assigned.
>
> Additionally there is another related bug as it's currently possible to work around this limitation, although breaking the whole thing, by:
> 1) changing the MAC address on master from X to Y
> 2) creating a slave, receiving address Y
> 3) restoring the original MAC address X on master
>
> So, either we fix this by forcing slaves to stay in sync with master,
I have already mentioned that this is the only acceptable fix out of
this patchset but not by way of rewriting headers. The simplest fix is
to use the master->dev_addr in dev_hard_header()

> or correctly support independent MAC addresses, which would be IMO preferable for the above reasons.
>
> Best Regards,
> Marco
> --------------------------------------------------------------
> Intel Research and Development Ireland Limited
> Registered in Ireland
> Registered Office: Collinstown Industrial Park, Leixlip, County Kildare
> Registered Number: 308263
>
>
> This e-mail and any attachments may contain confidential material for the sole
> use of the intended recipient(s). Any review or distribution by others is
> strictly prohibited. If you are not the intended recipient, please contact the
> sender and delete all copies.
