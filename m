From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [GIT PATCH net-2.6.23] IPV6: Configurable IPv6 address
 selection policy table (RFC3484)
Date: Sat, 28 Apr 2007 23:17:07 -0700 (PDT)
Message-ID: <20070428.231707.39159334.davem@davemloft.net>
References: <20070419.162856.20840698.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: drepper@redhat.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55127
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756235AbXD2GRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 02:17:11 -0400
In-Reply-To: <20070419.162856.20840698.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 19 Apr 2007 16:28:56 +0900 (JST)

> We store labels only in kernel, and leave precedence in userspace
> (/etc/gai.conf), so far.  The name resolution library (getaddrinfo(3))
> is required to be changed to try reading label information from kernel.
> On the other hand, on BSDs or on Solaris, full policy table including
> precedence seems to be stored in kernel, and the name resolution
> libary (getaddrinfo(3)) seems to use that information.
> We could choose this approach.
> 
> Note: Solaris uses string (up to 15 characters excluding NUL) labels.

As you mention the main problem is efficiently notifying
userspace that the table has changed in the same way that
file changes can be checked.

The last thing we want is for glibc to have to stat a bunch of files
every time it wants to do something, it does enough of that already
:-)

Probably, to start somewhere, it may be wise to put the entire
precedence table in the kernel just like BSD, Solaris, and your
patch do.  We can figure out how to make the update interface
efficient later, perhaps with something clever in netlink.

One idea is to have glibc have some kind of socket open, subscribed
to a group which gets "sticky" events.  It will be simple messages
such as "table of type X got updated".  If the socket already got
sent that message, on subsequent updates we wouldn't send it again
until glibc read the event message out.

It would be possible to not even use explicit messages.  Instead
some netlink socket state holds a generation counter, label
table updates increment the counter, and glibc just asks the
kernel via netlink whether it's generation count is out of date.
If so, the kernel returns true and also updates the generation
count for that socket to match the current one.

It is one idea.

