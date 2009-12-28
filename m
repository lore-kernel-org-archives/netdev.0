From: Bryan Donlan <bdonlan@gmail.com>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Mon, 28 Dec 2009 16:33:52 -0500
Message-ID: <3e8340490912281333l1459f769yf621a36ad1ed6482@mail.gmail.com>
References: <20091227190802.GH11737@elf.ucw.cz> <20091228060759.GB13266@heat>
	<20091228101006.GA19984@elf.ucw.cz> <8817.1262011044@localhost>
	<20091228205511.GD1637@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis.Kletnieks@vt.edu, Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"Am?rico Wang" <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091228205511.GD1637@ucw.cz>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 28, 2009 at 3:55 PM, Pavel Machek <pavel@ucw.cz> wrote:
> On Mon 2009-12-28 09:37:24, Valdis.Kletnieks@vt.edu wrote:
>> On Mon, 28 Dec 2009 11:10:06 +0100, Pavel Machek said:
>>
>> > a) make disablenetwork reset to "enablenetwork" during setuid exec
>>
>> That won't work either. =A0If you only make it 'setuid=3D=3D0' binar=
ies, you still
>> break 'setuid-FOO' binaries that require the net. If you just check =
the setuid
>> bit, it allows a trivial escape by creating a setuid-yourself binary=
 and using
>> that to exec something else (now with network access, because we app=
arently
>> don't have a way to remember the previous setting).
>
>
> it is really only required for binaries setuid to someone else, but
> that would be too ugly. (Plus, as someone said, ping is great for
> leaking data out.)

No, this is not sufficient; one needs only to find a setuid process
that can be convinced to run a program with the original (pre-suid)
privileges. For example, one could invoke gpg (older versions setuid
so it can lock memory, executes user code for the passphrase input
agent) or pulseaudio (in some cases setuid to go realtime, loads user
plugins) or screen (setuid for sharing sessions, obviously executes
user programs) or at/cron (did you remember to deny access to these?)
=2E..

Or one can target a non-root setuid program that may have security
holes - how about nethack?

While in modern distros these uses of setuid may be rare, they can
exist, and under the old security model they were safe. Not so
anymore. As such, re-enabling network access upon executing a setuid
program is not acceptable.

That said, I do feel this is a separate issue. The process should
first drop its ability to suid; then it can freely apply additional
restrictions without there being any risk of breaking setuid
applications.

In short, how does this sound:
* Add an API to allow processes to permanently revoke their own
ability to gain privileges from setuid-exec
* Add this disablenetwork facility, conditional on dropping
setuid-exec abilities

This also paves the way for:
* Allow processes that have dropped said suid ability to freely create
new namespaces (and chroot)

Which, combined with doing whatever audits are necessary to allow
cross-network-namespace uses of unix domain sockets, actually
eliminates the need for the disablenetwork API. :)
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
