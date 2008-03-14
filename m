From: Pavel Emelyanov <xemul@openvz.org>
Subject: Audit vs netlink interaction problem
Date: Fri, 14 Mar 2008 19:22:56 +0300
Message-ID: <47DAA660.90401@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Woodhouse <dwmw2@infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:59805 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751181AbYCNQXE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2008 12:23:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David!

I've found an interesting feature of how audit uses netlink for
communications. Look.

The kauditd_thread() calls netlink_unicast() and passes the 
audit_pid to it. The audit_pid, in turn, is received from the 
user space and the tool (I've checked the audit v1.6.9) uses 
getpid() to pass one in the kernel. Besides, this tool doesn't
bind the netlink socket to this id, but simply creates it 
allowing the kernel to auto-bind one.

That's the preamble.

The problem is that netlink_autobind() _does_not_ guarantees
that the socket will be auto-binded to the current pid. Instead
it uses the current pid as a hint to start looking for a free
id. So, in case of conflict, the audit messages can be sent
to a wrong socket. This can happen (it's unlikely, but can be)
in case some task opens more than one netlink sockets and then
the audit one starts - in this case the audit's pid can be busy
and its socket will be bound to another id.

The reason I raised this problem is that I'm now working on pid 
and network namespaces and found, that this problem doesn't
allow to resolve the following issue gracefully.

The task_struct->tgid field, which is currently used in netlink
for auto-binding, is going to be deprecated. Thus I have to make 
netlink auto-binding play another rules when selecting a pid, 
but this will break the audit work for sure, since it implicitly 
relies, that the netlink socket will be bound to the current 
task pid.

What do you think about it?

Thanks,
Pavel
