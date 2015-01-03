From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: Re: [PATCH iproute2 v2] bridge/link: add learning_sync policy flag
Date: Sat, 3 Jan 2015 06:53:58 +0530
Message-ID: <CA+CtxLSvB+vbUPS_7eJd8tfjQ1H_XVB9or=r=HAuusKVpoz9Kw@mail.gmail.com>
References: <1419884407-21998-1-git-send-email-sfeldma@gmail.com>
	<CA+CtxLS7x8zKQ-9xwjoH3=pidkXS9s5b2+K_VO4eDHJTWo5tYQ@mail.gmail.com>
	<CAE4R7bBpmR429F--8NNx0Jqos_bR-x2G4ybjmPhDW6Q+kV5y2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:46383 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998AbbACBX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 20:23:59 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so342477wiw.9
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 17:23:58 -0800 (PST)
In-Reply-To: <CAE4R7bBpmR429F--8NNx0Jqos_bR-x2G4ybjmPhDW6Q+kV5y2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think the aging settings are per-bridge, not per-bridge-port, so the
> policy control you're talking about wouldn't end up here on
> /sbin/bridge link.
>
Agree.

> However, I would argue even with hardware aging capability, we still
> should use Linux for aging since all the controls are already there
> and it just works.  It keeps the swdev model simple and the swdev
> driver simple.  Do you have a counter-argument for why enabling
> hardware aging would be better?

When traffic is being forwarded in hardware and if the entries are to
be software aged, the aging logic needs to periodically(once every
configured age interval) retrieve the FDB entry's hit bit in the
hardware. If this bit is not set it deletes the entry. If the hit bit
is set, it clears it. This could be CPU intensive if the FDB size runs
into few thousand entries.

If hardware aging is enabled, the above job is offloaded to hardware.

The current aging logic does not  differentiate between software
forwarded and hardware forwarded entries. When the traffic is being
forwarded in hardware, the aging logic is deleting the entries after
age interval.

So the solution could be

1)When hardware aging is enabled, only the notifications(probably via
br_fdb_external_learn_delete())  delete the fdb entries.
2)When software aging is enabled, aging logic needs to differentiate
between software forwarded and hardware forwarded entries. For entries
forwarded in hardware, the above aging logic needs to be implemented.



On Fri, Jan 2, 2015 at 11:27 PM, Scott Feldman <sfeldma@gmail.com> wrote:
> On Fri, Jan 2, 2015 at 9:14 AM, Siva Mannem <siva.mannem.lnx@gmail.com> wrote:
>> Hi,
>>
>>
>>> +.BR "learning_sync on " or " learning_sync off "
>>> +Controls whether a given port will sync MAC addresses learned on device port to
>>> +bridge FDB.
>>> +
>>
>> For the FDB entries synced from device port to bridge FDB, can the
>> device port also mention that it will take care of aging the synced
>> entries? I am thinking of a use case where the port supports hardware
>> learning and hardware aging?
>
> I think the aging settings are per-bridge, not per-bridge-port, so the
> policy control you're talking about wouldn't end up here on
> /sbin/bridge link.
>
> However, I would argue even with hardware aging capability, we still
> should use Linux for aging since all the controls are already there
> and it just works.  It keeps the swdev model simple and the swdev
> driver simple.  Do you have a counter-argument for why enabling
> hardware aging would be better?
>
> -scott
