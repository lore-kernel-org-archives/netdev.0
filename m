From: "Jay Vosburgh" <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] Re: Bonding driver unreliable under high CPU load
Date: Tue, 17 Sep 2002 13:01:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF5FEED16C.9C2ED639-ON88256C37.006CA80A@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Cureington, Tony" <tony.cureington@hp.com>,
   Andrew Morton <akpm@digeo.com>,
   Pascal Brisset <pascal.brisset-ml@wanadoo.fr>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



      Well, now that it's been pointed out to me, that does look pretty
grotty.  It works because MII_LINK_READY is defined to be 4, and the return
from bond_check_dev_link() is always a bitwise test against MII_LINK_READY,
so it works.  Could be cleaner, though.

      As far as netif_carrier_ok() goes, is it reliable?  In looking at the
drivers, it appears that some don't update the flag (e.g., 3c59x.c).

      -J


Jeff Garzik <jgarzik@mandrakesoft.com>@lists.sourceforge.net on 09/17/2002
12:45:57 PM

Sent by:    bonding-devel-admin@lists.sourceforge.net


To:    "Cureington, Tony" <tony.cureington@hp.com>
cc:    Andrew Morton <akpm@digeo.com>, Pascal Brisset
       <pascal.brisset-ml@wanadoo.fr>, bonding-devel@lists.sourceforge.net,
       netdev@oss.sgi.com
Subject:    Re: [Bonding-devel] Re: Bonding driver unreliable under high
       CPU load



Cureington, Tony wrote:
>                 /* Yes, the mii is overlaid on the ifreq.ifr_ifru */
>                 mii = (struct mii_ioctl_data *)&ifr.ifr_data;
>                 if (ioctl(dev, &ifr, SIOCGMIIPHY) != 0) {
>                         return MII_LINK_READY;   /* can't tell */
>                 }
>
>                 mii->reg_num = 1;
>                 if (ioctl(dev, &ifr, SIOCGMIIREG) == 0) {
>                         /*
>                          * mii->val_out contains MII reg 1, BMSR
>                          * 0x0004 means link established
>                          */
>                         return mii->val_out;
>                 }


Speaking of bonding, I wonder about the above code -- why do you return
mii->val_out directly?  AFAICS you should test BMSR_LSTATUS (a.k.a.
0x0004) and return MII_LINK_READY or zero -- not a bunch of random bits.

The status word can certainly be non-zero even when link is absent.

Also, a further question:  do you have access to the slave struct
net_device?  If so, just test netif_carrier_ok(slave_dev) and avoid all
that ioctl calling if it returns non-zero.

 Jeff





-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
Bonding-devel mailing list
Bonding-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/bonding-devel
