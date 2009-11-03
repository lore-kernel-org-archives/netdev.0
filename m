From: Eric Paris <eparis@redhat.com>
Subject: CLONE_NEWNET requires CAP_NET_RAW (and the intended CAP_SYS_ADMIN)
Date: Tue, 03 Nov 2009 15:15:52 -0500
Message-ID: <1257279352.2891.202.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, acme@redhat.com, dwalsh@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27770 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753896AbZKCUPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2009 15:15:49 -0500
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nA3KFsLr027437
	for <netdev@vger.kernel.org>; Tue, 3 Nov 2009 15:15:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We just saw today, because vsftpd just started using by default, that
CLONE_NEWNET requires both the intended CAP_SYS_ADMIN (see
kernel/nsproxy.c::copy_namespace()) and the unintended CAP_NET_RAW.
This is because tcp_sk_init() calls inet_ctl_sock_create() with
SOCK_RAW.  Ultimately we end up in inet_create() which see that
answer->capability is equal to CAP_NET_RAW.  So now it checks
capable(CAP_NET_RAW).

What you will find is that the generic __sock_create() has an argument
"int kern" which is passed to the security server to bypass checks which
were caused by the kernel, not because of userspace.  That flag is not
passed down to the create() function in struct net_proto_family.  I
think the easiest solution is to add the kern argument to the
net_proto_family create function and pass it along to the security
system so it can make the right decision.

I also see that the whole capability checking in struct inet_protosw
(and can, dccp, and sctp) seem overly complicated.  Most of it (all but
inet) could just be deleted since they aren't doing anything.  Inet
could replace it with just a single if (SOCK_RAW) which make the
security server changes very simple....

Did I explain my problem (I don't want to check CAP_NET_RAW)?  Do people
see an issue with me passing kern down to create?  Anyone have problems
with me ripping out the half ass unused security infrastructure?

-Eric

