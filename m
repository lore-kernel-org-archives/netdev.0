From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net v2 1/9] bridge: Fix the way to find old local fdb
 entries in br_fdb_changeaddr
Date: Fri, 03 Jan 2014 15:46:04 -0500
Message-ID: <52C7218C.2000205@redhat.com>
References: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp> <1387281821-21342-2-git-send-email-makita.toshiaki@lab.ntt.co.jp> <52C70F63.4020604@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11357 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752463AbaACUqK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jan 2014 15:46:10 -0500
In-Reply-To: <52C70F63.4020604@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/03/2014 02:28 PM, Vlad Yasevich wrote:
> On 12/17/2013 07:03 AM, Toshiaki Makita wrote:
>> br_fdb_changeaddr() assumes that there is at most one local entry per port
>> per vlan. It used to be true, but since commit 36fd2b63e3b4 ("bridge: allow
>> creating/deleting fdb entries via netlink"), it has not been so.
>> Therefore, the function might fail to search a correct previous address
>> to be deleted and delete an arbitrary local entry if user has added local
>> entries manually.
>>
>> Example of problematic case:
>>   ip link set eth0 address ee:ff:12:34:56:78
>>   brctl addif br0 eth0
>>   bridge fdb add 12:34:56:78:90:ab dev eth0 master
>>   ip link set eth0 address aa:bb:cc:dd:ee:ff
>> Then, the address 12:34:56:78:90:ab might be deleted instead of
>> ee:ff:12:34:56:78, the original mac address of eth0.
>>
>> Address this issue by introducing a new flag, added_by_user, to struct
>> net_bridge_fdb_entry.
>>
>> Note that br_fdb_delete_by_port() has to set added_by_user to 0 in case
>> like:
>>   ip link set eth0 address 12:34:56:78:90:ab
>>   ip link set eth1 address aa:bb:cc:dd:ee:ff
>>   brctl addif br0 eth0
>>   bridge fdb add aa:bb:cc:dd:ee:ff dev eth0 master
>>   brctl addif br0 eth1
>>   brctl delif br0 eth0
>> In this case, kernel should delete the user-added entry aa:bb:cc:dd:ee:ff,
>> but it also should have been added by "brctl addif br0 eth1" originally,
>> so we don't delete it and treat it a new kernel-created entry.
>>
> 
> I was looking over my patch series that adds something similar to this
> and noticed that you are not handing the NTF_USE case.  That case was
> always troublesome for me as it allows for 2 different way to create
> the same FDB: one through br_fdb_update() and one through fdb_add_entry().
> 
> It is possible, though I haven't found any users yet, that NTF_USE
> may be used and in that case, bridge will create a dynamic fdb and
> disregard all NUD flags.  In case case, add_by_user will not be set
> either.
> 
> I think that the above is broken and plan to submit a fix shortly.

Just looked again at my NTF_USE patch and while it seems ok, the whole
NTF_USE usage is racy to begin with and I am really starting to question
it's validity.

Presently, br_fdb_update() will not update local fdb entries.   Instead
it will log a misleading warning...  It will only let you update
non-local entries.  This is fine for user-created entries, but any
operation on dynamically created entries will only persist until
the next packet.  It also races against the packet, so there is
absolutely no guarantee that the values of fdb->dst and fdb->updated
will be consistent..

It seems to me that the update capability of NTF_USE would actually be
of more value on local or user-created fdb entries.

The fdb creation capability of NTF_USE should be disabled.

Thoughts?

-vlad


> 
> Thanks
> -vlad
> 
>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>> ---
>>  net/bridge/br_fdb.c     | 5 ++++-
>>  net/bridge/br_private.h | 1 +
>>  2 files changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
>> index 33e8f23..5dab230 100644
>> --- a/net/bridge/br_fdb.c
>> +++ b/net/bridge/br_fdb.c
>> @@ -104,7 +104,7 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
>>  			struct net_bridge_fdb_entry *f;
>>  
>>  			f = hlist_entry(h, struct net_bridge_fdb_entry, hlist);
>> -			if (f->dst == p && f->is_local) {
>> +			if (f->dst == p && f->is_local && !f->added_by_user) {
>>  				/* maybe another port has same hw addr? */
>>  				struct net_bridge_port *op;
>>  				u16 vid = f->vlan_id;
>> @@ -247,6 +247,7 @@ void br_fdb_delete_by_port(struct net_bridge *br,
>>  					    ether_addr_equal(op->dev->dev_addr,
>>  							     f->addr.addr)) {
>>  						f->dst = op;
>> +						f->added_by_user = 0;
>>  						goto skip_delete;
>>  					}
>>  				}
>> @@ -397,6 +398,7 @@ static struct net_bridge_fdb_entry *fdb_create(struct hlist_head *head,
>>  		fdb->vlan_id = vid;
>>  		fdb->is_local = 0;
>>  		fdb->is_static = 0;
>> +		fdb->added_by_user = 0;
>>  		fdb->updated = fdb->used = jiffies;
>>  		hlist_add_head_rcu(&fdb->hlist, head);
>>  	}
>> @@ -648,6 +650,7 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
>>  
>>  		modified = true;
>>  	}
>> +	fdb->added_by_user = 1;
>>  
>>  	fdb->used = jiffies;
>>  	if (modified) {
>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>> index 045d56e..91fb2c2 100644
>> --- a/net/bridge/br_private.h
>> +++ b/net/bridge/br_private.h
>> @@ -104,6 +104,7 @@ struct net_bridge_fdb_entry
>>  	mac_addr			addr;
>>  	unsigned char			is_local;
>>  	unsigned char			is_static;
>> +	unsigned char			added_by_user;
>>  	__u16				vlan_id;
>>  };
>>  
>>
> 
