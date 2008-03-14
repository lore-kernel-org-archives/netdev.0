From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: Audit vs netlink interaction problem
Date: Fri, 14 Mar 2008 20:05:41 +0300
Message-ID: <47DAB065.6060804@openvz.org>
References: <47DAA660.90401@openvz.org> <20080314163929.GP20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35182 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754666AbYCNRGA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2008 13:06:00 -0400
In-Reply-To: <20080314163929.GP20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf wrote:
> * Pavel Emelyanov <xemul@openvz.org> 2008-03-14 19:22
>> I've found an interesting feature of how audit uses netlink for
>> communications. Look.
>>
>> The kauditd_thread() calls netlink_unicast() and passes the 
>> audit_pid to it. The audit_pid, in turn, is received from the 
>> user space and the tool (I've checked the audit v1.6.9) uses 
>> getpid() to pass one in the kernel. Besides, this tool doesn't
>> bind the netlink socket to this id, but simply creates it 
>> allowing the kernel to auto-bind one.
>>
>> That's the preamble.
>>
>> The problem is that netlink_autobind() _does_not_ guarantees
>> that the socket will be auto-binded to the current pid. Instead
>> it uses the current pid as a hint to start looking for a free
>> id. So, in case of conflict, the audit messages can be sent
>> to a wrong socket. This can happen (it's unlikely, but can be)
>> in case some task opens more than one netlink sockets and then
>> the audit one starts - in this case the audit's pid can be busy
>> and its socket will be bound to another id.
> 
> The audit userspace tool should be fixed, no question. It can continue

Oh, this is good.
I was afraid, that we'd have to stick to this logic...

> to auto bind but must report the correct netlink pid.

Hmmm... I'm afraid, that this can break the audit filtering and signal
auditing. I haven't yet looked deep into it, but it compares the 
task->tgid with this audit_pid for different purposes. If audit_pid
changes this code will be broken.

That's why I asked David for comments.

> As a workaround: Assuming that the audit daemon is the only application
> to issue a AUDIT_SET command to set the status pid, the kernel can
> compare the netlink source pid of the AUDIT_SET message and compare it

Bu we have no the netlink socket at the moment of setting the pid to
check this. The audit_reveive_msg() call which does this set is received 
via another (pre-created global) socket.

> against the status pid provided. If they differ, issue a warning but
> use the netlink source pid thus covering the case where the auto bound
> netlink pid actually differs from the process pid.

I though, that proper behavior would be to split audit_pid, used for
filtering from the audit_nlk_pid used for netlink communications.
