From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/3] of_mdio: add new DT property 'managed' to specify
 the PHY management type
Date: Tue, 14 Jul 2015 10:51:54 -0700
Message-ID: <55A54C3A.1040403@gmail.com>
References: <55A5424D.4030809@list.ru> <55A5432C.1080609@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sebastien Rannou <mxs-i6rsG8ix9II@public.gmane.org>,
	Arnaud Ebalard <arno-LkuqDEemtHBg9hUCZPvPmw@public.gmane.org>,
	Stas Sergeev <stsp-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stas Sergeev <stsp-cmBhpYW9OiY@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55A5432C.1080609-cmBhpYW9OiY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 14/07/15 10:13, Stas Sergeev wrote:
> 
> Currently the PHY management type is selected by the MAC driver arbitrary.
> The decision is based on the presence of the "fixed-link" node and on a
> will of the driver's authors.
> This caused a regression recently, when mvneta driver suddenly started
> to use the in-band status for auto-negotiation on fixed links.
> It appears the auto-negotiation may not work when expected by the MAC driver.
> Sebastien Rannou explains:
> << Yes, I confirm that my HW does not generate an in-band status. AFAIK, it's
> a PHY that aggregates 4xSGMIIs to 1xQSGMII ; the MAC side of the PHY (with
> inband status) is connected to the switch through QSGMII, and in this context
> we are on the media side of the PHY. >>
> https://lkml.org/lkml/2015/7/10/206
> 
> This patch introduces the new string property 'managed' that allows
> the user to set the management type explicitly.
> The supported values are:
> "auto" - default. Uses either MDIO or nothing, depending on the presence
> of the fixed-link node
> "mdio" - use MDIO
> "in-band-status" - use in-band status
> "none" - use fixed-link description

I thought we agreed in the last thread that "mdio" was implied whenever
a proper PHY phandle to a device sitting on MDIO bus is used and that
"auto" did not make much sense unless we were also describing how to do
this auto-negotiation completely?

The way I see it, the only thing that is needed at this point is an
"in-band-status" property which you rightfully placed at the Ethernet
MAC DT node level, this is fine, however, I disagree with how the values
are enforced, see below:

> 
> Signed-off-by: Stas Sergeev <stsp-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> 
> CC: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> CC: Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>
> CC: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
> CC: Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
> CC: Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> CC: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> CC: Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> CC: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
>  Documentation/devicetree/bindings/net/ethernet.txt |  5 ++++
>  drivers/of/of_mdio.c                               | 28 ++++++++++++++++++++--
>  2 files changed, 31 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/ethernet.txt b/Documentation/devicetree/bindings/net/ethernet.txt
> index 3fc3605..23743e9 100644
> --- a/Documentation/devicetree/bindings/net/ethernet.txt
> +++ b/Documentation/devicetree/bindings/net/ethernet.txt
> @@ -19,7 +19,12 @@ The following properties are common to the Ethernet controllers:
>  - phy: the same as "phy-handle" property, not recommended for new bindings.
>  - phy-device: the same as "phy-handle" property, not recommended for new
>    bindings.
> +- managed: string, specifies the PHY management type. Supported values are:
> +  "auto", "mdio", "in-band-status", "none". "auto" is the default, and it
> +  sets the management type to either "mdio" or "none", depending on the
> +  presence of the "fixed-link" child node.

As mentioned below, "mdio" is redundant with finding a "phy-handle", and
"auto" is not specific enough to be useful to a consumer of this
information.

> 
>  Child nodes of the Ethernet controller are typically the individual PHY devices
>  connected via the MDIO bus (sometimes the MDIO bus controller is separate).
>  They are described in the phy.txt file in this same directory.
> +For non-MDIO PHY management see fixed-link.txt.
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 1bd4305..a460812 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -262,7 +262,16 @@ EXPORT_SYMBOL(of_phy_attach);
>  bool of_phy_is_fixed_link(struct device_node *np)
>  {
>  	struct device_node *dn;
> -	int len;
> +	int len, m_err;
> +	const char *managed;
> +
> +	m_err = of_property_read_string(np, "managed", &managed);
> +	if (m_err == 0) {
> +		if (strcmp(managed, "none") == 0)
> +			return true;
> +		if (strcmp(managed, "mdio") == 0)
> +			return false;
> +	}

managed = "mdio" on a fixed link is by definition not something remotely
correct, there should be a proper PHY driver for this, and therefore a
different representation: a PHY phandle to a PHY node on a MDIO bus. I
do not think enforcing this has been incorrect provides much value,
since you ought to write correct DT in the first place.

> 
>  	/* New binding */
>  	dn = of_get_child_by_name(np, "fixed-link");
> @@ -271,6 +280,9 @@ bool of_phy_is_fixed_link(struct device_node *np)
>  		return true;
>  	}
> 
> +	if (m_err == 0 && strcmp(managed, "auto") != 0)
> +		return true;
> +
>  	/* Old binding */
>  	if (of_get_property(np, "fixed-link", &len) &&
>  	    len == (5 * sizeof(__be32)))
> @@ -285,8 +297,20 @@ int of_phy_register_fixed_link(struct device_node *np)
>  	struct fixed_phy_status status = {};
>  	struct device_node *fixed_link_node;
>  	const __be32 *fixed_link_prop;
> -	int len;
> +	int len, err;
>  	struct phy_device *phy;
> +	const char *managed;
> +
> +	err = of_property_read_string(np, "managed", &managed);
> +	if (err == 0) {
> +		if (strcmp(managed, "mdio") == 0)
> +			return -EINVAL;
> +		if (strcmp(managed, "in-band-status") == 0) {
> +			status.link = 0;
> +			phy = fixed_phy_register(PHY_POLL, &status, np);
> +			return IS_ERR(phy) ? PTR_ERR(phy) : 0;
> +		}

And that is the only hunk of this patch that is really needed and useful
to solving the problem here.
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
