From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] Unprivileged: Disable acquisition of privileges
Date: Wed, 30 Dec 2009 04:47:02 -0800
Message-ID: <m1k4w4633t.fsf@fess.ebiederm.org>
References: <20091229050114.GC14362@heat>
	<3e8340490912290805s103fb789y13acea4a84669b20@mail.gmail.com>
	<m3oclhzgm4.fsf@ursa.amorsen.dk> <m17hs5y0mg.fsf@fess.ebiederm.org>
	<20091229211139.0732a0c1@lxorguk.ukuu.org.uk>
	<m1iqbpwjtp.fsf@fess.ebiederm.org> <20091229223631.GB22578@us.ibm.com>
	<m1aax1uoa3.fsf_-_@fess.ebiederm.org>
	<3e8340490912291954v5a837a26p64bd776102d281d7@mail.gmail.com>
	<m1r5qdt721.fsf@fess.ebiederm.org>
	<3e8340490912292057g3e87eaabn115f85b78af2b08c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Pavel Machek <pavel@ucw.cz>,
To: Bryan Donlan <bdonlan@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752383AbZL3Mrc@vger.kernel.org>
In-Reply-To: <3e8340490912292057g3e87eaabn115f85b78af2b08c@mail.gmail.com> (Bryan Donlan's message of "Tue\, 29 Dec 2009 23\:57\:50 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bryan Donlan <bdonlan@gmail.com> writes:

> On Tue, Dec 29, 2009 at 11:33 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> Bryan Donlan <bdonlan@gmail.com> writes:
>>
>>> Is this sufficient for other security models such as selinux or
>>> TOMOYO? Can processes in these models gain privileges through means
>>> not restricted here?
>>
>> The LSM is primarily about returning -EPERM more often.
>> Except for the prctl and the capability hooks I am not aware
>> of anywhere a LSM can increase a processes capabilities.
>
> I'm more concerned about a case where a privilege that the LSM
> currently denies is lifted by execing some executable - this is still
> an increase in privilege, even though the LSM only adds additional
> restrictions. That is:
>
> 1) Initial state: LSM denies access to /somefile (although normal
> POSIX permissions would permit access)
> 2) Disable capability-gaining
> 3) Disable network access with proposed API
> 4) Exec some application, which is labeled in a way that permits
> access to /somefile
> 5) Application fails to access the network, then does something to /somefile
>
> I'm not entirely sure if step 4) can happen in any of the currently
> existing LSMs - if it's not possible to gain privileges in them via a
> suid-like mechanism, this isn't a problem, but it's something that
> needs to be checked for.

A reasonable concern.  When the glitches get worked out of this patch
I intend to allow much more dangerous things like unprivileged unsharing
of all of the namespaces, and unprivileged mounts.

It appears I missed a place where MNT_NOSUID was handled in selinux.
So I will be adding a bprm->nosuid field so I don't have to duplicate
the MNT_NOSUID check everywhere it is used.

I don't understand TOMOYO  I think it is file based access control,
which suggests there is not a suid like mechanism.

Smack and selinux are label based.  Selinux at least can switch labels
on exec, but it handles NOSUID already.

Looking a little farther if I assume that lsm implementations that
implement the set_creds hook need attention.  Only selinux has
an interesting set_creds implementation and it handles nosuid already.

So I think we are ok.

Eric
