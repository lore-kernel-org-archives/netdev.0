From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH 0/3 v4] macvtap driver
Date: Wed, 10 Feb 2010 10:05:43 -0800
Message-ID: <1265825143.30414.81.camel@w-sridhar.beaverton.ibm.com>
References: <201001271104.20607.arnd@arndb.de>
	 <9ae48b021002080914j2811e7cejd1c29aa3653ba8de@mail.gmail.com>
	 <1265655334.31760.9.camel@w-sridhar.beaverton.ibm.com>
	 <201002101548.47634.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ed Swierk <eswierk@aristanetworks.com>, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:34628 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754640Ab0BJSFz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 13:05:55 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1AI2S7X016635
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 13:02:28 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1AI5jQI1581292
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 13:05:45 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1AI5jCK002782
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 16:05:45 -0200
In-Reply-To: <201002101548.47634.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-10 at 15:48 +0100, Arnd Bergmann wrote:
> On Monday 08 February 2010, Sridhar Samudrala wrote:
> > I am also seeing this issue with net-next-2.6.
> > Basically macvtap_put_user() and macvtap_get_user() call copy_to/from_user
> > from within a RCU read-side critical section.
> > 
> > The following patch fixes this issue by releasing the RCU read lock before
> > calling these routines, but instead hold a reference to q->sk.
> > 
> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> Yes, we need something like this, but we also need to protect the
> device from going away. The concept right now is to use file_get_queue
> to protect both the macvtap_queue and the macvlan_dev from going
> away. The sock_hold will keep the macvtap_queue around, but
> as far as I can tell, a user could still destroy the macvlan_dev
> using netlink at the same time, which still breaks.

may be we should do a dev_hold() in macvtap_set_queue() and dev_put()
in macvtap_del_queue() so that the underlying device cannot go away as
long the macvtap fd is open.

Thanks
Sridhar

