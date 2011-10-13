From: Mark Larwill <larwill@gmail.com>
Subject: Help with NULL pointer derefrence in net/ipv4/xfrm4_policy.c
Date: Thu, 13 Oct 2011 12:39:33 -0700
Message-ID: <CAEY+5yAY12EhntaoDetf7+OTvAHVYKXOJQckZXAowmHGm_p96g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42319 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753053Ab1JMTje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 15:39:34 -0400
Received: by gyb13 with SMTP id 13so384918gyb.19
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 12:39:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm an software developer working for a small firewall company. I am
running into a kernel NULL pointer deference bug (using an older
2.6.35.12 kernel), and noticed a patch submitted that seems like it
might fix my problem. I was hoping someone could help me out a bit. It
is not practical for me to simply upgrade to the latest Linux, rather
I must make a targeted fix.

First a little on my specific issue, then my questions. My problem is
in the file net/ipv4/xfrm4_policy.c in the function
xfrm4_dst_ifdown(), on this line: " if (xdst->u.rt.idev->dev == dev)
{" basically idev is all 0 so xdst->u.rt.idev->dev will crash.

But before I blindly apply the patch I was hoping someone could help
answer some questions on it so I don't make things worse by not
understanding everything. The patch I reference below removes all of
this idev stuff from the kernel. I can see that as long as the if
condition (mentioned above) is met the (xfrm4_dst_ifdown) code
basically goes through a list and assigns the idev structures loopback
devices, so my guess is that for some reason these idev devices are no
longer being used or never were used to begin with. Also similar
behavior is done in the generic ipv4_dst_ifdown() function in
net/ipv4/route.c.

My questions are:
Q1) Why was the idev stuff there to begin with if it was unnecessary?
/ What was it's original purpose?
Q2) Why did we have to assign the devices to the loopback device? (Was
it so no packets would go out during deletion?)
Q3) When, and in what context are the ipv4_dst_ops.ifdown, and
ops->ifdown function pointers called? (What are they doing and why?)
Q4) Between 2.6.35.12 and the patch that removes the idev stuff in
from 11 Nov 2010 in 2.6.38-rc8 are there any other things
removed/changed in between that made it possible to remove the idef
stuff?
Q5) All of these basically lead up to: Why is it safe to remove all of
the idev stuff?
Q6) Is there a safe way I can safely remove this idev stuff or at
least avoid the NULL pointer deference? (Just blindly returning if it
is NULL would be the immediate reaction without thinking about it, but
chances are that's wrong---otherwise why is xfrm4_dst_ifdown written
the way it is?

Any help is greatly appreciated, thanks very much!


--Mark Larwill

REFERENCES:
A)
This post here to kerneltrap.org which seems to describe the old behavior:
http://kerneltrap.org/mailarchive/linux-netdev/2007/9/27/324077

B) The main change I am referring to, and text below
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=72cdd1d971c0deb1619c5c339270570c43647a78


It seems idev field in struct rtable has no special purpose, but adding
extra atomic ops.

We hold refcounts on the device itself (using percpu data, so pretty
cheap in current kernel).

infiniband case is solved using dst.dev instead of idev->dev

Removal of this field means routing without route cache is now using
shared data, percpu data, and only potential contention is a pair of
atomic ops on struct neighbour per forwarded packet.

About 5% speedup on routing test.
