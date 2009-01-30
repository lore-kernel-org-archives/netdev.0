From: Stephen Hemminger <shemminger@vyatta.com>
Subject: virt-manager broken by bind(0) in net-next.
Date: Thu, 29 Jan 2009 22:50:35 -0800
Message-ID: <20090129225035.538aacd2@extreme>
References: <20090128212114.38be3e8c@extreme>
 <20090129103544.GC22110@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: berrange@redhat.com,
	Fedora/Linux Management Tools <et-mgmt-tools@redhat.com>,
	netdev@vger.kernel.org
To: "Daniel P. Berrange" <berrange@redhat.com>,
	Fedora/Linux Management Tools <et-mgmt-tools@redhat.com>,
	David Miller <davem@davemloft.net>,
	Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33268 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751069AbZA3Gui (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 01:50:38 -0500
In-Reply-To: <20090129103544.GC22110@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resend without screenshot that upsets vger spam filter!
The bind(0) optimization in David's net-next breaks virt machine manager when
a guest console window is started. 

virt-machine-manager
  click local-host (System)
  Run one of the existing VM's
 
The virtual console window then cause a dialog about allowing remote access to display;
(this never happened with earlier kernels), regression #1

Then if I allow it multiple copies of the window start cloning and general chaos ensues.
The problem is only in the net-next tree (not mainline 2.6.29-rcX).

Bisected down to the following commit, that breaks virt-manager


a9d8f9110d7e953c2f2b521087a4179677843c2a is first bad commit
commit a9d8f9110d7e953c2f2b521087a4179677843c2a
Author: Evgeniy Polyakov <zbr@ioremap.net>
Date:   Mon Jan 19 16:46:02 2009 -0800

    inet: Allowing more than 64k connections and heavily optimize bind(0) time.
    
    With simple extension to the binding mechanism, which allows to bind more
    than 64k sockets (or smaller amount, depending on sysctl parameters),
    we have to traverse the whole bind hash table to find out empty bucket.
    And while it is not a problem for example for 32k connections, bind()
    completion time grows exponentially (since after each successful binding
    we have to traverse one bucket more to find empty one) even if we start
    each time from random offset inside the hash table.
    
    So, when hash table is full, and we want to add another socket, we have
    to traverse the whole table no matter what, so effectivelly this will be
    the worst case performance and it will be constant.
    
