From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next 2/3] nfp: look for firmware image by device
 serial number and PCI name
Date: Thu, 27 Jul 2017 02:25:46 -0700
Message-ID: <20170727022546.1fe8d1ea@cakuba.netronome.com>
References: <20170726180948.3220-1-jakub.kicinski@netronome.com>
        <20170726180948.3220-3-jakub.kicinski@netronome.com>
        <063D6719AE5E284EB5DD2968C1650D6DD0043717@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oss-drivers@netronome.com" <oss-drivers@netronome.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33081 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751796AbdG0JZv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 05:25:51 -0400
Received: by mail-pg0-f51.google.com with SMTP id c14so3154470pgn.0
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 02:25:50 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0043717@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Jul 2017 08:20:22 +0000, David Laight wrote:
> From: Jakub Kicinski
> > Sent: 26 July 2017 19:10
> > We generally look up firmware by card type, but that doesn't allow
> > users who have more than one card of the same type in their system
> > to select firmware per adapter.
> > 
> > Unfortunately user space firmware helper seems fraught with
> > difficulties and to be on its way out.  In particular support for
> > handling firmware uevents have been dropped from systemd and most
> > distributions don't enable the FW fallback by default any more.
> > 
> > To allow users selecting firmware for a particular device look up
> > firmware names by serial and pci_name().  Use the direct lookup to
> > disable generating uevents when enabled in Kconfig and not print
> > any warnings to logs if adapter-specific files are missing.  Users
> > can place in /lib/firmware/netronome files named:
> > 
> > pci-${pci_name}.nffw
> > serial-${serial}.nffw
> > 
> > to target a specific card.  E.g.:
> > 
> > pci-0000:04:00.0.nffw
> > pci-0000:82:00.0.nffw
> > serial-00-aa-bb-11-22-33-10-ff.nffw
> > 
> > We use the full serial number including the interface id, as it
> > appears in lspci output (bytes separated by '-').  
> 
> Where does lspci get that from?

Extended capability type 3, Device Serial Number.

> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > ---
> >  drivers/net/ethernet/netronome/nfp/nfp_main.c | 20 +++++++++++++++++++-
> >  1 file changed, 19 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c
> > b/drivers/net/ethernet/netronome/nfp/nfp_main.c
> > index d67969d3e484..13d056da0765 100644
> > --- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
> > +++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
> > @@ -188,9 +188,27 @@ nfp_net_fw_find(struct pci_dev *pdev, struct nfp_pf *pf)
> >  	struct nfp_eth_table_port *port;
> >  	const char *fw_model;
> >  	char fw_name[256];
> > +	const u8 *serial;
> >  	int spc, err = 0;
> > +	u16 interface;
> >  	int i, j;
> > 
> > +	/* First try to find a firmware image specific for this device */
> > +	interface = nfp_cpp_interface(pf->cpp);
> > +	nfp_cpp_serial(pf->cpp, &serial);
> > +	sprintf(fw_name, "netronome/serial-%pMF-%02hhx-%02hhx.nffw",
> > +		serial, interface >> 8, interface & 0xff);  
> 
> WTF???

Please be civil.

> - use snprintf().

To effectively print an integer into an amply sized array?  I need to
guarantee that the string will fit otherwise I would request a FW image
with a wrong name.  snprintf() would only mask such a bug.

> - kill those hh, the arguments are of type 'int'.

It doesn't matter.  I will be more careful in the future, though.

> In fact make 'interface' 'unsigned int' as well.

It's a value read from the hardware, and it's 16 bits wide, therefore
my preference it to explicitly size the variable.
