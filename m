From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 7 Oct 2008 08:07:47 -0700
Message-ID: <20081007150747.GG6384@linux.vnet.ibm.com>
References: <20081006185026.GA10383@minyard.local> <48EA8197.6080502@cosmosbay.com> <20081006.144002.56418911.davem@davemloft.net> <48EA9A59.1090306@acm.org> <20081007083750.GB17079@2ka.mipt.ru> <48EB6F2D.100@linux-foundation.org> <20081007143346.GA6384@linux.vnet.ibm.com> <48EB7617.3060304@linux-foundation.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:36065 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753025AbYJGPQj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2008 11:16:39 -0400
Content-Disposition: inline
In-Reply-To: <48EB7617.3060304@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2008 at 09:45:43AM -0500, Christoph Lameter wrote:
> Paul E. McKenney wrote:
> 
> > But care is required -- SLAB_DESTROY_BY_RCU permits objects to be freed
> > and reallocated while a reader holds a reference.  The only guarantee is
> > that the -type- of the data structure will not change while a reader holds
> > a reference.  With something like UDP, this might well be sufficient.
> 
> Right so after the hash lookup operation you are not assured that the object
> has not been freed or even reallocated for a different purpose. So after
> finding the pointer to the object two things need to happen (under rcu_lock):
> 
> 1. Verify that the object is still in use
> 2. Verify that the object is matching the hash
> 
> If not then the operation needs to be redone because we have a stale hash
> pointer.

There is also the possibility that the element will be reused, but placed
in the same list that it resided in last time.  A reader referencing
that item during this process might then be relocated in the list, which
could either cause the reader to skip elements in the list (if the new
element is relocated farther down the list) or endlessly loop through
the list (if new elements were relocated closer to the list head and this
free-reallocate process repeated and the reader was insanely unlucky).

							Thanx, Paul
