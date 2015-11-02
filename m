From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is
 incorrect for sockets in accept(3)
Date: Mon, 2 Nov 2015 10:03:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBC8782@AcuExch.aculab.com>
References: <20151019095938.72ea48e6@xeon-e3>
 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
 <562594E1.8040403@oracle.com>
 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151021034950.GL22011@ZenIV.linux.org.uk> <5627A37B.4090208@oracle.com>
 <20151021185104.GM22011@ZenIV.linux.org.uk>
  <201510212033.t9LKX4G8007718@room101.nl.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dholland-tech@netbsd.org" <dholland-tech@netbsd.org>
To: "'Casper.Dik@oracle.com'" <Casper.Dik@oracle.com>,
	Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.192]:61959 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696AbbKBKEE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 05:04:04 -0500
In-Reply-To: <201510212033.t9LKX4G8007718@room101.nl.oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casper.Dik@oracle.com
> Sent: 21 October 2015 21:33
..
> >Er...  So fd2 = dup(fd);accept(fd)/close(fd) should *not* trigger that
> >behaviour, in your opinion?  Because fd is sure as hell not the last
> >descriptor refering to that socket - fd2 remains alive and well.
> >
> >Behaviour you describe below matches the _third_ option.
> 
> >> >BTW, for real fun, consider this:
> >> >7)
> >> >// fd is a socket
> >> >fd2 = dup(fd);
> >> >in thread A: accept(fd);
> >> >in thread B: accept(fd);
> >> >in thread C: accept(fd2);
> >> >in thread D: close(fd);

If D is going to do this, it ought to be using dup2() to clone
a copy of (say) /dev/null onto 'fd'.

> >> >Which threads (if any), should get hit where it hurts?
> >>
> >> A & B should return from the accept with an error. C should
> >> continue. Which is what happens on Solaris.

That seems to completely break the normal *nix file scheme...

> >> To this end each thread keeps a list of file descriptors
> >> in use by the current active system call.
> >

Remember, Solaris (and SYSV) has extra levels of multiplexing between
userspace and char special drivers (and probably sockets) than Linux does.
As well as having multiple fd referencing the same struct FILE, multiple
FILE can point to the same inode.
If you have two different /dev entries for the same major/minor you
also end up with separate inodes - all finally referencing the same
driver data (indexed only by minor number).
(You actually get two inodes in the chain, one for the disk filesystem
and one char-special. The ref counts on both can be greater than 1.)

	David
