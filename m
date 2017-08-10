From: Andreas Born <futur.andy@googlemail.com>
Subject: Re: Regression: Bug 196547 - Since 4.12 - bonding module not working
 with wireless drivers
Date: Thu, 10 Aug 2017 19:52:03 +0200
Message-ID: <CADps9UA7S2betC-+5sOXjYWmDC8gnk6JJ9aEueEOoYAC3DU8hg@mail.gmail.com>
References: <87shh0gewn.fsf@kamboji.qca.qualcomm.com> <8845e49b-3165-e6df-5935-c86278d220d9@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Kalle Valo <kvalo@codeaurora.org>,
        Mahesh Bandewar <maheshb@google.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, James Feeney <james@nurealm.net>
To: Arend van Spriel <arend.vanspriel@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:38286 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752437AbdHJRwE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 13:52:04 -0400
In-Reply-To: <8845e49b-3165-e6df-5935-c86278d220d9@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

2017-08-10 14:43 GMT+02:00 Arend van Spriel <arend.vanspriel@broadcom.com>:
>
>
> On 10-08-17 07:39, Kalle Valo wrote:
>>
>> Hi Mahesh and Andy,
>>
>> James Feeney reported that there's a serious regression in bonding
>> module since v4.12, it doesn't work with wireless drivers anymore as
>> wireless drivers don't report the link speed via ethtool:
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D196547
>>
>> In the bug report it's said that this commit is the culprit:
>>
>> 3f3c278c94dd bonding: fix active-backup transition
>
>
> This commit references another one. ie. commit c4adfc822bf5 ("bonding: ma=
ke speed, duplex setting consistent with link state"). Before this commit t=
he result of __ethtool_get_link_ksettings() was simply ignored.

Actually it was not simply ignored in any case: Further down in
bond_miimon_commit() there's a conditional call to
bond_3ad_handle_link_change() which triggers an update using
__get_link_speed() to actually access the result. A similar handler is
also called for lb modes.

>
> Commit 3f3c278c94dd ("bonding: fix active-backup transition") moves setti=
ng the link state to the call sites of bond_update_speed_duplex(), just not=
 all call sites.
>
>> Is there a fix for this or should that commit be reverted? This seems to
>> be a serious regression as there are multiple reports already and we
>> should get it fixed for v4.13, and the fix backported to v4.12 stable
>> release.
>
>
> The ethtool callbacks really seem optional. At least in brcmfmac, the wir=
eless driver I maintain, I only provide get_drvinfo callback and there is n=
o warning triggered upon registering the netdev. The changes above now requ=
ire each netdev to implement the get_link_ksettings callback (get_settings =
is deprecated) or the link is marked as DOWN ruling it out to be used as ac=
tive bond slave. To the end-users who were using bonding this is simply a r=
egression. So to fix that both changes should be reverted in my opinion.

Yes, also to me as user of a wireless slave in an active-backup bond
it's clearly a regression. But only partially for some modes like
active-backup since the bonding documentation [1] clearly lists as a
prerequisite

1) for 802.3ad: "Ethtool support in the base drivers for retrieving
the speed and duplex of each slave."
2) for tlb/alb: "Ethtool support in the base drivers for retrieving
the speed of each slave."

This was previously not directly enforced in the bonding code and thus
probably occasionally caused unexpected behavior. At least such
behavior is what to my understanding commit c4adfc822bf5 ("bonding:
make speed, duplex setting consistent with link state") and
3f3c278c94dd ("bonding: fix active-backup transition") intend to fix
with an apparent focus on 802.3ad. However those commits went too far
by requiring a get_link_ksettings implementation by every slave driver
REGARDLESS of the bond mode.

Earlier today I submitted the patch (bonding: require speed/duplex
only for 802.3ad, alb and tlb) [2] that only partially reverts what is
a regression following my aforementioned logic. This seems to me like
the best solution in the short term since it should satisfy both
usergroups represented by Mahesh and James and restores consistence
with the bonding documentation. James already commented approvingly on
that patch in the bug report. [3]

Regards
Andreas

[1] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree=
/Documentation/networking/bonding.txt
[2] https://www.spinics.net/lists/netdev/msg448662.html
[3] https://bugzilla.kernel.org/show_bug.cgi?id=3D196547#c10
