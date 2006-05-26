From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 2/3] pci: bcm43xx avoid pci_find_device
Date: Fri, 26 May 2006 12:32:36 +0159
Message-ID: <4476D95B.5030601@gmail.com>
References: <20060526001053.D2349C7C58@atrey.karlin.mff.cuni.cz> <44764D4B.6050105@pobox.com> <4476D63E.8090207@gmail.com> <4476D6EC.4060501@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org,
	mb@bu3sch.de, st3@riseup.net, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:57999 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751379AbWEZKdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 06:33:21 -0400
Received: by nf-out-0910.google.com with SMTP id h2so34085nfe
        for <netdev@vger.kernel.org>; Fri, 26 May 2006 03:33:20 -0700 (PDT)
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4476D6EC.4060501@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Jeff Garzik napsal(a):
> Jiri Slaby wrote:
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA1
>>
>> Jeff Garzik napsal(a):
>>> Jiri Slaby wrote:
>>>> bcm43xx avoid pci_find_device
>>>>
>>>> Change pci_find_device to safer pci_get_device with support for more
>>>> devices.
>>>>
>>>> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
>>>>
>>>> ---
>>>> commit 1d3b6caf027fe53351c645523587aeac40bc3e47
>>>> tree ae37c86b633442cdf8a7a19ac287542724081c90
>>>> parent ab3443d79c94d0ae6a9e020daefa4d29eccff50d
>>>> author Jiri Slaby <ku@bellona.localdomain> Fri, 26 May 2006 01:49:12
>>>> +0159
>>>> committer Jiri Slaby <ku@bellona.localdomain> Fri, 26 May 2006
>>>> 01:49:12 +0159
>>>>
>>>>  drivers/net/wireless/bcm43xx/bcm43xx_main.c |   20
>>>> ++++++++++++++++----
>>>>  1 files changed, 16 insertions(+), 4 deletions(-)
>>>>
>>>> diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
>>>> b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
>>>> index b488f77..56d2fc6 100644
>>>> --- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
>>>> +++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
>>>> @@ -2131,6 +2131,13 @@ out:
>>>>      return err;
>>>>  }
>>>>  
>>>> +#ifdef CONFIG_BCM947XX
>>>> +static struct pci_device_id bcm43xx_ids[] = {
>>>> +    { PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, 0x4324) },
>>>> +    { 0 }
>>>> +};
Table is here ^^^. You just add an entry, and that's it.
>>>> +#endif
>>>> +
>>>>  static int bcm43xx_initialize_irq(struct bcm43xx_private *bcm)
>>>>  {
>>>>      int res;
>>>> @@ -2141,10 +2148,15 @@ static int bcm43xx_initialize_irq(struct
>>>>  #ifdef CONFIG_BCM947XX
>>>>      if (bcm->pci_dev->bus->number == 0) {
>>>>          struct pci_dev *d = NULL;
>>>> -        /* FIXME: we will probably need more device IDs here... */
>>>> -        d = pci_find_device(PCI_VENDOR_ID_BROADCOM, 0x4324, NULL);
>>>> -        if (d != NULL) {
>>>> -            bcm->irq = d->irq;
>>>> +        struct pci_device_id *id = bcm43xx_ids;
>>>> +        while (id->vendor) {
>>>> +            d = pci_get_device(id->vendor, id->device, NULL);
>>>> +            if (d != NULL) {
>>>> +                bcm->irq = d->irq;
>>>> +                pci_dev_put(d);
>>>> +                break;
>>> You'll want to use pci_match_device() or pci_match_one_device()
>>> [I forget which one]
>> Why? Matching is done by pci_get_device() or pci_get_subsys(),
>> respectively.
>> [pci_match_device() is for matching dev <-> drv, you meant
>> pci_match_one_device()]
> 
> The FIXME says "we will probably need more device IDs here."
Yup.
> 
> Thus, if you are touching this area, it would make sense to add the
> capability to easily add a second (and third, fourth...) PCI ID.  And
> that means pci_match_one_device() and a pci_device_id table.
But the while loop do the work: unless id->vendor != NULL, do the matching with
the current raw (id) of the table, then jump to the next raw (id++).

pci_get_device returns NULL if the device with id->vendor, id->device wasn't
found, then we try next raw, otherwise, we break the loop.

Implementations before and now do the same strangeness -- assume there is only
one device (?shouldn't matter?, since it is embedded).

cheers,
- --
Jiri Slaby         www.fi.muni.cz/~xslaby
\_.-^-._   jirislaby@gmail.com   _.-^-._/
B67499670407CE62ACC8 22A032CC55C339D47A7E
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFEdtlbMsxVwznUen4RAo/OAJsHy6sED+a9QYmbcaGTMUjwSYm4vACgwfQL
GhmfbtwskPB3Dnvw8HfJzpE=
=+kxv
-----END PGP SIGNATURE-----
