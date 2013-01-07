From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2] sctp: Change defaults on cookie hmac selection
Date: Mon, 07 Jan 2013 11:39:06 -0500
Message-ID: <50EAFA2A.3000200@gmail.com>
References: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com> <1355534521-32719-1-git-send-email-nhorman@tuxdriver.com> <50EACCD3.90609@openwrt.org> <20130107144921.GA31577@hmsreliant.think-freely.org> <50EAEA71.1060007@gmail.com> <20130107154625.GD31577@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:39243 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463Ab3AGQjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 11:39:10 -0500
In-Reply-To: <20130107154625.GD31577@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2013 10:46 AM, Neil Horman wrote:
> On Mon, Jan 07, 2013 at 10:32:01AM -0500, Vlad Yasevich wrote:
>> On 01/07/2013 09:49 AM, Neil Horman wrote:
>>> On Mon, Jan 07, 2013 at 02:25:39PM +0100, Florian Fainelli wrote:
>>>> Hello Neil,
>>>>
>>>> Le 12/15/12 02:22, Neil Horman a =E9crit :
>>>>> Recently I posted commit 3c68198e75 which made selection of the c=
ookie hmac
>>>>> algorithm selectable.  This is all well and good, but Linus noted=
 that it
>>>>> changes the default config:
>>>>> http://marc.info/?l=3Dlinux-netdev&m=3D135536629004808&w=3D2
>>>>>
>>>>> I've modified the sctp Kconfig file to reflect the recommended wa=
y of making
>>>>> this choice, using the thermal driver example specified, and brou=
ght the
>>>>> defaults back into line with the way they were prior to my origio=
nal patch
>>>>>
>>>>> Also, on Linus' suggestion, re-adding ability to select default '=
none' hmac
>>>>> algorithm, so we don't needlessly bloat the kernel by forcing a n=
on-none
>>>>> default.  This also led me to note that we won't honor the defaul=
t none
>>>>> condition properly because of how sctp_net_init is encoded.  Fix =
that up as
>>>>> well.
>>>>>
>>>>> Tested by myself (allbeit fairly quickly).  All configuration com=
binations seems
>>>>> to work soundly.
>>>>>
>>>>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>>>>> CC: David Miller <davem@davemloft.net>
>>>>> CC: Linus Torvalds <torvalds@linux-foundation.org>
>>>>> CC: Vlad Yasevich <vyasevich@gmail.com>
>>>>> CC: linux-sctp@vger.kernel.org
>>>>> ---
>>>>>   net/sctp/Kconfig    | 27 +++++++++++++++++++++++++--
>>>>>   net/sctp/protocol.c |  4 ++--
>>>>>   2 files changed, 27 insertions(+), 4 deletions(-)
>>>>>
>>>>> diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
>>>>> index a9edd2e..c262106 100644
>>>>> --- a/net/sctp/Kconfig
>>>>> +++ b/net/sctp/Kconfig
>>>>> @@ -66,12 +66,36 @@ config SCTP_DBG_OBJCNT
>>>>>   	  'cat /proc/net/sctp/sctp_dbg_objcnt'
>>>>>
>>>>>   	  If unsure, say N
>>>>> +choice
>>>>> +	prompt "Default SCTP cookie HMAC encoding"
>>>>> +	default SCTP_COOKIE_HMAC_MD5
>>>>
>>>> Should not this be SCTP_DEFAULT_COOKIE_HMAC_MD5? I just tried to
>>>> update to 3.8-rc2, and I usually build my kernel-headers with:
>>>>
>>>> yes '' | ARCH=3Dfoo make oldconfig
>>>>
>>>> and this just kept asking me for this config symbol because none
>>>> could be provided.
>>>> --
>>>> Florian
>>>>
>>>
>>> No, the config mechanism is setup to offer the user the ability to =
choose a
>>> default cookie hmac, alg, then optionally select any other hmac alg=
s you would
>>> like to be made available (in the event you want to change the defa=
ult at run
>>> time).  When you select the default, it eables (via the select dire=
ctive), the
>>> corresponding SCTP_COOKIE_HMAC_* config option, which is used in th=
e build, and
>>> then prompts for the remaining values.
>>>
>>
>> Neil
>>
>> Actually, I think it should be as Florian suggests.  The default
>> value of the choice should be one of the values defined as part of
>> the choice (the SCTP_DEFAULT_COOKIE_*).  Turning on appropriate
>> default would turn on appropriate cookie config
>> (SCTP_COOKIE_HMAC_*).
>>
> I absolutely disagree.
>
>> Would that save all the config trouble?
>>
> Yes, it would fix it as Florian has noted, but at the cost of silentl=
y modifying
> what the default hmac config vaule is.  If you've expressly disabled
> SCTP_COOKIE_HMAC_MD5, and then blindly take the default choice in the
> SCTP_DEFAULT_COOKIE selection option (the default default as it were)=
, using the
> approach your suggesting, then that will silently enable SCTP_COOKIE_=
HMAC_MD5
> again, which may not be expected by users.  If you expressly have a c=
onfig
> option disabled in an old configuration, we should leave it there.

GACK.  Just reproduced this and I really don't like this infinite loop=20
of choice prompts.  That's a horrible bug and we need to fix this.

I don't think overriding the value is that big of a deal, especially=20
considering that this is exactly what 'make menuconfig' and other=20
graphical configs will do.
If I start with:
	CONFIG_IP_SCTP=3Dm
	CONFIG_NET_SCTPPROBE=3Dm
	# CONFIG_SCTP_DBG_MSG is not set
	# CONFIG_SCTP_DBG_OBJCNT is not set
	# CONFIG_SCTP_HMAC_NONE is not set
	CONFIG_SCTP_HMAC_SHA1=3Dy
	# CONFIG_SCTP_HMAC_MD5 is not set

then run:
	yes "" | make oldconfig

I get an infinite loop.

If I run "make menuconfig", I get:
	CONFIG_IP_SCTP=3Dm
	CONFIG_NET_SCTPPROBE=3Dm
	# CONFIG_SCTP_DBG_MSG is not set
	# CONFIG_SCTP_DBG_OBJCNT is not set
	CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5=3Dy
	# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
	# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
	CONFIG_SCTP_COOKIE_HMAC_MD5=3Dy
	# CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set

Note, that SHA1 is now overridden with MD5.

If I change the value of the default choice in Kconfig, the behavior=20
between oldconfig and menuconfig is the same.

-vlad







>
> We're doing the right thing now, IMO.  When presented with a conflict=
ly set
> of configuration options, the config utilty is (repeatedly) prompting=
 us to
> resolve them.  That seems like a much more reasonable approach to thi=
s, than
> silently changing pre-existing options so people can do the equivalen=
t of just
> blindly pressing enter through the config process (which is all yes "=
" | make
> oldconfig is).
>
> This is a momentary hiccup, corrected by taking 30 seconds to make a =
manual
> config change (or by taking a second to understand what the config ut=
ility is
> tell us by prompting for a default choice repeatedly).  Theres nothin=
g to fix
> here.
>
> Neil
>
>> -vlad
>>
>>> Neil
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
