From: Holger brunck <holger.brunck-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>
Subject: Re: powerpc, fs_enet: scanning PHY after Linux is up
Date: Mon, 11 Oct 2010 13:49:11 +0200
Message-ID: <4CB2F9B7.8080201@keymile.com>
References: <4CA9830A.2030605@denx.de><AANLkTinSersREjDnvg=8Gvpa6YmLuzgF1H8eEXRyCpW0@mail.gmail.com><4CAC472F.5070001@denx.de><AANLkTi=GkkD_-Vu-NswNedhgVuPaYePOHWa_2ytQgMf_@mail.gmail.com><4CAEDB6A.70600@keymile.com>
	<20101008170615.GC3863@angua.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, hs-ynQEQJNshbs@public.gmane.org,
	Detlev Zundel <dzu-ynQEQJNshbs@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20101008170615.GC3863-MrY2KI0G/OVr83L8+7iqerDks+cytr/Z@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Grant,

On 10/08/2010 07:06 PM, Grant Likely wrote:
> On Fri, Oct 08, 2010 at 10:50:50AM +0200, Holger brunck wrote:
>>> On Wed, Oct 6, 2010 at 3:53 AM, Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org> wrote:
>>
>>>> Wouldn;t it be good, just if we need a PHY (on calling fs_enet_open)
>>>> to look if there is one?
>>>>
>>>> Something like that (not tested):
>>>>
>>>> in drivers/net/fs_enet/fs_enet-main.c in fs_init_phy()
>>>> called from fs_enet_open():
>>>>
>>>> Do first:
>>>> phydev =  of_phy_find_device(fep->fpi->phy_node);
>>>>
>>>> Look if there is a driver (phy_dev->drv == NULL ?)
>>>>
>>>> If not, call new function
>>>> of_mdiobus_register_phy(mii_bus, fep->fpi->phy_node)
>>>> see below patch for it.
>>>>
>>>> If this succeeds, all is OK, and we can use this phy,
>>>> else ethernet not work.
>>>
>>> I don't like this approach because it muddies the concept of which
>>> device is actually responsible for managing the phys on the bus.  Is
>>> it managed by the mdio bus device or the Ethernet device?  It also has
>>> a potential race condition.  Whereas triggering a late driver bind
>>> will be safe.
>>>
>>> Alternately, I'd also be okay with a common method to trigger a
>>> reprobe of a particular phy from userspace, but I fear that would be a
>>> significantly more complex solution.
>>>
>>>>
>>>> !!just no idea, how to get mii_bus pointer ...
>>>
>>> You'd have to get the parent of the phy node, and then loop over all
>>> the registered mdio busses looking for a bus that uses that node.
>>>
>>
>> you say that you don't like the approach to probe the phy again in fs_enet_open,
>> but currently I don't understand what would be the alternate trigger point to
>> rescan the mdio bus?
> 
> Same trigger point, but different operation.  At fs_enet_open time,
> instead of registering the phy_device, the phy layer could sanity
> check the already registered phy_device, and refuse to connect to it
> if the phy isn't responding.  If it is responding, then it could
> re-attempt binding a phy_driver to it (although I just realized that
> this has other problems, such as correct module loading.  See below)
> 

ok.

>> I made a first patch to enhance the phy_device structure and rescan the mdio bus
>> at time of fs_enet_open (because I didn't see a better trigger point). The
>> advantage is that we got the mii_bus pointer and the phy addr stored in the
>> already created phy device structure and is therefore easy to use. See the patch
>> below for this modifications. Whats currently missing in the patch is to set the
>> phy_id if the phy was scanned later after phy_device creation. For the mgcoge
>> board it seems to solve our problem, but maybe I miss something important.
>>
>> Best regards
>> Holger Brunck
>>
>> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
>> index ec2f503..6bc117f 100644
>> --- a/drivers/net/fs_enet/fs_enet-main.c
>> +++ b/drivers/net/fs_enet/fs_enet-main.c
>> @@ -775,7 +774,8 @@ static int fs_enet_open(struct net_device *dev)
>>  {
>>         struct fs_enet_private *fep = netdev_priv(dev);
>>         int r;
>> -       int err;
>> +       int err = 0;
>> +       u32 phy_id = 0;
>>
>>         /* to initialize the fep->cur_rx,... */
>>         /* not doing this, will cause a crash in fs_enet_rx_napi */
>> @@ -795,13 +795,23 @@ static int fs_enet_open(struct net_device *dev)
>>                 return -EINVAL;
>>         }
>>
>> -       err = fs_init_phy(dev);
>> -       if (err) {
>> +       if (fep->phydev == NULL)
>> +               err = fs_init_phy(dev);
>> +
>> +       if (!err && (fep->phydev->available == false))
>> +               r = get_phy_id(fep->phydev->bus, fep->phydev->addr, &phy_id);
>> +
>> +       if (err || (phy_id == 0xffffffff)) {
>>                 free_irq(fep->interrupt, dev);
>>                 if (fep->fpi->use_napi)
>>                         napi_disable(&fep->napi);
>> -               return err;
>> +               if (err)
>> +                       return err;
>> +               else
>> +                       return -EINVAL;
>>         }
>> +       else
>> +               fep->phydev->available = true;
>>         phy_start(fep->phydev);
>>
>>         netif_start_queue(dev);
>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>> index adbc0fd..1f443cb 100644
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
>> @@ -173,6 +173,10 @@ struct phy_device* phy_device_create(struct mii_bus *bus,
>> int addr, int phy_id)
>>         dev->dev.bus = &mdio_bus_type;
>>         dev->irq = bus->irq != NULL ? bus->irq[addr] : PHY_POLL;
>>         dev_set_name(&dev->dev, PHY_ID_FMT, bus->id, addr);
>> +       if (phy_id == 0xffffffff)
>> +               dev->available = false;
>> +       else
>> +               dev->available = true;
> 
> This flag shouldn't be necessary.  Just check whether or not
> phy_device->phy_id is sane at phy_attach_direct() time.  If it is
> mostly f's, then don't attach.
>

Yes, indeed it is unneeded. Thanks for pointing out.

>>
>>         dev->state = PHY_DOWN;
>>
>> @@ -232,13 +236,11 @@ struct phy_device * get_phy_device(struct mii_bus *bus,
>> int addr)
>>         int r;
>>
>>         r = get_phy_id(bus, addr, &phy_id);
>> -       if (r)
>> -               return ERR_PTR(r);
>>
>>         /* If the phy_id is mostly Fs, there is no device there */
>> -       if ((phy_id & 0x1fffffff) == 0x1fffffff)
>> -               return NULL;
>> -
>> +       if (((phy_id & 0x1fffffff) == 0x1fffffff) || r)
>> +               phy_id = 0xffffffff;
>> +       /* create phy even if the phy is currently not available */
>>         dev = phy_device_create(bus, addr, phy_id);
> 
> Cannot do it this way because many phylib users probe the bus for phys
> instead of the explicit creation used with the device tree.  There
> needs to be a method to explicitly skip this test when creating a phy;
> possibly by having the device tree code call phy_device_create()
> directly.
> 

Ah ok, every phy_device_create() call from of_mdiobus_register should skip this
test, because if a phy is described in the dts it is present (sooner or later)
and if phy_device_create is called from somewhere else I do this test as usual.
I adapted my patch accordingly.

> Hmmm.... I see another problem.  Deferred probing of the phy will
> potentially cause problems with module loading.  If the binding is
> deferred to phy connect time; then the phy driver may not have time to
> get loaded before the phy layer decides there is no driver and binds
> it to the generic one.  Blech.
> 
> Okay, so it seems like a method of explicitly triggering a phy_device
> rebind from userspace is necessary.  This could be done with a
> per-phy_device sysfs file I suppose.  Just an empty file that when
> read triggers a re-read of the phy id registers, and retries binding a
> driver, including the request_module call in phy_device_create().
> 

Okay I suspected that there is not an easy solution for our problem. Another
solution comes in my mind. If we defer the call to fs_enet_probe at startup. So
enhance the dts entry with something like an hotplug indication and then trigger
via an sysfs entry the call to fs_enet_probe if the phy is up... Other hotplug
devices should have similar problems...

However for our mgcoge board we can live with the fact that we can't load/unload
the driver dynamically. So I think we will go with this modified "out of tree"
patch for our board. Thanks for your support.

Best regards
Holger Brunck
