From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: [IPSEC] Too many SADs!
Date: Wed, 23 Mar 2005 19:15:40 +0100
Message-ID: <200503231915.40882.wolfgang.walter@studentenwerk.mhn.de>
References: <200503220052.52756.wolfgang.walter@studentenwerk.mhn.de> <1111571845.3833.25.camel@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
To: KOVACS Krisztian <hidden@balabit.hu>
In-Reply-To: <1111571845.3833.25.camel@nienna.balabit>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Am Mittwoch, 23. M=E4rz 2005 10:57 schrieben Sie:
>   Hi,
>
> 2005-03-22, k keltez=E9ssel 00.52-kor Wolfgang Walter ezt =EDrta:
> > We had the same problem. Seems to be a limitation of the
> > pfkey-implementation of linux.
>
>   This is not really a limitation of the PFKEY implementation, at least
> not a limitation related to some upper limit of the number of entries
> (no such limit exists). The problem itself is caused by the too
> simplistic SAD/SPD dumping code in the implementation, which does not
> care about possibly lost messages. The problem is as follows: when
> setkey requests a dump, the kernel responds with a stream of messages.
> Each of these contains the dump of an SAD/SPD entry, and contains a
> decreasing sequence number. The sequence number of the last message is
> zero, this way the receiving user-space application can tell that the
> dump is over.
>
>   The problem occurs when there's not enough space in the socket buffer
> of the PFKEY socket. In this case the kernel simply drops all messages
> after the buffer becomes full, thus losing the precious end-of-dump
> marker last message as well. Racoon's setkey obviously cannot cope with
> this and is still waiting for the missing messages.
>
>   The problem itself comes from the unreliable nature of PFKEY, so it's
> not something which can be solved, but there are more ways to work it
> around.
>
>   AFAIK early Solaris PFKEY implementations made sure the first and las=
t
> message in the dump is delivered. This way the user-space application
> has the possibility to detect problems and do something about them.
> Another solution is to make dumping an all-or-nothing operation, even a=
t
> the cost of the socket buffer growing past its upper limit (this is in
> current NetBSD versions, for example). More information about the
> problem and its NetBSD workaround can be found here:
>

Thanks for the explanation.

>   http://mail-index.netbsd.org/tech-net/2004/05/21/0006.html
>
>   As a quick and dirty hack to see if you have the same problem, try
> increasing the net.core.rmem_default sysctl value. If you set that to a
> larger value than the memory needed for the complete dump you should
> have no problems. Of course I wouldn't recommend this as a long-term
> "solution".

We tried that. Detected a hard limit you mention later.

I think one should not need to manipulate net.core.rmem_default. It would=
 be=20
better if racoon tried to set the buffer size high enough or had at least=
 a=20
option to set the size.

>
>   Oh, wait, this is where a limitation of ipsec-tools comes into the
> picture. For some unknown reason, libipsec (PFKEY interface used by bot=
h
> setkey and racoon) sets the socket buffer size to 128K for _all_ PFKEY
> sockets. So even if you set a much higher default value through sysctl,
> setkey dumbly sets the limit to 128K. IMHO this is a bug in ipsec-tools=
,
> it should not impose such limitations. I've attached a quick-and-dirty
> patch which removes those ugly setsockopts.
>

Though this may solve the problem with dump I still think racoon together=
 with=20
pfkey will not handle large spd-sets reliable.

We did the following test: start racoon with an empty set and then add=20
spd-rules with setkey. Even with a relativ slow rate (say 1 rule/s) the=20
kernel seems to drop pfkey-messages once and again and racoon will therfo=
r=20
not see these policies. I think that the kernel dropped these messages si=
mply=20
because it fails to allocate memory for the message.

Probably this will happen for other pfkey-messages from kernel to userspa=
ce,=20
too.

> > We switched to iproute2 and openswan which both use the
> > netfilter-interface. Therefor they can handle thousands of SAD and SP=
D
> > rules.
>
>   Seems to justify the PFKEY problems I've summarized above.

Probably, for the dump-case especially.

But I think that the way racoon works makes it more difficult to ensure t=
hat=20
kernel and racoon are synchronous.

The relationship between pluto and kernel is simple: pluto is the master =
of=20
its rules: if you want to change policy-rules created by pluto you must n=
ot=20
change them via the kernel but change them via pluto which then updates t=
hem=20
in the kernel. On the other side pluto only manipulates its own rules.

With racoon you manipulate the ruleset in the kernel and racoon updates i=
ts=20
own database from it. If a pfkey-message is lost racoon would have to kno=
w=20
that so it can dump the spd (res. sad for messages concerning the sad).

I personally think that it would be better if racoon would not read the s=
pd=20
but instead create the spd-rules itself from its racoon.conf because your=
=20
racoon.conf must fit your spd anyway (and sometimes racoon already needs =
to=20
create spd-rules itself (for the road-warrior-case i.e.)).


Greetings,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
EDV
Leopoldstra=DFe 15
80802 M=FCnchen
