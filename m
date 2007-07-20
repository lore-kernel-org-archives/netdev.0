From: Patrick McHardy <kaber@trash.net>
Subject: [ofa-general] Re: [PATCH 03/10] dev.c changes.
Date: Fri, 20 Jul 2007 13:20:37 +0200
Message-ID: <46A09A85.7020500@trash.net>
References: <OFC586F180.42DDCDC5-ON6525731E.0038D792-6525731E.00397615@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, davem@davemloft.net, sri@us.ibm.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <OFC586F180.42DDCDC5-ON6525731E.0038D792-6525731E.00397615@in.ibm.com>
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

Krishna Kumar2 wrote:
> Hi Patrick,
>
> Thanks for your comments.
>
> Patrick McHardy <kaber@trash.net> wrote on 07/20/2007 03:34:30 PM:
>
>   
>> The queue length can be changed through multiple interfaces, if that
>> really is important you need to catch these cases too.
>>     
>
> I have a TODO comment in net-sysfs.c which is to catch this case.
>   

I noticed that. Still wondering why it is important at all though.

>   
>>> +      } else {
>>> +         dev->skb_blist = kmalloc(sizeof *dev->skb_blist,
>>> +                   GFP_KERNEL);
>>>       
>> Why not simply put the head in struct net_device? It seems to me that
>> this could also be used for gso_skb.
>>     
>
> Without going into GSO, it is wasting some 32 bytes on i386 since most
> drivers don't export this API.
>   

32 bytes? I count 16, - 4 for the pointer, so its 12 bytes of waste.
If you'd use it for gso_skb it would come down to 8 bytes. struct
net_device is a pig already, and there are better ways to reduce this
than starting to allocating single members with a few bytes IMO.

>   
>> Queue purging should be done in dev_deactivate.
>>     
>
> I originally had it in dev_deactivate, but when I did a ifdown eth0, ifup
> eth0,
> the system panic'd. The first solution I thought was to initialize the
> skb_blist
> in dev_change_flags() rather than in register_netdev(), but then felt that
> a
> series of ifup/ifdown will unnecessarily check stuff/malloc/free/initialize
> stuff,
> and so thought of putting it in unregister_netdev (where it is balanced
> with
> register_netdev).
>
> Is there any reason to move this ?
>   

Yes, packets can be holding references to various stuff and
these should be released on device down. As I said above I
don't really like the allocation, but even if you want to
keep it, just do the purging and dev_deactivate and keep the
freeing in unregister_netdev (actually I guess it should be
free_netdev to handle register_netdevice errors).
