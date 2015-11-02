From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Resource leak in unshare
Date: Mon, 02 Nov 2015 13:01:41 -0600
Message-ID: <87oafcrzsa.fsf@x220.int.ebiederm.org>
References: <CACT4Y+Y5mcBrnLOsXchJVrO_8FD-u=EFU67WsH3bU51aAU-idA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, nicolas.dichtel@6wind.com,
	Al Viro <viro@zeniv.linux.org.uk>, Thomas Graf <tgraf@suug.ch>,
	xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, Patrick McHardy <kaber@trash.net>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@google.com>,
	Julien Tinnes <jln@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42508 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025AbbKBTLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 14:11:37 -0500
In-Reply-To: <CACT4Y+Y5mcBrnLOsXchJVrO_8FD-u=EFU67WsH3bU51aAU-idA@mail.gmail.com>
	(Dmitry Vyukov's message of "Mon, 2 Nov 2015 12:05:09 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Vyukov <dvyukov@google.com> writes:

> Hello,
>
> I am hitting the following warnings on
> bcee19f424a0d8c26ecf2607b73c690802658b29 (4.3):

Do you have any trace of the earlier failures?

This appears to be something caused by an earlier failure (possibly
whatever fails to allocate memory).  Having network devices present
but being in the generic cleanup routines is wrong.

If there is no additional information can you please rerun with the
following change applied?  That should at least report which function is
failing, and give us a good clue where to start debugging this.

Eric
----

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 2c2eb1b629b1..125c94af22b8 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -292,6 +292,7 @@ out:
        return error;
 
 out_undo:
+       WARN(1, "net ops->init %pF returned with %d\n", ops->init, error);
        /* Walk through the list backwards calling the exit functions
         * for the pernet modules whose init functions did not fail.
         */
