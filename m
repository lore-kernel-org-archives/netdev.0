From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/2] sysctl: lockdep support.
Date: Sat, 21 Mar 2009 00:39:28 -0700
Message-ID: <m1iqm3xr2n.fsf_-_@fess.ebiederm.org>
References: <49B91A7E.76E4.0078.0@novell.com>
	<tip-6a09dfa870ba0ed21b1124539968a36b42660661@git.kernel.org>
	<1236934491.5188.209.camel@laptop> <49BA33BE.76E4.0078.0@novell.com>
	<1236937423.22914.3698.camel@twins> <20090313103828.GB31094@elte.hu>
	<m1d4cd9n4k.fsf@fess.ebiederm.org> <20090320085205.GB16021@elte.hu>
	<m14oxo8qis.fsf@fess.ebiederm.org> <20090320182404.GA31629@elte.hu>
	<1237575134.4667.5.camel@laptop> <1237577688.4667.68.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Jan Beulich <jbeulich@novell.com>,
	tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com,
	linux-kernel@vger.kernel.org, Gautham R Shenoy <ego@in.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52056 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753336AbZCUHjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 03:39:43 -0400
In-Reply-To: <1237577688.4667.68.camel@laptop> (Peter Zijlstra's message of "Fri\, 20 Mar 2009 20\:34\:48 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The problem:  There is a class of deadlocks that we currently
have in the kernel that lockdep does not recognize. 

In particular with the network stack we can have:

rtnl_lock();                         use_table();
unregister_netdevice();              rtnl_lock();
unregister_sysctl_table();           ....
wait_for_completion();               rtnl_lock();
....                                 unuse_table()
rtnl_unlock();                       complete();



Where we never make it to the lines labled ....

My patch following patches treats the sysctl use count as a read/writer
lock for purposes of lockdep.

The code works but I'm not certain I have plugged into lockdep quite
correctly.

Eric

