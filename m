From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] switchdev: fix BUG when port driver doesn't
 support set attr op
Date: Wed, 10 Jun 2015 15:00:47 -0700
Message-ID: <CAE4R7bBhvfbX2wUoensSBpVsOzaaHw_ZFtiu+woj45_sziOS6g@mail.gmail.com>
References: <1433969762-22406-1-git-send-email-sfeldma@gmail.com>
 <5578AB3C.5020206@gmail.com> <CAE4R7bD2RLa9D1_JnGr4RUMYHWMa-kQab=1ihN3YMkJgLqFViw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Brenden Blanco <bblanco@plumgrid.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:33863 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbbFJWBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 18:01:08 -0400
Received: by qkoo18 with SMTP id o18so32319471qko.1
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 15:01:07 -0700 (PDT)
In-Reply-To: <CAE4R7bD2RLa9D1_JnGr4RUMYHWMa-kQab=1ihN3YMkJgLqFViw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 2:47 PM, Scott Feldman <sfeldma@gmail.com> wrote:
> On Wed, Jun 10, 2015 at 2:25 PM, David Ahern <dsahern@gmail.com> wrote:
>> On 6/10/15 2:56 PM, sfeldma@gmail.com wrote:
>>>
>>> From: Scott Feldman <sfeldma@gmail.com>
>>>
>>> Fix a BUG() where CONFIG_NET_SWITCHDEV is set but the driver for a bridged
>>> port does not support switchdec_port_attr_set op.  Don't BUG() if
>>> -EOPNOTSUPP is returned.
>>>
>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>> Reported-by: Brenden Blanco <bblanco@plumgrid.com>
>>> ---
>>>   net/switchdev/switchdev.c |    2 +-
>>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>>> index e008057..99bced4 100644
>>> --- a/net/switchdev/switchdev.c
>>> +++ b/net/switchdev/switchdev.c
>>> @@ -103,7 +103,7 @@ static void switchdev_port_attr_set_work(struct
>>> work_struct *work)
>>>
>>>         rtnl_lock();
>>>         err = switchdev_port_attr_set(asw->dev, &asw->attr);
>>> -       BUG_ON(err);
>>> +       BUG_ON(err && err != -EOPNOTSUPP);
>>>         rtnl_unlock();
>>>
>>>         dev_put(asw->dev);
>>>
>>
>> Should that be WARN_ON instead of BUG_ON?
>
> I think I had it as WARN when we were working on the initial patches,
> but we changed it to BUG_ON because we should only get an error here
> if the driver screwed something up between PREPARE phase and COMMIT
> phase, so it should be considered a driver bug which needs fixing.

Actually, ignore what I said above.  I was confusing this BUG_ON with
the one in switchdev_port_attr_set().  Perhaps this BUG_ON() you're
commenting on should be WARN().  A driver could return an err in
PREPARE phase and that shouldn't be a BUG_ON situation; seems WARN
would be better.   It the case where the driver returns an err in
COMMIT phase but didn't return an err in PREPARE phase we want to
BUG_ON().  Maybe that case doesn't justify BUG_ON either, based on the
link you posted.

Jiri, IIRC, you suggested the BUG_ON().  Does it still sound right
based on the point David is raising?

-scott
