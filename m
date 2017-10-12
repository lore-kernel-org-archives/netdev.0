From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 0/3] Adding config get/set to devlink
Date: Thu, 12 Oct 2017 08:43:59 -0700
Message-ID: <24E5DE7C-A401-48BF-BF80-673ACC38FBBE@gmail.com>
References: <1507815262-33294-1-git-send-email-steven.lin1@broadcom.com> <CAJieiUjuKtmYDZ5-7UjYkWFJuMGu2gajhziLQKAZLTz6g63f2A@mail.gmail.com> <20171012144032.GG14672@nanopsycho> <CAJieiUiFmBr72yYP9VNtm0VBTNjJcA6Lj5nHJNBjDBC4moxE2A@mail.gmail.com> <20171012150419.GI14672@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Steve Lin <steven.lin1@broadcom.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        michael.chan@broadcom.com, linux-pci@vger.kernel.org,
        "John W. Linville" <linville@tuxdriver.com>, gospo@broadcom.com
To: Jiri Pirko <jiri@resnulli.us>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:49456 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752221AbdJLPoK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 11:44:10 -0400
In-Reply-To: <20171012150419.GI14672@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On October 12, 2017 8:04:19 AM PDT, Jiri Pirko <jiri@resnulli=2Eus> wrote:
>Thu, Oct 12, 2017 at 04:46:24PM CEST, roopa@cumulusnetworks=2Ecom wrote:
>>On Thu, Oct 12, 2017 at 7:40 AM, Jiri Pirko <jiri@resnulli=2Eus> wrote:
>>> Thu, Oct 12, 2017 at 04:35:10PM CEST, roopa@cumulusnetworks=2Ecom
>wrote:
>>>>On Thu, Oct 12, 2017 at 6:34 AM, Steve Lin
><steven=2Elin1@broadcom=2Ecom> wrote:
>>>>> Adds a devlink command for getting & setting device configuration
>>>>> parameters, and enumerates a bunch of those parameters as devlink
>>>>> attributes=2E  Also introduces an attribute that can be set by a
>>>>> driver to indicate that the config change doesn't take effect
>>>>> until the next restart (as in the case of the bnxt driver changes
>>>>> in this patchset, for which all the configuration changes affect
>NVM
>>>>> only, and aren't loaded until the next restart=2E)
>>>>>
>>>>> bnxt driver patches make use of these new devlink cmds/attributes=2E
>>>>>
>>>>> Steve Lin (3):
>>>>>   devlink: Add config parameter get/set operations
>>>>>   bnxt: Move generic devlink code to new file
>>>>>   bnxt: Add devlink support for config get/set
>>>>>
>>>>
>>>>Is the goal here to move all ethtool operations to devlink (I saw
>some
>>>>attrs related to speed etc)=2E ?=2E
>>>>We do need to move ethtool attrs to netlink and devlink is a good
>>>>place (and of-course leave the current ethtool api around for
>backward
>>>>compatibility)=2E
>>>
>>> We need to make sure we are not moving things to devlink which don't
>>> belong there=2E All options that use "netdev" as a handle should go
>into
>>> rtnetlink instead=2E
>>>
>>
>>Any reason you want to keep that restriction ?=2E
>>FWIS, devlink is a driver api just like ethtool is=2E
>>and ethtool needs to move to netlink soon=2E=2E=2Eand It would be better=
 to
>>not put the rtnl_lock burden on ethtool driver operations=2E Instead of
>>adding yet another driver api, extending devlink seems like a great
>>fit to me=2E
>
>Hmm, the original purpose of devlink was to obtain iface for things
>that
>could not use "netdev" as a handle=2E I try to stick with it as we
>already
>have iface for things that could use "netdev" as a handle - rtnetlink=2E
>
>Not sure we want to go this way and add "netdev"-handle things into
>devlink=2E Thoughts?

In the current situation where we have ethtool and devlink operating separ=
ately on different objects as entry points to the kernel, I agree with that=
 design=2E

Once we move ethtool (or however we name its successor) over to netlink th=
ere is an opportunity for accessing objects that do and do not have a netde=
vice representor today (e=2Eg: management ports on switches) with the same =
interface, and devlink could be used for that=2E

In terms of compatibility though we should have a pseudo generic layer tha=
t can take ethtool ioctl() and transform that into a netlink message and th=
en call back down to drivers with the existing ethtool_ops that are impleme=
nted=2E It is reasonably simple to use coccinelle to update these ethtool_o=
ps with possibly updated signatures to support netlink attributes and whatn=
ot, but forcing drivers to quit doing ethtool_ops entitely and implement ne=
w sets of "ethtool over netlink" ops is a non starter IMHO=2E

--=20
Florian
