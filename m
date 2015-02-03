From: Ignacy Gawedzki <ignacy.gawedzki@green-communications.fr>
Subject: RFC: Fix "tc filter show" for basic filters
Date: Tue, 3 Feb 2015 15:11:00 +0100
Message-ID: <20150203141059.GA25454@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:53376 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755826AbbBCOLs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 09:11:48 -0500
Received: from zenon.in.qult.net ([192.168.64.1] helo=zenon)
	by mail.qult.net with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YIeCL-0001XJ-DS
	for netdev@vger.kernel.org; Tue, 03 Feb 2015 15:11:25 +0100
Received: from ig by zenon with local (Exim 4.84_RC1)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YIeBw-0006p0-48
	for netdev@vger.kernel.org; Tue, 03 Feb 2015 15:11:00 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

I have a problem with tc filter and very simple "basic" filters with no
associated action.

The thing is I have an HTB qdisc with handle 1: with a single class 1:1
attached to it.  When I add a basic filter that does nothing,

  tc filter add dev eth0 prio 1 handle 1 parent 1: basic classid 1:1

it doesn't completely appear when I type

  tc filter show dev eth0

When debugging basic_dump() in net/sched/cls_basic.c, I noticed that
tcf_exts_dump_stats() returns -1, which triggers a jump to nla_put_fail=
ure
which ends up removing all the added attributes so far.  When looking a=
t
tcf_action_copy_stats() in net/sched/act_api.c, which is ultimately cal=
led by
tcf_exts_dump_stats(), I see that the returned error is triggered by a-=
>priv
being NULL.

Although I confess I didn't make the effort of understanding all the wo=
rkings
of a->priv in this context, it seems to me that if that is NULL, this i=
s
probably not a good reason to return an error.  I made the change below=
 and so
far it works for me.

Can anyone take a critical look at this?

Thanks.

Ignacy

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 3d43e49..6dd46be 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -602,7 +602,7 @@ int tcf_action_copy_stats(struct sk_buff *skb, stru=
ct
tc_action *a,
        struct tcf_common *p =3D a->priv;
=20
        if (p =3D=3D NULL)
-               goto errout;
+               return 0;
=20
        /* compat_mode being true specifies a call that is supposed
         * to add additional backward compatibility statistic TLVs.

--=20
Ignacy Gaw=EAdzki
R&D Engineer
Green Communications
