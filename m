From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH V2 net] core: Don't attempt to load the "" driver.
Date: Mon, 8 Sep 2014 13:23:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1748BC57@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D174856B9@AcuExch.aculab.com>
	<063D6719AE5E284EB5DD2968C1650D6D174862E0@AcuExch.aculab.com>
 <20140905.143241.114624370748725493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33929 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753047AbaIHNZC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 09:25:02 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12051-05 for <netdev@vger.kernel.org>;
 Mon,  8 Sep 2014 14:24:52 +0100 (BST)
In-Reply-To: <20140905.143241.114624370748725493.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> From: David Laight <David.Laight@ACULAB.COM>
> Date: Wed, 3 Sep 2014 08:55:21 +0000
> 
> > Requests like 'ifconfig ""' cause dev_load(net, "") be called, since
> > request_module("") return 0 (success) this generates the error message:
> > "Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and
> alias netdev- instead."
> >
> > Since dev_load() doesn't have to work, just ignore such names.
> >
> > Signed-off-by: David Laight <david.laight@aculab.com>
> > ---
> >
> > V2: Added sign off.
> >
> > If you search for the above error message, you'll find a lot of complaints.
> > While the applications shouldn't be calling an SIOCxxx ioctl with ifr_name[0] == 0
> > the kernel shouldn't be tracing the error either.
> >
> > Due to the complaints from users, this might be a backport candidate.
> 
> I have to say that I don't like this.
> 
> Why is request_module("") signalled with success unconditionally?
> A module didn't get loaded, so semantically this behavior makes
> no sense at all.
> 
> I would rather than simply request_module() signal an error in this
> case, and then _NOBODY_ has to have all of this duplicated logic to
> check for name[0]=='\0' throughout all of the call chains leading to
> request_module().

Maybe, but the SIOCxxx ioctl code is only doing a speculative module load.
Possibly it should error out the ioctl request earlier if ifr_name is "",
but maybe it is sometimes valid?

In this case you also want to stop the attempt to load "netdev-".
Hmmm... that really sucks...
This whole 'try to load the module' path should be predicated on
'interface not found'.
I presume that the locking rules prohibit the module load attempt
at that time.
Maybe the ioctl code should do a retry if it gets the 'interface not found'
error - instead of assuming that the module needs loading.

At the moment I think that if you run 'ifconfig eth0' it will try to
load "netdev-eth0" and "eth0" (maybe without the unit suffix) before
attempting to do anything else.

I didn't do any 'software archaeology' on the SIOCxxx ioctl code.

	David
