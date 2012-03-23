From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of the
 timecompare method
Date: Fri, 23 Mar 2012 15:39:08 -0400
Message-ID: <CAAsGZS460uazL5n=oc3DwWKqeuTtNdQROGXQrPbs=Qh92TpnDg@mail.gmail.com>
References: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
	<CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
	<20120316065537.GB2199@netboy.at.omicron.at>
	<CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
	<20120321170003.GA5533@netboy.at.omicron.at>
	<02874ECE860811409154E81DA85FBB580DA6E3@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS6QuMJoXz8mmqZsgfTF2ykRz6KG_nCoPBBkTA4z3idoGA@mail.gmail.com>
	<20120322064107.GB2182@netboy.at.omicron.at>
	<CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DB92C@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:44558 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920Ab2CWTjJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 15:39:09 -0400
Received: by pbcun15 with SMTP id un15so2810867pbc.19
        for <netdev@vger.kernel.org>; Fri, 23 Mar 2012 12:39:08 -0700 (PDT)
In-Reply-To: <02874ECE860811409154E81DA85FBB580DB92C@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 23, 2012 at 2:27 PM, Keller, Jacob E
<jacob.e.keller@intel.com> wrote:

> However the try_cnt would not work, because of a case where the timec=
ounter is just about to roll over. (So last check was 25 seconds ago.) =
Then the cyc2time function is called, determines that some RX timestamp=
 is in the 'future'. At this point on another CPU the timecounter_read =
is run, and updates the nsec value in the timecounter by 25 seconds, an=
d stores the last read timestamp value. Now the cyc2time function uses =
the 'new' values, but doesn't know to correct for it by using the "in t=
he past" subtraction. Thus, the resulting ns returned by cyc2time would=
 be 25 seconds in the future. This isn't just not accurate, it is very =
wrong and could throw of PTP calculations.
>

PS: for some reason the line endings were messed up already when I hit
reply to this msg.

So, how is it working today? Because we could have tx and rx
completions on different CPUs. Is it not possible to have the
following race today - between timecompare_update->timecompare_offset
-> timecounter_readdelta of say Rx and timecounter_cyc2time from Tx?



> The solution here is when the try_cnt runs out, drop the timestamp or=
 return 0 as the value. (So that the PTP app knows the timestamp was ba=
d.) However this is introducing more potentially dropped timestamps, =C2=
=A0which could be an issue.
>
> I think a better way to solve this problem is throttle the ioctls. Wo=
uld it be possible to detect users spamming the ioctls and return some =
sort of 'EBUSY' error? Maybe by using spin_trylock? That would prevent =
the starvation issues mentioned if a user were to spam set/get/adj in s=
ome weird loop, without a potentially dangerous locking scheme.
>
>

I was thinking of caching the tstamp values from the Tx/Rx path () and
also firing a kernel-thread per-driver to update the cached value. So
gettime (ab)users could be taken care off that way by returning the
cached value. But settime/adjtime would still be left.

So yes, rate limiting ioctls seems like a good idea.

How about rate limiting at the PHC class driver level? And then it
will work across the board for all the adapters at the device level.

Chetan
