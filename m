From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 09:45:43 -0500
Message-ID: <48EB7617.3060304@linux-foundation.org>
References: <20081006185026.GA10383@minyard.local> <48EA8197.6080502@cosmosbay.com> <20081006.144002.56418911.davem@davemloft.net> <48EA9A59.1090306@acm.org> <20081007083750.GB17079@2ka.mipt.ru> <48EB6F2D.100@linux-foundation.org> <20081007143346.GA6384@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48276 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750880AbYJGOyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 10:54:15 -0400
In-Reply-To: <20081007143346.GA6384@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney wrote:

> But care is required -- SLAB_DESTROY_BY_RCU permits objects to be freed
> and reallocated while a reader holds a reference.  The only guarantee is
> that the -type- of the data structure will not change while a reader holds
> a reference.  With something like UDP, this might well be sufficient.

Right so after the hash lookup operation you are not assured that the object
has not been freed or even reallocated for a different purpose. So after
finding the pointer to the object two things need to happen (under rcu_lock):

1. Verify that the object is still in use
2. Verify that the object is matching the hash

If not then the operation needs to be redone because we have a stale hash pointer.
