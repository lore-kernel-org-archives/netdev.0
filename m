From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: [PATCH 0/5] net: sysctl: share ipv4/ipv6 sysctl tables
Date: Fri, 4 Feb 2011 17:59:24 +0200
Message-ID: <AANLkTik=a3NmibvYM6NxvqCiSiaE0oUFNtRaqn4+g_+D@mail.gmail.com>
References: <cover.1296793770.git.lucian.grijincu@gmail.com> <AANLkTi=3kKhWRzM7S_f18YJ=jx1P7bN9zVo9yGC7zwN_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Octavian Purdila <opurdila@ixiacom.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=3kKhWRzM7S_f18YJ=jx1P7bN9zVo9yGC7zwN_@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 4, 2011 at 12:49 PM, Alexey Dobriyan <adobriyan@gmail.com> =
wrote:
>> Finally share the leaf sysctl tables for ipv4/ipv6:
>>
>> =C2=A0[PATCH 4/5] ipv4: share sysctl net/ipv4/conf/DEVNAME/ tables
>> =C2=A0[PATCH 5/5] ipv6: share sysctl net/ipv6/conf/DEVNAME/ tables
>
> Meh.
>
> First you remove ->parent, then heroically pass "struct file *"
> to sysctl handlers which duplicates all information already passed
> and brings dcache into picture.
>
> Binary sysctl rewrite confused you into thinking that d_name.name
> is the way, but it isn't.
> For binary sysctl(2) you wouldn't get d_name.name.


Are you really sure?

I ran this code on a machine with and without these patches. It seems
to work fine.

It reads the value from /proc/sys/net/ipv4/conf/default/tag and writes =
42 back.

I'm not sure what I have to do to pass the name of a device (e.g.
"eth0") instead of "default" but at least "default" and "all" work and
have valid dentries.


#define _GNU_SOURCE
#include <unistd.h>
#include <sys/syscall.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <linux/sysctl.h>


int main(void)
{
	struct __sysctl_args args;
	int oldtag, newtag;
	size_t oldtaglen, newtaglen;

	int name[] =3D { CTL_NET, NET_IPV4, NET_IPV4_CONF,
NET_PROTO_CONF_DEFAULT, NET_IPV4_CONF_TAG };

	memset(&args, 0, sizeof(struct __sysctl_args));
	args.name =3D name;
	args.nlen =3D sizeof(name)/sizeof(name[0]);

	oldtag =3D -1;
	oldtaglen =3D sizeof(oldtag);
	args.oldval =3D &oldtag;
	args.oldlenp =3D &oldtaglen;

	newtag =3D 42;
	newtaglen =3D sizeof(newtag);
	args.newval =3D &newtag;
	args.newlen =3D newtaglen;

	if (syscall(SYS__sysctl, &args) =3D=3D -1) {
		perror("_sysctl");
		exit(EXIT_FAILURE);
	}
	printf("Old tag was %d, new tag is %d\n", oldtag, newtag);
	exit(EXIT_SUCCESS);
}


--=20
=C2=A0.
=2E.: Lucian
