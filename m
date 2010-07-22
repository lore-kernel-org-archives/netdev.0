From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH nf-next-2.6] netfilter: add xt_cpu match
Date: Thu, 22 Jul 2010 17:39:34 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007221736150.12308@obet.zrqbmnf.qr>
References: <1279807385.2467.67.camel@edumazet-laptop>  <alpine.LSU.2.01.1007221611510.1619@obet.zrqbmnf.qr> <1279811939.2467.79.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:39306 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751989Ab0GVPjf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 11:39:35 -0400
In-Reply-To: <1279811939.2467.79.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 2010-07-22 17:18, Eric Dumazet wrote:

>Le jeudi 22 juillet 2010 =C3=A0 16:19 +0200, Jan Engelhardt a =C3=A9cr=
it :
>> On Thursday 2010-07-22 16:03, Eric Dumazet wrote:
>>=20
>> >This match is a bit strange, being packet content agnostic...
>> >+/*
>> >+ * Yes, packet content is not interesting for us, we only take car=
e
>> >+ * of cpu handling this packet
>> >+ */
>>=20
>> That is not so strange after all, we have many packet agnostic match=
es:=20
>> xt_time, xt_condition, xt_IDLETIMER, xt_iface.
>> So this little comment looks a bit redundant.
>>=20
>> Or it seems that academia can't come up with enough new protocols in=
 time that
>> we have to resort to do -m coffeemaker :)
>>=20
>> >@@ -0,0 +1,8 @@
>> >+#ifndef _XT_CPU_H
>> >+#define _XT_CPU_H
>> >+
>> >+struct xt_cpu_info {
>> >+	unsigned int	cpu;
>> >+	int		invert;
>> >+};
>> >+#endif /*_XT_MAC_H*/
>>=20
>> Please take a read in "Writing Netfilter Modules" e-book :-)
>> It will tell you that types other than fixed ones are a no-no.
>
>Ok, let's do that, but I doubt sizeof(int) can be different than 4 on =
a
>Linux 2.6 host right now.

Never say never. "long" already bit people in the past, and now we
have that CONFIG_COMPAT stuff.

If invert is the only flag, perhaps it makes sense to use __u8=20
for it.=20

>I prefer not doing the !!info->invert, and do the check only once.

>+static int cpu_mt_check(const struct xt_mtchk_param *par)
>+{
>+	const struct xt_cpu_info *info =3D par->matchinfo;
>+
>+	if (info->invert & ~1)
>+		return -EINVAL;
>+	return 0;
>+}
>+
>+static bool cpu_mt(const struct sk_buff *skb, struct xt_action_param =
*par)
>+{
>+	const struct xt_cpu_info *info =3D par->matchinfo;
>+
>+	return (info->cpu =3D=3D smp_processor_id()) ^ info->invert;
>+}

That works nicely indeed. Do you anticipate any future flags?

