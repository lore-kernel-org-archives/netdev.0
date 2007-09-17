From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] Re: [PATCH v2] iw_cxgb3: Support "iwarp-only"
 interfaces to avoid 4-tuple conflicts.
Date: Mon, 17 Sep 2007 10:25:04 -0500
Message-ID: <46EE9C50.7070406@opengridcomputing.com>
References: <20070913191617.30937.95960.stgit@dell3.ogc.int>
	<20070914130941.GG18517@2ka.mipt.ru>
	<46EC00BE.3020801@opengridcomputing.com>
	<20070916142241.GA26848@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org,
	linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070916142241.GA26848@2ka.mipt.ru>
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



Evgeniy Polyakov wrote:
> Hi Steve.
> 
> On Sat, Sep 15, 2007 at 10:56:46AM -0500, Steve Wise (swise@opengridcomputing.com) wrote:
>>>> The iWARP driver must translate all listens on address 0.0.0.0 to the
>>>> set of rdma-only ip addresses for the device in question.  This prevents
>>>> incoming connect requests to the TCP ipaddresses from going up the
>>>> rdma stack.
>>> If the only solutions to solve a problem with hardware are to steal
>>> packets or became a real device, then real device is much more
>>> appropriate. Is that correct?
>>>
>> This is a real device.  I don't understand your question?  Packets 
>> aren't being stolen.
> 
> I meant port from main network stack. Sorry for confusion.
> 
>>>> +static void insert_ifa(struct iwch_dev *rnicp, struct in_ifaddr *ifa)
>>>> +{
>>>> +	struct iwch_addrlist *addr;
>>>> +
>>>> +	addr = kmalloc(sizeof *addr, GFP_KERNEL);
>>> As a small nitpick: this wants to be sizeof(struct in_ifaddr)
>>>
>> No, insert_ifa() allocates a struct iwch_addrlist, which has 2 fields: a 
>> list_head for linking, and a struct in_ifaddr pointer.
> 
> sizeof(struct iwch_addrlist) of course, not (*addr).
> To simplify grep.
>  
>>>> +	if (!addr) {
>>>> +		printk(KERN_ERR MOD "%s - failed to alloc memory!\n",
>>>> +		       __FUNCTION__);
>>>> +		return;
>>>> +	}
>>>> +	addr->ifa = ifa;
>>>> +	mutex_lock(&rnicp->mutex);
>>>> +	list_add_tail(&addr->entry, &rnicp->addrlist);
>>>> +	mutex_unlock(&rnicp->mutex);
>>>> +}
>>> What about providing error back to caller and fail to register?
>>>
>> There are two causes where this is called: 1) during module init to 
>> populate the list of iwarp addresses.  If we failed in that case then, I 
>> _could_ then not register.  2) we get called via the notifier mechanism 
>> when an address is added.  If that fails, the caller doesn't care (since 
>> we're on the notifier callout thread).  But the code could perhaps 
>> unregister the device.  I prefer just logging an error in case 2.  I'll 
>> look into not registering if we cannot get any address due to lack of 
>> memory.  But there's another case:  we load the module and the admin 
>> hasn't yet created the ethX:iw interface.
>>
>> Perhaps I should change the code to only register as a working rdma 
>> device _when_ we get at least one ethX:iwY interface created?  Whatchathink?
> 
> Does second case ends up with problem you described in the initial
> e-mail not being fixed?

No, the 2nd case (a failure to get the list of iwarp-only ip addresses) 
will cause rdma apps to not receive any incoming connections.

Consider we have eth1 with 1.1.1.1/24.  Next, the admin creates the 
iwarp interface thusly:

ifconfig eth1:iw 2.2.2.2 netmask 255.255.255.0 up

The iw_cxgb3 driver gets a netblock notifier event for the addition of 
the eth1:iw interface, but FAILS to alloc the memory to keep track that 
2.2.2.2 is the iwarp-only address.

Next an rdma app binds to 0.0.0.0, port X.  The iw_cxgb3 attempts to map 
0.0.0.0 to the set of valid iwarp addresses, but there are none. 
iw_cxgb3 logs a warning saying no addresses are available.  The 
application ends up not listening to any address.

So TCP apps aren't affected.

Also, if the admin notes the error log entry, and re-initializes the 
eth1:iw interface -and- this time the kmalloc() works, then the existing 
rdma app bound to 0.0.0.0 port X will then start receiving connect 
requests to 2.2.2.2 port X.

Hope this makes sense.

>  
>>>> +static inline int is_iwarp_label(char *label)
>>>> +{
>>>> +	char *colon;
>>>> +
>>>> +	colon = strchr(label, ':');
>>>> +	if (colon && !strncmp(colon+1, "iw", 2))
>>>> +		return 1;
>>>> +	return 0;
>>>> +}
>>> I.e. it is not allowed to create ':iw' alias for anyone else?
>>> Well, looks crappy, but if it is the only solution...
>>>
>> It is kinda crappy.  But I don't see a better solution.  Any ideas?
> 
> Does creating the whole new netdevice is a too big overhead, or is it
> considered bad idea?

I think its too big overhead, and pretty invasive on the low level cxgb3 
driver.  I think having a device in the 'ifconfig -a' after iw_cxgb3 is 
loaded and devices discovered would be a good thing for the admin.  This 
is the angle Roland suggested.  I'm just not sure how to implement it.

But if someone could explain how I might create this full netdevice as a 
pseudo device on top of the real one, maybe I could implement it.

Note that non TCP traffic still needs to utilize this interface for ND 
to work properly with the RDMA core.


> 
>>>> +static struct iwch_listen_entry *alloc_listener(struct iwch_listen_ep 
>>>> *ep,
>>>> +						  __be32 addr)
>>> Do you know, that cxgb3 function names suck? :)
>>> Especially get_skb().
>>>
>>>> +{
>>>> +	struct iwch_dev *h = to_iwch_dev(ep->com.cm_id->device);
>>>> +	struct iwch_listen_entry *le;
>>>> +
>>>> +	le = kmalloc(sizeof *le, GFP_KERNEL);
>>> Wants to be sizeof(struct iwch_listen_entry) and in other places too.
>>>
>> Do you mean I shouldn't use sizeof *le, but rather sizeof(struct 
>> iwch_listen_entry)?  Is that the preferred coding style?
> 
> Yes, exactly.
>

Ok, now I get it. :)


Steve.
