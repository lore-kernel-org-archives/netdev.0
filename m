From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 64081] New: mdiobus_read fail and return -110 when called
 from get_phy_id  r6040: 0000:00:08.0 failed to register MII bus
Date: Wed, 30 Oct 2013 11:23:48 -0700
Message-ID: <20131030112348.58ceec8a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:53033 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590Ab3J3SXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 14:23:51 -0400
Received: by mail-pb0-f48.google.com with SMTP id mc17so1750247pbc.35
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 11:23:51 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id hz10sm42811404pbc.36.2013.10.30.11.23.50
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 30 Oct 2013 11:23:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 30 Oct 2013 11:10:47 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 64081] New: mdiobus_read fail and return -110 when called from get_phy_id  r6040: 0000:00:08.0 failed to register MII bus


https://bugzilla.kernel.org/show_bug.cgi?id=64081

            Bug ID: 64081
           Summary: mdiobus_read fail and return -110 when called from
                    get_phy_id  r6040: 0000:00:08.0 failed to register MII
                    bus
           Product: Networking
           Version: 2.5
    Kernel Version: 3.10.17
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: nils.koehler@ibt-interfaces.de
        Regression: No

I have tracked down an issue I have to get the device driver r6040.c to run on
Kernel 3.10.17.

It fails called get_phy_id.
In fails sometimes randomly on a phy id between 0 and 31.

the chance to get the error is 50% in my case after insmod r6040.ko

The error is caused by the following function:

int mdiobus_read(struct mii_bus *bus, int addr, u32 regnum)
{
    int retval;

    BUG_ON(in_interrupt());

    mutex_lock(&bus->mdio_lock);
    retval = bus->read(bus, addr, regnum);
    mutex_unlock(&bus->mdio_lock);

printk(KERN_INFO "IBT Debug 1 mdiobus_read retval:%d addr:%d
regnum:%d\n",retval,addr,regnum);

    return retval;
}
EXPORT_SYMBOL(mdiobus_read);

I have added a debug trace and in case of failure retval returns -110

This cause a break in get_phy_id flow and driver init fully fails because it
returns the an -EIO 

I saw that the real existing phy id 1 in my case always was propper detected
but the feeding loop try to init up to 31 Phy's and mostly one of them fail.

-- 
You are receiving this mail because:
You are the assignee for the bug.
