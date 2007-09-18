From: Chuck Ebbert <cebbert@redhat.com>
Subject: SFQ qdisc crashes with limit of 2 packets
Date: Tue, 18 Sep 2007 13:18:50 -0400
Message-ID: <46F0087A.3080104@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42418 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759436AbXIRRSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 13:18:53 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l8IHIpvd022157
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 13:18:51 -0400
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l8IHIoHj003141
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 13:18:50 -0400
Received: from [172.16.83.145] (dhcp83-145.boston.redhat.com [172.16.83.145])
	by mail.boston.redhat.com (8.13.1/8.13.1) with ESMTP id l8IHIoni005944
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 13:18:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Limit of 1 is forbidden, crashes with 2, works with 3:

https://bugzilla.redhat.com/show_bug.cgi?id=219895

=========

If the defect is produced at a console (as in ctrl-alt-f<0-6>) a kernel stack
trace can be seen the moment "ping" is invoked.  Since the stack trace is not
 written to the /var/log/messages here's part of it (manually copied):
  syscall_call(()
    sys_socketcall()
      sys_sendmsg()
        sock_sendmsg()
          inet_sendmsg()
            raw_sendmsg()      
              ip_push_pending_frames()
                ip_output()
                  neigh_resolve_output()
                    dev_queue_xmit()
                      __qdisc_run()
The location given in __qdisc_run() is 0x30/0x19b.  The value given for EIP is
sfq_dequeue+0xf6/0x179 in the sch_sfq module.

>From disassembling sch_sfq.ko it seems that it is on line 360 of sch_sfq.c:
    sch->qstats.backlog -= skb->len;
where "skb" is an invalid pointer:
    net/sched/sch_sfq.c:360
 194:   ff 4d 28                decl   0x28(%ebp)
 197:   8b 14 24                mov    (%esp),%edx
 19a:   8b 42 60                mov    0x60(%edx),%eax ** crash **
 19d:   29 45 58                sub    %eax,0x58(%ebp)


