From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/3 v4] macvtap driver
Date: Wed, 10 Feb 2010 19:10:07 +0100
Message-ID: <4B72F67F.1040008@trash.net>
References: <201001271104.20607.arnd@arndb.de>	 <9ae48b021002080914j2811e7cejd1c29aa3653ba8de@mail.gmail.com>	 <1265655334.31760.9.camel@w-sridhar.beaverton.ibm.com>	 <201002101548.47634.arnd@arndb.de> <1265825143.30414.81.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	Ed Swierk <eswierk@aristanetworks.com>, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56351 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756251Ab0BJSKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 13:10:14 -0500
In-Reply-To: <1265825143.30414.81.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sridhar Samudrala wrote:
> On Wed, 2010-02-10 at 15:48 +0100, Arnd Bergmann wrote:
>> On Monday 08 February 2010, Sridhar Samudrala wrote:
>>> I am also seeing this issue with net-next-2.6.
>>> Basically macvtap_put_user() and macvtap_get_user() call copy_to/from_user
>>> from within a RCU read-side critical section.
>>>
>>> The following patch fixes this issue by releasing the RCU read lock before
>>> calling these routines, but instead hold a reference to q->sk.
>>>
>>> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
>> Yes, we need something like this, but we also need to protect the
>> device from going away. The concept right now is to use file_get_queue
>> to protect both the macvtap_queue and the macvlan_dev from going
>> away. The sock_hold will keep the macvtap_queue around, but
>> as far as I can tell, a user could still destroy the macvlan_dev
>> using netlink at the same time, which still breaks.
> 
> may be we should do a dev_hold() in macvtap_set_queue() and dev_put()
> in macvtap_del_queue() so that the underlying device cannot go away as
> long the macvtap fd is open.

You either need some kind of loose binding (f.i. using the ifindex)
or need to handle the case that the device goes away asynchronously
by indicating an error to the socket and unbinding it.

But you can't make the lifetime of the device dependant on the socket.
