From: Moni Shoua <monisonlists@gmail.com>
Subject: Re: [ofa-general] Re: [PATCH V4 10/10] net/bonding: Destroy bonding
	master when last slave is gone
Date: Sun, 02 Sep 2007 14:32:53 +0300
Message-ID: <46DA9F65.2020201@gmail.com>
References: <46C9B474.5020202@voltaire.com> <46C9BA2D.7060204@voltaire.com>
	<3403.1188343986@death> <46D57D5D.3060706@gmail.com>
	<16908.1188417014@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, davem@davemloft.net, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <16908.1188417014@death>
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

Jay Vosburgh wrote:
> Moni Shoua <monisonlists@gmail.com> wrote:
> 
>> Jay Vosburgh wrote:
>>> Moni Shoua <monis@voltaire.com> wrote:
>>>
>>>> When bonding enslaves non Ethernet devices it takes pointers to functions 
>>>> in the module that owns the slaves. In this case it becomes unsafe
>>>> to keep the bonding master registered after last slave was unenslaved 
>>>> because we don't know if the pointers are still valid.  Destroying the bond when slave_cnt is zero
>>>> ensures that these functions be used anymore.
>>> 	Would it not be simpler to run the bonding master through
>>> ether_setup() again when the final slave is released (to reset all of
>>> the pointers to their "ethernet" values)?  I'm presuming here the
>>> pointers of questionable validity are the ones set in the
>>> bond_setup_by_slave() copied from the slave_dev->hard_header, et al.
>>>
>>> 	Having the bonding master disappear (but only sometimes) after
>>> the last slave is removed is a semantic change I'd rather not introduce
>>> if it's not necessary.
>> Thanks for the comments.
>>
>> Having the master disappear is one way I could think of to solve the problem of leaving
>> the bonding module with pointers to illegal addresses.
>> The other way is to increase the usage count, with try_module_get(), of the module which owns of the slave.
>> To do that I  have to restore the field  owner in structure net_device (it was removed in 2.6).
> 
> 	What I was asking above is really whether or not it's feasible
> to simply reset the affected pointers back to the "ethernet" values from
> ether_setup().  I would think this should return the bonding master back
> to the original state it started in before any slaves were added.
> Unless I'm missing something; I'm willing to believe there's some
> IB-specific tidbit I'm unaware of that makes this more complicated than
> it seems.

It's possible to reset the bonding master by calling ether_setup but with one exception: its neighbors.
When enslaving IPoIB devices, the bonding master neighbors point to a destructor function in the ib_ipoib module.
When ib_ipoib goes down the neighbors of the bonding master still exist and when their turn come to die they will
try to access this function and the kernel will crash. This is why I want to destroy the bonding master before ib_ipoib
is unloaded (to kill its neighbors). For any other issue (i.e. taken pointer), ether_setup would solve the problem.

> 
> 	This presumes that I'm correct in thinking that the pointers
> you're talking about (as being unsafe after removal of last slave) are
> the ones copied in your new function bond_setup_by_slave().
> 
> 	I don't think it's desirable to acquire a reference to the slave
> driver module.
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 
