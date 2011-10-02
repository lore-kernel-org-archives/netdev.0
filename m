From: Andy Fleming <afleming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFD PATCH] netdev/phy/of: Augment device tree bindings for PHYs
	to specify IEEE802.3-2005 Section 45 addressing.
Date: Sat, 1 Oct 2011 21:59:23 -0500
Message-ID: <CAKWjMd43YK=ucBhPkW=JDtM1qUos3OOqxFgUJ2rUWauvQ-=74A@mail.gmail.com>
References: <1317424182-29252-1-git-send-email-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1015257517849240157=="
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org"
	<devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1317424182-29252-1-git-send-email-david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============1015257517849240157==
Content-Type: multipart/alternative; boundary=20cf305b0ec4a4c5ec04ae480b7f

--20cf305b0ec4a4c5ec04ae480b7f
Content-Type: text/plain; charset=ISO-8859-1

On Friday, September 30, 2011, David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org> wrote:
> Many 10 gigabit Ethernet PHY devices are interfaced to the MDIO bus
> using a protocol called IEEE802.3-2005 Section 45.  Where as PHYS for
> 1G, 100M and 10M usually use IEEE802.3-2005 Section 22.  These two
> protocols can be present on the same MDIO bus.
>
> If we look at the Linux PHY probing code in drivers/of/of_mdio.c and
> drivers/net/phy/phy_device.c, we have the situation where we need to
> read the PHY registers to get the PHY ID out so that we can use this
> to bind to a compatible driver.  However we can only read these
> registers if we know the proper MDIO bus protocol to use.
>
> My idea is as follows:
>
> o Add an optional property "mdio-clause-45" to the PHY's device tree
>  node to indicate that clause 45 addressing is used.
>
> o When calling get_phy_id() we will set MII_ADDR_C45 in the address
>  if we know that clause 45 addressing is required for the PHY.
>  get_phy_id() will then use the proper bus protocol and register
>  numbers to read PHY ID based on MII_ADDR_C45.
>
> o of_mdiobus_register() will signal MII_ADDR_C45 for PHYs tagged with
>  "mdio-clause-45"
>
> o Existing PHYs without "mdio-clause-45" are unaffected.
>
> o If no specific driver for the probed PHY ID is present, we can still
>  communicate with the PHY and perhaps use a generic 10G phy driver.
>  If the MDIO bus protocol were just to depend on the "compatible"
>  property, then we could not use generic drivers for unknown PHY IDs
>
> Comments/other ideas welcome.


About a year ago, I  submitted some patches to deal with the Clause 45
stuff. I'm currently working on updating them and fixing the issues raised
during the review. My preferred solution is actually to modify all of the
mdio drivers to support an additional argument which will either be
MDIO_DEVAD_NONE, or an actual device address. IMHO, it makes the interface
more communicative.

I had a mechanism in place in my patches which, I believe, should have
properly noted whether a PHY at a given address was operating under clause
45 rather than clause 22. I also had a generic driver (The last issues
remaining with my patches are related to how the generic driver operates; my
original driver was a stub which worked fine for my particular PHY, but
assumed too much about the PHY state).

However, I think that the idea of a different compatible property for 10g
PHYs could be useful, anyway.

>
> Thanks,
>
> Signed-off-by: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> ---
>  Documentation/devicetree/bindings/net/phy.txt |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/Documentation/devicetree/bindings/net/phy.txt
b/Documentation/devicetree/bindings/net/phy.txt
> index bb8c742..69fd948 100644
> --- a/Documentation/devicetree/bindings/net/phy.txt
> +++ b/Documentation/devicetree/bindings/net/phy.txt
> @@ -14,6 +14,11 @@ Required properties:
>  - linux,phandle :  phandle for this node; likely referenced by an
>    ethernet controller node.
>
> +Optional properties:
> +
> + - mdio-clause-45 : Optional.  If present, IEEE802.3-2005 Section 45
> +   protocol is used for register access (usually for 10G PHYs).
> +
>  Example:
>
>  ethernet-phy@0 {
> --
> 1.7.2.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--20cf305b0ec4a4c5ec04ae480b7f
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br>On Friday, September 30, 2011, David Daney &lt;<a href=3D"mailto:da=
vid.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org">david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org</a>&gt; wrote:<br>&gt; Many 10=
 gigabit Ethernet PHY devices are interfaced to the MDIO bus<br>&gt; using =
a protocol called IEEE802.3-2005 Section 45. =A0Where as PHYS for<br>
&gt; 1G, 100M and 10M usually use IEEE802.3-2005 Section 22. =A0These two<b=
r>&gt; protocols can be present on the same MDIO bus.<br>&gt;<br>&gt; If we=
 look at the Linux PHY probing code in drivers/of/of_mdio.c and<br>&gt; dri=
vers/net/phy/phy_device.c, we have the situation where we need to<br>
&gt; read the PHY registers to get the PHY ID out so that we can use this<b=
r>&gt; to bind to a compatible driver. =A0However we can only read these<br=
>&gt; registers if we know the proper MDIO bus protocol to use.<br>&gt;<br>
&gt; My idea is as follows:<br>&gt;<br>&gt; o Add an optional property &quo=
t;mdio-clause-45&quot; to the PHY&#39;s device tree<br>&gt; =A0node to indi=
cate that clause 45 addressing is used.<br>&gt;<br>&gt; o When calling get_=
phy_id() we will set MII_ADDR_C45 in the address<br>
&gt; =A0if we know that clause 45 addressing is required for the PHY.<br>&g=
t; =A0get_phy_id() will then use the proper bus protocol and register<br>&g=
t; =A0numbers to read PHY ID based on MII_ADDR_C45.<br>&gt;<br>&gt; o of_md=
iobus_register() will signal MII_ADDR_C45 for PHYs tagged with<br>
&gt; =A0&quot;mdio-clause-45&quot;<br>&gt;<br>&gt; o Existing PHYs without =
&quot;mdio-clause-45&quot; are unaffected.<br>&gt;<br>&gt; o If no specific=
 driver for the probed PHY ID is present, we can still<br>&gt; =A0communica=
te with the PHY and perhaps use a generic 10G phy driver.<br>
&gt; =A0If the MDIO bus protocol were just to depend on the &quot;compatibl=
e&quot;<br>&gt; =A0property, then we could not use generic drivers for unkn=
own PHY IDs<br>&gt;<br>&gt; Comments/other ideas welcome.<br><br><br>About =
a year ago, I =A0submitted some patches to deal with the Clause 45 stuff. I=
&#39;m currently working on updating them and fixing the issues raised duri=
ng the review. My preferred solution is actually to modify all of the mdio =
drivers to support an additional argument which will either be MDIO_DEVAD_N=
ONE, or an actual device address. IMHO, it makes the interface more communi=
cative.<br>
<br>I had a mechanism in place in my patches which, I believe, should have =
properly noted whether a PHY at a given address was operating under clause =
45 rather than clause 22. I also had a generic driver (The last issues rema=
ining with my patches are related to how the generic driver operates; my or=
iginal driver was a stub which worked fine for my particular PHY, but assum=
ed too much about the PHY state).<br>
<br>However, I think that the idea of a different compatible property for 1=
0g PHYs could be useful, anyway.<br><br>&gt;<br>&gt; Thanks,<br>&gt;<br>&gt=
; Signed-off-by: David Daney &lt;<a href=3D"mailto:david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org">=
david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org</a>&gt;<br>
&gt; ---<br>&gt; =A0Documentation/devicetree/bindings/net/phy.txt | =A0 =A0=
5 +++++<br>&gt; =A01 files changed, 5 insertions(+), 0 deletions(-)<br>&gt;=
<br>&gt; diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Docum=
entation/devicetree/bindings/net/phy.txt<br>
&gt; index bb8c742..69fd948 100644<br>&gt; --- a/Documentation/devicetree/b=
indings/net/phy.txt<br>&gt; +++ b/Documentation/devicetree/bindings/net/phy=
.txt<br>&gt; @@ -14,6 +14,11 @@ Required properties:<br>&gt; =A0- linux,pha=
ndle : =A0phandle for this node; likely referenced by an<br>
&gt; =A0 =A0ethernet controller node.<br>&gt;<br>&gt; +Optional properties:=
<br>&gt; +<br>&gt; + - mdio-clause-45 : Optional. =A0If present, IEEE802.3-=
2005 Section 45<br>&gt; + =A0 protocol is used for register access (usually=
 for 10G PHYs).<br>
&gt; +<br>&gt; =A0Example:<br>&gt;<br>&gt; =A0ethernet-phy@0 {<br>&gt; --<b=
r>&gt; 1.7.2.3<br>&gt;<br>&gt; --<br>&gt; To unsubscribe from this list: se=
nd the line &quot;unsubscribe netdev&quot; in<br>&gt; the body of a message=
 to <a href=3D"mailto:majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org">majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org<=
/a><br>
&gt; More majordomo info at =A0<a href=3D"http://vger.kernel.org/majordomo-=
info.html">http://vger.kernel.org/majordomo-info.html</a><br>&gt;

--20cf305b0ec4a4c5ec04ae480b7f--

--===============1015257517849240157==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devicetree-discuss mailing list
devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
https://lists.ozlabs.org/listinfo/devicetree-discuss

--===============1015257517849240157==--
