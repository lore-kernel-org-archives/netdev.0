From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] switchdev: fix BUG when port driver doesn't
 support set attr op
Date: Thu, 11 Jun 2015 08:16:19 +0200
Message-ID: <20150611061619.GA2121@nanopsycho.orion>
References: <1433969762-22406-1-git-send-email-sfeldma@gmail.com>
 <5578AB3C.5020206@gmail.com>
 <CAE4R7bD2RLa9D1_JnGr4RUMYHWMa-kQab=1ihN3YMkJgLqFViw@mail.gmail.com>
 <CAE4R7bBhvfbX2wUoensSBpVsOzaaHw_ZFtiu+woj45_sziOS6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsahern@gmail.com>, Netdev <netdev@vger.kernel.org>,
	Brenden Blanco <bblanco@plumgrid.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:36734 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbbFKGQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 02:16:23 -0400
Received: by wgbgq6 with SMTP id gq6so48550158wgb.3
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 23:16:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bBhvfbX2wUoensSBpVsOzaaHw_ZFtiu+woj45_sziOS6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jun 11, 2015 at 12:00:47AM CEST, sfeldma@gmail.com wrote:
>On Wed, Jun 10, 2015 at 2:47 PM, Scott Feldman <sfeldma@gmail.com> wrote:
>> On Wed, Jun 10, 2015 at 2:25 PM, David Ahern <dsahern@gmail.com> wrote:
>>> On 6/10/15 2:56 PM, sfeldma@gmail.com wrote:
>>>>
>>>> From: Scott Feldman <sfeldma@gmail.com>
>>>>
>>>> Fix a BUG() where CONFIG_NET_SWITCHDEV is set but the driver for a bridged
>>>> port does not support switchdec_port_attr_set op.  Don't BUG() if
>>>> -EOPNOTSUPP is returned.
>>>>
>>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>>> Reported-by: Brenden Blanco <bblanco@plumgrid.com>
>>>> ---
>>>>   net/switchdev/switchdev.c |    2 +-
>>>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>>>> index e008057..99bced4 100644
>>>> --- a/net/switchdev/switchdev.c
>>>> +++ b/net/switchdev/switchdev.c
>>>> @@ -103,7 +103,7 @@ static void switchdev_port_attr_set_work(struct
>>>> work_struct *work)
>>>>
>>>>         rtnl_lock();
>>>>         err = switchdev_port_attr_set(asw->dev, &asw->attr);
>>>> -       BUG_ON(err);
>>>> +       BUG_ON(err && err != -EOPNOTSUPP);
>>>>         rtnl_unlock();
>>>>
>>>>         dev_put(asw->dev);
>>>>
>>>
>>> Should that be WARN_ON instead of BUG_ON?
>>
>> I think I had it as WARN when we were working on the initial patches,
>> but we changed it to BUG_ON because we should only get an error here
>> if the driver screwed something up between PREPARE phase and COMMIT
>> phase, so it should be considered a driver bug which needs fixing.
>
>Actually, ignore what I said above.  I was confusing this BUG_ON with
>the one in switchdev_port_attr_set().  Perhaps this BUG_ON() you're
>commenting on should be WARN().  A driver could return an err in
>PREPARE phase and that shouldn't be a BUG_ON situation; seems WARN
>would be better.   It the case where the driver returns an err in
>COMMIT phase but didn't return an err in PREPARE phase we want to
>BUG_ON().  Maybe that case doesn't justify BUG_ON either, based on the
>link you posted.
>
>Jiri, IIRC, you suggested the BUG_ON().  Does it still sound right
>based on the point David is raising?

Hmm, looking at code of switchdev_port_attr_set. In case that fails in
prepare state (which can easily happen for example due to -ENOMEM) this
BUG_ON is hit as well. That is not right. I think we should change it
just to warning. Also I think that prink (or a flavour) is more suitable
here than WARN.

Btw, why switchdev_port_obj_add has WARN and not BUG ?
