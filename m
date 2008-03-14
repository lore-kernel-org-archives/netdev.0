From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Audit vs netlink interaction problem
Date: Fri, 14 Mar 2008 17:39:29 +0100
Message-ID: <20080314163929.GP20815@postel.suug.ch>
References: <47DAA660.90401@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:51207 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753502AbYCNQjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2008 12:39:08 -0400
Content-Disposition: inline
In-Reply-To: <47DAA660.90401@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Pavel Emelyanov <xemul@openvz.org> 2008-03-14 19:22
> I've found an interesting feature of how audit uses netlink for
> communications. Look.
> 
> The kauditd_thread() calls netlink_unicast() and passes the 
> audit_pid to it. The audit_pid, in turn, is received from the 
> user space and the tool (I've checked the audit v1.6.9) uses 
> getpid() to pass one in the kernel. Besides, this tool doesn't
> bind the netlink socket to this id, but simply creates it 
> allowing the kernel to auto-bind one.
> 
> That's the preamble.
> 
> The problem is that netlink_autobind() _does_not_ guarantees
> that the socket will be auto-binded to the current pid. Instead
> it uses the current pid as a hint to start looking for a free
> id. So, in case of conflict, the audit messages can be sent
> to a wrong socket. This can happen (it's unlikely, but can be)
> in case some task opens more than one netlink sockets and then
> the audit one starts - in this case the audit's pid can be busy
> and its socket will be bound to another id.

The audit userspace tool should be fixed, no question. It can continue
to auto bind but must report the correct netlink pid.

As a workaround: Assuming that the audit daemon is the only application
to issue a AUDIT_SET command to set the status pid, the kernel can
compare the netlink source pid of the AUDIT_SET message and compare it
against the status pid provided. If they differ, issue a warning but
use the netlink source pid thus covering the case where the auto bound
netlink pid actually differs from the process pid.
