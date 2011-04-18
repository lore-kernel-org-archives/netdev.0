From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Suspend/resume - slow resume
Date: Mon, 18 Apr 2011 11:49:01 -0700
Message-ID: <BANLkTim_1OgqjCeD1a4Ay2fWJSmPHa_XTQ@mail.gmail.com>
References: <Pine.SOC.4.64.1104150931390.1320@er3.rutgers.edu>
 <BANLkTinO+HFq+Mgg1aUz9V==zYs7qSBtDw@mail.gmail.com> <Pine.SOC.4.64.1104151122330.1320@er3.rutgers.edu>
 <BANLkTi=Gq5thZk2f1nWTz3dDA5Non8ANZg@mail.gmail.com> <20110417101731.GA17986@electric-eye.fr.zoreil.com>
 <BANLkTi=tPc6NmUuTYqbVZduNRNbE=-c34Q@mail.gmail.com> <20110418180813.GA18469@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf3054965b7d849404a135d966
Cc: Ciprian Docan <docan@eden.rutgers.edu>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
	"Rafael, J. Wysocki" <rjw@sisk.pl>, Greg KH <gregkh@suse.de>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59051 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756310Ab1DRStv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 14:49:51 -0400
In-Reply-To: <20110418180813.GA18469@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--20cf3054965b7d849404a135d966
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 18, 2011 at 11:08 AM, Francois Romieu <romieu@fr.zoreil.com> wr=
ote:
> [...]
>> =A0- unload not on close, but on device unregister (iow not when you do
>> "ifconfig eth0 down", but when the "eth0" device really goes away)
>
> Without further action, the firmware(s) will thus be locked in until the
> driver is removed.

I do agree. It's a downside. Maybe doing it in "close()" is the right
thing, as long as we don't have that crazy "every four timer ticks"
situation with rtl8169_reinit_task.

As mentioned, the only real reason for me to be worried about the
close thing is that I don't have a good feel for what happens at boot
time. Are the setup scripts going to look at the interface lots of
times? On my desktop, I couldn't care less, but I try to keep boot
time in mind.

Maybe in practice there's just a single open at boot-time (for dhcp or
whatever), and I'm just worried for no good reason.

Without having looked at that whole rtl8169_reinit_task thing, I
probably wouldn't even worry about anything else doing something
similar ;)

> As long as it can be fixed... If the 60s delay is removed and the firmwar=
e
> loading emits some messages for programmer barbie, I am more than happy.

So the firmware loading timeout used to be ten seconds (which I
already think is excessive), but then commit
2f65168de7d68a5795e945e781d85b313bdc97b9 increased it to 60s because

    https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D174589

    The ipw driver sometimes takes a long time to load its firmware.
    Whilst the ipw driver should be using the async interface of
    the firmware loader to make this a non-issue, this is a minimal fix.

although when I actually look at that bugzilla entry, the _timestamps_
for the failed case do not seem to support this being a timeout.

Very odd.

But the real problem is that we do that timeout even in cases where it
cannot help, ie when people load firmware during early boot or during
suspend. So I think drivers/base/firmware_class.c should be made a bit
smarter.

We have a few cases where call_usermodehelper() fails immediately:

 - khelper_wq hasn't been set up yet
 - usermodehelper_disabled is set.

and in particular, during suspend/resume, that
"usermodehelper_disabled" flag will be set.

I don't think it is sensible to do a user request for firmware during
that time either, and that 60-second timeout is just silly. It's not
going to help.

Why doesn't the firmware loader class check the error return from the
kobject_uevent()? I'd expect that if that fails, we should just warn
and abort, rather than wait 60 seconds to time out. Greg?

TOTALLY UNTESTED PATCH ATTACHED!

Ciprian - does this get rid of the 60-second wait? Do you get a nice
kernel traceback in your dmesg instead?

> If someone can tell me where Realtek's firmware should be sent to as Davi=
d
> W. seems to be busy, it will be perfect.

Hmm. Dunno about that.

                       Linus

--20cf3054965b7d849404a135d966
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gmnrce850

IGRyaXZlcnMvYmFzZS9maXJtd2FyZV9jbGFzcy5jIHwgICAgMyArKy0KIDEgZmlsZXMgY2hhbmdl
ZCwgMiBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMv
YmFzZS9maXJtd2FyZV9jbGFzcy5jIGIvZHJpdmVycy9iYXNlL2Zpcm13YXJlX2NsYXNzLmMKaW5k
ZXggOGM3OThlZjdmMTNmLi45NTZkZDM0ZTU5ZGEgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvYmFzZS9m
aXJtd2FyZV9jbGFzcy5jCisrKyBiL2RyaXZlcnMvYmFzZS9maXJtd2FyZV9jbGFzcy5jCkBAIC01
NDksNyArNTQ5LDggQEAgc3RhdGljIGludCBfcmVxdWVzdF9maXJtd2FyZShjb25zdCBzdHJ1Y3Qg
ZmlybXdhcmUgKipmaXJtd2FyZV9wLAogCQkJCSAgcm91bmRfamlmZmllc191cChqaWZmaWVzICsK
IAkJCQkJCSAgIGxvYWRpbmdfdGltZW91dCAqIEhaKSk7CiAKLQkJa29iamVjdF91ZXZlbnQoJmZ3
X3ByaXYtPmRldi5rb2JqLCBLT0JKX0FERCk7CisJCWlmIChXQVJOX09OKGtvYmplY3RfdWV2ZW50
KCZmd19wcml2LT5kZXYua29iaiwgS09CSl9BREQpKSkKKwkJCWZ3X2xvYWRfYWJvcnQoZndfcHJp
dik7CiAJfQogCiAJd2FpdF9mb3JfY29tcGxldGlvbigmZndfcHJpdi0+Y29tcGxldGlvbik7Cg==
--20cf3054965b7d849404a135d966--
