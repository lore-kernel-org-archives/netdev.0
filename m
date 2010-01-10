From: Kyle Moffett <kyle@moffetthome.net>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Sun, 10 Jan 2010 17:18:49 -0500
Message-ID: <f73f7ab81001101418x3b3f8652j256f6311ad6244c5@mail.gmail.com>
References: <alpine.LRH.2.00.1001110811350.25601@tundra.namei.org>
	<20100110215409.GA3705@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James Morris <jmorris@namei.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Pavel Machek <pavel@ucw.cz>,
	A
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20100110215409.GA3705@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 10, 2010 at 16:54, Michael Stone <michael@laptop.org> wrote=
:
> On Fri, 1 Jan 2010, Pavel Machek wrote:
>> > > For the record: NAK, as it introduces security holes.
>>
>> Please elaborate.
>
> Pavel's position is that disablenetwork is likely to permit some atta=
cker
> somewhere to deny network access to some setuid app some day in a way=
 that
> violates some security policy.
>
> He has mentioned specific concern over scenarios like:
>
> =C2=A0Alice configures PAM auth to 'fail open' by checking login cred=
entials
> =C2=A0against a restrictive LDAP server and, if the server is unavail=
able,
> against
> =C2=A0a very permissive files database.
>
> =C2=A0Alice updates her kernel to a version with disablenetwork.
>
> =C2=A0Mallory calls disablenetwork, calls su -, and vanquishes all.

No, there is a *MUCH* bigger security issue here.  There are existing
PAM modules which lazily fork background processes to handle
authentication, authorization, logging, etc.  Now assume that one of
those PAM modules is hooked from /etc/pam.d/su.

(1) Mallory runs "disablenetwork su -"
(2) The PAM module lazily starts its background daemon with a
10-minute idle timeout.
(3) The daemon has network disabled, and so it is completely nonfunctio=
nal.
(4) The daemon automatically denies all logins because it cannot
communicate with the login server
(5) Alice tries to run "su -" from her regular terminal.
(6) Alice's "su" process communicates with the running daemon and
fails because "the network is down".

All of that software is perfectly reasonably designed... the daemon is
even fail-secure in the event that the network really is inaccessible.
 Unfortunately it lets Mallory easily DoS every superuser login on the
system without generating a single audit log.  The only process that
knows what he did is the one that cannot communicate with the remote
audit daemon.

Moreover, that DoS would continue until the 10-minute idle timeout
actually expired.  As Alice keeps trying to log in, it will keep
automatically extending the daemon's lifetime.

Now, you can try to claim "Nobody has it configured like that" or
"None of the standard Linux PAM modules do that"... but that does not
resolve the problem.  A sysadmin and part-time programmer (not knowing
about a little-documented "disablenetwork" feature) could very easily
write software like that and assume that it is secure.

The #1 rule for setuid binaries is that you DO NOT INHERIT ANYTHING.
Any kernel feature or setuid program which violates that rule is just
going to cause big security holes.  Security models must be either
obviously correct or mathematically provable (or both)... and this is
neither.

Cheers,
Kyle Moffett
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
