From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH net-next 1/2] net: davinci_mdio: don't request io address
 range
Date: Wed, 11 Mar 2015 12:35:48 -0400
Message-ID: <55006EE4.3070600@ti.com>
References: <1424813251-31610-1-git-send-email-m-karicheri2@ti.com> <20150227165100.GY11056@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <mugunthanvnm@ti.com>,
	<prabhakar.csengg@gmail.com>, <varkabhadram@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<grygorii.strashko@ti.com>, <lokeshvutla@ti.com>,
	<mpa@pengutronix.de>, <w-kwok2@ti.com>
To: Tony Lindgren <tony@atomide.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150227165100.GY11056@atomide.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tony,

On 02/27/2015 11:51 AM, Tony Lindgren wrote:
> * Murali Karicheri<m-karicheri2@ti.com>  [150224 13:32]:
>> From: Grygorii Strashko<grygorii.strashko@ti.com>
>>
>> Historically Davinci MDIO driver was  created with assumption that
>> MDIO is standalone device, but for Keystone 2 it's a part
>> of NETCP module and now NETCP driver requests IO range which
>> includes MDIO IO range too. This causes Keystone 2 networking stack
>> failure during the boot.
>>
>> "netcp-1.0 2620110.netcp: Probe of module(netcp-gbe) failed with -16"
>>
>> Hence, don't request io address range from Davinci MDIO driver and
>> just remap it.
>
> Best to fix this up properly so you don't have overlapping resources.
> You probably want to have the whole hardware driver block defined
> in the dts file as a single entry, and then have the modules within
> that hardware block use the dt ranges property. This allows you to
> do standard Linux drivers without any extra hacks.
>
> Sounds like this following untested imaginary example should do
> the trick:
>
> mac: ethernet@deadbeef {
> 	compatible = "ti,cpsw", "simple-bus";
> 	reg =<0xdeadbeef 0x1000>;
> 	ranges =<0 0xdeadbeef 0x2000>;
> 	...
>
> 	davinci_mdio: mdio@1000 {
> 		reg =<0x1000 0x100>;
> 		...
> 	};
> };
>
> That allows you to get rid of all the existing code for dealing
> with the chilren with for_each_child_of_node(node, slave_node)
> in cpsw_probe_dt() as that all happens automatically for you and
> does not cause problems with modules being moved around.

This is not for CPSW driver. I am working to add the support for NetCP.
NetCP driver depends on DaVinci MDIO driver to talk to the Phy. So this
can be outside the NetCP device node. I will rework the NetCP driver to 
map only it's register space and let MDIO manage the mapping of its 
register region. I plan to use ranges to define the NetCP address space 
and use reg to refer to individual module reg spaces (Packet 
Accelerator, Ethenet sub system and security accelerator). This way MDIO 
can have its own register space and will not collide with the address 
NetCP driver maps. My v1 will implement this.

Murali
>
> Regards,
>
> Tony


-- 
Murali Karicheri
Linux Kernel, Texas Instruments
