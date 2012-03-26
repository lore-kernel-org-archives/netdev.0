From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of the
 timecompare method
Date: Mon, 26 Mar 2012 13:11:32 -0400
Message-ID: <CAAsGZS5Kn0nnwE0=0Eoo9a9e4+9w2fQ4nWjbCNsNrL-yfE3BtQ@mail.gmail.com>
References: <CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
	<20120321170003.GA5533@netboy.at.omicron.at>
	<02874ECE860811409154E81DA85FBB580DA6E3@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS6QuMJoXz8mmqZsgfTF2ykRz6KG_nCoPBBkTA4z3idoGA@mail.gmail.com>
	<20120322064107.GB2182@netboy.at.omicron.at>
	<CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
	<02874ECE860811409154E81DA85FBB580DB92C@ORSMSX105.amr.corp.intel.com>
	<CAAsGZS460uazL5n=oc3DwWKqeuTtNdQROGXQrPbs=Qh92TpnDg@mail.gmail.com>
	<20120324065147.GB2201@netboy.at.omicron.at>
	<CAAsGZS556o4iXtsWBzpiXxmv4isoZzw_h+RNv5eBMTGOsK905w@mail.gmail.com>
	<20120326152730.GA10212@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:54744 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932667Ab2CZRLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 13:11:32 -0400
Received: by pbcun15 with SMTP id un15so6199449pbc.19
        for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 10:11:32 -0700 (PDT)
In-Reply-To: <20120326152730.GA10212@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 26, 2012 at 11:27 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Mon, Mar 26, 2012 at 11:07:40AM -0400, chetan loke wrote:
>> On Sat, Mar 24, 2012 at 2:51 AM, Richard Cochran
>> <richardcochran@gmail.com> wrote:
>> > On Fri, Mar 23, 2012 at 03:39:08PM -0400, chetan loke wrote:
>> >>
>> >> So, how is it working today? Because we could have tx and rx
>> >> completions on different CPUs. Is it not possible to have the
>> >> following race today - between timecompare_update->timecompare_offset
>> >> -> timecounter_readdelta of say Rx and timecounter_cyc2time from Tx?
>> >
>> > I works (in the igb) because of the spinlock. You know, that thing
>> > that you are so against using.
>> >
>>
>> I meant, was there a lock before the PHC functionality in igb?
>
> There was no lock, and yes, it was a bug.

Ok, so this needs to be fixed irrespective of the PHC code.

>
>> >> How about rate limiting at the PHC class driver level? And then it
>> >> will work across the board for all the adapters at the device level.
>> >
>> > No, don't go there. Enough bikeshedding already. If you have a serious


Did I ever tell you that your patch is costing us 'N' clock-cycles in
the fast path? We all understand that to gain some features we may
have to sacrifice something. Folks who want time-stamping might have
to take a small performance hit (may be to work around hardware issues
and so on).

You are confusing 'blocking the driver's fast path' with
performance/optimization etc. We cannot let user-space code jam the
system. Kernel code should be designed such that
bugs(intentional/unintentional) in user-space code cannot cause system
wide adverse affects. Period.

Does your existing design limit (ab)users from pounding the ioctls?

As I mentioned earlier, it could be possible to take care of gettime
and the driver's Rx/Tx path by using a mixture of locks/kernel-thread.
But settime/adjtime still needs to be curbed.

Why isn't ioctl-rate limiting acceptable? Let's say an app that is
trying to set/adj NIC counter is running on host side then how often
would it need to read and correct/set/adj? once every msec(so 1000
times a second), once every 10 msec(100 times a second) etc?

So, will pounding the ioctl 1000 times, while processing ~820K
frames(1500 byte payload on 10G link) still cause a problem for the
driver is what we would need to see. rate can also be a factor of
link-speed(?).

And we don't need 100 such apps. Only 1 app should be working in
tandem with the NIC. If other apps fail then atleast the sysadmin or
users would know someone else is (ab)using it.


> Thanks,
> Richard

Chetan
