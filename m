From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Sun, 16 Jan 2011 22:17:04 +0100
Message-ID: <4D336050.9030602@netfilter.org>
References: <54347.1295168081@internode.on.net> <1295169670.3977.36.camel@edumazet-laptop> <alpine.LNX.2.01.1101161144350.8081@obet.zrqbmnf.qr> <4D32E3BA.5040008@internode.on.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070907060203070404030701"
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Arthur Marsh <arthur.marsh@internode.on.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41806 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753666Ab1APVRK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jan 2011 16:17:10 -0500
In-Reply-To: <4D32E3BA.5040008@internode.on.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070907060203070404030701
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

On 16/01/11 13:25, Arthur Marsh wrote:
> Jan Engelhardt wrote, on 16/01/11 21:20:
>>
>> Le dimanche 16 janvier 2011 à 19:24 +1030, Arthur Marsh a écrit :
>>>
>>>> With kernels up to and including 2.6.37-git7, inbound telnetd-ssl
>>>> connections worked fine. With kernel 2.6.37-git9 and later inbound
>>>> telnetd-ssl connections failed, and on machine shut-down, there
>>>> were warning messages about daemons not return status.
>>
>> Which daemons are these? For reference, what distro do you happen
>> to use?
> 
> avahi-daemon (which gave multiple warning messages, hence I thought it
> may have been multiple packages)
> 
> I'm running Debian unstable with kernel.org kernels.
> 
>>
>>>> commit 0ab03c2b1478f2438d2c80204f7fef65b1bca9cf
>>>>      netlink: test for all flags of the NLM_F_DUMP composite
>>
>> Each of the hunks in this commit is independent of another.
>> Would you mind bisecting these too?
> 
> Recompiling with the only the first patch (attached) resulted in a
> repeat of the problem.
> 
> I've removed one person from the cc: list as they did not want to
> receive email about this even though they signed off the commit.

Please, pass this patch to the avahi-daemon developers. They use an
invalid netlink flag combination for dump operations.

This patch has spotted a problem that they have to fix indeed.


--------------070907060203070404030701
Content-Type: text/x-patch;
 name="fix-netlink-in-avahi.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="fix-netlink-in-avahi.patch"

avahi: fix wrong use of netlink flags for dump operations

The avahi-daemon uses a wrong flag combination to operate with
rtnetlink. This patch fixes the problems.

No need to set NLM_F_ACK since the dump operation already includes
the trailing NLMSG_DONE message that informs about the end of the
dump operation.

Please, consider porting the avahi-daemon to libmnl:

http://www.netfilter.org/projects/libmnl/index.html

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Index: avahi-0.6.27/avahi-autoipd/iface-linux.c
===================================================================
--- avahi-0.6.27.orig/avahi-autoipd/iface-linux.c	2011-01-16 22:06:20.000000000 +0100
+++ avahi-0.6.27/avahi-autoipd/iface-linux.c	2011-01-16 22:07:34.000000000 +0100
@@ -262,7 +262,7 @@ int iface_get_initial_state(State *state
     n->nlmsg_len = NLMSG_LENGTH(sizeof(*ifi));
     n->nlmsg_type = RTM_GETLINK;
     n->nlmsg_seq = seq;
-    n->nlmsg_flags = NLM_F_MATCH|NLM_F_REQUEST|NLM_F_ACK;
+    n->nlmsg_flags = NLM_F_REQUEST|NLM_F_DUMP;
     n->nlmsg_pid = 0;
 
     ifi = NLMSG_DATA(n);
Index: avahi-0.6.27/avahi-core/iface-linux.c
===================================================================
--- avahi-0.6.27.orig/avahi-core/iface-linux.c	2011-01-16 22:06:51.000000000 +0100
+++ avahi-0.6.27/avahi-core/iface-linux.c	2011-01-16 22:07:08.000000000 +0100
@@ -53,7 +53,7 @@ static int netlink_list_items(AvahiNetli
     n = (struct nlmsghdr*) req;
     n->nlmsg_len = NLMSG_LENGTH(sizeof(struct rtgenmsg));
     n->nlmsg_type = type;
-    n->nlmsg_flags = NLM_F_ROOT|NLM_F_REQUEST;
+    n->nlmsg_flags = NLM_F_REQUEST|NLM_F_DUMP;
     n->nlmsg_pid = 0;
 
     gen = NLMSG_DATA(n);


--------------070907060203070404030701--
