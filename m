From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the rockchip
 tree
Date: Mon, 28 Aug 2017 11:33:36 +1000
Message-ID: <20170828113336.1045e231@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        David Wu <david.wu@rock-chips.com>,
        Liang Chen <cl@rock-chips.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Heiko Stuebner <heiko@sntech.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  arch/arm64/boot/dts/rockchip/rk3328-evb.dts

between commit:

  0e54e062692a ("arm64: dts: rockchip: add mmc nodes for rk3328 evaluation board")
  57fca160b2be ("arm64: dts: rockchip: add cpu regulator for rk3328 evaluation board")

from the rockchip tree and commit:

  4b05bc6157eb ("ARM64: dts: rockchip: Enable gmac2phy for rk3328-evb")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc arch/arm64/boot/dts/rockchip/rk3328-evb.dts
index f82b2d0d9e86,b9f36dad17e6..000000000000
--- a/arch/arm64/boot/dts/rockchip/rk3328-evb.dts
+++ b/arch/arm64/boot/dts/rockchip/rk3328-evb.dts
@@@ -51,217 -51,24 +51,234 @@@
  		stdout-path = "serial2:1500000n8";
  	};
  
 +	dc_12v: dc-12v {
 +		compatible = "regulator-fixed";
 +		regulator-name = "dc_12v";
 +		regulator-always-on;
 +		regulator-boot-on;
 +		regulator-min-microvolt = <12000000>;
 +		regulator-max-microvolt = <12000000>;
 +	};
 +
 +	sdio_pwrseq: sdio-pwrseq {
 +		compatible = "mmc-pwrseq-simple";
 +		pinctrl-names = "default";
 +		pinctrl-0 = <&wifi_enable_h>;
 +
 +		/*
 +		 * On the module itself this is one of these (depending
 +		 * on the actual card populated):
 +		 * - SDIO_RESET_L_WL_REG_ON
 +		 * - PDN (power down when low)
 +		 */
 +		reset-gpios = <&gpio1 18 GPIO_ACTIVE_LOW>;
 +	};
 +
+ 	vcc_phy: vcc-phy-regulator {
+ 		compatible = "regulator-fixed";
+ 		regulator-name = "vcc_phy";
+ 		regulator-always-on;
+ 		regulator-boot-on;
+ 	};
++
 +	vcc_sys: vcc-sys {
 +		compatible = "regulator-fixed";
 +		regulator-name = "vcc_sys";
 +		regulator-always-on;
 +		regulator-boot-on;
 +		regulator-min-microvolt = <5000000>;
 +		regulator-max-microvolt = <5000000>;
 +		vin-supply = <&dc_12v>;
 +	};
 +
 +	vcc_sd: sdmmc-regulator {
 +		compatible = "regulator-fixed";
 +		gpio = <&gpio0 30 GPIO_ACTIVE_LOW>;
 +		pinctrl-names = "default";
 +		pinctrl-0 = <&sdmmc0m1_gpio>;
 +		regulator-name = "vcc_sd";
 +		regulator-min-microvolt = <3300000>;
 +		regulator-max-microvolt = <3300000>;
 +		vin-supply = <&vcc_io>;
 +	};
 +};
 +
 +&cpu0 {
 +	cpu-supply = <&vdd_arm>;
 +};
 +
 +&emmc {
 +	bus-width = <8>;
 +	cap-mmc-highspeed;
 +	non-removable;
 +	pinctrl-names = "default";
 +	pinctrl-0 = <&emmc_clk &emmc_cmd &emmc_bus8>;
 +	status = "okay";
  };
  
+ &gmac2phy {
+ 	phy-supply = <&vcc_phy>;
+ 	clock_in_out = "output";
+ 	assigned-clocks = <&cru SCLK_MAC2PHY_SRC>;
+ 	assigned-clock-rate = <50000000>;
+ 	assigned-clocks = <&cru SCLK_MAC2PHY>;
+ 	assigned-clock-parents = <&cru SCLK_MAC2PHY_SRC>;
+ 	status = "okay";
+ };
+ 
 +&i2c1 {
 +	status = "okay";
 +
 +	rk805: rk805@18 {
 +		compatible = "rockchip,rk805";
 +		reg = <0x18>;
 +		interrupt-parent = <&gpio2>;
 +		interrupts = <6 IRQ_TYPE_LEVEL_LOW>;
 +		#clock-cells = <1>;
 +		clock-output-names = "xin32k", "rk805-clkout2";
 +		gpio-controller;
 +		#gpio-cells = <2>;
 +		pinctrl-names = "default";
 +		pinctrl-0 = <&pmic_int_l>;
 +		rockchip,system-power-controller;
 +		wakeup-source;
 +
 +		vcc1-supply = <&vcc_sys>;
 +		vcc2-supply = <&vcc_sys>;
 +		vcc3-supply = <&vcc_sys>;
 +		vcc4-supply = <&vcc_sys>;
 +		vcc5-supply = <&vcc_io>;
 +		vcc6-supply = <&vcc_io>;
 +
 +		regulators {
 +			vdd_logic: DCDC_REG1 {
 +				regulator-name = "vdd_logic";
 +				regulator-min-microvolt = <712500>;
 +				regulator-max-microvolt = <1450000>;
 +				regulator-always-on;
 +				regulator-boot-on;
 +				regulator-state-mem {
 +					regulator-on-in-suspend;
 +					regulator-suspend-microvolt = <1000000>;
 +				};
 +			};
 +
 +			vdd_arm: DCDC_REG2 {
 +				regulator-name = "vdd_arm";
 +				regulator-min-microvolt = <712500>;
 +				regulator-max-microvolt = <1450000>;
 +				regulator-always-on;
 +				regulator-boot-on;
 +				regulator-state-mem {
 +					regulator-on-in-suspend;
 +					regulator-suspend-microvolt = <950000>;
 +				};
 +			};
 +
 +			vcc_ddr: DCDC_REG3 {
 +				regulator-name = "vcc_ddr";
 +				regulator-always-on;
 +				regulator-boot-on;
 +				regulator-state-mem {
 +					regulator-on-in-suspend;
 +				};
 +			};
 +
 +			vcc_io: DCDC_REG4 {
 +				regulator-name = "vcc_io";
 +				regulator-min-microvolt = <3300000>;
 +				regulator-max-microvolt = <3300000>;
 +				regulator-always-on;
 +				regulator-boot-on;
 +				regulator-state-mem {
 +					regulator-on-in-suspend;
 +					regulator-suspend-microvolt = <3300000>;
 +				};
 +			};
 +
 +			vcc_18: LDO_REG1 {
 +				regulator-name = "vcc_18";
 +				regulator-min-microvolt = <1800000>;
 +				regulator-max-microvolt = <1800000>;
 +				regulator-always-on;
 +				regulator-boot-on;
 +				regulator-state-mem {
 +					regulator-on-in-suspend;
 +					regulator-suspend-microvolt = <1800000>;
 +				};
 +			};
 +
 +			vcc18_emmc: LDO_REG2 {
 +				regulator-name = "vcc18_emmc";
 +				regulator-min-microvolt = <1800000>;
 +				regulator-max-microvolt = <1800000>;
 +				regulator-always-on;
 +				regulator-boot-on;
 +				regulator-state-mem {
 +					regulator-on-in-suspend;
 +					regulator-suspend-microvolt = <1800000>;
 +				};
 +			};
 +
 +			vdd_10: LDO_REG3 {
 +				regulator-name = "vdd_10";
 +				regulator-min-microvolt = <1000000>;
 +				regulator-max-microvolt = <1000000>;
 +				regulator-always-on;
 +				regulator-boot-on;
 +				regulator-state-mem {
 +					regulator-on-in-suspend;
 +					regulator-suspend-microvolt = <1000000>;
 +				};
 +			};
 +		};
 +	};
 +};
 +
 +&pinctrl {
 +	pmic {
 +		pmic_int_l: pmic-int-l {
 +			rockchip,pins = <2 RK_PA6 RK_FUNC_GPIO &pcfg_pull_up>;
 +		};
 +	};
 +
 +	sdio-pwrseq {
 +		wifi_enable_h: wifi-enable-h {
 +		rockchip,pins =
 +			<1 18 RK_FUNC_GPIO &pcfg_pull_none>;
 +		};
 +	};
 +};
 +
 +&sdio {
 +	bus-width = <4>;
 +	cap-sd-highspeed;
 +	cap-sdio-irq;
 +	keep-power-in-suspend;
 +	max-frequency = <150000000>;
 +	mmc-pwrseq = <&sdio_pwrseq>;
 +	non-removable;
 +	pinctrl-names = "default";
 +	pinctrl-0 = <&sdmmc1_bus4 &sdmmc1_cmd &sdmmc1_clk>;
 +	status = "okay";
 +};
 +
 +&sdmmc {
 +	bus-width = <4>;
 +	cap-mmc-highspeed;
 +	cap-sd-highspeed;
 +	disable-wp;
 +	max-frequency = <150000000>;
 +	pinctrl-names = "default";
 +	pinctrl-0 = <&sdmmc0_clk &sdmmc0_cmd &sdmmc0_dectn &sdmmc0_bus4>;
 +	vmmc-supply = <&vcc_sd>;
 +	status = "okay";
 +};
 +
 +&tsadc {
 +	status = "okay";
 +};
 +
  &uart2 {
  	status = "okay";
  };
