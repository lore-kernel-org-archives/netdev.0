From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: [ofa-general] Re: [PATCH V3 0/7] net/bonding: ADD IPoIB support
 for	the	bonding driver
Date: Tue, 31 Jul 2007 17:57:46 +0300
Message-ID: <46AF4DEA.9050202@voltaire.com>
References: <46ADDB89.5030601@voltaire.com>
	<adaejipr3l5.fsf@cisco.com>	<46AF3CA8.6050201@gmail.com>	<20070731140436.GA16015@mellanox.co.il>	<46AF44E0.50700@voltaire.com>	<20070731142234.GC16015@mellanox.co.il>	<46AF48D5.9000502@voltaire.com>
	<20070731144827.GB17331@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>, fubar@us.ibm.com,
	davem@davemloft.net, general@lists.openfabrics.org
To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070731144827.GB17331@mellanox.co.il>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Michael S. Tsirkin wrote:
>> Quoting Or Gerlitz <ogerlitz@voltaire.com>:
>> Michael S. Tsirkin wrote:

>>> It's always wrong to copy symbols from another module without
>>> referencing it.
>> Its the --first-- time you make this comment,

> It's really a well known fact. That's where the crash
> with modprobe -r comes from, right?

no, the crash --only-- comes from the neighbour cleanup function being 
called while ipoib is now probed out of the kernel. The other symbols 
are not problematic. I got positive feedback that this --is-- the 
problem in the previous posts and from Roland during my Sonoma presentation.

>> please suggest a different approach,

> I don't know, really - if you want to access a module, you really must get
> a reference to it, or to the device.
> How about adding the module pointer to struct net_device?

I think there used to be there owner field of type struct module and it 
was removed... we will check that.

>> the relevant code is below.
> 
>> +static void bond_setup_by_slave(struct net_device *bond_dev,
>> +				struct net_device *slave_dev)
>> +{
>> +	bond_dev->hard_header	        = slave_dev->hard_header;
>> +	bond_dev->rebuild_header        = slave_dev->rebuild_header;
>> +	bond_dev->hard_header_cache	= slave_dev->hard_header_cache;
>> +	bond_dev->header_cache_update   = slave_dev->header_cache_update;
>> +	bond_dev->hard_header_parse	= slave_dev->hard_header_parse;
>> +
>> +	bond_dev->neigh_setup           = slave_dev->neigh_setup;
>> +
>> +	bond_dev->type		    = slave_dev->type;
>> +	bond_dev->hard_header_len   = slave_dev->hard_header_len;
>> +	bond_dev->addr_len	    = slave_dev->addr_len;
>> +
>> +	memcpy(bond_dev->broadcast, slave_dev->broadcast,
>> +		slave_dev->addr_len);
>> +}
>> +
> 
> Hmm, it seems that switching to hard_header_cache as I suggested won't help at all.

why? please clarify.

> I wonder: is bonding currently broken with devices that implement
> hard_header_cache/header_cache_update?

I don't think so. Note that bond_setup_by_slave is only called for 
slaves whose ether type is --not-- Ethernet.

Or.
