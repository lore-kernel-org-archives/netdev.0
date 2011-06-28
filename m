From: Jon Mason <mason@myri.com>
Subject: Re: [PATCH 3/9 v2] myri10ge: rework parity error check and cleanup
Date: Mon, 27 Jun 2011 22:31:23 -0500
Message-ID: <BANLkTinaH0yCg+uFOZL5MiHhFqXNxd4sAw@mail.gmail.com>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
	<1309187108-12715-3-git-send-email-mason@myri.com>
	<20110627205432.GA18978@myri.com>
	<1309227435.3344.20.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Andrew Gallatin <gallatin@myri.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:47707 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755918Ab1F1Db0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 23:31:26 -0400
Received: by iwn6 with SMTP id 6so4626245iwn.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 20:31:25 -0700 (PDT)
In-Reply-To: <1309227435.3344.20.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2011 at 9:17 PM, Joe Perches <joe@perches.com> wrote:
> On Mon, 2011-06-27 at 15:54 -0500, Jon Mason wrote:
>> Clean up watchdog reset code:
>> =A0- move code that checks for stuck slice to a common routine
>> =A0- unless there is a confirmed h/w fault, verify that a stuck
>> =A0 =A0slice is still stuck in the watchdog worker; if the slice is =
no
>> =A0 =A0longer stuck, abort the reset.
>> =A0- this removes an egregious 2000ms pause in the watchdog worker t=
hat
>> =A0 =A0was a diagnostic aid (to look for spurious resets) the snuck =
into
>> =A0 =A0production code.
>> v2 includes corrections from Ben Hutchings and Joe Perches
>
> Here's some more trivia:
>
>> diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/=
myri10ge.c
> []
>> @@ -3442,6 +3443,42 @@ static u32 myri10ge_read_reboot(struct myri10=
ge_priv *mgp)
>> =A0 =A0 =A0 return reboot;
>> =A0}
>>
>> +static void
>> +myri10ge_check_slice(struct myri10ge_slice_state *ss, int *reset_ne=
eded,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int *busy_slice_cnt, u32 rx_pau=
se_cnt)
>> +{
> []
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* nic seems like it might be stuck.. */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (rx_pause_cnt !=3D mgp->watchdog_pause)=
 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (net_ratelimit())
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_war=
n(mgp->dev, "slice %d: TX paused, "
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 "check link partner\n", slice);
>
> I think this would be better if the format weren't split.
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netdev=
_warn(mgp->dev, "slice %d: TX paused, check link partner\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0slice);
> or
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netdev=
_warn(mgp->dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0"slice %d: TX paused, check link partner\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0slice);
> or if you really must split it because exceeding 80 columns
> makes you itchy:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netdev=
_warn(mgp->dev, "slice %d: "
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0"TX paused, check link partner\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0slice);

Naa, I prefer it this way.

>> @@ -3465,8 +3504,7 @@ static void myri10ge_watchdog(struct work_stru=
ct *work)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* For now, just report it */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 reboot =3D myri10ge_read_reboot(mgp);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(mgp->dev, "NIC rebooted (0x%x=
),%s resetting\n",
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reboot,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0myri10ge_reset_reco=
ver ? "" : " not");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reboot, myri10ge_re=
set_recover ? " " : " not");
>
> I think this was correct before you changed it.
>
> Maybe:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reboot, myri10ge_=
reset_recover ? "" : " not");

Yes, I believe this was the intent.

>
>
>
