From: Holger brunck <holger.brunck@keymile.com>
Subject: Re: powerpc, fs_enet: scanning PHY after Linux is up
Date: Fri, 08 Oct 2010 10:50:50 +0200
Message-ID: <4CAEDB6A.70600@keymile.com>
References: <4CA9830A.2030605@denx.de> <AANLkTinSersREjDnvg=8Gvpa6YmLuzgF1H8eEXRyCpW0@mail.gmail.com><4CAC472F.5070001@denx.de>
	 <AANLkTi=GkkD_-Vu-NswNedhgVuPaYePOHWa_2ytQgMf_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hs@denx.de, linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, Detlev Zundel <dzu@denx.de>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.de.keymile.com ([195.8.104.1]:37808 "HELO
	mail.de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756234Ab0JHIvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 04:51:14 -0400
In-Reply-To: <AANLkTi=GkkD_-Vu-NswNedhgVuPaYePOHWa_2ytQgMf_@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Grant,

On 10/06/2010 06:52 PM, Grant Likely wrote:
> On Wed, Oct 6, 2010 at 3:53 AM, Heiko Schocher <hs@denx.de> wrote:
>>>> So, the question is, is there a possibility to solve this problem?
>>>>
>>>> If there is no standard option, what would be with adding a
>>>> "scan_phy" file in
>>>>
>>>> /proc/device-tree/soc\@f0000000/cpm\@119c0/mdio\@10d40
>>>> (or better destination?)
>>>>
>>>> which with we could rescan a PHY with
>>>> "echo addr > /proc/device-tree/soc\@f0000000/cpm\@119c0/mdio\@10d40/scan_phy"
>>>> (so there is no need for using of_find_node_by_path(), as we should
>>>>  have the associated device node here, and can step through the child
>>>>  nodes with "for_each_child_of_node(np, child)" and check if reg == addr)
>>>>
>>>> or shouldn;t be at least, if the phy couldn;t be found when opening
>>>> the port, retrigger a scanning, if the phy now is accessible?
>>>
>>> One option would be to still register a phy_device for each phy
>>> described in the device tree, but defer binding a driver to each phy
>>> that doesn't respond.  Then at of_phy_find_device() time, if it
>>
>> Maybe I din;t get the trick, but the problem is, that
>> you can;t register a phy_device in drivers/of/of_mdio.c
>> of_mdiobus_register(), if the phy didn;t respond with the
>> phy_id ... and of_phy_find_device() is not (yet) used in fs_enet
> 
> I'm suggesting modifying the phy layer so that it is possible to
> register a phy_device that doesn't (yet) respond.
> 

yes this sounds reasonable.

>>> matches with a phy_device that isn't bound to a driver yet, then
>>> re-trigger the binding operation.  At which point the phy id can be
>>> probed and the correct driver can be chosen.  If binding succeeds,
>>> then return the phy_device handle.  If not, then fail as it currently
>>> does.
>>
>> Wouldn;t it be good, just if we need a PHY (on calling fs_enet_open)
>> to look if there is one?
>>
>> Something like that (not tested):
>>
>> in drivers/net/fs_enet/fs_enet-main.c in fs_init_phy()
>> called from fs_enet_open():
>>
>> Do first:
>> phydev =  of_phy_find_device(fep->fpi->phy_node);
>>
>> Look if there is a driver (phy_dev->drv == NULL ?)
>>
>> If not, call new function
>> of_mdiobus_register_phy(mii_bus, fep->fpi->phy_node)
>> see below patch for it.
>>
>> If this succeeds, all is OK, and we can use this phy,
>> else ethernet not work.
> 
> I don't like this approach because it muddies the concept of which
> device is actually responsible for managing the phys on the bus.  Is
> it managed by the mdio bus device or the Ethernet device?  It also has
> a potential race condition.  Whereas triggering a late driver bind
> will be safe.
> 
> Alternately, I'd also be okay with a common method to trigger a
> reprobe of a particular phy from userspace, but I fear that would be a
> significantly more complex solution.
> 
>>
>> !!just no idea, how to get mii_bus pointer ...
> 
> You'd have to get the parent of the phy node, and then loop over all
> the registered mdio busses looking for a bus that uses that node.
> 

you say that you don't like the approach to probe the phy again in fs_enet_open,
but currently I don't understand what would be the alternate trigger point to
rescan the mdio bus?

I made a first patch to enhance the phy_device structure and rescan the mdio bus
at time of fs_enet_open (because I didn't see a better trigger point). The
advantage is that we got the mii_bus pointer and the phy addr stored in the
already created phy device structure and is therefore easy to use. See the patch
below for this modifications. Whats currently missing in the patch is to set the
phy_id if the phy was scanned later after phy_device creation. For the mgcoge
board it seems to solve our problem, but maybe I miss something important.

Best regards
Holger Brunck

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index ec2f503..6bc117f 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -775,7 +774,8 @@ static int fs_enet_open(struct net_device *dev)
 {
        struct fs_enet_private *fep = netdev_priv(dev);
        int r;
-       int err;
+       int err = 0;
+       u32 phy_id = 0;

        /* to initialize the fep->cur_rx,... */
        /* not doing this, will cause a crash in fs_enet_rx_napi */
@@ -795,13 +795,23 @@ static int fs_enet_open(struct net_device *dev)
                return -EINVAL;
        }

-       err = fs_init_phy(dev);
-       if (err) {
+       if (fep->phydev == NULL)
+               err = fs_init_phy(dev);
+
+       if (!err && (fep->phydev->available == false))
+               r = get_phy_id(fep->phydev->bus, fep->phydev->addr, &phy_id);
+
+       if (err || (phy_id == 0xffffffff)) {
                free_irq(fep->interrupt, dev);
                if (fep->fpi->use_napi)
                        napi_disable(&fep->napi);
-               return err;
+               if (err)
+                       return err;
+               else
+                       return -EINVAL;
        }
+       else
+               fep->phydev->available = true;
        phy_start(fep->phydev);

        netif_start_queue(dev);
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index adbc0fd..1f443cb 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -173,6 +173,10 @@ struct phy_device* phy_device_create(struct mii_bus *bus,
int addr, int phy_id)
        dev->dev.bus = &mdio_bus_type;
        dev->irq = bus->irq != NULL ? bus->irq[addr] : PHY_POLL;
        dev_set_name(&dev->dev, PHY_ID_FMT, bus->id, addr);
+       if (phy_id == 0xffffffff)
+               dev->available = false;
+       else
+               dev->available = true;

        dev->state = PHY_DOWN;

@@ -232,13 +236,11 @@ struct phy_device * get_phy_device(struct mii_bus *bus,
int addr)
        int r;

        r = get_phy_id(bus, addr, &phy_id);
-       if (r)
-               return ERR_PTR(r);

        /* If the phy_id is mostly Fs, there is no device there */
-       if ((phy_id & 0x1fffffff) == 0x1fffffff)
-               return NULL;
-
+       if (((phy_id & 0x1fffffff) == 0x1fffffff) || r)
+               phy_id = 0xffffffff;
+       /* create phy even if the phy is currently not available */
        dev = phy_device_create(bus, addr, phy_id);

        return dev;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 6a7eb40..12dc3e4 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -303,6 +303,9 @@ struct phy_device {

        int link_timeout;

+       /* Flag to support delayed availability */
+       bool available;
+
        /*
         * Interrupt number for this PHY
         * -1 means no interrupt

