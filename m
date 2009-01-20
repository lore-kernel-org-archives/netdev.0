From: Stephan Peijnik <stephan@peijnik.at>
Subject: RFC: Mandatory Access Control for sockets aka "personal firewalls"
Date: Tue, 20 Jan 2009 18:48:39 +0100
Message-ID: <1232473719.24943.102.camel@sp-laptop3.sp-local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: linux-security-module <linux-security-module@vger.kernel.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello all of you,

I am sending this email as a discussion about this topic has been going
on at linux-security-module@vger.kernel.org for some time now and I
believe that all parties affected or somehow related to this should be
involved in the discussion. We would like to hear your opinion on this
matter and would be glad if we could work together on finding a possible
solution. I have CC'ed linux-security-module, netfilter-devel and
netdev, but if you believe that I missed someone, feel free to forward
this email to the respective list.

Firstly, I would like to elaborate on what we more or less agreed on a
personal firewall should be able to do and what such a piece of software
is intended for.

A personal firewall should implement per-application mandatory access
control for sockets. In short this means that such a program decides
every time a call to either socket(), accept(), bind(), connect() or
listen() is made whether the invoking program is allowed to do so or
not. No per-packet filtering can be done and neither is connection
intercepting of any interest.

As personal firewalls are targeted at single-user, desktop systems the
decision on whether a call is allowed or not is usually made by the user
of that system (for example using a popup asking the user what to do).
This means personal firewalls should not enforce system security policy,
but rather a per-user security policy.
The implementations can then add caching of decisions made (ie.
"remember this decision") and thus not ask every time a call is made.
Also, the only protocols to be supported are IPv4 and IPv6. Adding
support for AF_UNIX and/or AF_NETLINK doesn't make much sense, as this
is not network-related and would only increase the amount of work a
personal firewall implementation has to do.

All proposed implementations of personal firewalls until now have made
it rather clear that the decision-making logic should be placed in
userspace, whilst only a small piece of code communicating with a
userspace daemon should be placed in the kernel itself.


Okay, enough of the (not so) brief description on what people want to do
and on to a summary of what has been discussed so far.

Most implementations started out using the LSM framework for creating a
personal firewall, that's also the reason the whole discussion started
out on the LSM mailing list.
Even though this looks like a good solution there is one main problem
with the LSM framework right now: only a single LSM module can be loaded
and enabled at a time. However, this was done intentionally as stacking
multiple LSMs proved to be complex and not entirely sane.
This means that if one decides to enable a personal firewall LSM at boot
time one will not be able to use a generic-purpose LSM, like SELinux or
AppArmor simultaneously. Additionally LSMs can only be enabled at boot
time and cannot be LKMs, they have to be linked statically into the
kernel. 

Another approach that has been suggested is using the netfilter
framework for this purpose. Even though this again sounds like a good
idea in the first place it also has its flaws.
netfilter was designed to work on the network level and, at least from
my understanding, is not process-context aware. Doing lookups to get the
process context on each and every connection/packet passing netfilter
could be done, but might have a negative effect on the overall system
performance.

And yet another approach was suggested: hooking socket-related calls
directly in net/socket.c. This would mean that the personal firewall
code is called directly from net/socket.c and can this way work in
process-context, without using the LSM framework.
On the other hand this would add, besides the LSM calls that are in
place in net/socket.c a few extra calls which might not be what we want.
One should also keep in mind that calls can (and may, this is
intentional) be blocked by the personal firewall system. This could be
seen as an advantage or disadvantage, but would allow waiting for user
input until proceeding with the execution of the caller.

What has not been agreed on yet is whether only a way of hooking these
calls should be made available to implementations or whether the whole
in-kernel part should be developed together and allow implementations of
personal firewalls in userspace only, for example using a netlink socket
to communicate with the shared in-kernel code.

Implementations using the LSM approach are TuxGuardian [0] and snet [1].
Code implementing the last mentioned approach can be found in git over
at [2] in the sactl-direct branch.
Please don't forget that these implementations are probably in either a
defunct state or are up to discussion themselves.

As a final note I would like to add that I believe that all lists this
mail has been sent to are somehow affected by the topic we are
discussing and I (or better said we) would love to hear your opinions.
Also, I hope I didn't miss anything that was discussed, but if I did
feel free to correct me.

-- Stephan

[0] http://tuxguardian.sourceforge.net/
[1] http://www.synack.fr/project/snet/snet.html
[2] http://repo.or.cz/w/linux-2.6/sactl.git

