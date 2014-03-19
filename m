From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: stmmac-socfpga breakage in arm-soc
Date: Wed, 19 Mar 2014 15:58:47 +0100
Message-ID: <29079107.ja9Hu9mMY0@wuerfel>
References: <201403191333.01095.arnd@arndb.de> <4337501.shzGE38xmF@wuerfel>
 <5329AAE1.7030705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Srinivas Kandagatla <srinivas.kandagatla@st.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Hans de Goede <hdegoede@redhat.com>,
 arm@kernel.org, linux-arm-kernel@lists.infradead.org,
 Giuseppe Cavallaro <peppe.cavallaro@st.com>,
 "David S. Miller" <davem@davemloft.net>, Dinh Nguyen <dinguyen@altera.com>
To: Dinh Nguyen <dinh.linux@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <5329AAE1.7030705@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wednesday 19 March 2014 09:34:09 Dinh Nguyen wrote:
> 
> diff --git a/arch/arm/boot/dts/socfpga.dtsi 
> b/arch/arm/boot/dts/socfpga.dtsi
> index 5f1e256..953801c 100644
> --- a/arch/arm/boot/dts/socfpga.dtsi
> +++ b/arch/arm/boot/dts/socfpga.dtsi
> @@ -456,8 +456,10 @@
>                          altr,sysmgr-syscon = <&sysmgr 0x60>;
>                          reg = <0xff700000 0x2000>;
>                          interrupts = <0 115 4>;
> +                       interrupt-names = "macirq";
>                          mac-address = [00 00 00 00 00 00];/* Filled in 
> by U-Boot */
>                          clocks = <&emac0_clk>;
> +                       clock-names = "stmmaceth";
>                  };

Ah, I see. I missed the "macirq" name in the binding, but the clock name
must be documented in the binding first. I see that it is present in
Documentation/devicetree/bindings/net/allwinner,sun7i-a20-gmac.txt, but
not in any of the other bindings. The driver however prints out a warning
if it's not present.

I've added this part to my patch now.


	Arnd

diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
index ec216e0..f7aa231 100644
--- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
@@ -20,6 +20,8 @@ gmac0: ethernet@ff700000 {
 	status = "disabled";
 	reg = <0xff700000 0x2000>;
 	interrupts = <0 115 4>;
+	interrupt-names = "macirq";
 	mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
 	clocks = <&emac0_clk>;
+	clocks-names = ""stmmaceth";
 };
diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 5748351..19d5648 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -31,6 +31,10 @@ Optional properties:
 - reset-names: Should contain the reset signal name "stmmaceth", if a
 	reset phandle is given
 - max-frame-size: See ethernet.txt file in the same directory
+- clocks: If present, the first clock should be the GMAC main clock,
+  further clocks may be specified in derived bindings
+- clock-names: One name for each entry in the clocks property, the
+  first one should be "stmmaceth".
 
 Examples:
 
@@ -43,4 +47,6 @@ Examples:
 		mac-address = [000000000000]; /* Filled in by U-Boot */
 		max-frame-size = <3800>;
 		phy-mode = "gmii";
+		clocks = <&clock>;
+		clock-names = "stmmaceth">
 	};
diff --git a/arch/arm/boot/dts/socfpga.dtsi b/arch/arm/boot/dts/socfpga.dtsi
index 1595712..982649e 100644
--- a/arch/arm/boot/dts/socfpga.dtsi
+++ b/arch/arm/boot/dts/socfpga.dtsi
@@ -457,8 +457,10 @@
 			altr,sysmgr-syscon = <&sysmgr 0x60>;
 			reg = <0xff700000 0x2000>;
 			interrupts = <0 115 4>;
+			interrupt-names = "macirq";
 			mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
 			clocks = <&emac0_clk>;
+			clock-names = "stmmaceth";
 		};
 
 		gmac1: ethernet@ff702000 {
@@ -467,8 +469,10 @@
 			altr,sysmgr-syscon = <&sysmgr 0x60>;
 			reg = <0xff702000 0x2000>;
 			interrupts = <0 120 4>;
+			interrupt-names = "macirq";
 			mac-address = [00 00 00 00 00 00];/* Filled in by U-Boot */
 			clocks = <&emac1_clk>;
+			clock-names = "stmmaceth";
 		};
 
 		L2: l2-cache@fffef000 {
