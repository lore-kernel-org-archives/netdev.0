From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [0/5] bcma/brcmsmac suspend/resume cleanups and fixes
Date: Sat, 14 Jan 2012 15:28:20 -0800
Message-ID: <CA+55aFyHCyUq=v4DED5yA+VdPhjG+1b270ZUq+mP_mS4ip_HcQ@mail.gmail.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
 <1326440480-26271-1-git-send-email-zajec5@gmail.com> <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
 <4F101047.4090902@broadcom.com> <CA+55aFxtaw+FF8wRf9td1rU0A_vhM8XwgSznzE-ph_4j=t5gWg@mail.gmail.com>
 <20120114122222.GA21233@nautica> <CA+55aFxTkKwTy8mq9vRzHLNE7W8SYd5kbg2Ofr8LiG0DznLy6A@mail.gmail.com>
 <20120114230839.GA12667@nautica>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arend van Spriel <arend@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Dominique Martinet <asmadeus@codewreck.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:50829 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032Ab2ANX2m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 18:28:42 -0500
Received: by wibhm14 with SMTP id hm14so1208921wib.19
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2012 15:28:41 -0800 (PST)
In-Reply-To: <20120114230839.GA12667@nautica>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 14, 2012 at 3:08 PM, Dominique Martinet
<asmadeus@codewreck.org> wrote:
>
> Right, I missed it. Suspend works as long as I don't use wireless
> before.

Ok. Your suspend hang may be related to the cfg80211_wext hang that is
apparently unrelated to the issues we saw.

> I still get a warning:
>
> [ =A0 30.256946] ------------[ cut here ]------------
> [ =A0 30.256956] WARNING: at drivers/base/core.c:194 device_release+0=
x6a/0x73()

Yes. This warning is annoying but harmless. We'll fix it some way
(possibly by just turning it back to a single line, like it used to
be), but for now you can just ignore it.

> brcmsmac seems to have a problem that looks like it's fixed in
> wireless-next, after a suspend if it's been used then all network
> operation hang (i.e. 'ip addr', something like resolving an host does=
n't
> work but doesn't hang either, modprobe -r brcmsmac hangs as well)
> Here's the revelent information about this:
>
> [ =A0361.248353] INFO: task wpa_supplicant:9102 blocked for more than=
 120 seconds.
> [ =A0361.248362] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" d=
isables this message.
> [ =A0361.248367] wpa_supplicant =A0D ffff880062d68400 =A0 =A0 0 =A091=
02 =A0 =A0 =A01 0x00000000
> [ =A0361.248397] Call Trace:
> [ =A0361.248411] =A0[<ffffffff81313307>] ? __mutex_lock_common.clone.=
5+0x114/0x179
> [ =A0361.248432] =A0[<ffffffffa03bef8a>] ? cfg80211_wext_siwscan+0xbd=
/0x2dc [cfg80211]
> [ =A0361.248439] =A0[<ffffffff81313137>] ? mutex_lock+0x12/0x25
> [ =A0361.248458] =A0[<ffffffffa03f83c1>] ? ieee80211_request_scan+0x2=
0/0x4e [mac80211]

Ok, judging by the call trace this seems to be a generic wireless bug,
likely not a brcmsmac bug.  Presumably people like me (and obviously
wireless developers) avoid this by not using wpa_supplicant o
rsomething. You might want to enable LOCKDEP to verify - if it's a
deadlock (either direct, or ABBA) - lockdep should give you a big
splat immediately rather than having to wait for 2 minutes.

Linwille/David - can you please make sure the fix gets to my tree,
since it's apparently already ok in the development tree?

                     Linus
