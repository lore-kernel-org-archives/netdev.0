From: David Daney <ddaney.cavm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC] How should the device tree represent multiple Ethernet PHYs
 in a single package?
Date: Thu, 23 Aug 2012 17:21:38 -0700
Message-ID: <5036C912.7090203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
To: Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
 Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
 Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

We are working with a Dual 10G Ethernet PHY Device (Vitesse vcs8488) and 
would like to represent it in the device tree for several of our boards. 
  This device has some registers and pins that are common to both of the 
PHY units on the die.  Other registers are standard IEEE803.3-C45.

Here is my first (hand-waving) take at how it should look:


ethernet-phy-nexus@0 {
	reg = <0x00>;
	/* The Vitesse VSC8488 is a dual-PHY where
	 * some of the configuration is common across
	 * both of the phy devices such as the reset
	 * line and the base MDIO address.
	 */
	compatible = "vitesse,vsc8488-nexus", "ethernet-phy-nexus";
	#address-cells = <1>;
	#size-cells = <0>;
	ranges;
	
	/* Hardware reset signal */
	reset = <&gpio 17 0>;

	/* Other common initialization (laser power, etc. )*/

	phy30: ethernet-phy@0 {
		/* Absolute address */
		reg = <0x0>;
		compatible = "vitesse,vsc8488", "ethernet-phy-ieee802.3-c45";
		interrupt-parent = <&gpio>;
		interrupts = <13 8>;

		/* TX Fault GPIO line */
		tx_fault = <1>;
		/* GPIO that enables output */
		txon = <4>;
		/* INT A GPIO output */
		inta = <5>;
	};

	phy31: ethernet-phy@1 {
		/* Absolute address */
		reg = <0x1>;
		compatible = "vitesse,vsc8488", "ethernet-phy-ieee802.3-c45";
		interrupt-parent = <&gpio>;
		interrupts = <13 8>;

		/* TX Fault GPIO line */
		tx_fault = <8>;
		/* GPIO that enables output */
		txon = <10>;
		/* INT A GPIO output */
		inta = <5>;
         };
};


We would then modify of_mdio.c so that when it encountered an 
"ethernet-phy-nexus", it would add all the children of the nexus.

Comments?  Objections?

Thanks, and let me know what you think,
David Daney
