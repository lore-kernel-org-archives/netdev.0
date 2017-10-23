From: Steve Lin <steven.lin1@broadcom.com>
Subject: Re: [PATCH net-next v2 1/6] devlink: Add permanent config parameter
 get/set operations
Date: Mon, 23 Oct 2017 11:27:17 -0400
Message-ID: <CA+Jmh7Hbyvnvjdxx9qrev6U8zU+aZXD7aUdzUwGLYRtm5R3g4A@mail.gmail.com>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
 <1508440630-25830-2-git-send-email-steven.lin1@broadcom.com>
 <AM0PR0502MB3683FB1536D1A204E5D1369EBF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
 <CA+Jmh7Gdud=T47iK=ZjgoXvXj+frBgP=HcvGDWHzJxUzN9L=tA@mail.gmail.com> <AM0PR0502MB3683CA10099EA2075269A979BF400@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "gospo@broadcom.com" <gospo@broadcom.com>
To: Yuval Mintz <yuvalm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:48297 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751260AbdJWP1j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 11:27:39 -0400
Received: by mail-qt0-f195.google.com with SMTP id f8so26618767qta.5
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 08:27:38 -0700 (PDT)
In-Reply-To: <AM0PR0502MB3683CA10099EA2075269A979BF400@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 21, 2017 at 10:12 AM, Yuval Mintz <yuvalm@mellanox.com> wrote:
>> On Thu, Oct 19, 2017 at 4:21 PM, Yuval Mintz <yuvalm@mellanox.com>
>> wrote:
>> >> Subject: [PATCH net-next v2 1/6] devlink: Add permanent config
>> parameter
>> >> get/set operations
>> >>
>> >> Add support for permanent config parameter get/set commands. Used
>> >> for parameters held in NVRAM, persistent device configuration.
>> >
>> > Given some of the attributes aren't Boolean, what about an API that
>> > allows the user to learn of supported values per option?
>> > Otherwise only way for configuring some of them would be trial & error=
.
>>
>> Interesting suggestion.  There's a couple of places where this could
>> be a factor.  (1) When a user wants to know what values are
>> defined/available in the API, and (2) When the user wants to know what
>> values are supported by a specific driver/device.
>>
>> The intention for (1) is to push that into userspace.  The userspace
>> devlink tool patches I am working on (not yet submitted) essentially
>> mirror the config parameters and their options, with string "keywords"
>> associated with each parameter and option, since it's the userspace
>> app that will be parsing the command line strings and converting to
>> API enums.  So the userspace app can provide the list of
>> parameters/options it supports, which could be a subset of what's
>> available in the API.
>>
>> For (2), currently there is no mechanism other than trial/error as you
>> suggest (up to driver to either return an error or else make use of
>> the value specified by the user).  We could contemplate adding such a
>> mechanism, but it's a little complicated as some options take a range
>> (i.e. # of VFs per PF for example), and others may take one of a set
>> of enumerated values (pre-boot link speed for example).
>>
>> To clarify, are you suggesting some mechanism to allow a driver to
>> report which parameters and options it supports (case (2))?  Or are
>> you suggesting something in the kernel API to handle case (1) above?
>
> I was thinking of (2). And I agree it would take some effort.

I don't disagree that this could be a useful addition.  But, it seems
like this could be added as a follow on patch.  I think many/most
users of this permanent device config API probably already know what
capabilities their device offers, and if they are wrong, the driver
can indicate invalid config options.  Nothing in the patchset prevents
future work to add a new devlink operation to query the driver for
supported options.  Thoughts?

>> > Isn't it possible that a response for a single request for multiple AT=
TRs
>> > wouldn't fit in a single message?
>> >
>>
>> Hmm... Given the small size and relatively small total number of these
>> attributes, even when additional drivers add their own, I think it's
>
> We probably have a different idea about 'small'.
> Didn=E2=80=99t your *initial* series attempt to add 35 attributes at once=
?
>

Yes, and I'd still like to get those ~35 parameters in eventually! :)
But even if there were 100 parameters, and all 100 were being get or
set at once, if you assume 20 bytes per parameter (4 bytes each for
DEVLINK_ATTR_CONFIG, DEVLINK_ATTR_CONFIG_PARAMETER,
DEVLINK_ATTR_CONFIG_VALUE, 8 for nesting), that's ~2000 bytes in the
message.  A little overhead, too, of course, but still less than half
a typical netlink message size of 4KB.

So, at some point - if a device with 250 parameters comes along, say,
all of which are set/get at once - this could be a problem, but it's
not clear if this is a realistic scenario to prepare for?
