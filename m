From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH] network: return errors if we know tcp_connect failed
Date: Fri, 12 Nov 2010 17:54:29 +0100
Message-ID: <4CDD7145.8070606@trash.net>
References: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com> <00c201cb81eb$84e18160$8ea48420$@com> <1289578108.3083.95.camel@localhost.localdomain> <1289578532.3185.265.camel@edumazet-laptop> <20101112163543.GB122902@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Paris <eparis@redhat.com>, Hua Zhong <hzhong@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, paul.moore@hp.com
To: David Lamparter <equinox@diac24.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101112163543.GB122902@jupiter.n2.diac24.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 12.11.2010 17:35, schrieb David Lamparter:
> On Fri, Nov 12, 2010 at 05:15:32PM +0100, Eric Dumazet wrote:
>> Le vendredi 12 novembre 2010 =C3=A0 11:08 -0500, Eric Paris a =C3=A9=
crit :
>>
>>> 2) What should the generic TCP code (tcp_connect()) do if the skb f=
ailed
>>> to send.  Should it return error codes back up the stack somehow or
>>> should they continue to be ignored?  Obviously continuing to just i=
gnore
>>> information we have doesn't make me happy (otherwise I wouldn't hav=
e
>>> started scratching this itch).  But the point about ENOBUFS is well
>>> taken.  Maybe I should make tcp_connect(), or the caller to
>>> tcp_connect() more intelligent about specific error codes?
>>>
>>> I'm looking for a path forward.  If SELinux is rejecting the SYN pa=
ckets
>>> on connect() I want to pass that info to userspace rather than just
>>> hanging.  What's the best way to accomplish that?
>>>
>>
>> Eric, if you can differentiate a permanent reject, instead of a
>> temporary one (congestion, or rate limiting, or ENOBUF, or ...), the=
n
>> yes, you could make tcp_connect() report to user the permanent error=
,
>> and ignore the temporary one.

Indeed. We could even make the NF_DROP return value configurable
by encoding it in the verdict.

> If the netfilter targets DROP/REJECT match the NF_DROP/NF_REJECT
> counterparts, which i guess they do but i didn't read the source ;),
> then SELinux should use NF_REJECT in my opinion.

There is no NF_REJECT.

> NF_DROP does exactly what the name says, it drops the packet aka
> basically puts it in /dev/null. As with writing to /dev/null, you don=
't
> get an error for that. Even more, if in the meantime the DROP rule do=
es
> not match anymore, the 2nd or 3rd SYN from the connect() can come
> through and establish a connection (think of "-m statistic" & co.)
>=20
> This is very different from REJECT.

Returning NF_DROP results in -EPERM getting reported back. As Eric
noticed, this is ignored for SYN packets.

> If REJECT doesn't immediately get reported to the application, that *=
is*
> a bug, but last time i checked i got EPERM immediately. I would fix
> SELinux to use the same mechanism.

NF_DROP returns -EPERM, the REJECT targets send packets to reject
a connection. Whether this is reported immediately depends on the
error and the protocol in question. Using a TCP reset immediately
resets the connection.
