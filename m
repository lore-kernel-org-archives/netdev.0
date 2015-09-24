From: huangdaode <huangdaode@hisilicon.com>
Subject: Re: [PATCH v2 1/5] net: add Hisilicon Network Subsystem support (config
 and documents)
Date: Thu, 24 Sep 2015 09:58:13 +0800
Message-ID: <560358B5.3050403@hisilicon.com>
References: <1442472710-20909-1-git-send-email-huangdaode@hisilicon.com> <1442472710-20909-2-git-send-email-huangdaode@hisilicon.com> <560019C5.6030407@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<davem@davemloft.net>, <paul.gortmaker@windriver.com>,
	<dingtianhong@huawei.com>, <zhangfei.gao@linaro.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <salil.mehta@huawei.com>,
	<kenneth-lee-2012@foxmail.com>, <xuwei5@hisilicon.com>,
	<lisheng011@huawei.com>
To: Rob Herring <robh@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <560019C5.6030407@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015/9/21 22:52, Rob Herring wrote:
> On 09/17/2015 01:51 AM, huangdaode wrote:
>> The Hisilicon Network Subsystem is a long term evolution IP which is
>> supposed to be used in Hisilicon ICT SoC. The IP, which is called hns
>> for short, is a TCP/IP acceleration engine, which can directly decode
>> TCP/IP stream and distribute them to different ring buffers.
>>
>> HNS can be configured to work on different mode for different scenario.
>> This patch make use only some of the mode to make it as standard
>> ethernet NIC. The other mode will be added soon.
>>
>> The whole function has 4 kernel sub-modules:
>>
>> hnae: the HNS acceleration engine framework. It provides a abstract
>> interface between the engine and the upper layers which make use of the
>> engine by ring buffer.
>>
>> hns_enet_drv: a standard ethernet driver that base on the ring buffer.
>>
>> hns_dsaf: one of the implementation of HNS acceleration engine, which is
>> applied on Hililicon hip05, Hi1610 and other later-on SoCs
>>
>> hns_mdio: the mdio control to the PHY, used by acceleration engine
>>
>> This submit add basic config and documents
>>
>> Signed-off-by: huangdaode <huangdaode@hisilicon.com>
>> Signed-off-by: Kenneth Lee <liguozhu@huawei.com>
>> Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
>> ---
>>   .../bindings/net/hisilicon-hip04-net.txt           |   4 +-
>>   .../devicetree/bindings/net/hisilicon-hns-dsaf.txt |  49 ++++++
>>   .../devicetree/bindings/net/hisilicon-hns-mdio.txt |  22 +++
>>   .../devicetree/bindings/net/hisilicon-hns-nic.txt  |  47 +++++
>>   arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi       | 193 +++++++++++++++++++++
>>   5 files changed, 313 insertions(+), 2 deletions(-)
>>   create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
>>   create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
>>   create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
>>   create mode 100644 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
>>
>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt b/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
>> index 988fc69..d1df8a0 100644
>> --- a/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hip04-net.txt
>> @@ -32,13 +32,13 @@ Required properties:
>>   
>>   Required properties:
>>   
>> -- compatible: should be "hisilicon,hip04-mdio".
>> +- compatible: should be "hisilicon,mdio".
> Why are you removing the old one? Please use more specific compatible
> strings, not less specific.


we have unified the hip04_mdio.c and hip05_mdio.c  into hns_mdio.c, so 
we plan use
"hisilicon,mdio", "hisilicon,hns-mdio" "hisilicon,hns-mdio Vx", in this 
case, "hisilicon, mdio "
is more suitable for us, meanwhile, we will upstream hip04 dts file 
later, and will apply the
compatible property with "hisilicon,mdio".

>>   - Inherits from MDIO bus node binding [2]
>>   [2] Documentation/devicetree/bindings/net/phy.txt
>>   
>>   Example:
>>   	mdio {
>> -		compatible = "hisilicon,hip04-mdio";
>> +		compatible = "hisilicon,mdio";
>>   		reg = <0x28f1000 0x1000>;
>>   		#address-cells = <1>;
>>   		#size-cells = <0>;
>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
>> new file mode 100644
>> index 0000000..80411b2
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
>> @@ -0,0 +1,49 @@
>> +Hisilicon DSA Fabric device controller
>> +
>> +Required properties:
>> +- compatible: should be "hisilicon,hns-dsaf-v1" or "hisilicon,hns-dsaf-v2".
>> +  "hisilicon,hns-dsaf-v1" is for hip05.
>> +  "hisilicon,hns-dsaf-v2" is for Hi1610 and Hi1612.
>> +- dsa-name: dsa fabric name who provide this interface.
>> +  should be "dsafX", X is the dsaf id.
> What is this for? Find a different way to distinguish instances other
> than an index.

our driver support multi dsaf, so X in dsafX is the dsaf id.
the enet driver interface use the dsa-name to match the dsaf engine, 
then get it's handle.
when there are 2 dsafs ,we use dsaf0 and dsaf1 to distinguish them. The 
default is dsaf0.

>> +- mode: dsa fabric mode string. only support one of dsaf modes like these:
>> +		"2port-64vf",
>> +		"6port-16rss",
>> +		"6port-16vf".
>> +- interrupt-parent: the interrupt parent of this device.
>> +- interrupts: should contain the DSA Fabric and rcb interrupt.
>> +- reg: specifies base physical address(es) and size of the device registers.
>> +  The first region is external interface control register base and size.
>> +  The second region is SerDes base register and size.
>> +  The third region is the PPE register base and size.
>> +  The fourth region is dsa fabric base register and size.
>> +  The fifth region is cpld base register and size, it is not required if do not use cpld.
>> +- phy-handle: phy handle of physicl port, 0 if not any phy device. see ethernet.txt [1].
>> +- buf-size: rx buffer size, should be 16-1024.
> This is a h/w property?

yes. it's.

>> +- desc-num: number of description in TX and RX queue, should be 512, 1024, 2048 or 4096.
> This is a h/w property?

yes.

>> +
>> +[1] Documentation/devicetree/bindings/net/phy.txt
>> +
>> +Example:
>> +
>> +dsa: dsa@c7000000 {
>> +	compatible = "hisilicon,hns-dsaf-v1";
>> +	dsa_name = "dsaf0";
>> +	mode = "6port-16rss";
>> +	interrupt-parent = <&mbigen_dsa>;
>> +	reg = <0x0 0xC0000000 0x0 0x420000
>> +	       0x0 0xC2000000 0x0 0x300000
>> +	       0x0 0xc5000000 0x0 0x890000
>> +	       0x0 0xc7000000 0x0 0x60000>;
>> +	phy-handle = <0 0 0 0 &soc0_phy4 &soc0_phy5 0 0>;
>> +	interrupts = <131 4>,<132 4>, <133 4>,<134 4>,
>> +		     <135 4>,<136 4>, <137 4>,<138 4>,
>> +		     <139 4>,<140 4>, <141 4>,<142 4>,
>> +		     <143 4>,<144 4>, <145 4>,<146 4>,
>> +		     <147 4>,<148 4>, <384 1>,<385 1>,
>> +		     <386 1>,<387 1>, <388 1>,<389 1>,
>> +		     <390 1>,<391 1>,
>> +	buf-size = <4096>;
>> +	desc-num = <1024>;
>> +	dma-coherent;
>> +};
>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
>> new file mode 100644
>> index 0000000..9940aa0
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hns-mdio.txt
>> @@ -0,0 +1,22 @@
>> +Hisilicon MDIO bus controller
>> +
>> +Properties:
>> +- compatible: "hisilicon,mdio","hisilicon,hns-mdio".
> How is this related to the other MDIO ctrlr?

hns-mdio  module only supports Hisilicon SoCs, such as hip04, hip05 and 
other later on SoC  MDIO ctrlr.
what does the other MDIO ctrlr mean?
>
> Most specific string should come first.

agreed.

>
>> +- reg: The base address of the MDIO bus controller register bank.
>> +- #address-cells: Must be <1>.
>> +- #size-cells: Must be <0>.  MDIO addresses have no size component.
>> +
>> +Typically an MDIO bus might have several children.
>> +
>> +Example:
>> +         mdio@803c0000 {
>> +                   #address-cells = <1>;
>> +                   #size-cells = <0>;
>> +                   compatible = "hisilicon,mdio","hisilicon,hns-mdio";
>> +                   reg = <0x0 0x803c0000 0x0 0x10000>;
>> +
>> +                   ethernet-phy@0 {
>> +                            ...
>> +                            reg = <0>;
>> +                   };
>> +         };
>> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
>> new file mode 100644
>> index 0000000..41d19be
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
>> @@ -0,0 +1,47 @@
>> +Hisilicon Network Subsystem NIC controller
>> +
>> +Required properties:
>> +- compatible: "hisilicon,hns-nic-v1" or "hisilicon,hns-nic-v2".
>> +  "hisilicon,hns-nic-v1" is for hip05.
>> +  "hisilicon,hns-nic-v2" is for Hi1610 and Hi1612.
>> +- ae-name: accelerator name who provides this interface,
>> +  is simply a name referring to the name of name in the accelerator node.
> Why is this needed?

this is used to distinguish the different SOCs, the driver use it 
recognize the current SoC(such as hip05,hi1610 and later on SoCs ) on 
board.

>> +- port-id: is the index of port provided by DSAF (the accelerator). DSAF can
>> +  connect to 8 PHYs. Port 0 to 1 are both used for adminstration purpose. They
>> +  are called debug ports.
> Could the OF graph binding be used to describe this connection?

sorry, i can not exactly get your points.
could you please explain it clearly?

>> +
>> +  The remaining 6 PHYs are taken according to the mode of DSAF.
>> +
>> +  In NIC mode of DSAF, all 6 PHYs are taken as ethernet ports to the CPU. The
>> +  port-id can be 2 to 7. Here is the diagram:
>> +            +-----+---------------+
>> +            |            CPU      |
>> +            +-+-+-+---+-+-+-+-+-+-+
>> +              | |     | | | | | |
>> +             debug       service
>> +             port         port
>> +             (0,1)       (2-7)
>> +
>> +  In Switch mode of DSAF, all 6 PHYs are taken as physical ports connect to a
>> +  LAN Switch while the CPU side assume itself have one single NIC connect to
>> +  this switch. In this case, the port-id will be 2 only.
>> +            +-----+---------------+
>> +            |            CPU      |
>> +            +-+-+-+---+-+-+-+-+-+-+
>> +              | |   service| port(2)
>> +             debug   +------------+
>> +             port    |   switch   |
>> +             (0,1)   +-+-+-+-+-+-++
>> +                       | | | | | |
>> +                      external port
>> +
>> +- local-mac-address: mac addr of the ethernet interface
>> +
>> +Example:
>> +
>> +	ethernet@0{
>> +		compatible = "hisilicon,hns-nic-v1";
>> +		ae-name = "dsaf0";
>> +		port-id = <0>;
>> +		local-mac-address = [a2 14 e4 4b 56 76];
>> +	};
>> diff --git a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
>> new file mode 100644
>> index 0000000..3500586
>> --- /dev/null
>> +++ b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
>> @@ -0,0 +1,193 @@
>> +soc0: soc@000000000 {
>> +	#address-cells = <2>;
>> +	#size-cells = <2>;
>> +	device_type = "soc";
>> +	compatible = "simple-bus";
>> +	ranges = <0x0 0x0 0x0 0x0 0x1 0x0>;
>> +	chip-id = <0>;
>> +
>> +	soc0_mdio0: mdio@803c0000 {
>> +		#address-cells = <1>;
>> +		#size-cells = <0>;
>> +		compatible = "hisilicon,hns-mdio";
>> +		reg = <0x0 0x803c0000 0x0 0x10000
>> +		       0x0 0x80000000 0x0 0x10000>;
>> +
>> +		soc0_phy4: ethernet-phy@4 {
>> +			reg = <0x0>;
> Should be 4?

on hip05 d02 board, this Phy is connected to port4, since this is the 
file describe the device
connection, so 4 is more specific than 0.

>
>> +			device_type = "ethernet-phy";
> Drop device_type.

agreed.

>
>> +			compatible = "ethernet-phy-ieee802.3-c22";
>> +		};
>> +		soc0_phy5: ethernet-phy@5 {
>> +			reg = <0x1>;
> Should be 5? Or unit-address should be 1.

the reason is same with 4.

>
>> +			device_type = "ethernet-phy";
>> +			compatible = "ethernet-phy-ieee802.3-c22";
>> +		};
>> +	};
>> +
>> +	dsa: dsa@c7000000 {
>> +		compatible = "hisilicon,hns-dsaf-v1";
>> +		dsa_name = "dsaf0";
>> +		mode = "6port-16rss";
>> +		interrupt-parent = <&mbigen_dsa>;
>> +
>> +		reg = <0x0 0xC0000000 0x0 0x420000
>> +		       0x0 0xC2000000 0x0 0x300000
>> +		       0x0 0xc5000000 0x0 0x890000
>> +		       0x0 0xc7000000 0x0 0x60000
>> +		       >;
>> +
>> +		phy-handle = <0 0 0 0 &soc0_phy4 &soc0_phy5 0 0>;
>> +		interrupts = <
>> +			/* [14] ge fifo err 8 / xge 6**/
>> +			149 0x4 150 0x4 151 0x4 152 0x4
>> +			153 0x4 154 0x4  26 0x4 27 0x4
>> +			155 0x4 156 0x4 157 0x4 158 0x4 159 0x4 160 0x4
>> +			/* [12] rcb com 4*3**/
>> +			0x6 0x4 0x7 0x4 0x8 0x4 0x9 0x4
>> +			 16 0x4  17 0x4  18 0x4  19 0x4
>> +			 22 0x4  23 0x4  24 0x4  25 0x4
>> +			/* [8] ppe tnl 0-7***/
>> +			0x0 0x4 0x1 0x4 0x2 0x4 0x3 0x4
>> +			0x4 0x4 0x5 0x4 12 0x4 13 0x4
>> +			/* [21] dsaf event int 3+18**/
>> +			 128 0x4  129 0x4  130 0x4
>> +			0x83 0x4 0x84 0x4 0x85 0x4 0x86 0x4 0x87 0x4 0x88 0x4
>> +			0x89 0x4 0x8a 0x4 0x8b 0x4 0x8c 0x4 0x8d 0x4 0x8e 0x4
>> +			0x8f 0x4 0x90 0x4 0x91 0x4 0x92 0x4 0x93 0x4 0x94 0x4
>> +			/* [4] debug rcb 2*2*/
>> +			0xe 0x1 0xf 0x1 0x14 0x1 0x15 0x1
>> +			/* [256] sevice rcb 2*128*/
>> +			0x180 0x1 0x181 0x1 0x182 0x1 0x183 0x1
>> +			0x184 0x1 0x185 0x1 0x186 0x1 0x187 0x1
>> +			0x188 0x1 0x189 0x1 0x18a 0x1 0x18b 0x1
>> +			0x18c 0x1 0x18d 0x1 0x18e 0x1 0x18f 0x1
>> +			0x190 0x1 0x191 0x1 0x192 0x1 0x193 0x1
>> +			0x194 0x1 0x195 0x1 0x196 0x1 0x197 0x1
>> +			0x198 0x1 0x199 0x1 0x19a 0x1 0x19b 0x1
>> +			0x19c 0x1 0x19d 0x1 0x19e 0x1 0x19f 0x1
>> +			0x1a0 0x1 0x1a1 0x1 0x1a2 0x1 0x1a3 0x1
>> +			0x1a4 0x1 0x1a5 0x1 0x1a6 0x1 0x1a7 0x1
>> +			0x1a8 0x1 0x1a9 0x1 0x1aa 0x1 0x1ab 0x1
>> +			0x1ac 0x1 0x1ad 0x1 0x1ae 0x1 0x1af 0x1
>> +			0x1b0 0x1 0x1b1 0x1 0x1b2 0x1 0x1b3 0x1
>> +			0x1b4 0x1 0x1b5 0x1 0x1b6 0x1 0x1b7 0x1
>> +			0x1b8 0x1 0x1b9 0x1 0x1ba 0x1 0x1bb 0x1
>> +			0x1bc 0x1 0x1bd 0x1 0x1be 0x1 0x1bf 0x1
>> +			0x1c0 0x1 0x1c1 0x1 0x1c2 0x1 0x1c3 0x1
>> +			0x1c4 0x1 0x1c5 0x1 0x1c6 0x1 0x1c7 0x1
>> +			0x1c8 0x1 0x1c9 0x1 0x1ca 0x1 0x1cb 0x1
>> +			0x1cc 0x1 0x1cd 0x1 0x1ce 0x1 0x1cf 0x1
>> +			0x1d0 0x1 0x1d1 0x1 0x1d2 0x1 0x1d3 0x1
>> +			0x1d4 0x1 0x1d5 0x1 0x1d6 0x1 0x1d7 0x1
>> +			0x1d8 0x1 0x1d9 0x1 0x1da 0x1 0x1db 0x1
>> +			0x1dc 0x1 0x1dd 0x1 0x1de 0x1 0x1df 0x1
>> +			0x1e0 0x1 0x1e1 0x1 0x1e2 0x1 0x1e3 0x1
>> +			0x1e4 0x1 0x1e5 0x1 0x1e6 0x1 0x1e7 0x1
>> +			0x1e8 0x1 0x1e9 0x1 0x1ea 0x1 0x1eb 0x1
>> +			0x1ec 0x1 0x1ed 0x1 0x1ee 0x1 0x1ef 0x1
>> +			0x1f0 0x1 0x1f1 0x1 0x1f2 0x1 0x1f3 0x1
>> +			0x1f4 0x1 0x1f5 0x1 0x1f6 0x1 0x1f7 0x1
>> +			0x1f8 0x1 0x1f9 0x1 0x1fa 0x1 0x1fb 0x1
>> +			0x1fc 0x1 0x1fd 0x1 0x1fe 0x1 0x1ff 0x1
>> +			0x200 0x1 0x201 0x1 0x202 0x1 0x203 0x1
>> +			0x204 0x1 0x205 0x1 0x206 0x1 0x207 0x1
>> +			0x208 0x1 0x209 0x1 0x20a 0x1 0x20b 0x1
>> +			0x20c 0x1 0x20d 0x1 0x20e 0x1 0x20f 0x1
>> +			0x210 0x1 0x211 0x1 0x212 0x1 0x213 0x1
>> +			0x214 0x1 0x215 0x1 0x216 0x1 0x217 0x1
>> +			0x218 0x1 0x219 0x1 0x21a 0x1 0x21b 0x1
>> +			0x21c 0x1 0x21d 0x1 0x21e 0x1 0x21f 0x1
>> +			0x220 0x1 0x221 0x1 0x222 0x1 0x223 0x1
>> +			0x224 0x1 0x225 0x1 0x226 0x1 0x227 0x1
>> +			0x228 0x1 0x229 0x1 0x22a 0x1 0x22b 0x1
>> +			0x22c 0x1 0x22d 0x1 0x22e 0x1 0x22f 0x1
>> +			0x230 0x1 0x231 0x1 0x232 0x1 0x233 0x1
>> +			0x234 0x1 0x235 0x1 0x236 0x1 0x237 0x1
>> +			0x238 0x1 0x239 0x1 0x23a 0x1 0x23b 0x1
>> +			0x23c 0x1 0x23d 0x1 0x23e 0x1 0x23f 0x1
>> +			0x240 0x1 0x241 0x1 0x242 0x1 0x243 0x1
>> +			0x244 0x1 0x245 0x1 0x246 0x1 0x247 0x1
>> +			0x248 0x1 0x249 0x1 0x24a 0x1 0x24b 0x1
>> +			0x24c 0x1 0x24d 0x1 0x24e 0x1 0x24f 0x1
>> +			0x250 0x1 0x251 0x1 0x252 0x1 0x253 0x1
>> +			0x254 0x1 0x255 0x1 0x256 0x1 0x257 0x1
>> +			0x258 0x1 0x259 0x1 0x25a 0x1 0x25b 0x1
>> +			0x25c 0x1 0x25d 0x1 0x25e 0x1 0x25f 0x1
>> +			0x260 0x1 0x261 0x1 0x262 0x1 0x263 0x1
>> +			0x264 0x1 0x265 0x1 0x266 0x1 0x267 0x1
>> +			0x268 0x1 0x269 0x1 0x26a 0x1 0x26b 0x1
>> +			0x26c 0x1 0x26d 0x1 0x26e 0x1 0x26f 0x1
>> +			0x270 0x1 0x271 0x1 0x272 0x1 0x273 0x1
>> +			0x274 0x1 0x275 0x1 0x276 0x1 0x277 0x1
>> +			0x278 0x1 0x279 0x1 0x27a 0x1 0x27b 0x1
>> +			0x27c 0x1 0x27d 0x1 0x27e 0x1 0x27f 0x1>;
>> +		buf-size = <4096>;
>> +		desc-num = <1024>;
>> +		dma-coherent;
>> +	};
>> +
>> +	eth0: ethernet@0{
>> +		compatible = "hisilicon,hns-nic-v1";
>> +		ae-name = "dsaf0";
>> +		port-id = <0>;
> These should perhaps be subnodes of dsaf. That would solve associating
> them with a particular dsaf.
>
> There is no register interface for these?

hns_enet works on top of the abstraction of ring buffer. It does not 
touch the hardware configuration.

>> +		local-mac-address = [00 00 00 01 00 58];
>> +		status = "disabled";
>> +		dma-coherent;
> Is this really per port?

in non dsaf mode, a port is a network interface, so the property is per 
port under non dsaf mode.
we should specify every port information, so that the enet module can 
identify each of them.

>> +	};
>> +	eth1: ethernet@1{
>> +		compatible = "hisilicon,hns-nic-v1";
>> +		ae-name = "dsaf0";
>> +		port-id = <1>;
>> +		status = "disabled";
>> +		dma-coherent;
>> +	};
>> +	eth2: ethernet@2{
>> +		compatible = "hisilicon,hns-nic-v1";
>> +		ae-name = "dsaf0";
>> +		port-id = <2>;
>> +		local-mac-address = [00 00 00 01 00 5a];
>> +		status = "disabled";
>> +		dma-coherent;
>> +	};
>> +	eth3: ethernet@3{
>> +		compatible = "hisilicon,hns-nic-v1";
>> +		ae-name = "dsaf0";
>> +		port-id = <3>;
>> +		local-mac-address = [00 00 00 01 00 5b];
>> +		status = "disabled";
>> +		dma-coherent;
>> +	};
>> +	eth4: ethernet@4{
>> +		compatible = "hisilicon,hns-nic-v1";
>> +		ae-name = "dsaf0";
>> +		port-id = <4>;
>> +		local-mac-address = [00 00 00 01 00 5c];
>> +		status = "disabled";
>> +		dma-coherent;
>> +	};
>> +	eth5: ethernet@5{
>> +		compatible = "hisilicon,hns-nic-v1";
>> +		ae-name = "dsaf0";
>> +		port-id = <5>;
>> +		local-mac-address = [00 00 00 01 00 5d];
>> +		status = "disabled";
>> +		dma-coherent;
>> +	};
>> +	eth6: ethernet@6{
>> +		compatible = "hisilicon,hns-nic-v1";
>> +		ae-name = "dsaf0";
>> +		port-id = <6>;
>> +		local-mac-address = [00 00 00 01 00 5e];
>> +		status = "disabled";
>> +		dma-coherent;
>> +	};
>> +	eth7: ethernet@7{
>> +		compatible = "hisilicon,hns-nic-v1";
>> +		ae-name = "dsaf0";
>> +		port-id = <7>;
>> +		local-mac-address = [00 00 00 01 00 5f];
>> +		status = "disabled";
>> +		dma-coherent;
>> +	};
>> +};
>>

thanks.

>
> .
>
