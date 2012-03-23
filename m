From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH][RFC] bonding: delete migrated IP addresses from the rlb
 hash table
Date: Fri, 23 Mar 2012 11:33:21 +0100
Message-ID: <20120323103321.GA11340@midget.suse.cz>
References: <20120227173400.GB816@midget.suse.cz>
 <4F6C21D7.2000609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: WeipingPan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38361 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754207Ab2CWKd0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2012 06:33:26 -0400
Content-Disposition: inline
In-Reply-To: <4F6C21D7.2000609@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 23, 2012 at 03:10:15PM +0800, WeipingPan wrote:
> On 02/28/2012 01:34 AM, Jiri Bohac wrote:
> >This patch solves this by looking at all incoming ARP packets,
> >and checking if the source IP address is one of the source
> >addresses stored in the rx_hashtbl. If it is, the corresponding
> >hash table entries are removed. Thus, when an IP address is
> >migrated, the first ARP broadcast by its new owner will purge the
> >offending entries of rx_hashtbl.
> >
> >   (a simpler approach, where bonding would monitor IP address
> >    changes on the local system does not work for setups like:
> >    HostA --- NetworkA --- eth0-bond0-br0 --- NetworkB --- hostB
> >    and an IP address migrating from HostB to HostA)
> Hi, Jiri,
> Do "NetworkA" and "NetworkB" mean different subnet ?
> How to configure bonding and bridge to make HostA communicate with hostB ?
> What is the problem for this setup ?

No, NetworkA and NetworkB are the same subnet, same L2 network.
It may be two ethernet segments that are bridge by the br0
bridge. A more common scenario is that HostB is a virtual machine
that communicates through br0->bond0->ethX with HostA.

In this setup, bond0 can not solve the original bug (stale ARP
information in the rlb hash table) simply by monitoring the
removal of IP addresses on the local host. The IP address that is
about to be migrated from HostB to HostA is _not_ configured on
any of the interfaces of the machine running bond0.

The patch solves the problem by looking at ARP requests coming
from NetworkA and deleting RLB hash table entries that were
created while the ARP's src_ip was still assigned in NetworkB.

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
