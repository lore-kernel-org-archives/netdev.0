From: "Andrew G. Morgan" <morgan@kernel.org>
Subject: Re: [RFC][PATCH v3] Unprivileged: Disable raising of privileges
Date: Thu, 31 Dec 2009 10:20:18 -0800
Message-ID: <551280e50912311020x2bdc5b1o699a601f67b91662@mail.gmail.com>
References: <551280e50912300652r1007dee0j8de750bf33af9b3c@mail.gmail.com>
	 <m1fx6suswz.fsf@fess.ebiederm.org> <20091230201712.GA23999@us.ibm.com>
	 <m1hbr8tb8q.fsf_-_@fess.ebiederm.org>
	 <20091230212931.233003b9@lxorguk.ukuu.org.uk>
	 <m1skasrvnq.fsf@fess.ebiederm.org>
	 <20091230230042.5d2e78ac@lxorguk.ukuu.org.uk>
	 <3e8340490912301844p4fddaf57ke58ceeba9582e0fa@mail.gmail.com>
	 <20091231173334.5e3d7557@lxorguk.ukuu.org.uk>
	 <20091231175257.GA7210@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Bryan Donlan <bdonlan@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
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
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufl
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091231175257.GA7210@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Why not implement this as another securebit? So far as I can see the
whole thing can be implemented in the capability LSM.

What is less clear to me is whether per-process 'disabling of setuid
bits on files' should force mandatory disabling of file capabilities.
It seems as if disabling the transition of one luser to another luser
through a setuid executable is something distinct from privilege
escalation.

Since there is already independent support for disabling file
capabilities (the privilege escalation part), I see these two
mechanisms as separable.

Cheers

Andrew

On Thu, Dec 31, 2009 at 9:52 AM, Serge E. Hallyn <serue@us.ibm.com> wro=
te:
> Quoting Alan Cox (alan@lxorguk.ukuu.org.uk):
>> > I see this as being a security-model agnostic API - the reason bei=
ng,
>>
>> Thats what everyone else says about their security model too
>
> LOL
>
>> > the application is specifying a policy for itself that has meaning=
 in
>> > all existing security models, and which does not require administr=
ator
>> > intervention to configure. Rather than reimplementing this for eac=
h
>> > security model, it's far better to do it just once. Moreover, by
>> > having a single, common API, the application can state the general
>> > policy "I will never need to gain priviliges over exec" without
>> > needing to know what LSM is in use.
>>
>> So it can sit in the security hooks and stack.
>>
>> > The future goal of this API is to allow us to relax restrictions o=
n
>> > creating new namespaces, chrooting, and otherwise altering the tas=
k's
>> > environment in ways that may confuse privileged applications. Sinc=
e
>>
>> All of which are security policy, general purpose and frequently par=
t of
>> the main LSM module loaded - in other words it's nothing of the sort=
 when
>> it comes to being separate. Its just another magic interface hook, a=
nd as
>> I think the history of capability stuff in kernel shows it doesn't w=
ork
>> that way.
>>
>> > security hooks are all about making the existing security restrict=
ions
>> > _stricter_, it's not easy to later relax these using the security =
hook
>> > model. And once we put in the general requirement that "this task
>> > shall never gain privilege", it should be safe to relax these
>> > restrictions for _all_ security models.
>>
>> In which case the hooks can be tweaked. It's an interface it can be
>> tuned =A0- and has been - eg for Tomoyo.
>>
>> > In short, this is something which is meaningful for all existing L=
SMs
>>
>> But is it - and if its combined with 500 other similar hooks and a s=
et of
>> system policies can you even work out the result ?
>>
>> > restrictions later, it doesn't make sense to put it in a LSM as th=
ey
>> > stand now.
>>
>> And it certainly doesn't make sense to add this and the several hund=
red
>> other variants of this "can't open sockets, can't mount, can't this,
>> can't that ...." stuff continually being suggested by randomly exten=
ding
>> other unrelated interfaces.
>>
>> Look up the sendmail security archive and you'll even find examples =
where
>> enforcing extra security on setuid *caused* security problems to sho=
w up
>> that were basically impossible to hit otherwise.
>
> That's exactly what we're trying to avoid :) =A0But I'm personally no=
t
> against making this an LSM. =A0As you say:
>
>> We have a security system, with a set of interfaces for attaching
>> security models, please stop trying to go round the back of the kern=
el
>> design because you can't be bothered to do the required work to do t=
he
>> job right and would rather add more unmaintainable crap all over the
>> place.
>>
>> Yes it might mean the hooks need tweaking, yes it probably means the
>
> Yes, and in particular, we'll need to do something about data
> ->security annotations, since, if we make this an LSM, then we can't
> use a per-thread flag.
>
> This feature is used during exec and ptrace, not on hot-paths, so
> dereferencing task->security would be fine. =A0But finding a way to
> multiplex task->security so it can be used by Eric's nosuid lsm,
> Michael's disablenetwork LSM, and SELinux/smack/apparmor, that
> will likely take months, and, history shows, may never happen.
>
>> people who want these need to do some trivial stacking work, but if =
as
>> many people are actually really interested as are having random 'let=
s add
>> a button to disable reading serial ports on wednesday' ideas there s=
hould
>> be no shortage of people to do the job right.
>
> Eric, the thing is, once an API goes upstream, we can't change it,
> but in contrast we can change how task->security is used at any time.
> So I'd suggest just adding
>
> #ifdef CONFIG_SECURITY_NOSUID
> =A0 =A0 =A0 =A0short nosuid;
> #endif
>
> or something like it next to the
>
> #ifdef CONFIG_SECURITY
> =A0 =A0 =A0 =A0void *security;
> #endif
>
> in struct cred and doing that for a first go. =A0You could
> share that field with Michael's disablenetwork, or not if you
> prefer - either way, it keeps you and SELinux out of each other's
> ways.
>
> -serge
>
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
