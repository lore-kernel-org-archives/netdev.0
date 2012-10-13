From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] Kernel recieves DNS reply, but doesn't deliver it to a
 waiting application
Date: Sat, 13 Oct 2012 15:44:20 +0200
Message-ID: <1350135860.21172.14606.camel@edumazet-glaptop>
References: <20121003232548.eb6b6b22.bircoph@gmail.com>
	 <20121013163639.87abca00.bircoph@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Savchenko <bircoph@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:63353 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925Ab2JMNoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2012 09:44:23 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so503087wib.1
        for <netdev@vger.kernel.org>; Sat, 13 Oct 2012 06:44:22 -0700 (PDT)
In-Reply-To: <20121013163639.87abca00.bircoph@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-10-13 at 16:36 +0400, Andrew Savchenko wrote:
> Hello,
> 
> On Wed, 3 Oct 2012 23:25:48 +0400 Andrew Savchenko wrote:
> > I encountered a very weird bug: after a while of uptime kernel stops to deliver
> > DNS reply to applications. Tcpdump shows that correct reply is recieved, but 
> > strace shows inquiring application never recieves it and ends with timeout,
> > epoll_wait() always returns 0:
> > a slice from: $ host kernel.org 8.8.8.8:
> > 
> > sendmsg(20, {msg_name(16)={sa_family=AF_INET, sin_port=htons(53),
> > sin_addr=inet_addr("8.8.8.8")}, msg_iov(1)=[{"\266\344\1\0\0\1\0\0\0\0\0\0\6k
> > ernel\3org\0\0\1\0\1", 28}], msg_controllen=0, msg_flags=0}, 0) = 28            
> > epoll_wait(3, {}, 64, 0)                = 0                                     
> > epoll_wait(3, {}, 64, 4999)             = 0
> > 
> > Though tcpdump shows a normal reply:
> > 
> > 20:28:44.162897 IP 10.7.74.7.43167 > 8.8.8.8.domain: 46820+ A? kernel.org. (28) 
> > 20:28:44.221308 IP 8.8.8.8.domain > 10.7.74.7.43167: 46820 1/0/0 A 149.20.4.69
> > (44)
> > 
> > After this bug has occured, it is no longer possible to perform DNS request on
> > the crippled system. I tried to stop/restart all network-related daemons, to
> > recreate network interfaces whenever possible (e.g. pppX devices), but with no
> > help. I use iptables and ebtables on this host, but reseting them (flushing all
> > chains, removing user chains, setting all policies to ACCEPT) doesn't help. The
> > only worknig solution is to reboot the system.
> > 
> > This bug happens rarely and randomly (about once in 7-12 days on 24x7 available
> > production system), but I had it 5 times already. Due to rare and random nature
> > of the bug I can't bisect it.
> > 
> > This problem occured after I updated vanilla kernel from 2.6.39.4 to 3.4.6.
> > Afterward I updated kernel to 3.4.10 in the hope that this will fix the
> > problem, but with no result. (I updated kernel due to commit
> > 2ce42ec4ef551b08d2e5d26775d838ac640f82ad, which describes somewhat similar
> > issue, though I don't use I/OAT engine due to lack of hardware support.)
> > 
> > More details, attached trace files and kernel configs are available at bugzilla:
> > https://bugzilla.kernel.org/show_bug.cgi?id=48081
> > 
> > In a few days I'll try 3.4.12 (I need to rebuild kernel anyway due to unrelated
> > issue) and will report if this bug will occur again. But please note it may
> > take several weeks to check this.
> 
> I got this problem again with 3.4.12 kernel. System lasted less than
> a week and reboot was the only option...

You should investigate and check where the incoming packet is lost

Tools :

netstat -s

drop_monitor module and dropwatch command

cat /proc/net/udp
