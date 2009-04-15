From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH 05/14] phylib: add *_direct() variants of phy_connect and
	phy_attach functions
Date: Wed, 15 Apr 2009 16:10:16 -0500
Message-ID: <FD808CF0-C694-4388-BBBE-B92367663F54@freescale.com>
References: <20090331075537.1427.7819.stgit@localhost.localdomain>
	<20090331082709.1427.48689.stgit@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, olof@lixom.net
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090331082709.1427.48689.stgit@localhost.localdomain>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Mar 31, 2009, at 3:27 AM, Grant Likely wrote:

> From: Grant Likely <grant.likely@secretlab.ca>
>
> Add phy_connect_direct() and phy_attach_direct() functions so that
> drivers can use a pointer to the phy_device instead of trying to  
> determine
> the phy's bus_id string.
>
> This patch is useful for OF device tree descriptions of phy devices  
> where
> the driver doesn't need or know what the bus_id value in order to  
> get a
> phy_device pointer.
>
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> ---
> @@ -312,18 +339,21 @@ struct phy_device * phy_connect(struct  
> net_device *dev, const char *bus_id,
> 		phy_interface_t interface)
> {
> 	struct phy_device *phydev;
> +	struct device *d;
> +	int rc;
>
> -	phydev = phy_attach(dev, bus_id, flags, interface);
> -
> -	if (IS_ERR(phydev))
> -		return phydev;
> -
> -	phy_prepare_link(phydev, handler);
> -
> -	phy_start_machine(phydev, NULL);
> +	/* Search the list of PHY devices on the mdio bus for the
> +	 * PHY with the requested name */
> +	d = bus_find_device_by_name(&mdio_bus_type, NULL, bus_id);
> +	if (!d) {
> +		pr_err("PHY %s not found\n", bus_id);
> +		return ERR_PTR(-ENODEV);
> +	}
> +	phydev = to_phy_device(d);
>
> -	if (phydev->irq > 0)
> -		phy_start_interrupts(phydev);
> +	rc = phy_attach_direct(dev, phydev, flags, interface);
> +	if (rc)
> +		return ERR_PTR(rc);


Why not just invoke phy_attach(), here, and thereby avoid the  
duplicate search code?

Otherwise, looks good.

Andy
