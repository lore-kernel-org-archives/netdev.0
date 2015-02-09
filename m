From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH net-next] drivers: net: cpsw: make cpsw_ale.c a module to
 allow re-use on Keystone
Date: Mon, 9 Feb 2015 08:41:21 -0800
Message-ID: <20150209164120.GH25235@atomide.com>
References: <1422573351-5603-1-git-send-email-m-karicheri2@ti.com>
 <1422573351-5603-2-git-send-email-m-karicheri2@ti.com>
 <1802322.NDR3d5ZRSA@wuerfel>
 <20150202164032.GA9418@atomide.com>
 <54D3EFDB.9060300@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, w-kwok2@ti.com, davem@davemloft.net,
	mugunthanvnm@ti.com, prabhakar.csengg@gmail.com,
	grygorii.strashko@ti.com, lokeshvutla@ti.com, mpa@pengutronix.de,
	lsorense@csclub.uwaterloo.ca, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54D3EFDB.9060300@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Murali Karicheri <m-karicheri2@ti.com> [150205 14:37]:
> On 02/02/2015 11:40 AM, Tony Lindgren wrote:
> >* Arnd Bergmann<arnd@arndb.de>  [150129 15:51]:
> >>On Thursday 29 January 2015 18:15:51 Murali Karicheri wrote:
> >>>NetCP on Keystone has cpsw ale function similar to other TI SoCs
> >>>and this driver is re-used. To allow both ti cpsw and keystone netcp
> >>>to re-use the driver, convert the cpsw ale to a module and configure
> >>>it through Kconfig option CONFIG_TI_CPSW_ALE. Currently it is statically
> >>>linked to both TI CPSW and NetCP and this causes issues when the above
> >>>drivers are built as dynamic modules. This patch addresses this issue
> >>>
> >>>While at it, fix the Makefile and code to build both netcp_core and
> >>>netcp_ethss as dynamic modules. This is needed to support arm allmodconfig.
> >>>This also requires exporting of API calls provided by netcp_core so that
> >>>both the above can be dynamic modules.
> >>>
> >>>Signed-off-by: Murali Karicheri<m-karicheri2@ti.com>
> >>>---
> >>>  drivers/net/ethernet/ti/Kconfig       |   19 +++++++++++++++++--
> >>>  drivers/net/ethernet/ti/Makefile      |    8 +++++---
> >>>  drivers/net/ethernet/ti/cpsw_ale.c    |   26 ++++++++++++++++++++++++--
> >>>  drivers/net/ethernet/ti/netcp_core.c  |    8 ++++++++
> >>>  drivers/net/ethernet/ti/netcp_ethss.c |    5 +++++
> >>>  5 files changed, 59 insertions(+), 7 deletions(-)
> >>
> >>I was hoping there would be a way without exporting all those symbols, but
> >>I also couldn't come up with a better solution. I'm putting this into the
> >>randconfig build test for now, but I'm guessing it's fine.
> >
> >Probably the best way in the long run is to add a single exported
> >function to cpsw-common.c I just added for the MAC address function.
> 
> If understand correctly, what you have done is moved the common mac function
> and exported the function in cpsw-common.c and called it from cpsw.c. How is
> this any different from exporting all common functions from cpsw_ale.c as is
> done today? Not sure what you meant by a single exported function. Are you
> talking about defining a ale_ops struct of function ptrs and exporting that
> instead of individual functions? So
> 
> cpsw_ale_common.c
>   Move all of the common functions here and define them as static.
>   Defined cpsw_ale_ops and export it.
>   cpsw.c and netcp_ethss.c calls something like
> 
>   cpsw_ale_ops.foo();

Yeah something like that. I was thinking struct cpsw_common with
shared function pointers. Then in cpsw-common.c, export cpsw_register()
and cpsw_free() that the cpsw like drivers can use to configure whatever
combination of cpsw shared functions it can use. It could be naturally
more than one struct, or maybe struct cpsw_ale, struct cpdma and struct
netcp could be within the struct cpsw_common.

I only attempted to set up a place for future cpsw code sharing
with cpsw-common.c. I have not identified what all could be shared,
looks like you have a much better idea about that :)

By registering cpsw like drivers with cpsw-common allows exporting
only a few selected functions instead of exporting tons of custom
functions (currently 43 of them).

Regards,

Tony
