From: manoj bm <manoj.bm8@gmail.com>
Subject: query : unregister/register netdev
Date: Wed, 23 Nov 2011 16:44:58 +0530
Message-ID: <CA+aNqjqHhSOHOcd1sjZMr-rf2ZTBHK3+-jjQwXLYysdZr+YDOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:61556 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab1KWLO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 06:14:59 -0500
Received: by vbbfc26 with SMTP id fc26so279285vbb.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 03:14:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Guys,
   WRT below mail chain link, I am facing similar issue.
http://www.spinics.net/lists/netdev/msg180176.html

Please find the usage details below:

Situation:
I have concurrent  interfaces running & active doing data
transactions. (ex: interface0 & interface1)

-> whenever user want to delete activity on one interface, i have to
stop activity & hide from user (this i am trying to achieve by
unregistering the netdev but not freeing it)
-> whenever user want to  create activity on interface, i have to
start activity & make it visible to user (this i am trying to achieve
by registering the netdev which would have unregistered previously)

Issues
-> First interface(0) is basic so i have allocated private driver data
area to it & other interfaces contains basic info & pointing to this
"netdev[0]->net_priv" (i.e. first interface private data area).
Because of this above requirement i cant free the netdev0 until chip
is power supply removed.

Other options thought of but not used are:

-> I can remove other interfaces using unregister_netdev followed by
free_netdev() BUT i am afraid that  during the heavy data traffic
conditions(apps continuously pumping data with high bandwidth),
allocating & registering might causes the issue of registration fail
because of resource crunch. Which we never tolerate as this a
concurrent interface solution

-> After verification found that, even ethernet also works in similar
fashion. If chip is powered then irrespective of RJ45 connected or not
interface is given & visible to the user. That's the way i also
created all of my interfaces statically(during initialization)
depending on the user input i want to hide/unhide (i.e.
register/unregister netdev) corresponding netdevice visible using
ifconfig.

Currently i am facing a issue that  bug_on from kernel
--------------------------------------------------------------------------
-> Depending on application input i have to unregister & register the
same netdev without freeing
I am facing the bug_on from kernel during registration as below
BUG_ON(dev->reg_state != NETREG_UNINITIALIZED);

-> If we forcefully reset the dev->reg_state to uninitialized in our
driver, then this works fine but kernel warns already registered
device & some thing seriously wrong here (i dont want to hack netdev
structures here :))

->  Then i have tried to initialize the device after unregistration by
calling ether_setup & then again registering BUT same bug_on appeared.

My requirement is quiet simple,
-> Whenever user application want to "delete the netdev interface"
then i have to make the interface disappeared for ifconfig/iwconfig,
so that user can't play with that
-> Whenever user application want to "Add the netdev interface" then i
have to make the interface appearing for ifconfig/iwconfig, so that
user can use those

The problem is i don't want to call Alloc_netdev/free_netdev based on
application input (dynamically creating/destroying), i just want to
register/unregister statically created interfaces accordingly.

Please let me know your views on it. Thanks in advance

Thanks,
  Manoj
