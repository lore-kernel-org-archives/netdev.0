From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net v2 8/9] bridge: Properly check if local fdb entry
 can be deleted when deleting vlan
Date: Wed, 18 Dec 2013 11:55:36 +0900
Message-ID: <1387335336.3563.33.camel@ubuntu-vm-makita>
References: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <1387281821-21342-9-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <52B0A75D.90609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:36049 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833Ab3LRCzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 21:55:46 -0500
In-Reply-To: <52B0A75D.90609@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-17 at 14:34 -0500, Vlad Yasevich wrote:
> On 12/17/2013 07:03 AM, Toshiaki Makita wrote:
> > Vlan codes unconditionally delete local fdb entries.
> > We should consider the possibility that other ports have the same
> > address and vlan.
> > 
> > Example of problematic case:
> >   ip link set eth0 address 12:34:56:78:90:ab
> >   ip link set eth1 address aa:bb:cc:dd:ee:ff
> >   brctl addif br0 eth0
> >   brctl addif br0 eth1 # br0 will have mac address 12:34:56:78:90:ab
> >   bridge vlan add dev eth0 vid 10
> >   bridge vlan add dev eth1 vid 10
> >   bridge vlan add dev br0 vid 10 self
> > We will have fdb entry such that f->dst == eth0, f->vlan_id == 10 and
> > f->addr == 12:34:56:78:90:ab at this time.
> > Next, delete eth0 vlan 10.
> >   bridge vlan del dev eth0 vid 10
> > In this case, we still need the entry for br0, but it will be deleted.
> > 
> > Note that br0 needs the entry even though its mac address is not set
> > manually. To delete the entry with proper condition checking,
> > fdb_delete_local() is suitable to use.
> > 
> > Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> 
> Acked-by: Vlad Yasevich <vyasevic@redhat.com>
> 
> Note: All these special cases are begging for something in the fdb
> to track if this fdb refers to multiple ports or not.  May be
> a list of pointers to ports?  Then we can simply check to see if
> the list is not empty and assign to the first one in the list..

Maybe the list will simplify fdb_delete_local().
The difficult point is maintaining the list properly.
I will think about it more deeply.

Thanks,
Toshiaki Makita
