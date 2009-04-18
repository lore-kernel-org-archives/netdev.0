From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH 1/3] net: introduce a list of device addresses
	dev_addr_list (v3)
Date: Sat, 18 Apr 2009 09:01:52 +0200
Message-ID: <20090418070151.GA3370@psychotron.englab.brq.redhat.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090415081720.GA21342@psychotron.englab.brq.redhat.com> <20090415081819.GB21342@psychotron.englab.brq.redhat.com> <20090415180215.GA22540@psychotron.englab.brq.redhat.com> <20090417115723.GE9556@psychotron.englab.brq.redhat.com> <20090417083315.2f089755@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, davem@davemloft.net,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, kaber@trash.net,
	mschmidt@redhat.com, dada1@cosmosbay.com, ivecera@redhat.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42332 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753095AbZDRHDW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Apr 2009 03:03:22 -0400
Content-Disposition: inline
In-Reply-To: <20090417083315.2f089755@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 17, 2009 at 05:33:15PM CEST, shemminger@vyatta.com wrote:

<snip>

>> +struct netdev_hw_addr {
>> +	struct list_head	list;
>> +	unsigned char		addr[MAX_ADDR_LEN];
>> +	int			refcount;
>> +	struct rcu_head		rcu_head;
>> +};
>
>Minor nit, the ordering of elements cause holes that might not be
>needed.

Agree that ordering might be done better. Will do.
>
>Space saving? is rcu_head needed or would using synchronize_net
>make code cleaner and save space. 
>

Well I originaly had this done by synchronize_rcu(). Eric argued that it might
cause especially __hw_addr_del_multiple_ii() to run long and suggested to use
call_rcu() instead. I plan to switch this to kfree_rcu() (or whatever it's
called) once it hits the tree.

<snip>

>> +	ha = kzalloc(max(sizeof(*ha), L1_CACHE_BYTES), GFP_ATOMIC);
>> +	if (!ha)
>> +		return -ENOMEM;
>Since you are initializing all fields, kzalloc isn't really needed

Noted.
>
>> +	memcpy(ha->addr, addr, addr_len);
>> +	ha->refcount = 1;
>> +	list_add_tail_rcu(&ha->list, list);
>> +	return 0;
>> +}

<snip>

>> +static void dev_addr_flush(struct net_device *dev)
>> +{
>> +	ASSERT_RTNL();
>> +
>Since this is local you should be able to audit all
>the callers and remove this ASSERT.

Okay. I will at least put a comment instead of this.
>
>> +	__hw_addr_flush(&dev->dev_addr_list);
>> +	dev->dev_addr = NULL;
>> +}
>> +
>> +static int dev_addr_init(struct net_device *dev)
>> +{
>> +	unsigned char addr[MAX_ADDR_LEN];
>> +	struct netdev_hw_addr *ha;
>> +	int err;
>> +
>> +	ASSERT_RTNL();
>Ditto, ASSERT_RTNL makes sense for exposed kernel API and
>initial testing.
>
>> +	INIT_LIST_HEAD(&dev->dev_addr_list);
>> +	memset(addr, 0, sizeof(*addr));
>> +	err = __hw_addr_add(&dev->dev_addr_list, addr, sizeof(*addr));
>> +	if (!err) {
>> +		/*
>> +		 * Get the first (previously created) address from the list
>> +		 * and set dev_addr pointer to this location.
>> +		 */
>> +		ha = list_first_entry(&dev->dev_addr_list,
>> +				      struct netdev_hw_addr, list);
>> +		dev->dev_addr = ha->addr;
>> +	}
>> +	return err;
>> +}

<snip>

