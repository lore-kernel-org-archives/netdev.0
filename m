From: Duncan Sands <duncan.sands@math.u-psud.fr>
Subject: Re: [Linux-ATM-General] [RFC][PATCH] Very basic sysfs support for ATM devices (updated)
Date: Mon, 7 Feb 2005 10:03:08 +0100
Message-ID: <200502071003.09211.duncan.sands@math.u-psud.fr>
References: <20050121085123.GA2471@katya> <200502041811.j14IBOna020338@ginger.cmf.nrl.navy.mil> <20050204201327.GA2439@katya>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Roman Kagan <rkagan@mail.ru>,
        chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>, netdev@oss.sgi.com,
        linux-atm-general@lists.sourceforge.net
To: usbatm@lists.infradead.org
In-Reply-To: <20050204201327.GA2439@katya>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Roman,

> Besides, I've encountered a problem with hotplug being called from
> atm_dev_register: the device actually becomes usable only when the
> driver sets .dev_data, which may happen after hotplug has been called.
> E.g. if I call br2684ctl in my hotplug script, and it happens to attempt
> to open a socket on the device before .dev_data is set, br2684ctl fails
> (rather disgracefully BTW, forgetting to cleanup nasX).  I had to work
> around it by adding a sleep for a couple of seconds to the hotplug
> script, and hoping that was enough for the driver to complete
> initializing atm_dev.  I suspect the only way to fix it is to split the
> atm_dev initialization into two stages, allocation and registration, as
> it is done for net_device.

this is a long-standing problem with ATM device initialisation: the device
becomes available before the struct atm_dev is initialised!  In theory a
driver's ATM methods could be called the moment atm_dev_register returns,
and before the driver has had a chance to fill in any fields.  That's why
all the ATM methods in the speedtouch driver check atm_dev->dev_data, and
return without doing anything if it is NULL: atm_dev->dev_data is only set
to a non-NULL value when the struct atm_dev has been fully initialised (this
is the reason for the memory barrier by the way).  When you say
"the device actually becomes usable only when the driver sets .dev_data",
I think that's a property of the speedtouch driver only.  With other drivers
it is probably worse: you get to open a connection even though the structure
is not initialized, and boom!  In the past, this race was only a theoretical
problem for SMP machines; but with your patch it hits everyone.

Ciao,

Duncan.
