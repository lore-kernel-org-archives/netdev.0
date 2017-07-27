From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/3] nfp: look for firmware image by device
 serial number and PCI name
Date: Thu, 27 Jul 2017 08:20:22 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0043717@AcuExch.aculab.com>
References: <20170726180948.3220-1-jakub.kicinski@netronome.com>
 <20170726180948.3220-3-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "oss-drivers@netronome.com" <oss-drivers@netronome.com>
To: 'Jakub Kicinski' <jakub.kicinski@netronome.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:65478 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751510AbdG0IU0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 04:20:26 -0400
In-Reply-To: <20170726180948.3220-3-jakub.kicinski@netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski
> Sent: 26 July 2017 19:10
> We generally look up firmware by card type, but that doesn't allow
> users who have more than one card of the same type in their system
> to select firmware per adapter.
> 
> Unfortunately user space firmware helper seems fraught with
> difficulties and to be on its way out.  In particular support for
> handling firmware uevents have been dropped from systemd and most
> distributions don't enable the FW fallback by default any more.
> 
> To allow users selecting firmware for a particular device look up
> firmware names by serial and pci_name().  Use the direct lookup to
> disable generating uevents when enabled in Kconfig and not print
> any warnings to logs if adapter-specific files are missing.  Users
> can place in /lib/firmware/netronome files named:
> 
> pci-${pci_name}.nffw
> serial-${serial}.nffw
> 
> to target a specific card.  E.g.:
> 
> pci-0000:04:00.0.nffw
> pci-0000:82:00.0.nffw
> serial-00-aa-bb-11-22-33-10-ff.nffw
> 
> We use the full serial number including the interface id, as it
> appears in lspci output (bytes separated by '-').

Where does lspci get that from?

> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
>  drivers/net/ethernet/netronome/nfp/nfp_main.c | 20 +++++++++++++++++++-
>  1 file changed, 19 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c
> b/drivers/net/ethernet/netronome/nfp/nfp_main.c
> index d67969d3e484..13d056da0765 100644
> --- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
> +++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
> @@ -188,9 +188,27 @@ nfp_net_fw_find(struct pci_dev *pdev, struct nfp_pf *pf)
>  	struct nfp_eth_table_port *port;
>  	const char *fw_model;
>  	char fw_name[256];
> +	const u8 *serial;
>  	int spc, err = 0;
> +	u16 interface;
>  	int i, j;
> 
> +	/* First try to find a firmware image specific for this device */
> +	interface = nfp_cpp_interface(pf->cpp);
> +	nfp_cpp_serial(pf->cpp, &serial);
> +	sprintf(fw_name, "netronome/serial-%pMF-%02hhx-%02hhx.nffw",
> +		serial, interface >> 8, interface & 0xff);

WTF???
- use snprintf().
- kill those hh, the arguments are of type 'int'.
In fact make 'interface' 'unsigned int' as well.

	David
