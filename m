From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: sysfs^H^H^H^H^Hsysctl warnings, reserved names
Date: Fri, 17 Feb 2012 04:07:02 -0800
Message-ID: <m1k43lhdeh.fsf_-_@fess.ebiederm.org>
References: <41230e67c273dde6b60cfc7110f496e2@visp.net.lb>
	<1329475042.2861.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1329476631.2861.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53050 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009Ab2BQMEG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 07:04:06 -0500
In-Reply-To: <1329476631.2861.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	(Eric Dumazet's message of "Fri, 17 Feb 2012 12:03:51 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Le vendredi 17 f=C3=A9vrier 2012 =C3=A0 11:37 +0100, Eric Dumazet a =C3=
=A9crit :
>> Le vendredi 17 f=C3=A9vrier 2012 =C3=A0 12:14 +0200, Denys Fedoryshc=
henko a
>> =C3=A9crit :
>> > Hi
>> >=20
>> > Just did a test:
>> >=20
>> > ip link set dev eth1 name default
>> >=20
>> > And got a lot of (expected) sysfs warnings:
>> > [1068625.677143] sysctl table check failed:=20
>> > /net/ipv4/conf/default/promote_secondaries  Sysctl already exists
>> > [1068625.677151] Pid: 18106, comm: ip Not tainted 3.2.4-centaur #1
>> > and etc
>> >=20
>> > Kernel 3.2.4, but i guess it doesn't matter much.
>> > Maybe such names (as all and default) should be "reserved"?
>> > Or it is ok like that?
>> >=20
>>=20
>> You're right, we should forbid this to happen.
>>=20
>>=20
>
> Following is a quick hack, I CC Eric because its probaly better to
> address this in sysfs.

Well we are talking about sysctl not sysfs but same difference, I keep
an on eye on them.

I expect renaming a network device to "all" or "default" would be a
problem in any kernel supporting renaming of networking devices.

At the basic level of handling it.  sysctl checks for this sometimes
now and as soon as my sysctl tree is merged the checks will become
unconditionally present.  In what sense were you thinking it would
be better to address this in the sysctl?

My feel on the situation is that since this is how the network stack
has choosen to use /proc/sys the names "all" and "default" should just
be outlawed unconditionally.

The CONFIG_INET check seems wrong, and CONFIG_SYSCTL seems unnecessary.
I think we should just reserve those names.

As for the rest the sysctl registration that happens during the rename
is failing so if you want to wire up catching that failure in the
networking code we can handle it that way but that seems like a lot
of work for very little benefit.  We don't test those failure paths
so if we put in the work to handle the error the code will probably
just bitrot and do something strange by the next time someone tries
to use "default" or "all" as device names.

By contrast outlawing the names as you do in dev_valid_name below is
absolutely trivial, and much less likely to bitrot.

Eric

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 763a0ed..ec68f89 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -856,7 +856,11 @@ int dev_valid_name(const char *name)
>  		return 0;
>  	if (!strcmp(name, ".") || !strcmp(name, ".."))
>  		return 0;
> -
> +#if defined(CONFIG_SYSCTL) && defined(CONFIG_INET)
> +	/* /proc/sys/net/ipv{4|6}/conf/{default|all} are reserved */
> +	if (!strcmp(name, "default") || !strcmp(name, "all"))
> +		return 0;
> +#endif
>  	while (*name) {
>  		if (*name =3D=3D '/' || isspace(*name))
>  			return 0;
>
>
